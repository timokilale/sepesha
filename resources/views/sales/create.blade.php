@extends('layouts.app')

@section('content')
<div class="max-w-2xl mx-auto px-4">
  <h1 class="text-2xl font-bold text-gray-800 mb-4">Add Sale</h1>

  <div class="bg-white rounded shadow p-6">
    <form method="POST" action="{{ route('sales.store') }}" class="space-y-4">
      @csrf
      <div>
        <label class="block text-sm text-gray-700 mb-1">Purchase (item)</label>
        <select name="purchase_id" class="w-full border rounded px-3 py-2" required>
          <option value="">Select item</option>
          @foreach ($purchases as $purchase)
            <option value="{{ $purchase->id }}">{{ $purchase->item_name }} (Remaining: {{ $purchase->remaining_quantity }})</option>
          @endforeach
        </select>
        @error('purchase_id')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
      </div>
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div>
          <label class="block text-sm text-gray-700 mb-1">Selling price</label>
          <input type="number" step="0.01" name="selling_price" value="{{ old('selling_price') }}" class="w-full border rounded px-3 py-2" required />
          @error('selling_price')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>
        <div>
          <label class="block text-sm text-gray-700 mb-1">Quantity sold</label>
          <input type="number" min="1" name="quantity_sold" value="{{ old('quantity_sold',1) }}" class="w-full border rounded px-3 py-2" required />
          @error('quantity_sold')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>
        <div>
          <label class="block text-sm text-gray-700 mb-1">Sale date</label>
          <input type="date" name="sale_date" value="{{ old('sale_date') }}" class="w-full border rounded px-3 py-2" required />
          @error('sale_date')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>
      </div>
      <div>
        <label class="block text-sm text-gray-700 mb-1">Notes</label>
        <textarea name="notes" class="w-full border rounded px-3 py-2" rows="3">{{ old('notes') }}</textarea>
      </div>
      <div class="flex flex-col sm:flex-row gap-2 sm:gap-3">
        <button class="px-4 py-2 bg-green-600 text-white rounded">Save</button>
        <a href="{{ route('sales.index') }}" class="px-4 py-2 bg-gray-100 rounded text-center">Cancel</a>
      </div>
    </form>
  </div>
</div>
@endsection
