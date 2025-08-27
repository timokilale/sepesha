@extends('layouts.app')

@section('content')
<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
  <div class="flex flex-col sm:flex-row sm:items-center justify-between mb-3 gap-3">
    <h1 class="text-xl font-semibold text-gray-900">Sales</h1>
    <a href="{{ route('sales.create') }}" class="px-3 py-2 bg-green-600 text-white rounded hover:bg-green-700 text-center">Add Sale</a>
  </div>

  <!-- Filters -->
  <div x-data="{ open: {{ request('start_date') || request('end_date') || request('sort') ? 'true' : 'false' }} }" class="mb-3">
    <button type="button" @click="open = !open" class="inline-flex items-center gap-2 px-3 py-1.5 border rounded bg-white hover:bg-gray-50 text-sm">
      Filters
      <svg x-show="!open" xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M5.23 7.21a.75.75 0 011.06.02L10 10.94l3.71-3.71a.75.75 0 111.06 1.06l-4.24 4.24a.75.75 0 01-1.06 0L5.21 8.29a.75.75 0 01.02-1.08z" clip-rule="evenodd"/></svg>
      <svg x-show="open" xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M14.77 12.79a.75.75 0 01-1.06-.02L10 9.06l-3.71 3.71a.75.75 0 11-1.06-1.06l4.24-4.24a.75.75 0 011.06 0l4.24 4.24c.29.29.3.77.02 1.08z" clip-rule="evenodd"/></svg>
      @if(request('start_date') || request('end_date') || request('sort'))
        <span class="ml-1 inline-flex items-center px-2 py-0.5 rounded bg-green-50 text-green-700 text-xs">Active</span>
      @endif
    </button>
    <div x-show="open" x-collapse class="mt-2">
      <form method="GET" action="{{ route('sales.index') }}" class="bg-white rounded border p-3">
        <div class="grid grid-cols-1 sm:grid-cols-5 gap-2">
          <div class="sm:col-span-2">
            <label class="block text-xs text-gray-600 mb-1">Start date</label>
            <input type="date" name="start_date" value="{{ request('start_date') }}" class="w-full border rounded px-2 py-1" />
          </div>
          <div class="sm:col-span-2">
            <label class="block text-xs text-gray-600 mb-1">End date</label>
            <input type="date" name="end_date" value="{{ request('end_date') }}" class="w-full border rounded px-2 py-1" />
          </div>
          <div>
            <label class="block text-xs text-gray-600 mb-1">Sort</label>
            <select name="sort" class="w-full border rounded px-2 py-1">
              <option value="" @selected(!request('sort'))>Latest</option>
              <option value="name_asc" @selected(request('sort')==='name_asc')>Name A–Z</option>
              <option value="name_desc" @selected(request('sort')==='name_desc')>Name Z–A</option>
            </select>
          </div>
        </div>
        <div class="mt-2 flex gap-2">
          <button class="px-3 py-1.5 bg-green-600 text-white rounded">Apply</button>
          <a href="{{ route('sales.index') }}" class="px-3 py-1.5 bg-gray-100 rounded">Reset</a>
        </div>
      </form>
    </div>
  </div>

  <div class="bg-white rounded border overflow-hidden">
    <div class="overflow-x-auto">
      <table class="data-table min-w-full divide-y divide-gray-200">
        <thead class="bg-gray-50">
          <tr>
            <th class="px-2 sm:px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Item</th>
            <th class="px-2 sm:px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase hidden sm:table-cell">Price</th>
            <th class="px-2 sm:px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase hidden sm:table-cell">Qty</th>
            <th class="px-2 sm:px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Total</th>
            <th class="px-2 sm:px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase hidden md:table-cell">Date</th>
            <th class="px-2 sm:px-4 py-2 text-right">Actions</th>
          </tr>
        </thead>
        <tbody class="bg-white divide-y divide-gray-200">
          @forelse ($sales as $s)
          <tr>
            <td class="px-2 sm:px-4 py-2 text-gray-800">
              <div class="font-medium">{{ $s->purchase->item_name }}</div>
            </td>
            <td class="px-2 sm:px-4 py-2 font-medium hidden sm:table-cell">TZS {{ number_format($s->display_price,2) }}</td>
            <td class="px-2 sm:px-4 py-2 hidden sm:table-cell">{{ $s->display_quantity }} {{ $s->display_unit }}</td>
            <td class="px-2 sm:px-4 py-2">TZS {{ number_format($s->quantity_sold * $s->selling_price, 2) }}</td>
            <td class="px-2 sm:px-4 py-2 hidden md:table-cell">{{ $s->sale_date->format('Y-m-d') }}</td>
            <td class="px-2 sm:px-4 py-2 text-right">
              <div x-data="{ open: false }" class="flex flex-col items-end gap-1 justify-end">
                <button @click="open = true" class="text-gray-700 text-sm hover:text-gray-900">View</button>
                {{-- <a href="{{ route('sales.edit.single', ['id' => $s->id]) }}" class="text-indigo-600 text-sm hover:text-indigo-800">Edit</a> --}}
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
                      <div class="flex justify-between"><span class="text-gray-500">Selling Price</span><span class="font-medium">TZS {{ number_format($s->display_price,2) }} per {{ $s->display_unit }}</span></div>
                      <div class="flex justify-between"><span class="text-gray-500">Quantity Sold</span><span class="font-medium">{{ $s->display_quantity }} {{ $s->display_unit }}</span></div>
                      <div class="flex justify-between"><span class="text-gray-500">Total</span><span class="font-medium">TZS {{ number_format($s->quantity_sold * $s->selling_price, 2) }}</span></div>
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
          <tr><td colspan="6" class="px-2 sm:px-4 py-4 text-gray-500">No sales yet.</td></tr>
          @endforelse
        </tbody>
      </table>
    </div>
    <div class="p-3">{{ $sales->links() }}</div>
  </div>
</div>
@endsection
