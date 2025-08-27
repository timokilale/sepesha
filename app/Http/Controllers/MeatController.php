<?php

namespace App\Http\Controllers;

use App\Models\Item;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Str;

class MeatController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
    }

    public function create()
    {
        return view('meat.create');
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'unit_name' => 'nullable|string|max:100',
            'notes' => 'nullable|string',
            'category' => 'nullable|string|max:100',
            'image' => 'nullable|image|max:2048',
        ]);

        $validated['user_id'] = Auth::id();
        $validated['uom_type'] = 'weight';
        $validated['carton_size'] = null; // Not applicable for meat
        $validated['volume_ml'] = null; // Not applicable for meat

        // Set default unit name for weight items
        if (empty($validated['unit_name'])) {
            $validated['unit_name'] = 'kg';
        }

        // Set default category if not provided
        if (empty($validated['category'])) {
            $validated['category'] = 'meat';
        }

        // Handle image upload
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
            ->with('success', 'Meat product created successfully. SKU: ' . $item->sku);
    }
}
