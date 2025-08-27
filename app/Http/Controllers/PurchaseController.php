<?php

namespace App\Http\Controllers;

use App\Models\Purchase;
use App\Models\Item;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class PurchaseController extends Controller
{
    /**
     * Create a new controller instance.
     */
    public function __construct()
    {
        $this->middleware('auth');
    }

    /**
     * Display a listing of the purchases.
     */
    public function index()
    {
        $purchases = Purchase::with('sales')
            ->orderBy('purchase_date', 'desc')
            ->paginate(10);
            
        return view('purchases.index', compact('purchases'));
    }

    /**
     * Show the form for creating a new purchase.
     */
    public function create()
    {
        $items = Item::orderBy('name')->get();
        return view('purchases.create', compact('items'));
    }

    /**
     * Store a newly created purchase in storage.
     */
    public function store(Request $request)
    {
        $baseRules = [
            'item_id' => 'required|exists:items,id,deleted_at,NULL',
            'purchase_date' => 'required|date',
            'description' => 'nullable|string',
            'product_type' => 'required|in:beverage,meat',
        ];
        $validated = $request->validate($baseRules);

        $validated['user_id'] = Auth::id();

        // Ensure selected item exists and set display name (shop-wide)
        $item = Item::where('id', $validated['item_id'])->first();
        if (!$item) {
            abort(422, 'Selected item is invalid.');
        }
        $validated['item_name'] = $item->name;

        if ($validated['product_type'] === 'meat' || $item->uom_type === 'weight') {
            // Weight-based purchase: expect weight, price_per_kg
            $more = $request->validate([
                'weight' => 'required|numeric|min:0.1',
                'price_per_kg' => 'required|numeric|min:0',
            ]);
            $weightKg = (float)$more['weight'];
            $pricePerKg = (float)$more['price_per_kg'];
            $totalCost = $weightKg * $pricePerKg;
            
            // Convert to grams for storage (base unit)
            $qtyBase = $item->toBaseQuantity($weightKg, 'kg'); // grams
            $validated['quantity'] = max(1, (int) $qtyBase);
            $validated['cost_price'] = $validated['quantity'] > 0 ? round($totalCost / $validated['quantity'], 4) : 0;
            
            // Null out carton fields
            $validated['cartons'] = null;
            $validated['units_per_carton'] = null;
            $validated['carton_cost'] = null;
        } else {
            // Carton-based purchase (beverage/volume items)
            $more = $request->validate([
                'cartons' => 'required|integer|min:1',
                'units_per_carton' => 'required|integer|min:1',
                'carton_cost' => 'required|numeric|min:0',
            ]);
            $cartons = (int) $more['cartons'];
            $unitsPerCarton = (int) $more['units_per_carton'];
            $cartonCost = (float) $more['carton_cost'];
            $totalUnits = $cartons * $unitsPerCarton; // bottles/pieces
            $validated['quantity'] = max(1, $totalUnits);
            $validated['cost_price'] = round($cartonCost / max(1, $unitsPerCarton), 2);
            $validated = array_merge($validated, $more);
        }

        Purchase::create($validated);

        return redirect()->route('purchases.index')
            ->with('success', 'Purchase added successfully!');
    }

    /**
     * Display the specified purchase.
     */
    public function show($id)
    {
        $purchase = Purchase::with('sales')->findOrFail($id);
        return view('purchases.show', compact('purchase'));
    }

    /**
     * Show the form for editing the specified purchase.
     */
    public function edit($id)
    {
        $purchase = Purchase::findOrFail($id);
        $items = Item::orderBy('name')->get();
        return view('purchases.edit', compact('purchase','items'));
    }

    /**
     * Update the specified purchase in storage.
     */
    public function update(Request $request, $id)
    {
        $purchase = Purchase::findOrFail($id);

        $baseRules = [
            'item_id' => 'required|exists:items,id,deleted_at,NULL',
            'purchase_date' => 'required|date',
            'description' => 'nullable|string',
        ];
        $validated = $request->validate($baseRules);

        // Ensure selected item exists and set display name (shop-wide)
        $item = Item::where('id', $validated['item_id'])->first();
        if (!$item) {
            abort(422, 'Selected item is invalid.');
        }
        $validated['item_name'] = $item->name;

        // Check if this is a weight-based update (meat products)
        $productType = $request->input('product_type', ($item->uom_type === 'weight' ? 'meat' : 'beverage'));
        
        if ($productType === 'meat' || $item->uom_type === 'weight') {
            $more = $request->validate([
                'weight' => 'required|numeric|min:0.1',
                'price_per_kg' => 'required|numeric|min:0',
            ]);
            $weightKg = (float)$more['weight'];
            $pricePerKg = (float)$more['price_per_kg'];
            $totalCost = $weightKg * $pricePerKg;
            
            $qtyBase = $item->toBaseQuantity($weightKg, 'kg');
            $validated['quantity'] = max(1, (int) $qtyBase);
            $validated['cost_price'] = $validated['quantity'] > 0 ? round($totalCost / $validated['quantity'], 4) : 0;
            $validated['cartons'] = null;
            $validated['units_per_carton'] = null;
            $validated['carton_cost'] = null;
        } else {
            $more = $request->validate([
                'cartons' => 'required|integer|min:1',
                'units_per_carton' => 'required|integer|min:1',
                'carton_cost' => 'required|numeric|min:0',
            ]);
            $cartons = (int) $more['cartons'];
            $unitsPerCarton = (int) $more['units_per_carton'];
            $cartonCost = (float) $more['carton_cost'];
            $validated['quantity'] = $cartons * $unitsPerCarton;
            $validated['cost_price'] = round($cartonCost / max(1, $unitsPerCarton), 2);
            $validated = array_merge($validated, $more);
        }

        $purchase->update($validated);

        return redirect()->route('purchases.index')
            ->with('success', 'Purchase updated successfully!');
    }

    /**
     * Remove the specified purchase from storage.
     */
    public function destroy($id)
    {
        $purchase = Purchase::findOrFail($id);
        $purchase->delete();

        return redirect()->route('purchases.index')
            ->with('success', 'Purchase deleted successfully!');
    }
}
