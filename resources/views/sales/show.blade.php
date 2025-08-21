@extends('layouts.app')

@section('content')
<div class="max-w-3xl mx-auto px-4">
  <h1 class="text-2xl font-bold text-gray-800 mb-4">Sale Details</h1>

  <div class="bg-white rounded shadow p-6 space-y-4">
    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
      <div>
        <div class="text-gray-500 text-sm">Item</div>
        <div class="font-medium text-gray-900">{{ $sale->purchase->item_name }}</div>
      </div>
      <div>
        <div class="text-gray-500 text-sm">Selling Price</div>
        <div class="font-medium text-gray-900">${{ number_format($sale->selling_price, 2) }}</div>
      </div>
      <div>
        <div class="text-gray-500 text-sm">Quantity Sold</div>
        <div class="font-medium text-gray-900">{{ $sale->quantity_sold }}</div>
      </div>
      <div>
        <div class="text-gray-500 text-sm">Sale Date</div>
        <div class="font-medium text-gray-900">{{ $sale->sale_date->format('Y-m-d') }}</div>
      </div>
    </div>
    @if($sale->notes)
      <div>
        <div class="text-gray-500 text-sm">Notes</div>
        <div class="text-gray-900">{{ $sale->notes }}</div>
      </div>
    @endif
  </div>

  <div class="mt-6 flex gap-3">
    <a href="{{ route('sales.index') }}" class="px-4 py-2 bg-gray-100 rounded">Back</a>
    <a href="{{ route('sales.edit', $sale) }}" class="px-4 py-2 bg-indigo-600 text-white rounded">Edit</a>
  </div>
</div>
@endsection
