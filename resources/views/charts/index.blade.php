@extends('layouts.app')

@section('content')
<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
  <div class="flex items-center justify-between mb-4">
    <h1 class="text-lg font-semibold text-gray-800">Charts</h1>
  </div>

  <form method="GET" action="{{ route('charts.index') }}" class="bg-white border rounded p-4 mb-4 grid grid-cols-1 sm:grid-cols-5 gap-3">
    <div class="sm:col-span-2">
      <label class="block text-xs text-gray-600 mb-1">Start date</label>
      <input type="month" name="start_date" value="{{ substr($range['start_date'],0,7) }}" class="w-full border rounded px-3 py-2" />
    </div>
    <div class="sm:col-span-2">
      <label class="block text-xs text-gray-600 mb-1">End date</label>
      <input type="month" name="end_date" value="{{ substr($range['end_date'],0,7) }}" class="w-full border rounded px-3 py-2" />
    </div>
    <div class="sm:col-span-1 flex items-end">
      <button class="w-full sm:w-auto px-4 py-2 bg-indigo-600 text-white rounded hover:bg-indigo-700">Apply</button>
    </div>
  </form>

  <section class="border rounded p-4 bg-white">
    <h2 class="text-sm font-medium text-gray-700 mb-3">Income vs Expenses</h2>
    <canvas id="rangeChart" height="160"></canvas>
  </section>
</div>

<script>
  const ctx = document.getElementById('rangeChart').getContext('2d');
  new Chart(ctx, {
    type: 'bar',
    data: {
      labels: @json($labels),
      datasets: [
        { label: 'Purchases', backgroundColor: '#ef4444', data: @json($purchases) },
        { label: 'Sales', backgroundColor: '#22c55e', data: @json($sales) }
      ]
    },
    options: { responsive: true, scales: { y: { beginAtZero: true } } }
  });
</script>
@endsection
