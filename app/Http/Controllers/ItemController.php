<?php

namespace App\Http\Controllers;

use App\Models\Item;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Str;

class ItemController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
    }

    public function index()
    {
        $items = Item::orderBy('name')->paginate(10);
        return view('items.index', compact('items'));
    }

    public function create()
    {
        return view('items.create');
    }

    public function createMeat()
    {
        // Separate form for weight-based meat items
        return view('items.create_meat');
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'sku' => 'nullable|string|max:255',
            'uom_type' => 'required|in:unit,volume,weight',
            'unit_name' => 'nullable|string|max:100',
            'notes' => 'nullable|string',
            'category' => 'nullable|string|max:100',
            'carton_size' => 'nullable|integer|min:1',
            // volume capture (only when uom_type=volume)
            'volume_value' => 'nullable|numeric|min:0.001',
            'volume_unit' => 'nullable|in:ml,l',
            'image' => 'nullable|image|max:2048',
        ]);
        $validated['user_id'] = Auth::id();
        // Always auto-generate SKU; ignore any incoming value
        unset($validated['sku']);
        
        // Unit name default for volume items
        if (($validated['uom_type'] ?? null) === 'volume' && empty($validated['unit_name'])) {
            $validated['unit_name'] = 'bottle';
        }

        // Compute volume_ml from inputs if provided
        $volumeMl = null;
        if (($validated['uom_type'] ?? null) === 'volume' && !empty($validated['volume_value'])) {
            $val = (float) $validated['volume_value'];
            $unit = $validated['volume_unit'] ?? 'ml';
            $volumeMl = $unit === 'l' ? (int) round($val * 1000) : (int) round($val);
        }
        unset($validated['volume_value'], $validated['volume_unit']);
        $validated['volume_ml'] = $volumeMl;

        // If weight or unit type, clear carton_size when not relevant
        if (($validated['uom_type'] ?? null) === 'weight') {
            $validated['carton_size'] = null;
        }

        // Prevent exact duplicates only when both name and volume match (shop-wide)
        if (($validated['uom_type'] ?? null) === 'volume' && $volumeMl !== null) {
            $incomingNorm = $this->normalizeName($validated['name']);
            $exists = Item::query()
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
            $file = $request->file('image');
            // Ensure destination exists
            if (!is_dir(public_path('images'))) {
                @mkdir(public_path('images'), 0755, true);
            }
            $ext = $file->getClientOriginalExtension() ?: 'png';
            $filename = Str::random(40) . '.' . strtolower($ext);
            $file->move(public_path('images'), $filename);
            $validated['image_path'] = 'images/' . $filename;
        }

        $item = Item::create($validated);
        return redirect()->route('items.show.single', ['id' => $item->id])
            ->with('success', 'Item created. SKU: ' . $item->sku);
    }

    public function show($id)
    {
        $item = Item::findOrFail($id);
        return view('items.show', compact('item'));
    }

    public function edit($id)
    {
        $item = Item::findOrFail($id);
        return view('items.edit', compact('item'));
    }

    public function update(Request $request, $id)
    {
        $item = Item::findOrFail($id);
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'sku' => 'nullable|string|max:255',
            'uom_type' => 'required|in:unit,volume,weight',
            'unit_name' => 'nullable|string|max:100',
            'notes' => 'nullable|string',
            'category' => 'nullable|string|max:100',
            'carton_size' => 'nullable|integer|min:1',
            'volume_value' => 'nullable|numeric|min:0.001',
            'volume_unit' => 'nullable|in:ml,l',
            'image' => 'nullable|image|max:2048',
        ]);

        if ($request->hasFile('image')) {
            $file = $request->file('image');
            if (!is_dir(public_path('images'))) {
                @mkdir(public_path('images'), 0755, true);
            }
            $ext = $file->getClientOriginalExtension() ?: 'png';
            $filename = Str::random(40) . '.' . strtolower($ext);
            $file->move(public_path('images'), $filename);
            $validated['image_path'] = 'images/' . $filename;
        }

        // Prevent SKU changes via update
        unset($validated['sku']);

        // Compute volume_ml if provided and prevent exact duplicates on (name + volume_ml)
        $volumeMl = null;
        if (($validated['uom_type'] ?? $item->uom_type) === 'volume' && !empty($validated['volume_value'])) {
            $val = (float) $validated['volume_value'];
            $unit = $validated['volume_unit'] ?? 'ml';
            $volumeMl = $unit === 'l' ? (int) round($val * 1000) : (int) round($val);
        } else {
            // If not provided, keep existing value
            $volumeMl = $item->volume_ml;
        }
        unset($validated['volume_value'], $validated['volume_unit']);
        $validated['volume_ml'] = $volumeMl;

        if (($validated['uom_type'] ?? $item->uom_type) === 'volume' && $volumeMl !== null) {
            $incomingNorm = $this->normalizeName($validated['name']);
            $exists = Item::query()
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
        if (($validated['uom_type'] ?? $item->uom_type) !== 'volume') {
            $validated['carton_size'] = null;
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
        // Deletion is disabled. Prevent permanent removal.
        return redirect()->route('items.index')->with('error', 'Deleting products is disabled. You can disable a product instead.');
    }

    /**
     * Disable an item (soft inactive state).
     */
    public function disable($id)
    {
        $item = Item::findOrFail($id);
        $item->is_active = false;
        $item->save();
        return redirect()->route('items.index')->with('success', 'Product disabled');
    }

    /**
     * Enable an item back.
     */
    public function enable($id)
    {
        $item = Item::findOrFail($id);
        $item->is_active = true;
        $item->save();
        return redirect()->route('items.index')->with('success', 'Product enabled');
    }
}
