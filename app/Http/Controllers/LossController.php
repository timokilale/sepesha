<?php

namespace App\Http\Controllers;

use App\Models\Item;
use App\Models\Loss;
use App\Models\Purchase;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class LossController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
    }

    public function create(Request $request)
    {
        $items = Item::where('user_id', Auth::id())->orderBy('name')->get();
        $itemId = (int) $request->get('item_id');
        $purchaseId = (int) $request->get('purchase_id');
        $selectedItem = $itemId ? $items->firstWhere('id', $itemId) : null;
        $purchases = collect();
        if ($selectedItem) {
            $purchases = $selectedItem->purchases()->orderByDesc('purchase_date')->get();
        }
        return view('losses.create', compact('items','itemId','purchaseId','purchases'));
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'item_id' => 'required|exists:items,id,deleted_at,NULL',
            'purchase_id' => 'nullable|exists:purchases,id,deleted_at,NULL',
            'reason' => 'required|string|max:255',
            'loss_date' => 'required|date',
            'notes' => 'nullable|string',
            // quantity fields depend on item type; validate broadly then convert
            'quantity_value' => 'required|numeric|min:0.001',
            'quantity_unit' => 'nullable|string|max:10',
        ]);

        $item = Item::where('id', $validated['item_id'])->where('user_id', Auth::id())->firstOrFail();
        $purchase = null;
        if (!empty($validated['purchase_id'])) {
            $purchase = Purchase::where('id', $validated['purchase_id'])->where('user_id', Auth::id())->first();
        }

        // Convert quantity_value + quantity_unit to base units according to item type
        $unit = $validated['quantity_unit'] ?? $item->baseUnit();
        $baseQty = $item->toBaseQuantity((float)$validated['quantity_value'], $unit);

        $data = [
            'user_id' => Auth::id(),
            'item_id' => $item->id,
            'purchase_id' => $purchase?->id,
            'quantity' => max(1, (int) $baseQty),
            'reason' => $validated['reason'],
            'loss_date' => $validated['loss_date'],
            'notes' => $validated['notes'] ?? null,
        ];

        Loss::create($data);

        return redirect()->route('items.show.single', ['id' => $item->id])
            ->with('success', 'Loss recorded and stock adjusted.');
    }
}
