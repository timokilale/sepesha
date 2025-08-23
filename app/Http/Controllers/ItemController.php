<?php

namespace App\Http\Controllers;

use App\Models\Item;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class ItemController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
    }

    public function index()
    {
        $items = Auth::user()->items()->orderBy('name')->paginate(10);
        return view('items.index', compact('items'));
    }

    public function create()
    {
        return view('items.create');
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'sku' => 'nullable|string|max:255',
            'unit_name' => 'nullable|string|max:100',
            'notes' => 'nullable|string',
        ]);
        $validated['user_id'] = Auth::id();
        Item::create($validated);
        return redirect()->route('items.index')->with('success', 'Item created');
    }

    public function show(Item $item)
    {
        abort_if($item->user_id !== Auth::id(), 403);
        return view('items.show', compact('item'));
    }

    public function edit(Item $item)
    {
        abort_if($item->user_id !== Auth::id(), 403);
        return view('items.edit', compact('item'));
    }

    public function update(Request $request, Item $item)
    {
        abort_if($item->user_id !== Auth::id(), 403);
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'sku' => 'nullable|string|max:255',
            'unit_name' => 'nullable|string|max:100',
            'notes' => 'nullable|string',
        ]);
        $item->update($validated);
        return redirect()->route('items.index')->with('success', 'Item updated');
    }

    public function destroy(Item $item)
    {
        abort_if($item->user_id !== Auth::id(), 403);
        $item->delete();
        return redirect()->route('items.index')->with('success', 'Item deleted');
    }
}
