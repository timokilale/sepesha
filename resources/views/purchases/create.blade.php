@extends('layouts.app')

@section('content')
<div class="max-w-2xl mx-auto px-4" x-data="{
  productType: '{{ old('product_type', 'beverage') }}',
  cartons: Number('{{ old('cartons', 1) }}') || 1,
  unitsPerCarton: Number('{{ old('units_per_carton', 12) }}') || 0,
  cartonCost: Number('{{ old('carton_cost', 0) }}') || 0,
  weight: Number('{{ old('weight', 0) }}') || 0,
  pricePerKg: Number('{{ old('price_per_kg', 0) }}') || 0,
  totalBottles(){ return Math.max(0, this.cartons * this.unitsPerCarton) },
  perBottle(){ return this.unitsPerCarton > 0 ? (this.cartonCost / this.unitsPerCarton) : 0 },
  totalMeatCost(){ return this.weight * this.pricePerKg }
}"
     x-init="
       // On load, align productType with selected item's uom_type if any
       (() => {
         const sel = $refs.itemSelect;
         if (sel && sel.selectedIndex > 0) {
           const opt = sel.options[sel.selectedIndex];
           const t = opt?.dataset?.uomType;
           if (t === 'weight') { productType = 'meat'; } else { productType = 'beverage'; }
         }
       })()
     ">
  <h1 class="text-xl font-semibold text-gray-900 mb-3">Buy Stock for <span x-text="productType === 'meat' ? 'Meat' : 'Beverage'"></span> Products</h1>

  <div class="bg-white rounded border p-4">
    <form method="POST" action="{{ route('purchases.store') }}" class="space-y-4">
      @csrf
      
      <!-- Product Type Selection -->
      <div>
        <label class="block text-sm text-gray-700 mb-1">Product Type</label>
        <select name="product_type" x-model="productType" class="w-full border rounded px-3 py-2" required>
          <option value="beverage" @selected(old('product_type', 'beverage')==='beverage')>Beverage</option>
          <option value="meat" @selected(old('product_type')==='meat')>Meat</option>
        </select>
        @error('product_type')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div class="md:col-span-2">
          <label class="block text-sm text-gray-700 mb-1">Pick a product</label>
          <select name="item_id" id="item_id" class="w-full border rounded px-3 py-2" required
                  x-ref="itemSelect"
                  @change="
                    const opt = $refs.itemSelect.options[$refs.itemSelect.selectedIndex];
                    const t = opt?.dataset?.uomType;
                    if (t === 'weight') { productType = 'meat'; } else { productType = 'beverage'; }
                  ">
            <option value="">-- Select item --</option>
            @foreach($items as $item)
              <option value="{{ $item->id }}" data-uom-type="{{ $item->uom_type }}" @selected(old('item_id', request('item_id'))==$item->id)>{{ $item->name }}</option>
            @endforeach
          </select>
          @error('item_id')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>
      </div>

      <!-- Beverage (Carton-based) fields -->
      <div x-show="productType === 'beverage'" class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div>
          <label class="block text-sm text-gray-700 mb-1">How many cartons?</label>
          <input type="number" min="1" name="cartons" x-model.number="cartons" class="w-full border rounded px-3 py-2"
                 :required="productType === 'beverage'" :disabled="productType !== 'beverage'" />
          @error('cartons')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>
        <div>
          <label class="block text-sm text-gray-700 mb-1">Bottles per carton</label>
          <input type="number" min="1" name="units_per_carton" x-model.number="unitsPerCarton" class="w-full border rounded px-3 py-2"
                 :required="productType === 'beverage'" :disabled="productType !== 'beverage'" />
          @error('units_per_carton')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>
        <div>
          <label class="block text-sm text-gray-700 mb-1">Price per carton (TZS)</label>
          <input type="number" step="0.01" min="0" name="carton_cost" x-model.number="cartonCost" class="w-full border rounded px-3 py-2"
                 :required="productType === 'beverage'" :disabled="productType !== 'beverage'" />
          @error('carton_cost')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>
      </div>

      <!-- Meat (Weight-based) fields -->
      <div x-show="productType === 'meat'" class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label class="block text-sm text-gray-700 mb-1">Weight (kg)</label>
          <input type="number" min="0.1" step="0.1" name="weight" x-model.number="weight" class="w-full border rounded px-3 py-2" placeholder="e.g., 5.5"
                 :required="productType === 'meat'" :disabled="productType !== 'meat'" />
          @error('weight')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>
        <div>
          <label class="block text-sm text-gray-700 mb-1">Price per kg (TZS)</label>
          <input type="number" step="0.01" min="0" name="price_per_kg" x-model.number="pricePerKg" class="w-full border rounded px-3 py-2" placeholder="e.g., 7000"
                 :required="productType === 'meat'" :disabled="productType !== 'meat'" />
          @error('price_per_kg')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div>
          <label class="block text-sm text-gray-700 mb-1">Purchase date</label>
          <input type="date" name="purchase_date" value="{{ old('purchase_date') }}" class="w-full border rounded px-3 py-2" required />
          @error('purchase_date')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>
      </div>

      <!-- Summary Section -->
      <div class="rounded border p-3 bg-gray-50 text-sm text-gray-800">
        <div class="flex flex-wrap gap-4">
          <!-- Beverage Summary -->
          <div x-show="productType === 'beverage'">
            <div class="text-gray-500">Total bottles</div>
            <div class="font-medium" x-text="totalBottles()"></div>
            <div class="text-gray-500 mt-2">Per-bottle cost (computed)</div>
            <div class="font-medium">TZS <span x-text="perBottle().toFixed(1)"></span></div>
            <div class="text-gray-500 mt-2">Total purchase cost</div>
            <div class="font-medium">TZS <span x-text="(cartons * cartonCost).toFixed(2)"></span></div>
          </div>
          
          <!-- Meat Summary -->
          <div x-show="productType === 'meat'">
            <div class="text-gray-500">Total weight</div>
            <div class="font-medium"><span x-text="weight"></span> kg</div>
            <div class="text-gray-500 mt-2">Price per kg</div>
            <div class="font-medium">TZS <span x-text="pricePerKg.toFixed(2)"></span></div>
            <div class="text-gray-500 mt-2">Total purchase cost</div>
            <div class="font-medium">TZS <span x-text="totalMeatCost().toFixed(2)"></span></div>
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