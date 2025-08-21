@extends('layouts.app')

@section('content')
<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
  <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-6 mb-6">
    <div class="bg-white overflow-hidden shadow-sm rounded-lg p-6">
      <div class="text-gray-500 text-sm">Total Purchases</div>
      <div class="text-2xl font-bold text-gray-800 mt-2">${{ number_format($totalPurchases, 2) }}</div>
    </div>
    <div class="bg-white overflow-hidden shadow-sm rounded-lg p-6">
      <div class="text-gray-500 text-sm">Total Sales</div>
      <div class="text-2xl font-bold text-gray-800 mt-2">${{ number_format($totalSales, 2) }}</div>
    </div>
    <div class="bg-white overflow-hidden shadow-sm rounded-lg p-6">
      <div class="text-gray-500 text-sm">Profit / Loss</div>
      <div class="text-2xl font-bold mt-2 {{ $totalProfit >= 0 ? 'text-green-600' : 'text-red-600' }}">
        ${{ number_format($totalProfit, 2) }}
      </div>
    </div>
  </div>

  <div class="grid grid-cols-1 lg:grid-cols-3 gap-4 lg:gap-6">
    <div class="bg-white overflow-hidden shadow-sm rounded-lg p-6 lg:col-span-2">
      <div class="flex items-center justify-between mb-4">
        <h2 class="text-lg font-semibold text-gray-800">Income vs Expenses (Last 6 months)</h2>
      </div>
      <canvas id="incomeExpenseChart" height="110"></canvas>
    </div>

    <div class="bg-white overflow-hidden shadow-sm rounded-lg p-6">
      <h2 class="text-lg font-semibold text-gray-800 mb-4">Quick Actions</h2>
      <div class="space-y-3">
        <a href="{{ route('purchases.create') }}" class="w-full inline-flex items-center justify-center px-4 py-2 bg-indigo-600 text-white rounded hover:bg-indigo-700">Add Purchase</a>
        <a href="{{ route('sales.create') }}" class="w-full inline-flex items-center justify-center px-4 py-2 bg-green-600 text-white rounded hover:bg-green-700">Add Sale</a>
      </div>
    </div>
  </div>

  <div class="grid grid-cols-1 lg:grid-cols-2 gap-4 lg:gap-6 mt-6">
    <div class="bg-white overflow-hidden shadow-sm rounded-lg p-6">
      <div class="flex items-center justify-between mb-4">
        <h2 class="text-lg font-semibold text-gray-800">Recent Purchases</h2>
      </div>
      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-2 sm:px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Item</th>
              <th class="px-2 sm:px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Cost</th>
              <th class="px-2 sm:px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase hidden sm:table-cell">Qty</th>
              <th class="px-2 sm:px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase hidden md:table-cell">Date</th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            @forelse ($recentPurchases as $p)
            <tr>
              <td class="px-2 sm:px-4 py-2 text-gray-800">
                <div class="font-medium">{{ $p->item_name }}</div>
                <div class="text-sm text-gray-500 sm:hidden">Qty: {{ $p->quantity }} • {{ $p->purchase_date->format('M d') }}</div>
              </td>
              <td class="px-2 sm:px-4 py-2 font-medium">${{ number_format($p->cost_price, 2) }}</td>
              <td class="px-2 sm:px-4 py-2 hidden sm:table-cell">{{ $p->quantity }}</td>
              <td class="px-2 sm:px-4 py-2 hidden md:table-cell">{{ $p->purchase_date->format('Y-m-d') }}</td>
            </tr>
            @empty
            <tr><td colspan="4" class="px-2 sm:px-4 py-3 text-gray-500">No purchases yet.</td></tr>
            @endforelse
          </tbody>
        </table>
      </div>
    </div>

    <div class="bg-white overflow-hidden shadow-sm rounded-lg p-6">
      <div class="flex items-center justify-between mb-4">
        <h2 class="text-lg font-semibold text-gray-800">Recent Sales</h2>
      </div>
      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-2 sm:px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Item</th>
              <th class="px-2 sm:px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Price</th>
              <th class="px-2 sm:px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase hidden sm:table-cell">Qty</th>
              <th class="px-2 sm:px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase hidden md:table-cell">Date</th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            @forelse ($recentSales as $s)
            <tr>
              <td class="px-2 sm:px-4 py-2 text-gray-800">
                <div class="font-medium">{{ $s->purchase->item_name }}</div>
                <div class="text-sm text-gray-500 sm:hidden">Qty: {{ $s->quantity_sold }} • {{ $s->sale_date->format('M d') }}</div>
              </td>
              <td class="px-2 sm:px-4 py-2 font-medium">${{ number_format($s->selling_price, 2) }}</td>
              <td class="px-2 sm:px-4 py-2 hidden sm:table-cell">{{ $s->quantity_sold }}</td>
              <td class="px-2 sm:px-4 py-2 hidden md:table-cell">{{ $s->sale_date->format('Y-m-d') }}</td>
            </tr>
            @empty
            <tr><td colspan="4" class="px-2 sm:px-4 py-3 text-gray-500">No sales yet.</td></tr>
            @endforelse
          </tbody>
        </table>
      </div>
    </div>
  </div>
</div>

<script>
  const ctx = document.getElementById('incomeExpenseChart').getContext('2d');
  new Chart(ctx, {
    type: 'bar',
    data: {
      labels: @json($monthlyData['months']),
      datasets: [
        { label: 'Purchases', backgroundColor: '#ef4444', data: @json($monthlyData['purchases']) },
        { label: 'Sales', backgroundColor: '#22c55e', data: @json($monthlyData['sales']) }
      ]
    },
    options: {
      responsive: true,
      scales: { y: { beginAtZero: true } }
    }
  });
</script>
@endsection
