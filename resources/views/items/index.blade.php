@extends('layouts.app')

@section('content')
<div class="max-w-4xl mx-auto px-4">
  <div class="flex items-center justify-between mb-1">
    <h1 class="text-xl font-semibold text-gray-900">Products</h1>
    <a href="{{ route('items.create') }}" class="px-3 py-2 bg-indigo-600 text-white rounded">Add Product</a>
  </div>
  <p class="text-xs text-gray-500 mb-3">SKU = product code. We create it for you.</p>

  @if($items->count() === 0)
    <div class="bg-white rounded border p-6 text-center text-gray-500">No items yet.</div>
  @else
    <div class="grid gap-3" style="grid-template-columns: repeat(2, minmax(0, 1fr));">
      @foreach($items as $item)
        <div class="bg-white rounded border p-3 flex gap-3">
          @if($item->image_url)
            <img src="{{ $item->image_url }}" alt="{{ $item->name }}" class="h-16 w-16 object-cover rounded border" />
          @else
            <div class="h-16 w-16 rounded border flex items-center justify-center text-xs text-gray-500">No Image</div>
          @endif
          <div class="flex-1 min-w-0">
            <div class="flex items-start justify-between">
              <div class="font-medium text-gray-900 truncate">{{ $item->name }}</div>
              <div class="text-xs text-gray-500 ml-2">{{ $item->sku }}</div>
            </div>
            <div class="text-xs text-gray-600 mt-0.5">
              @php
                $vol = $item->volume_ml;
                $volText = $vol ? ($vol >= 1000 && $vol % 1000 === 0 ? ($vol/1000).' L' : $vol.' ml') : null;
              @endphp
              @if($volText)
                <span>{{ $volText }}</span>
                <span class="mx-1">·</span>
              @endif
              @if($item->unit_name)
                <span>{{ $item->unit_name }}</span>
                <span class="mx-1">·</span>
              @endif
              @if($item->carton_size)
                <span>Carton: {{ $item->carton_size }}</span>
              @endif
            </div>
            <div class="mt-2 text-sm">
              <a class="text-indigo-600" href="{{ route('items.show.single', ['id' => $item->id]) }}">View</a>
              <span class="mx-1">·</span>
              <a class="text-gray-700" href="{{ route('items.edit.single', ['id' => $item->id]) }}">Edit</a>
              <span class="mx-1">·</span>
              <form action="{{ route('items.destroy.single', ['id' => $item->id]) }}" method="POST" class="inline" onsubmit="return confirm('Delete this item?')">
                @csrf
                @method('DELETE')
                <button class="text-red-600">Delete</button>
              </form>
            </div>
          </div>
        </div>
      @endforeach
    </div>
  @endif

  <div class="mt-3">{{ $items->links() }}</div>
</div>
@endsection
