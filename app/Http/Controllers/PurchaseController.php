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
        return view('purchases.create');
    }

    /**
     * Store a newly created purchase in storage.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'item_name' => 'required|string|max:255',
            'cost_price' => 'required|numeric|min:0',
            'purchase_date' => 'required|date',
            'description' => 'nullable|string',
            'quantity' => 'required|integer|min:1',
        ]);

        $validated['user_id'] = Auth::id();

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

        return view('purchases.edit', compact('purchase'));
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
            'item_name' => 'required|string|max:255',
            'cost_price' => 'required|numeric|min:0',
            'purchase_date' => 'required|date',
            'description' => 'nullable|string',
            'quantity' => 'required|integer|min:1',
        ]);

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
