@extends('layouts.app')

@section('content')
<div class="max-w-2xl mx-auto px-4">
  <h1 class="text-xl font-semibold text-gray-900 mb-3">Add Item</h1>
  <div class="bg-white rounded border p-4">
    <form method="POST" action="{{ route('items.store') }}" class="space-y-4">
      @csrf
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label class="block text-sm text-gray-700 mb-1">Name</label>
          <input name="name" value="{{ old('name') }}" class="w-full border rounded px-3 py-2" required />
          @error('name')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>
        <div>
          <label class="block text-sm text-gray-700 mb-1">SKU (optional)</label>
          <input name="sku" value="{{ old('sku') }}" class="w-full border rounded px-3 py-2" />
          @error('sku')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>
      </div>
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label class="block text-sm text-gray-700 mb-1">Unit name (optional)</label>
          <input name="unit_name" value="{{ old('unit_name') }}" class="w-full border rounded px-3 py-2" placeholder="e.g., bottle, piece" />
          @error('unit_name')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>
        <div>
          <label class="block text-sm text-gray-700 mb-1">Notes (optional)</label>
          <input name="notes" value="{{ old('notes') }}" class="w-full border rounded px-3 py-2" />
          @error('notes')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>
      </div>
      <div class="flex gap-2">
        <button class="px-3 py-2 bg-indigo-600 text-white rounded">Save</button>
        <a href="{{ route('items.index') }}" class="px-3 py-2 bg-gray-100 rounded">Cancel</a>
      </div>
    </form>
  </div>
</div>
@endsection
