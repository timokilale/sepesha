@extends('layouts.app')

@section('content')
<div class="max-w-2xl mx-auto px-4">
  <h1 class="text-2xl font-bold text-gray-800 mb-4">Add Purchase</h1>

  <div class="bg-white rounded shadow p-6">
    <form method="POST" action="{{ route('purchases.store') }}" class="space-y-4">
      @csrf
      <div>
        <label class="block text-sm text-gray-700 mb-1">Item name</label>
        <input name="item_name" value="{{ old('item_name') }}" class="w-full border rounded px-3 py-2" required />
        @error('item_name')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
      </div>
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div>
          <label class="block text-sm text-gray-700 mb-1">Cost price</label>
          <input type="number" step="0.01" name="cost_price" value="{{ old('cost_price') }}" class="w-full border rounded px-3 py-2" required />
          @error('cost_price')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>
        <div>
          <label class="block text-sm text-gray-700 mb-1">Quantity</label>
          <input type="number" min="1" name="quantity" value="{{ old('quantity',1) }}" class="w-full border rounded px-3 py-2" required />
          @error('quantity')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>
        <div>
          <label class="block text-sm text-gray-700 mb-1">Purchase date</label>
          <input type="date" name="purchase_date" value="{{ old('purchase_date') }}" class="w-full border rounded px-3 py-2" required />
          @error('purchase_date')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>
      </div>
      <div>
        <label class="block text-sm text-gray-700 mb-1">Description</label>
        <textarea name="description" class="w-full border rounded px-3 py-2" rows="3">{{ old('description') }}</textarea>
        @error('description')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
      </div>
      <div class="flex flex-col sm:flex-row gap-2 sm:gap-3">
        <button class="px-4 py-2 bg-indigo-600 text-white rounded">Save</button>
        <a href="{{ route('purchases.index') }}" class="px-4 py-2 bg-gray-100 rounded text-center">Cancel</a>
      </div>
    </form>
  </div>
</div>
@endsection
