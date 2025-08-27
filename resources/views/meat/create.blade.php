@extends('layouts.app')

@section('content')
<div class="max-w-2xl mx-auto px-4">
  <h1 class="text-xl font-semibold text-gray-900 mb-1">Add Meat Product</h1>
  <div class="bg-white rounded border p-4">
    <form method="POST" action="{{ route('meat.store') }}" enctype="multipart/form-data" class="space-y-4">
      @csrf

      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label class="block text-sm text-gray-700 mb-1">Product Name *</label>
          <input name="name" value="{{ old('name') }}" class="w-full border rounded px-3 py-2" required />
          @error('name')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>
        <div>
          <label class="block text-sm text-gray-700 mb-1">Unit Name</label>
          <input name="unit_name" value="{{ old('unit_name', 'kg') }}" class="w-full border rounded px-3 py-2" />
          <p class="text-xs text-gray-500 mt-1">Default: kg</p>
          @error('unit_name')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label class="block text-sm text-gray-700 mb-1">Category</label>
          <input name="category" value="{{ old('category', 'meat') }}" class="w-full border rounded px-3 py-2" />
          @error('category')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>
        <div>
          <label class="block text-sm text-gray-700 mb-1">Product Image</label>
          <input type="file" name="image" accept="image/*" class="w-full border rounded px-3 py-2" />
          <p class="text-xs text-gray-500 mt-1">Optional. Max 2 MB.</p>
          @error('image')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>
      </div>

      <div>
        <label class="block text-sm text-gray-700 mb-1">Notes</label>
        <textarea name="notes" class="w-full border rounded px-3 py-2" rows="3" placeholder="Additional notes about this meat product...">{{ old('notes') }}</textarea>
        @error('notes')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
      </div>

      <div class="bg-blue-50 p-3 rounded">
        <p class="text-sm text-blue-800">
          <strong>Weight-based product:</strong> This item will be sold by weight (kg). 
          Carton sizes don't apply to meat products.
        </p>
      </div>

      <div class="flex gap-2">
        <button type="submit" class="px-4 py-2 bg-indigo-600 text-white rounded hover:bg-indigo-700">
          Save Meat Product
        </button>
        <a href="{{ route('items.index') }}" class="px-4 py-2 bg-gray-100 text-gray-700 rounded hover:bg-gray-200">
          Cancel
        </a>
      </div>
    </form>
  </div>
</div>
@endsection
