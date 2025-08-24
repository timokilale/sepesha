@extends('layouts.app')

@section('content')
<div class="max-w-2xl mx-auto px-4">
  <h1 class="text-xl font-semibold text-gray-900 mb-3">Edit Purchase</h1>

  <div class="bg-white rounded border p-4">
    <form method="POST" action="{{ route('purchases.update.single', ['id' => $purchase->id]) }}" class="space-y-4">
      @csrf
      @method('PUT')
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div class="md:col-span-2">
          <label class="block text-sm text-gray-700 mb-1">Item</label>
          <select name="item_id" class="w-full border rounded px-3 py-2" required>
            <option value="">-- Select item --</option>
            @foreach($items as $item)
              <option value="{{ $item->id }}" @selected(old('item_id', $purchase->item_id)==$item->id)>{{ $item->name }}</option>
            @endforeach
          </select>
          @error('item_id')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>
      </div>
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div>
          <label class="block text-sm text-gray-700 mb-1">Purchase date</label>
          <input type="date" name="purchase_date" value="{{ old('purchase_date', $purchase->purchase_date->format('Y-m-d')) }}" class="w-full border rounded px-3 py-2" required />
        </div>
      </div>

      <div class="border rounded p-3">
        <h2 class="text-sm font-semibold text-gray-800 mb-2">Packaging</h2>
        <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
          <div>
            <label class="block text-sm text-gray-700 mb-1">Cartons</label>
            <input type="number" min="1" name="cartons" value="{{ old('cartons', $purchase->cartons) }}" class="w-full border rounded px-3 py-2" required />
            @error('cartons')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
          </div>
          <div>
            <label class="block text-sm text-gray-700 mb-1">Bottles per carton</label>
            <input type="number" min="1" name="units_per_carton" value="{{ old('units_per_carton', $purchase->units_per_carton) }}" class="w-full border rounded px-3 py-2" required />
            @error('units_per_carton')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
          </div>
          <div>
            <label class="block text-sm text-gray-700 mb-1">Loose bottles (optional)</label>
            <input type="number" min="0" name="loose_units" value="{{ old('loose_units', $purchase->loose_units) }}" class="w-full border rounded px-3 py-2" />
            @error('loose_units')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
          </div>
          <div>
            <label class="block text-sm text-gray-700 mb-1">Price per carton (TZS)</label>
            <input type="number" step="0.01" min="0" name="carton_cost" value="{{ old('carton_cost', $purchase->carton_cost) }}" class="w-full border rounded px-3 py-2" required />
            @error('carton_cost')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
          </div>
        </div>
        <p class="text-xs text-gray-500 mt-2">We will recompute total bottles and per-bottle cost on save.</p>
      </div>
      <div>
        <label class="block text-sm text-gray-700 mb-1">Description</label>
        <textarea name="description" class="w-full border rounded px-3 py-2" rows="3">{{ old('description', $purchase->description) }}</textarea>
      </div>
      <div class="flex flex-col sm:flex-row gap-2 sm:gap-3">
        <button class="px-3 py-2 bg-indigo-600 text-white rounded">Update</button>
        <a href="{{ route('purchases.index') }}" class="px-3 py-2 bg-gray-100 rounded text-center">Cancel</a>
      </div>
    </form>
  </div>
</div>
@endsection
