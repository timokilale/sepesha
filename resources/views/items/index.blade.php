@extends('layouts.app')

@section('content')
<div class="max-w-4xl mx-auto px-4">
  <div class="flex items-center justify-between mb-1">
    <h1 class="text-xl font-semibold text-gray-900">Products</h1>
    <div class="flex gap-2">
      <a href="{{ route('items.create') }}" class="px-3 py-2 bg-indigo-600 text-white rounded">Add Kinywaji</a>
      <a href="{{ route('meat.create') }}" class="px-3 py-2 bg-red-600 text-white rounded">Add Meat</a>
    </div>
  </div>
  <p class="text-xs text-gray-500 mb-3">SKU = product code. We create it for you.</p>

  @if($items->count() === 0)
    <div class="bg-white rounded border p-6 text-center text-gray-500">No items yet.</div>
  @else
    <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
      @foreach($items as $item)
        <div class="bg-white rounded border p-3 flex gap-3 {{ $item->is_active ? '' : 'opacity-50' }}">
          @if($item->image_url)
            <img src="{{ $item->image_url }}" alt="{{ $item->name }}" class="h-16 w-16 object-cover rounded border" />
          @else
            <div class="h-16 w-16 rounded border flex items-center justify-center text-xs text-gray-500">No Image</div>
          @endif
          <div class="flex-1 min-w-0">
            <div class="flex items-start justify-between">
              <div class="font-medium text-gray-900 truncate flex items-center gap-2">
                <span>{{ $item->name }}</span>
                @unless($item->is_active)
                  <span class="text-xs px-1.5 py-0.5 rounded bg-gray-200 text-gray-700">Inactive</span>
                @endunless
              </div>
              <div class="text-xs text-gray-500 ml-2">{{ $item->sku }}</div>
            </div>
            <div class="text-xs text-gray-600 mt-0.5">
              @php
                $uom = $item->uom_type ?? 'unit';
                $vol = $item->volume_ml;
                $volText = $vol ? ($vol >= 1000 && $vol % 1000 === 0 ? ($vol/1000).' L' : $vol.' ml') : null;
              @endphp
              <span class="px-1.5 py-0.5 rounded bg-gray-100 text-gray-700">{{ ucfirst($uom) }}</span>
              @if($uom !== 'weight')
                @if($volText)
                  <span class="mx-1">·</span>
                  <span>{{ $volText }}</span>
                @endif
                @if($item->unit_name)
                  <span class="mx-1">·</span>
                  <span>{{ $item->unit_name }}</span>
                @endif
                @if($item->carton_size)
                  <span class="mx-1">·</span>
                  <span>Carton: {{ $item->carton_size }}</span>
                @endif
              @endif
            </div>
            <div class="mt-2 text-sm flex items-center gap-2 flex-wrap">
              <a class="text-indigo-600" href="{{ route('items.show.single', ['id' => $item->id]) }}">View</a>
              <span class="mx-1">·</span>
              <a class="text-gray-700" href="{{ route('items.edit.single', ['id' => $item->id]) }}">Edit</a>
              <span class="mx-1">·</span>
              @if($item->is_active)
                <form action="{{ route('items.disable.single', ['id' => $item->id]) }}" method="POST" class="inline" onsubmit="return confirm('Disable this product? It will be hidden and grayed out until enabled again.')">
                  @csrf
                  <button class="text-gray-600">Disable</button>
                </form>
              @else
                <form action="{{ route('items.enable.single', ['id' => $item->id]) }}" method="POST" class="inline">
                  @csrf
                  <button class="text-green-700">Enable</button>
                </form>
              @endif
            </div>
          </div>
        </div>
      @endforeach
    </div>
  @endif

  <div class="mt-3">{{ $items->links() }}</div>
</div>
@endsection
