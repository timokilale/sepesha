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
        $purchases = Auth::user()->purchases()
            ->whereRaw('quantity > (SELECT COALESCE(SUM(quantity_sold), 0) FROM sales WHERE purchase_id = purchases.id)')
            ->get();
            
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
        $purchase = Purchase::findOrFail($validated['purchase_id']);
        if ($purchase->user_id !== Auth::id()) {
            abort(403);
        }

        // Check if there's enough quantity available
        $remainingQuantity = $purchase->quantity - $purchase->sales->sum('quantity_sold');
        if ($validated['quantity_sold'] > $remainingQuantity) {
            return back()->withErrors([
                'quantity_sold' => 'Not enough quantity available. Remaining: ' . $remainingQuantity
            ])->withInput();
        }

        $validated['user_id'] = Auth::id();

        Sale::create($validated);

        return redirect()->route('sales.index')
            ->with('success', 'Sale recorded successfully!');
    }

    /**
     * Display the specified sale.
     */
    public function show(Sale $sale)
    {
        // Ensure the sale belongs to the authenticated user
        if ($sale->user_id !== Auth::id()) {
            abort(403);
        }

        $sale->load('purchase');
        
        return view('sales.show', compact('sale'));
    }

    /**
     * Show the form for editing the specified sale.
     */
    public function edit(Sale $sale)
    {
        // Ensure the sale belongs to the authenticated user
        if ($sale->user_id !== Auth::id()) {
            abort(403);
        }

        $purchases = Auth::user()->purchases()->get();
        
        return view('sales.edit', compact('sale', 'purchases'));
    }

    /**
     * Update the specified sale in storage.
     */
    public function update(Request $request, Sale $sale)
    {
        // Ensure the sale belongs to the authenticated user
        if ($sale->user_id !== Auth::id()) {
            abort(403);
        }

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

        $sale->update($validated);

        return redirect()->route('sales.index')
            ->with('success', 'Sale updated successfully!');
    }

    /**
     * Remove the specified sale from storage.
     */
    public function destroy(Sale $sale)
    {
        // Ensure the sale belongs to the authenticated user
        if ($sale->user_id !== Auth::id()) {
            abort(403);
        }

        $sale->delete();

        return redirect()->route('sales.index')
            ->with('success', 'Sale deleted successfully!');
    }
}
