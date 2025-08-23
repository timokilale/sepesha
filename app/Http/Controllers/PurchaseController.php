<?php

namespace App\Http\Controllers;

use App\Models\Purchase;
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
        $purchases = Auth::user()->purchases()
            ->with('sales')
            ->orderBy('purchase_date', 'desc')
            ->paginate(10);
            
        return view('purchases.index', compact('purchases'));
    }

    /**
     * Show the form for creating a new purchase.
     */
    public function create()
    {
        $items = Auth::user()->items()->orderBy('name')->get();
        return view('purchases.create', compact('items'));
    }

    /**
     * Store a newly created purchase in storage.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'item_id' => 'nullable|exists:items,id',
            'item_name' => 'required_without:item_id|string|max:255',
            'cost_price' => 'nullable|numeric|min:0', // if carton_cost given, we'll derive unit cost
            'purchase_date' => 'required|date',
            'description' => 'nullable|string',
            'quantity' => 'nullable|integer|min:1', // optional when using cartons
            // packaging fields (optional)
            'cartons' => 'nullable|integer|min:0',
            'loose_units' => 'nullable|integer|min:0',
            'units_per_carton' => 'nullable|integer|min:1',
            'carton_cost' => 'nullable|numeric|min:0',
        ]);

        $validated['user_id'] = Auth::id();

        // Compute quantity (total units) and unit cost if carton info provided
        $cartons = (int) ($validated['cartons'] ?? 0);
        $loose = (int) ($validated['loose_units'] ?? 0);
        $unitsPerCarton = (int) ($validated['units_per_carton'] ?? 0);
        $cartonCost = isset($validated['carton_cost']) ? (float) $validated['carton_cost'] : null;

        if ($unitsPerCarton > 0) {
            $totalUnits = ($cartons * $unitsPerCarton) + $loose;
            $validated['quantity'] = max(1, $totalUnits);
            if ($cartonCost !== null) {
                // Unit cost rounded up to the nearest whole (TZS has no cents)
                $perUnit = (float) ceil($cartonCost / $unitsPerCarton);
                $validated['cost_price'] = $perUnit;
            }
        }

        // Fallbacks if still missing
        if (empty($validated['quantity'])) {
            $validated['quantity'] = 1;
        }
        if (!isset($validated['cost_price'])) {
            $validated['cost_price'] = 0;
        }

        Purchase::create($validated);

        return redirect()->route('purchases.index')
            ->with('success', 'Purchase added successfully!');
    }

    /**
     * Display the specified purchase.
     */
    public function show(Purchase $purchase)
    {
        // Ensure the purchase belongs to the authenticated user
        if ($purchase->user_id !== Auth::id()) {
            abort(403);
        }

        $purchase->load('sales');
        
        return view('purchases.show', compact('purchase'));
    }

    /**
     * Show the form for editing the specified purchase.
     */
    public function edit(Purchase $purchase)
    {
        // Ensure the purchase belongs to the authenticated user
        if ($purchase->user_id !== Auth::id()) {
            abort(403);
        }

        $items = Auth::user()->items()->orderBy('name')->get();
        return view('purchases.edit', compact('purchase','items'));
    }

    /**
     * Update the specified purchase in storage.
     */
    public function update(Request $request, Purchase $purchase)
    {
        // Ensure the purchase belongs to the authenticated user
        if ($purchase->user_id !== Auth::id()) {
            abort(403);
        }

        $validated = $request->validate([
            'item_id' => 'nullable|exists:items,id',
            'item_name' => 'required_without:item_id|string|max:255',
            'cost_price' => 'nullable|numeric|min:0',
            'purchase_date' => 'required|date',
            'description' => 'nullable|string',
            'quantity' => 'nullable|integer|min:1',
            'cartons' => 'nullable|integer|min:0',
            'loose_units' => 'nullable|integer|min:0',
            'units_per_carton' => 'nullable|integer|min:1',
            'carton_cost' => 'nullable|numeric|min:0',
        ]);

        // Recompute quantity and unit cost if carton info present
        $cartons = (int) ($validated['cartons'] ?? $purchase->cartons ?? 0);
        $loose = (int) ($validated['loose_units'] ?? $purchase->loose_units ?? 0);
        $unitsPerCarton = (int) ($validated['units_per_carton'] ?? $purchase->units_per_carton ?? 0);
        $cartonCost = array_key_exists('carton_cost', $validated) ? (float) $validated['carton_cost'] : ($purchase->carton_cost ?? null);

        if ($unitsPerCarton > 0) {
            $totalUnits = ($cartons * $unitsPerCarton) + $loose;
            if ($totalUnits > 0) {
                $validated['quantity'] = $totalUnits;
            }
            if ($cartonCost !== null) {
                $validated['cost_price'] = (float) ceil($cartonCost / $unitsPerCarton);
            }
        }

        $purchase->update($validated);

        return redirect()->route('purchases.index')
            ->with('success', 'Purchase updated successfully!');
    }

    /**
     * Remove the specified purchase from storage.
     */
    public function destroy(Purchase $purchase)
    {
        // Ensure the purchase belongs to the authenticated user
        if ($purchase->user_id !== Auth::id()) {
            abort(403);
        }

        $purchase->delete();

        return redirect()->route('purchases.index')
            ->with('success', 'Purchase deleted successfully!');
    }
}
