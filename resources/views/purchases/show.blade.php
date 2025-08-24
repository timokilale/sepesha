@extends('layouts.app')

@section('content')
<div class="max-w-3xl mx-auto px-4">
  <h1 class="text-2xl font-bold text-gray-800 mb-4">Purchase Details</h1>

  <div class="bg-white rounded shadow p-6 space-y-4">
    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
      <div>
        <div class="text-gray-500 text-sm">Item</div>
        <div class="font-medium text-gray-900">{{ $purchase->item_name }}</div>
      </div>
      <div>
        <div class="text-gray-500 text-sm">Unit cost</div>
        <div class="font-medium text-gray-900">TZS {{ number_format($purchase->cost_price, 2) }}</div>
      </div>
      <div>
        <div class="text-gray-500 text-sm">Quantity</div>
        <div class="font-medium text-gray-900">{{ $purchase->quantity }}</div>
      </div>
      <div>
        <div class="text-gray-500 text-sm">Total</div>
        <div class="font-medium text-gray-900">TZS {{ number_format($purchase->cost_price * $purchase->quantity, 2) }}</div>
      </div>
      <div>
        <div class="text-gray-500 text-sm">Purchase Date</div>
        <div class="font-medium text-gray-900">{{ $purchase->purchase_date->format('Y-m-d') }}</div>
      </div>
    </div>
    @if($purchase->description)
      <div>
        <div class="text-gray-500 text-sm">Description</div>
        <div class="text-gray-900">{{ $purchase->description }}</div>
      </div>
    @endif
  </div>

  <h2 class="text-xl font-semibold text-gray-800 mt-8 mb-3">Sales for this Item</h2>
  <div class="bg-white rounded shadow overflow-hidden">
    <table class="min-w-full divide-y divide-gray-200">
      <thead class="bg-gray-50">
        <tr>
          <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Price</th>
          <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Qty</th>
          <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Date</th>
        </tr>
      </thead>
      <tbody class="bg-white divide-y divide-gray-200">
        @forelse ($purchase->sales as $s)
          <tr>
            <td class="px-4 py-2">${{ number_format($s->selling_price,2) }}</td>
            <td class="px-4 py-2">{{ $s->quantity_sold }}</td>
            <td class="px-4 py-2">{{ $s->sale_date->format('Y-m-d') }}</td>
          </tr>
        @empty
          <tr><td colspan="3" class="px-4 py-3 text-gray-500">No sales yet.</td></tr>
        @endforelse
      </tbody>
    </table>
  </div>

  <div class="mt-6">
    <a href="{{ route('purchases.index') }}" class="px-4 py-2 bg-gray-100 rounded">Back</a>
  </div>
</div>
@endsection
