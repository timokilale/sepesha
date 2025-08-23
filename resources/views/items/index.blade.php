@extends('layouts.app')

@section('content')
<div class="max-w-4xl mx-auto px-4">
  <div class="flex items-center justify-between mb-3">
    <h1 class="text-xl font-semibold text-gray-900">Items</h1>
    <a href="{{ route('items.create') }}" class="px-3 py-2 bg-indigo-600 text-white rounded">Add Item</a>
  </div>
  <div class="bg-white rounded border">
    <table class="w-full text-sm">
      <thead>
        <tr class="text-left border-b">
          <th class="p-3">Name</th>
          <th class="p-3">SKU</th>
          <th class="p-3">Unit</th>
          <th class="p-3"></th>
        </tr>
      </thead>
      <tbody>
        @forelse($items as $item)
        <tr class="border-b">
          <td class="p-3">{{ $item->name }}</td>
          <td class="p-3">{{ $item->sku }}</td>
          <td class="p-3">{{ $item->unit_name }}</td>
          <td class="p-3 text-right">
            <a class="text-indigo-600" href="{{ route('items.show', $item) }}">View</a>
            <span class="mx-1">·</span>
            <a class="text-gray-700" href="{{ route('items.edit', $item) }}">Edit</a>
            <span class="mx-1">·</span>
            <form action="{{ route('items.destroy', $item) }}" method="POST" class="inline" onsubmit="return confirm('Delete this item?')">
              @csrf
              @method('DELETE')
              <button class="text-red-600">Delete</button>
            </form>
          </td>
        </tr>
        @empty
        <tr><td colspan="4" class="p-3 text-center text-gray-500">No items yet.</td></tr>
        @endforelse
      </tbody>
    </table>
  </div>
  <div class="mt-3">{{ $items->links() }}</div>
</div>
@endsection
