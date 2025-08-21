@extends('layouts.app')

@section('content')
<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
  <div class="flex flex-col sm:flex-row sm:items-center justify-between mb-4 gap-3">
    <h1 class="text-2xl font-bold text-gray-800">Purchases</h1>
    <a href="{{ route('purchases.create') }}" class="px-4 py-2 bg-indigo-600 text-white rounded hover:bg-indigo-700 text-center">Add Purchase</a>
  </div>

  <div class="bg-white rounded shadow overflow-hidden">
    <div class="overflow-x-auto">
      <table class="min-w-full divide-y divide-gray-200">
        <thead class="bg-gray-50">
          <tr>
            <th class="px-2 sm:px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Item</th>
            <th class="px-2 sm:px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Cost</th>
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
            <td class="px-2 sm:px-4 py-2 font-medium">${{ number_format($p->cost_price,2) }}</td>
            <td class="px-2 sm:px-4 py-2 hidden sm:table-cell">{{ $p->quantity }}</td>
            <td class="px-2 sm:px-4 py-2 hidden md:table-cell">{{ $p->purchase_date->format('Y-m-d') }}</td>
            <td class="px-2 sm:px-4 py-2 text-right">
              <div class="flex flex-col sm:flex-row gap-1 sm:gap-2 justify-end">
                <a href="{{ route('purchases.edit', $p) }}" class="text-indigo-600 text-sm hover:text-indigo-800">Edit</a>
                <form action="{{ route('purchases.destroy', $p) }}" method="POST" class="inline">
                  @csrf
                  @method('DELETE')
                  <button class="text-red-600 text-sm hover:text-red-800" onclick="return confirm('Delete this purchase?')">Delete</button>
                </form>
              </div>
            </td>
          </tr>
          @empty
          <tr><td colspan="5" class="px-2 sm:px-4 py-4 text-gray-500">No purchases yet.</td></tr>
          @endforelse
        </tbody>
      </table>
    </div>
    <div class="p-4">{{ $purchases->links() }}</div>
  </div>
</div>
@endsection
