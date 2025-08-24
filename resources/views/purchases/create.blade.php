@extends('layouts.app')

@section('content')
<div class="max-w-2xl mx-auto px-4" x-data="{
  cartons: Number('{{ old('cartons', 1) }}') || 1,
  unitsPerCarton: Number('{{ old('units_per_carton', 12) }}') || 0,
  cartonCost: Number('{{ old('carton_cost', 0) }}') || 0,
  totalBottles(){ return Math.max(0, this.cartons * this.unitsPerCarton) },
  perBottle(){ return this.unitsPerCarton > 0 ? Math.ceil(this.cartonCost / this.unitsPerCarton) : 0 }
}">
  <h1 class="text-xl font-semibold text-gray-900 mb-3">Buy Stock</h1>

  <div class="bg-white rounded border p-4">
    <form method="POST" action="{{ route('purchases.store') }}" class="space-y-4">
      @csrf
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div class="md:col-span-2">
          <label class="block text-sm text-gray-700 mb-1">Pick a product</label>
          <select name="item_id" class="w-full border rounded px-3 py-2" required>
            <option value="">-- Select item --</option>
            @foreach($items as $item)
              <option value="{{ $item->id }}" @selected(old('item_id', request('item_id'))==$item->id)>{{ $item->name }}</option>
            @endforeach
          </select>
          @error('item_id')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>
      </div>
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div>
          <label class="block text-sm text-gray-700 mb-1">How many cartons?</label>
          <input type="number" min="1" name="cartons" x-model.number="cartons" class="w-full border rounded px-3 py-2" required />
          @error('cartons')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>
        <div>
          <label class="block text-sm text-gray-700 mb-1">Bottles per carton</label>
          <input type="number" min="1" name="units_per_carton" x-model.number="unitsPerCarton" class="w-full border rounded px-3 py-2" required />
          @error('units_per_carton')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>
        <div>
          <label class="block text-sm text-gray-700 mb-1">Price per carton (TZS)</label>
          <input type="number" step="0.01" min="0" name="carton_cost" x-model.number="cartonCost" class="w-full border rounded px-3 py-2" required />
          @error('carton_cost')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>
      </div>
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div>
          <label class="block text-sm text-gray-700 mb-1">Purchase date</label>
          <input type="date" name="purchase_date" value="{{ old('purchase_date') }}" class="w-full border rounded px-3 py-2" required />
          @error('purchase_date')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>
      </div>

      <div class="rounded border p-3 bg-gray-50 text-sm text-gray-800">
        <div class="flex flex-wrap gap-4">
          <div>
            <div class="text-gray-500">Total bottles</div>
            <div class="font-medium" x-text="totalBottles()"></div>
          </div>
          <div>
            <div class="text-gray-500">Per-bottle cost (computed)</div>
            <div class="font-medium">TZS <span x-text="perBottle().toFixed(0)"></span></div>
          </div>
          <div>
            <div class="text-gray-500">Total purchase cost</div>
            <div class="font-medium">TZS <span x-text="(cartons * cartonCost).toFixed(2)"></span></div>
          </div>
        </div>
      </div>

      
      <div>
        <label class="block text-sm text-gray-700 mb-1">Description</label>
        <textarea name="description" class="w-full border rounded px-3 py-2" rows="3">{{ old('description') }}</textarea>
        @error('description')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
      </div>
      <div class="flex flex-col sm:flex-row gap-2 sm:gap-3">
        <button class="px-3 py-2 bg-indigo-600 text-white rounded">Save Purchase</button>
        <a href="{{ route('purchases.index') }}" class="px-3 py-2 bg-gray-100 rounded text-center">Cancel</a>
      </div>
    </form>
  </div>
</div>
@endsection
