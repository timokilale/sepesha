@extends('layouts.app')

@section('content')
<div class="max-w-2xl mx-auto px-4">
  <h1 class="text-xl font-semibold text-gray-900 mb-1">Add Meat</h1>
  <div class="bg-white rounded border p-4">
    <form method="POST" action="{{ route('items.store') }}" enctype="multipart/form-data" class="space-y-4">
      @csrf
      <input type="hidden" name="uom_type" value="weight">

      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label class="block text-sm text-gray-700 mb-1">Name</label>
          <input name="name" value="{{ old('name') }}" class="w-full border rounded px-3 py-2" required />
          @error('name')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>
        <div>
          <label class="block text-sm text-gray-700 mb-1">Product image (optional)</label>
          <input type="file" name="image" accept="image/*" class="w-full border rounded px-3 py-2" />
          <p class="text-xs text-gray-500 mt-1">Upload a photo. Max 2 MB.</p>
          @error('image')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label class="block text-sm text-gray-700 mb-1">Category (optional)</label>
          <input name="category" value="{{ old('category', 'meat') }}" class="w-full border rounded px-3 py-2" />
          @error('category')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>
        <div>
          <label class="block text-sm text-gray-700 mb-1">Carton size</label>
          <input type="number" name="carton_size" class="w-full border rounded px-3 py-2 bg-gray-50" placeholder="Not applicable" disabled />
          <p class="text-xs text-gray-500 mt-1">Not used for meat items.</p>
        </div>
      </div>

      <div>
        <label class="block text-sm text-gray-700 mb-1">Notes</label>
        <textarea name="notes" class="w-full border rounded px-3 py-2" rows="3">{{ old('notes') }}</textarea>
        @error('notes')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
      </div>

      <div class="flex gap-2">
        <button class="px-3 py-2 bg-indigo-600 text-white rounded">Save</button>
        <a href="{{ route('items.index') }}" class="px-3 py-2 bg-gray-100 rounded">Cancel</a>
      </div>
    </form>
  </div>
</div>
@endsection
