@extends('layouts.app')

@section('content')
<div class="max-w-2xl mx-auto px-4">
  <h1 class="text-xl font-semibold text-gray-900 mb-1">Add Kinywaji</h1>
  <!--<p class="text-xs text-gray-500 mb-3">We generate a product code (SKU) for you.</p>-->
  <div class="bg-white rounded border p-4">
    <form method="POST" action="{{ route('items.store') }}" enctype="multipart/form-data" class="space-y-4">
      @csrf
      <!-- Row 1: Name | Image upload -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label class="block text-sm text-gray-700 mb-1">Name</label>
          <input name="name" value="{{ old('name') }}" class="w-full border rounded px-3 py-2" required />
          @error('name')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>
        <div>
          <label class="block text-sm text-gray-700 mb-1">Product image (optional)</label>
          <input type="file" name="image" accept="image/*" class="w-full border rounded px-3 py-2" />
          <p class="text-xs text-gray-500 mt-1">Upload a photo for this product. Max 2 MB.</p>
          @error('image')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>
      </div>

      <!-- Unit type selector -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label class="block text-sm text-gray-700 mb-1">Unit Type</label>
          <select name="uom_type" id="uom_type" class="w-full border rounded px-3 py-2">
            <option value="volume" @selected(old('uom_type','volume')==='volume')>Volume (L/ml)</option>
          </select>
          @error('uom_type')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>
        <div>
          <label class="block text-sm text-gray-700 mb-1">Category (optional)</label>
          <input name="category" value="{{ old('category') }}" class="w-full border rounded px-3 py-2" placeholder="e.g., beverage, meat" />
          @error('category')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>
      </div>

      <!-- Row 2: Volume fields (for beverages) | Carton size (for volume/units) -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div id="volume_fields">
          <label id="volume_label" class="block text-sm text-gray-700 mb-1">Kiasi <span class="text-red-600">*</span></label>
          <div class="flex gap-2">
            <input type="number" step="0.001" min="0.001" name="volume_value" value="{{ old('volume_value') }}" class="w-full border rounded px-3 py-2" placeholder="mfano, 500" />
            <select name="volume_unit" class="border rounded px-3 py-2">
              <option value="ml" @selected(old('volume_unit','ml')==='ml')>ml</option>
              <option value="l" @selected(old('volume_unit')==='l')>L</option>
            </select>
          </div>
          <p class="text-xs text-gray-500 mt-1">Mfano: 500 ml au 1 L</p>
          @error('volume_value')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
          @error('volume_unit')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>
        <div id="carton_field">
          <label class="block text-sm text-gray-700 mb-1">Carton size</label>
          <input type="number" min="1" name="carton_size" id="carton_size" value="{{ old('carton_size') }}" class="w-full border rounded px-3 py-2" placeholder="Units per carton" />
          @error('carton_size')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>
      </div>

      <div>
        <label class="block text-sm text-gray-700 mb-1">Notes</label>
        <textarea name="notes" class="w-full border rounded px-3 py-2" rows="3">{{ old('notes') }}</textarea>
        <p class="text-xs text-gray-500 mt-1">Optional: any extra details about this product.</p>
        @error('notes')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
      </div>
      <p class="text-xs text-gray-500">For beverages, carton size ni idadi ya chupa katika katoni au kreti moja.</p>
      <div class="flex gap-2">
        <button class="px-3 py-2 bg-indigo-600 text-white rounded">Save</button>
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
      } else { // unit
        vol.style.display = 'none';
        carton.style.display = '';
      }
    }
    document.getElementById('uom_type').addEventListener('change', toggleFields);
    toggleFields();
  })();
</script>
@endpush
