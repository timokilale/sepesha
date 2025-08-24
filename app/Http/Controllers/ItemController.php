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
            'category' => 'nullable|string|max:100',
            'carton_size' => 'required|integer|min:1',
            // volume capture (optional)
            'volume_value' => 'nullable|numeric|min:0.001',
            'volume_unit' => 'nullable|in:ml,l',
            'image' => 'nullable|image|max:2048',
        ]);
        $validated['user_id'] = Auth::id();
        // Always auto-generate SKU; ignore any incoming value
        unset($validated['sku']);

        // Compute volume_ml from inputs if provided
        $volumeMl = null;
        if (!empty($validated['volume_value'])) {
            $val = (float) $validated['volume_value'];
            $unit = $validated['volume_unit'] ?? 'ml';
            $volumeMl = $unit === 'l' ? (int) round($val * 1000) : (int) round($val);
        }
        unset($validated['volume_value'], $validated['volume_unit']);
        $validated['volume_ml'] = $volumeMl;

        // Prevent exact duplicates only when both name and volume match for this user
        if ($volumeMl !== null) {
            $incomingNorm = $this->normalizeName($validated['name']);
            $exists = Auth::user()->items()
                ->get(['name','volume_ml'])
                ->contains(function ($it) use ($incomingNorm, $volumeMl) {
                    return $this->normalizeName($it->name) === $incomingNorm && (int) $it->volume_ml === (int) $volumeMl;
                });
            if ($exists) {
                return back()
                    ->withErrors(['name' => 'Product with same name and volume already exists.'])
                    ->withInput();
            }
        }

        if ($request->hasFile('image')) {
            $path = $request->file('image')->store('items', 'public');
            $validated['image_path'] = $path;
        }

        $item = Item::create($validated);
        return redirect()->route('items.show.single', ['id' => $item->id])
            ->with('success', 'Item created. SKU: ' . $item->sku);
    }

    public function show($id)
    {
        $item = Auth::user()->items()->findOrFail($id);
        return view('items.show', compact('item'));
    }

    public function edit($id)
    {
        $item = Auth::user()->items()->findOrFail($id);
        return view('items.edit', compact('item'));
    }

    public function update(Request $request, $id)
    {
        $item = Auth::user()->items()->findOrFail($id);
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'sku' => 'nullable|string|max:255',
            'unit_name' => 'nullable|string|max:100',
            'notes' => 'nullable|string',
            'category' => 'nullable|string|max:100',
            'carton_size' => 'required|integer|min:1',
            'volume_value' => 'nullable|numeric|min:0.001',
            'volume_unit' => 'nullable|in:ml,l',
            'image' => 'nullable|image|max:2048',
        ]);

        if ($request->hasFile('image')) {
            $path = $request->file('image')->store('items', 'public');
            $validated['image_path'] = $path;
        }

        // Prevent SKU changes via update
        unset($validated['sku']);

        // Compute volume_ml if provided and prevent exact duplicates on (name + volume_ml)
        $volumeMl = null;
        if (!empty($validated['volume_value'])) {
            $val = (float) $validated['volume_value'];
            $unit = $validated['volume_unit'] ?? 'ml';
            $volumeMl = $unit === 'l' ? (int) round($val * 1000) : (int) round($val);
        } else {
            // If not provided, keep existing value
            $volumeMl = $item->volume_ml;
        }
        unset($validated['volume_value'], $validated['volume_unit']);
        $validated['volume_ml'] = $volumeMl;

        if ($volumeMl !== null) {
            $incomingNorm = $this->normalizeName($validated['name']);
            $exists = Auth::user()->items()
                ->where('id', '!=', $item->id)
                ->get(['name','volume_ml'])
                ->contains(function ($it) use ($incomingNorm, $volumeMl) {
                    return $this->normalizeName($it->name) === $incomingNorm && (int) $it->volume_ml === (int) $volumeMl;
                });
            if ($exists) {
                return back()
                    ->withErrors(['name' => 'Product with same name and volume already exists.'])
                    ->withInput();
            }
        }
        $item->update($validated);
        return redirect()->route('items.index')->with('success', 'Item updated');
    }

    /**
     * Normalize a product name by removing non-alphanumeric characters and lowercasing.
     */
    private function normalizeName(string $name): string
    {
        $norm = preg_replace('/[^a-z0-9]+/i', '', $name);
        return strtolower($norm ?? '');
    }

    public function destroy($id)
    {
        $item = Auth::user()->items()->findOrFail($id);
        $item->delete();
        return redirect()->route('items.index')->with('success', 'Item deleted');
    }
}
