@extends('layouts.app')

@section('content')
<div class="max-w-2xl mx-auto px-4">
  <h1 class="text-xl font-semibold text-gray-900 mb-1">Add Product</h1>
  <p class="text-xs text-gray-500 mb-3">We generate a product code (SKU) for you.</p>
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

      <!-- Row 2: Unit name | Volume | Carton size -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div>
          <label class="block text-sm text-gray-700 mb-1">Unit name (optional)</label>
          <input name="unit_name" value="{{ old('unit_name', 'bottle') }}" class="w-full border rounded px-3 py-2" />
          @error('unit_name')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>
        <div>
          <label class="block text-sm text-gray-700 mb-1">Volume (optional)</label>
          <div class="flex gap-2">
            <input type="number" step="0.001" min="0.001" name="volume_value" value="{{ old('volume_value') }}" class="w-full border rounded px-3 py-2" placeholder="e.g., 500" />
            <select name="volume_unit" class="border rounded px-3 py-2">
              <option value="ml" @selected(old('volume_unit','ml')==='ml')>ml</option>
              <option value="l" @selected(old('volume_unit')==='l')>L</option>
            </select>
          </div>
          <p class="text-xs text-gray-500 mt-1">Example: 500 ml or 1 L</p>
        </div>
        <div>
          <label class="block text-sm text-gray-700 mb-1">Carton size<span class="text-red-600">*</span></label>
          <input type="number" min="1" name="carton_size" value="{{ old('carton_size') }}" class="w-full border rounded px-3 py-2" placeholder="Units per carton" required />
          @error('carton_size')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>
      </div>

      <div>
        <label class="block text-sm text-gray-700 mb-1">Notes</label>
        <textarea name="notes" class="w-full border rounded px-3 py-2" rows="3">{{ old('notes') }}</textarea>
        <p class="text-xs text-gray-500 mt-1">Optional: any extra details about this product.</p>
        @error('notes')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
      </div>
      <p class="text-xs text-gray-500">Carton size is how many base units (e.g., bottles) are in one carton.</p>
      <div class="flex gap-2">
        <button class="px-3 py-2 bg-indigo-600 text-white rounded">Save</button>
        <a href="{{ route('items.index') }}" class="px-3 py-2 bg-gray-100 rounded">Cancel</a>
      </div>
    </form>
  </div>
</div>
@endsection
