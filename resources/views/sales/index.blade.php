@extends('layouts.app')

@section('content')
<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
  <div class="flex flex-col sm:flex-row sm:items-center justify-between mb-3 gap-3">
    <h1 class="text-xl font-semibold text-gray-900">Sales</h1>
    <a href="{{ route('sales.create') }}" class="px-3 py-2 bg-green-600 text-white rounded hover:bg-green-700 text-center">Add Sale</a>
  </div>

  <div class="bg-white rounded border overflow-hidden">
    <div class="overflow-x-auto">
      <table class="data-table min-w-full divide-y divide-gray-200">
        <thead class="bg-gray-50">
          <tr>
            <th class="px-2 sm:px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Item</th>
            <th class="px-2 sm:px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Price</th>
            <th class="px-2 sm:px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase hidden sm:table-cell">Qty</th>
            <th class="px-2 sm:px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase hidden md:table-cell">Date</th>
            <th class="px-2 sm:px-4 py-2 text-right">Actions</th>
          </tr>
        </thead>
        <tbody class="bg-white divide-y divide-gray-200">
          @forelse ($sales as $s)
          <tr>
            <td class="px-2 sm:px-4 py-2 text-gray-800">
              <div class="font-medium">{{ $s->purchase->item_name }}</div>
              <div class="text-sm text-gray-500 sm:hidden">Qty: {{ $s->quantity_sold }} • {{ $s->sale_date->format('M d, Y') }}</div>
            </td>
            <td class="px-2 sm:px-4 py-2 font-medium">TZS {{ number_format($s->selling_price,2) }}</td>
            <td class="px-2 sm:px-4 py-2 hidden sm:table-cell">{{ $s->quantity_sold }}</td>
            <td class="px-2 sm:px-4 py-2 hidden md:table-cell">{{ $s->sale_date->format('Y-m-d') }}</td>
            <td class="px-2 sm:px-4 py-2 text-right">
              <div x-data="{ open: false }" class="flex flex-col items-end gap-1 justify-end">
                <button @click="open = true" class="text-gray-700 text-sm hover:text-gray-900">View</button>
                <a href="{{ route('sales.edit.single', ['id' => $s->id]) }}" class="text-indigo-600 text-sm hover:text-indigo-800">Edit</a>
                <form action="{{ route('sales.destroy.single', ['id' => $s->id]) }}" method="POST" class="inline">
                  @csrf
                  @method('DELETE')
                  <button class="text-red-600 text-sm hover:text-red-800" onclick="return confirm('Delete this sale?')">Delete</button>
                </form>

                <!-- Modal -->
                <div x-show="open" x-transition class="fixed inset-0 z-50 flex items-center justify-center">
                  <div class="absolute inset-0 bg-black/30" @click="open = false"></div>
                  <div class="relative bg-white w-full max-w-md rounded shadow-lg p-4 mx-4">
                    <div class="flex items-center justify-between mb-2">
                      <h3 class="text-lg font-semibold text-gray-900">Sale Details</h3>
                      <button @click="open = false" class="text-gray-500 hover:text-gray-700">&times;</button>
                    </div>
                    <div class="space-y-2 text-sm text-gray-800">
                      <div class="flex justify-between"><span class="text-gray-500">Item</span><span class="font-medium">{{ $s->purchase->item_name }}</span></div>
                      <div class="flex justify-between"><span class="text-gray-500">Selling Price</span><span class="font-medium">TZS {{ number_format($s->selling_price,2) }}</span></div>
                      <div class="flex justify-between"><span class="text-gray-500">Quantity Sold</span><span class="font-medium">{{ $s->quantity_sold }}</span></div>
                      <div class="flex justify-between"><span class="text-gray-500">Date</span><span class="font-medium">{{ $s->sale_date->format('Y-m-d') }}</span></div>
                      <div>
                        <div class="text-gray-500">Purchase Description</div>
                        <p class="mt-1 whitespace-pre-line">{{ optional($s->purchase)->description ?? '—' }}</p>
                      </div>
                    </div>
                    <div class="mt-4 flex justify-end">
                      <button @click="open = false" class="px-3 py-1.5 bg-gray-100 rounded hover:bg-gray-200">Close</button>
                    </div>
                  </div>
                </div>
              </div>
            </td>
          </tr>
          @empty
          <tr><td colspan="5" class="px-2 sm:px-4 py-4 text-gray-500">No sales yet.</td></tr>
          @endforelse
        </tbody>
      </table>
    </div>
    <div class="p-3">{{ $sales->links() }}</div>
  </div>
</div>
@endsection
