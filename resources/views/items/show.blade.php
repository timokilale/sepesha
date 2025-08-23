@extends('layouts.app')

@section('content')
<div class="max-w-2xl mx-auto px-4">
  <h1 class="text-xl font-semibold text-gray-900 mb-3">Item</h1>
  <div class="bg-white rounded border p-4 space-y-2">
    <div><span class="text-gray-600">Name:</span> <span class="font-medium">{{ $item->name }}</span></div>
    <div><span class="text-gray-600">SKU:</span> <span class="font-medium">{{ $item->sku }}</span></div>
    <div><span class="text-gray-600">Unit:</span> <span class="font-medium">{{ $item->unit_name }}</span></div>
    <div><span class="text-gray-600">Notes:</span> <span class="font-medium">{{ $item->notes }}</span></div>
  </div>
  <div class="mt-3">
    <a href="{{ route('items.edit', $item) }}" class="px-3 py-2 bg-gray-100 rounded">Edit</a>
    <a href="{{ route('items.index') }}" class="px-3 py-2">Back</a>
  </div>
</div>
@endsection
