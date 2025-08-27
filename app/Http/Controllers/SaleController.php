<?php

namespace App\Http\Controllers;

use App\Models\Sale;
use App\Models\Purchase;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class SaleController extends Controller
{
    /**
     * Create a new controller instance.
     */
    public function __construct()
    {
        $this->middleware('auth');
    }

    /**
     * Display a listing of the sales.
     */
    public function index()
    {
        $sales = Sale::with('purchase')
            ->orderBy('sale_date', 'desc')
            ->paginate(10);
            
        return view('sales.index', compact('sales'));
    }

    /**
     * Show the form for creating a new sale.
     */
    public function create()
    {
        $query = Purchase::with(['item', 'sales'])
            ->whereRaw('quantity > (SELECT COALESCE(SUM(quantity_sold), 0) FROM sales WHERE purchase_id = purchases.id)')
            ->where(function ($q) {
                // Keep purchases without an item (ad-hoc), or with a non-deleted item
                $q->whereNull('item_id')
                  ->orWhereHas('item', function ($iq) {
                      $iq->whereNull('deleted_at');
                  });
            });
        if (request()->filled('item_id')) {
            $query->where('item_id', request('item_id'));
        }
        $purchases = $query->get();
            
        return view('sales.create', compact('purchases'));
    }

    /**
     * Store a newly created sale in storage.
     */
    public function store(Request $request)
    {
        $baseRules = [
            'purchase_id' => 'required|exists:purchases,id',
            'sale_date' => 'required|date',
            'notes' => 'nullable|string',
            'product_type' => 'required|in:beverage,meat',
        ];
        $validated = $request->validate($baseRules);

        // Find the purchase globally (shared shop)
        $purchase = Purchase::with('item')->findOrFail($validated['purchase_id']);

        if ($validated['product_type'] === 'meat' || ($purchase->item && $purchase->item->uom_type === 'weight')) {
            // Weight-based sale: expect weight_sold, price_per_kg_sale
            $more = $request->validate([
                'weight_sold' => 'required|numeric|min:0.1',
                'price_per_kg_sale' => 'required|numeric|min:0',
            ]);
            $weightKg = (float)$more['weight_sold'];
            $pricePerKg = (float)$more['price_per_kg_sale'];
            
            // Convert to grams for storage (base unit)
            $qtyBase = $purchase->item->toBaseQuantity($weightKg, 'kg'); // grams
            $requestedQuantity = (int) $qtyBase;
            $perUnitPrice = $pricePerKg / 1000; // price per gram
        } else {
            // Beverage sale: expect quantity_sold, selling_price
            $more = $request->validate([
                'quantity_sold' => 'required|integer|min:1',
                'selling_price' => 'required|numeric|min:0',
            ]);
            $requestedQuantity = (int) $more['quantity_sold'];
            $perUnitPrice = (float) $more['selling_price'];
        }

        // Check if there's enough quantity available
        $remainingQuantity = $purchase->quantity - $purchase->sales->sum('quantity_sold');
        if ($requestedQuantity > $remainingQuantity) {
            $unitName = ($purchase->item && $purchase->item->uom_type === 'weight') ? 'kg' : 'bottles';
            $displayRemaining = ($purchase->item && $purchase->item->uom_type === 'weight') 
                ? $purchase->item->formatBaseQuantity($remainingQuantity)
                : $remainingQuantity . ' ' . $unitName;
            return back()->withErrors([
                'quantity_sold' => 'Not enough quantity available. Remaining: ' . $displayRemaining
            ])->withInput();
        }

        $toCreate = [
            'user_id' => Auth::id(),
            'purchase_id' => (int) $validated['purchase_id'],
            'selling_price' => $perUnitPrice,
            'sale_date' => $validated['sale_date'],
            'quantity_sold' => $requestedQuantity,
            'notes' => $validated['notes'] ?? null,
        ];

        $sale = Sale::create($toCreate);

        // Update daily sales aggregate per item (if available)
        try {
            $itemId = $purchase->item_id; // may be null if purchase not linked to catalog
            $itemName = $purchase->item_name;
            \App\Models\DailySale::upsertAggregate(
                Auth::id(),
                $itemId,
                $itemName,
                $validated['sale_date'],
                (int) $requestedQuantity,
                (float) $perUnitPrice * (int) $requestedQuantity
            );
        } catch (\Throwable $e) {
            // swallow aggregate errors to not block primary flow
        }

        return redirect()->route('sales.index')
            ->with('success', 'Sale recorded successfully!');
    }

    /**
     * Display the specified sale.
     */
    public function show($id)
    {
        $sale = Sale::with('purchase')->findOrFail($id);
        return view('sales.show', compact('sale'));
    }

    /**
     * Show the form for editing the specified sale.
     */
    public function edit($id)
    {
        $sale = Sale::findOrFail($id);
        $purchases = Purchase::with(['item', 'sales'])
            ->where(function ($q) use ($sale) {
                $q->whereNull('item_id')
                  ->orWhereHas('item', function ($iq) {
                      $iq->whereNull('deleted_at');
                  })
                  ->orWhere('id', $sale->purchase_id); // always include the currently selected batch
            })
            ->get();
        return view('sales.edit', compact('sale', 'purchases'));
    }

    /**
     * Update the specified sale in storage.
     */
    public function update(Request $request, $id)
    {
        $sale = Sale::findOrFail($id);

        $validated = $request->validate([
            'purchase_id' => 'required|exists:purchases,id',
            'selling_price' => 'required|numeric|min:0',
            'sale_date' => 'required|date',
            'quantity_sold' => 'required|integer|min:1',
            'notes' => 'nullable|string',
        ]);

        // Shared shop: ensure purchase exists
        $purchase = Purchase::findOrFail($validated['purchase_id']);

        // Bottle-only: requested quantity is already in bottles
        $requestedBottles = (int) $validated['quantity_sold'];

        // When editing, account for previously reserved bottles by this sale
        $currentRemaining = $purchase->quantity - ($purchase->sales->where('id', '!=', $sale->id)->sum('quantity_sold'));
        if ($requestedBottles > $currentRemaining) {
            return back()->withErrors([
                'quantity_sold' => 'Not enough quantity available. Remaining bottles: ' . $currentRemaining
            ])->withInput();
        }

        $perBottlePrice = (float) $validated['selling_price'];

        $sale->update([
            'purchase_id' => (int) $validated['purchase_id'],
            'selling_price' => $perBottlePrice,
            'sale_date' => $validated['sale_date'],
            'quantity_sold' => $requestedBottles,
            'notes' => $validated['notes'] ?? null,
        ]);

        return redirect()->route('sales.index')
            ->with('success', 'Sale updated successfully!');
    }

    /**
     * Remove the specified sale from storage.
     */
    public function destroy($id)
    {
        $sale = Sale::findOrFail($id);
        $sale->delete();

        return redirect()->route('sales.index')
            ->with('success', 'Sale deleted successfully!');
    }
}
