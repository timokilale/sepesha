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
          <select name="item_id" id="item_id" class="w-full border rounded px-3 py-2" required>
            <option value="">-- Select item --</option>
            @foreach($items as $item)
              <option value="{{ $item->id }}" data-uom-type="{{ $item->uom_type }}" @selected(old('item_id', $purchase->item_id)==$item->id)>{{ $item->name }}</option>
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
        <h2 class="text-sm font-semibold text-gray-800 mb-2">Quantity & Cost</h2>
        <!-- Carton section -->
        <div id="carton_fields" class="grid grid-cols-1 md:grid-cols-4 gap-4">
          <div>
            <label class="block text-sm text-gray-700 mb-1">Cartons</label>
            <input type="number" min="1" name="cartons" value="{{ old('cartons', $purchase->cartons) }}" class="w-full border rounded px-3 py-2" />
            @error('cartons')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
          </div>
          <div>
            <label class="block text-sm text-gray-700 mb-1">Bottles per carton</label>
            <input type="number" min="1" name="units_per_carton" value="{{ old('units_per_carton', $purchase->units_per_carton) }}" class="w-full border rounded px-3 py-2" />
            @error('units_per_carton')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
          </div>
          <div>
            <label class="block text-sm text-gray-700 mb-1">Loose bottles (optional)</label>
            <input type="number" min="0" name="loose_units" value="{{ old('loose_units', $purchase->loose_units) }}" class="w-full border rounded px-3 py-2" />
            @error('loose_units')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
          </div>
          <div>
            <label class="block text-sm text-gray-700 mb-1">Price per carton (TZS)</label>
            <input type="number" step="0.01" min="0" name="carton_cost" value="{{ old('carton_cost', $purchase->carton_cost) }}" class="w-full border rounded px-3 py-2" />
            @error('carton_cost')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
          </div>
        </div>
        <!-- Weight section -->
        <div id="weight_fields" class="grid grid-cols-1 md:grid-cols-4 gap-4" style="display:none">
          <div class="md:col-span-2">
            <label class="block text-sm text-gray-700 mb-1">Weight</label>
            <div class="flex gap-2">
              <input type="number" min="0.001" step="0.001" name="weight_value" value="{{ old('weight_value') }}" class="w-full border rounded px-3 py-2" placeholder="e.g., 5" />
              <select name="weight_unit" class="border rounded px-3 py-2">
                <option value="kg" @selected(old('weight_unit')==='kg')>kg</option>
                <option value="g" @selected(old('weight_unit')==='g')>g</option>
              </select>
            </div>
            @error('weight_value')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
            @error('weight_unit')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
          </div>
          <div class="md:col-span-2">
            <label class="block text-sm text-gray-700 mb-1">Total cost (TZS)</label>
            <input type="number" step="0.01" min="0" name="total_cost" value="{{ old('total_cost') }}" class="w-full border rounded px-3 py-2" placeholder="e.g., 35000" />
            @error('total_cost')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
          </div>
        </div>
        <p class="text-xs text-gray-500 mt-2">Carton or weight fields will be used depending on the product type.</p>
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

@push('scripts')
<script>
  (function(){
    function toggleByType(type){
      var carton = document.getElementById('carton_fields');
      var weight = document.getElementById('weight_fields');
      if(type === 'weight'){
        carton.style.display = 'none';
        weight.style.display = '';
      } else {
        carton.style.display = '';
        weight.style.display = 'none';
      }
    }
    var sel = document.getElementById('item_id');
    function onChange(){
      var opt = sel.options[sel.selectedIndex];
      var t = opt ? (opt.getAttribute('data-uom-type') || 'unit') : 'unit';
      toggleByType(t);
    }
    sel.addEventListener('change', onChange);
    onChange();
  })();
</script>
@endpush
