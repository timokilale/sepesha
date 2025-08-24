@extends('layouts.app')

@section('content')
<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
  <div class="flex flex-col sm:flex-row sm:items-center justify-between mb-3 gap-3">
    <h1 class="text-xl font-semibold text-gray-900">Purchases</h1>
    <a href="{{ route('purchases.create') }}" class="px-3 py-2 bg-indigo-600 text-white rounded hover:bg-indigo-700 text-center">Add Purchase</a>
  </div>

  <div class="bg-white rounded border overflow-hidden">
    <div class="overflow-x-auto">
      <table class="data-table min-w-full divide-y divide-gray-200">
        <thead class="bg-gray-50">
          <tr>
            <th class="px-2 sm:px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Item</th>
            <th class="px-2 sm:px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Total</th>
            <th class="px-2 sm:px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase hidden sm:table-cell">Qty</th>
            <th class="px-2 sm:px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase hidden md:table-cell">Date</th>
            <th class="px-2 sm:px-4 py-2 text-right">Actions</th>
          </tr>
        </thead>
        <tbody class="bg-white divide-y divide-gray-200">
          @forelse ($purchases as $p)
          <tr>
            <td class="px-2 sm:px-4 py-2 text-gray-800">
              <div class="font-medium">{{ $p->item_name }}</div>
              <div class="text-sm text-gray-500 sm:hidden">Qty: {{ $p->quantity }} • {{ $p->purchase_date->format('M d, Y') }}</div>
            </td>
            <td class="px-2 sm:px-4 py-2">
              <div class="font-semibold">TZS {{ number_format($p->cost_price * $p->quantity, 2) }}</div>
              <div class="text-xs text-gray-500">Unit: TZS {{ number_format($p->cost_price, 2) }}</div>
            </td>
            <td class="px-2 sm:px-4 py-2 hidden sm:table-cell">{{ $p->quantity }}</td>
            <td class="px-2 sm:px-4 py-2 hidden md:table-cell">{{ $p->purchase_date->format('Y-m-d') }}</td>
            <td class="px-2 sm:px-4 py-2 text-right">
              <div x-data="{ open: false }" class="flex flex-col items-end gap-1 justify-end">
                <button @click="open = true" class="text-gray-700 text-sm hover:text-gray-900">View</button>
                <a href="{{ route('purchases.edit.single', ['id' => $p->id]) }}" class="text-indigo-600 text-sm hover:text-indigo-800">Edit</a>
                <form action="{{ route('purchases.destroy.single', ['id' => $p->id]) }}" method="POST" class="inline">
                  @csrf
                  @method('DELETE')
                  <button class="text-red-600 text-sm hover:text-red-800" onclick="return confirm('Delete this purchase?')">Delete</button>
                </form>

                <!-- Modal -->
                <div x-show="open" x-transition class="fixed inset-0 z-50 flex items-center justify-center">
                  <div class="absolute inset-0 bg-black/30" @click="open = false"></div>
                  <div class="relative bg-white w-full max-w-md rounded shadow-lg p-4 mx-4">
                    <div class="flex items-center justify-between mb-2">
                      <h3 class="text-lg font-semibold text-gray-900">Purchase Details</h3>
                      <button @click="open = false" class="text-gray-500 hover:text-gray-700">&times;</button>
                    </div>
                    <div class="space-y-2 text-sm text-gray-800">
                      <div class="flex justify-between"><span class="text-gray-500">Item</span><span class="font-medium">{{ $p->item_name }}</span></div>
                      <div class="flex justify-between"><span class="text-gray-500">Unit cost</span><span class="font-medium">TZS {{ number_format($p->cost_price,2) }}</span></div>
                      <div class="flex justify-between"><span class="text-gray-500">Quantity</span><span class="font-medium">{{ $p->quantity }}</span></div>
                      <div class="flex justify-between"><span class="text-gray-500">Total</span><span class="font-medium">TZS {{ number_format($p->cost_price * $p->quantity,2) }}</span></div>
                      <div class="flex justify-between"><span class="text-gray-500">Date</span><span class="font-medium">{{ $p->purchase_date->format('Y-m-d') }}</span></div>
                      <div>
                        <div class="text-gray-500">Description</div>
                        <p class="mt-1 whitespace-pre-line">{{ $p->description ?? '—' }}</p>
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
          <tr><td colspan="5" class="px-2 sm:px-4 py-4 text-gray-500">No purchases yet.</td></tr>
          @endforelse
        </tbody>
      </table>
    </div>
    <div class="p-3">{{ $purchases->links() }}</div>
  </div>
</div>
@endsection
