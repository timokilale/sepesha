@extends('layouts.app')

@section('content')
<div class="max-w-2xl mx-auto px-4">
  <h1 class="text-2xl font-bold text-gray-800 mb-4">Edit Sale</h1>

  <div class="bg-white rounded shadow p-6">
    <form method="POST" action="{{ route('sales.update', $sale) }}" class="space-y-4">
      @csrf
      @method('PUT')
      <div>
        <label class="block text-sm text-gray-700 mb-1">Purchase (item)</label>
        <select name="purchase_id" class="w-full border rounded px-3 py-2" required>
          @foreach ($purchases as $purchase)
            <option value="{{ $purchase->id }}" {{ $sale->purchase_id == $purchase->id ? 'selected' : '' }}>
              {{ $purchase->item_name }}
            </option>
          @endforeach
        </select>
      </div>
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div>
          <label class="block text-sm text-gray-700 mb-1">Selling price</label>
          <input type="number" step="0.01" name="selling_price" value="{{ old('selling_price', $sale->selling_price) }}" class="w-full border rounded px-3 py-2" required />
        </div>
        <div>
          <label class="block text-sm text-gray-700 mb-1">Quantity sold</label>
          <input type="number" min="1" name="quantity_sold" value="{{ old('quantity_sold', $sale->quantity_sold) }}" class="w-full border rounded px-3 py-2" required />
        </div>
        <div>
          <label class="block text-sm text-gray-700 mb-1">Sale date</label>
          <input type="date" name="sale_date" value="{{ old('sale_date', $sale->sale_date->format('Y-m-d')) }}" class="w-full border rounded px-3 py-2" required />
        </div>
      </div>
      <div>
        <label class="block text-sm text-gray-700 mb-1">Notes</label>
        <textarea name="notes" class="w-full border rounded px-3 py-2" rows="3">{{ old('notes', $sale->notes) }}</textarea>
      </div>
      <div class="flex gap-3">
        <button class="px-4 py-2 bg-green-600 text-white rounded">Update</button>
        <a href="{{ route('sales.index') }}" class="px-4 py-2 bg-gray-100 rounded">Cancel</a>
      </div>
    </form>
  </div>
</div>
@endsection
