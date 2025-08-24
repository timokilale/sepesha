@extends('layouts.app')

@section('content')
<div class="max-w-2xl mx-auto px-4" x-data="{ mode: 'simple' }">
  <h1 class="text-xl font-semibold text-gray-900 mb-3">Sell Stock</h1>

  <div class="bg-white rounded border p-4">
    <form method="POST" action="{{ route('sales.store') }}" class="space-y-4">
      @csrf
      <div class="flex items-center gap-2 text-sm">
        <button type="button" @click="mode='simple'" :class="mode==='simple' ? 'bg-indigo-600 text-white' : 'bg-gray-100 text-gray-700'" class="px-3 py-1.5 rounded">Simple</button>
        <button type="button" @click="mode='advanced'" :class="mode==='advanced' ? 'bg-indigo-600 text-white' : 'bg-gray-100 text-gray-700'" class="px-3 py-1.5 rounded">Advanced</button>
      </div>
      <div>
        <label class="block text-sm text-gray-700 mb-1">Pick stock to sell (remaining shown in bottles)</label>
        <select name="purchase_id" class="w-full border rounded px-3 py-2">
          @foreach($purchases as $purchase)
            <option value="{{ $purchase->id }}" @selected(old('purchase_id', request('purchase_id'))==$purchase->id)>
              {{ $purchase->item?->name ?? $purchase->item_name }} — left: {{ $purchase->remaining_quantity }} @if($purchase->item?->unit_name){{ $purchase->item?->unit_name }}@endif @ TZS {{ number_format($purchase->unit_cost, 2) }}
            </option>
          @endforeach
        </select>
        @error('purchase_id')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        <p class="text-xs text-gray-500 mt-1">Tip: Choose the batch you want to sell from. Remaining bottles help you avoid overselling.</p>
      </div>
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div>
          <label class="block text-sm text-gray-700 mb-1">Selling price</label>
          <input type="number" step="0.01" name="selling_price" value="{{ old('selling_price') }}" class="w-full border rounded px-3 py-2" />
          @error('selling_price')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>
        <div>
          <label class="block text-sm text-gray-700 mb-1">Quantity</label>
          <input type="number" min="1" name="quantity_sold" value="{{ old('quantity_sold') }}" class="w-full border rounded px-3 py-2" />
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
        <button class="px-3 py-2 bg-indigo-600 text-white rounded">Save Sale</button>
        <a href="{{ route('sales.index') }}" class="px-3 py-2 bg-gray-100 rounded text-center">Cancel</a>
      </div>
    </form>
  </div>
</div>
@endsection
