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
            'item_id' => 'required|exists:items,id,deleted_at,NULL',
            'purchase_date' => 'required|date',
            'description' => 'nullable|string',
            // carton-based required inputs
            'cartons' => 'required|integer|min:1',
            'units_per_carton' => 'required|integer|min:1',
            'carton_cost' => 'required|numeric|min:0',
        ]);

        $validated['user_id'] = Auth::id();

        // Ensure selected item belongs to this user and set display name
        $item = Item::where('id', $validated['item_id'])->where('user_id', Auth::id())->first();
        if (!$item) {
            abort(422, 'Selected item is invalid.');
        }
        $validated['item_name'] = $item->name;

        // Compute quantity (total bottles) and unit cost per bottle from cartons
        $cartons = (int) $validated['cartons'];
        $unitsPerCarton = (int) $validated['units_per_carton'];
        $cartonCost = (float) $validated['carton_cost'];

        $totalUnits = $cartons * $unitsPerCarton; // bottles
        $validated['quantity'] = max(1, $totalUnits);
        // Unit cost rounded up (TZS has no cents)
        $validated['cost_price'] = (float) ceil($cartonCost / $unitsPerCarton);

        Purchase::create($validated);

        return redirect()->route('purchases.index')
            ->with('success', 'Purchase added successfully!');
    }

    /**
     * Display the specified purchase.
     */
    public function show($id)
    {
        $purchase = Auth::user()->purchases()->with('sales')->findOrFail($id);
        return view('purchases.show', compact('purchase'));
    }

    /**
     * Show the form for editing the specified purchase.
     */
    public function edit($id)
    {
        $purchase = Auth::user()->purchases()->findOrFail($id);
        $items = Auth::user()->items()->orderBy('name')->get();
        return view('purchases.edit', compact('purchase','items'));
    }

    /**
     * Update the specified purchase in storage.
     */
    public function update(Request $request, $id)
    {
        $purchase = Auth::user()->purchases()->findOrFail($id);

        $validated = $request->validate([
            'item_id' => 'required|exists:items,id,deleted_at,NULL',
            'purchase_date' => 'required|date',
            'description' => 'nullable|string',
            'cartons' => 'required|integer|min:1',
            'units_per_carton' => 'required|integer|min:1',
            'carton_cost' => 'required|numeric|min:0',
        ]);

        // Compute total bottles and per-bottle unit cost
        $cartons = (int) $validated['cartons'];
        $unitsPerCarton = (int) $validated['units_per_carton'];
        $cartonCost = (float) $validated['carton_cost'];
        $validated['quantity'] = $cartons * $unitsPerCarton;
        $validated['cost_price'] = (float) ceil($cartonCost / $unitsPerCarton);

        // Ensure selected item belongs to this user and set display name
        $item = Item::where('id', $validated['item_id'])->where('user_id', Auth::id())->first();
        if (!$item) {
            abort(422, 'Selected item is invalid.');
        }
        $validated['item_name'] = $item->name;

        $purchase->update($validated);

        return redirect()->route('purchases.index')
            ->with('success', 'Purchase updated successfully!');
    }

    /**
     * Remove the specified purchase from storage.
     */
    public function destroy($id)
    {
        $purchase = Auth::user()->purchases()->findOrFail($id);
        $purchase->delete();

        return redirect()->route('purchases.index')
            ->with('success', 'Purchase deleted successfully!');
    }
}
