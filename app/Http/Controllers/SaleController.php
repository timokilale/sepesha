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
        $sales = Auth::user()->sales()
            ->with('purchase')
            ->orderBy('sale_date', 'desc')
            ->paginate(10);
            
        return view('sales.index', compact('sales'));
    }

    /**
     * Show the form for creating a new sale.
     */
    public function create()
    {
        $query = Auth::user()->purchases()
            ->with(['item', 'sales'])
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
        $validated = $request->validate([
            'purchase_id' => 'required|exists:purchases,id',
            'selling_price' => 'required|numeric|min:0',
            'sale_date' => 'required|date',
            'quantity_sold' => 'required|integer|min:1',
            'notes' => 'nullable|string',
        ]);

        // Verify the purchase belongs to the authenticated user
        $purchase = Auth::user()->purchases()->findOrFail($validated['purchase_id']);

        // Bottle-only: requested quantity is already in bottles
        $requestedBottles = (int) $validated['quantity_sold'];

        // Check if there's enough quantity available (in bottles)
        $remainingQuantity = $purchase->quantity - $purchase->sales->sum('quantity_sold');
        if ($requestedBottles > $remainingQuantity) {
            return back()->withErrors([
                'quantity_sold' => 'Not enough quantity available. Remaining bottles: ' . $remainingQuantity
            ])->withInput();
        }

        // Store per-bottle price and bottle quantity
        $perBottlePrice = (float) $validated['selling_price'];

        $toCreate = [
            'user_id' => Auth::id(),
            'purchase_id' => (int) $validated['purchase_id'],
            'selling_price' => $perBottlePrice,
            'sale_date' => $validated['sale_date'],
            'quantity_sold' => $requestedBottles,
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
                (int) $requestedBottles,
                (float) $perBottlePrice * (int) $requestedBottles
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
        $sale = Auth::user()->sales()->with('purchase')->findOrFail($id);
        return view('sales.show', compact('sale'));
    }

    /**
     * Show the form for editing the specified sale.
     */
    public function edit($id)
    {
        $sale = Auth::user()->sales()->findOrFail($id);
        $purchases = Auth::user()->purchases()
            ->with(['item', 'sales'])
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
        $sale = Auth::user()->sales()->findOrFail($id);

        $validated = $request->validate([
            'purchase_id' => 'required|exists:purchases,id',
            'selling_price' => 'required|numeric|min:0',
            'sale_date' => 'required|date',
            'quantity_sold' => 'required|integer|min:1',
            'notes' => 'nullable|string',
        ]);

        // Verify the purchase belongs to the authenticated user
        $purchase = Purchase::findOrFail($validated['purchase_id']);
        if ($purchase->user_id !== Auth::id()) {
            abort(403);
        }

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
        $sale = Auth::user()->sales()->findOrFail($id);
        $sale->delete();

        return redirect()->route('sales.index')
            ->with('success', 'Sale deleted successfully!');
    }
}
