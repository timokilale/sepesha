@extends('layouts.app')

@section('content')
<div class="max-w-2xl mx-auto px-4">
  <h1 class="text-xl font-semibold text-gray-900 mb-3">Edit Item</h1>
  <div class="bg-white rounded border p-4">
    <form method="POST" action="{{ route('items.update.single', ['id' => $item->id]) }}" enctype="multipart/form-data" class="space-y-4">
      @csrf
      @method('PUT')
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label class="block text-sm text-gray-700 mb-1">Name</label>
          <input name="name" value="{{ old('name', $item->name) }}" class="w-full border rounded px-3 py-2" required />
        </div>
        <div>
          <label class="block text-sm text-gray-700 mb-1">SKU</label>
          <input value="{{ $item->sku }}" class="w-full border rounded px-3 py-2 bg-gray-50 text-gray-700" readonly />
          <p class="text-xs text-gray-500 mt-1">Auto-generated. Shown for reference.</p>
        </div>
      </div>
      <!-- Unit type selector and category -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label class="block text-sm text-gray-700 mb-1">Unit Type</label>
          <select name="uom_type" id="uom_type" class="w-full border rounded px-3 py-2">
            @php
              $selType = old('uom_type', $item->uom_type ?? 'volume');
            @endphp
            <option value="volume" @selected($selType==='volume')>Volume (L/ml)</option>
            <option value="weight" @selected($selType==='weight')>Weight (kg/g)</option>
            <option value="unit" @selected($selType==='unit')>Count (pieces)</option>
          </select>
          @error('uom_type')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>
        <div>
          <label class="block text-sm text-gray-700 mb-1">Category (optional)</label>
          <input name="category" value="{{ old('category', $item->category) }}" class="w-full border rounded px-3 py-2" placeholder="e.g., beverage, meat" />
          @error('category')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>
      </div>

      <!-- Volume and carton fields (conditional) -->
      @php
        $volMl = old('volume_value') ? null : ($item->volume_ml ?? null);
        $prefUnit = 'ml';
        $prefVal = '';
        if ($volMl) {
          if ($volMl >= 1000 && $volMl % 1000 === 0) {
            $prefUnit = 'l';
            $prefVal = number_format($volMl / 1000, 3, '.', '');
          } else {
            $prefUnit = 'ml';
            $prefVal = (string) $volMl;
          }
        }
      @endphp
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div id="volume_fields">
          <label class="block text-sm text-gray-700 mb-1">Ujazo wa chupa</label>
          <div class="flex gap-2">
            <input type="number" step="0.001" min="0.001" name="volume_value" value="{{ old('volume_value', $prefVal) }}" class="w-full border rounded px-3 py-2" placeholder="mfano, 500" />
            <select name="volume_unit" class="border rounded px-3 py-2">
              <option value="ml" @selected(old('volume_unit', $prefUnit)==='ml')>ml</option>
              <option value="l" @selected(old('volume_unit', $prefUnit)==='l')>L</option>
            </select>
          </div>
          <p class="text-xs text-gray-500 mt-1">Mfano: 500 ml au 1 L</p>
          @error('volume_value')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
          @error('volume_unit')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>
        <div id="carton_field">
          <label class="block text-sm text-gray-700 mb-1">Carton size</label>
          <input type="number" min="1" name="carton_size" value="{{ old('carton_size', $item->carton_size) }}" class="w-full border rounded px-3 py-2" placeholder="Units per carton" />
          @error('carton_size')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>
      </div>
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label class="block text-sm text-gray-700 mb-1">Product image (optional)</label>
          <input type="file" name="image" accept="image/*" class="w-full border rounded px-3 py-2" />
          <p class="text-xs text-gray-500 mt-1">Upload a photo for this product. Max 2 MB.</p>
          @error('image')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
          @if($item->image_url)
            <img src="{{ $item->image_url }}" alt="{{ $item->name }}" class="mt-2 h-20 w-20 object-cover rounded border" />
          @endif
        </div>
      </div>
      <p class="text-xs text-gray-500">For beverages, carton size ni idadi ya chupa katika katoni au kreti moja. For meat, volume and carton are hidden.</p>
      <div>
        <label class="block text-sm text-gray-700 mb-1">Notes (optional)</label>
        <input name="notes" value="{{ old('notes', $item->notes) }}" class="w-full border rounded px-3 py-2" />
      </div>
      <div class="flex gap-2">
        <button class="px-3 py-2 bg-indigo-600 text-white rounded">Update</button>
        <a href="{{ route('items.index') }}" class="px-3 py-2 bg-gray-100 rounded">Cancel</a>
      </div>
    </form>
  </div>
</div>
@endsection

@push('scripts')
<script>
  (function(){
    function toggleFields() {
      var type = document.getElementById('uom_type').value;
      var vol = document.getElementById('volume_fields');
      var carton = document.getElementById('carton_field');
      if (type === 'volume') {
        vol.style.display = '';
        carton.style.display = '';
      } else if (type === 'unit') {
        vol.style.display = 'none';
        carton.style.display = '';
      } else { // weight
        vol.style.display = 'none';
        carton.style.display = 'none';
      }
    }
    document.getElementById('uom_type').addEventListener('change', toggleFields);
    toggleFields();
  })();
</script>
@endpush
