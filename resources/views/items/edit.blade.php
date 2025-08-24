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
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div>
          <label class="block text-sm text-gray-700 mb-1">Unit name (optional)</label>
          <input name="unit_name" value="{{ old('unit_name', $item->unit_name) }}" class="w-full border rounded px-3 py-2" />
        </div>
        <div>
          <label class="block text-sm text-gray-700 mb-1">Volume (optional)</label>
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
          <div class="flex gap-2">
            <input type="number" step="0.001" min="0.001" name="volume_value" value="{{ old('volume_value', $prefVal) }}" class="w-full border rounded px-3 py-2" placeholder="e.g., 500" />
            <select name="volume_unit" class="border rounded px-3 py-2">
              <option value="ml" @selected(old('volume_unit', $prefUnit)==='ml')>ml</option>
              <option value="l" @selected(old('volume_unit', $prefUnit)==='l')>L</option>
            </select>
          </div>
          <p class="text-xs text-gray-500 mt-1">Example: 500 ml or 1 L</p>
        </div>
        <div>
          <label class="block text-sm text-gray-700 mb-1">Carton size <span class="text-red-600">*</span></label>
          <input type="number" min="1" name="carton_size" value="{{ old('carton_size', $item->carton_size) }}" class="w-full border rounded px-3 py-2" required />
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
      <p class="text-xs text-gray-500">Carton size is how many base units (e.g., bottles) are in one carton.</p>
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
