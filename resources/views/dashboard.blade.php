@extends('layouts.app')

@section('content')
<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
  <!-- Quick actions on Home -->
  <div class="mb-4 flex items-center gap-2">
    <a href="{{ route('purchases.create') }}" class="px-3 py-2 text-sm rounded border bg-white hover:bg-gray-50">+ Add purchase</a>
    <a href="{{ route('sales.create') }}" class="px-3 py-2 text-sm rounded border bg-white hover:bg-gray-50">+ Add sale</a>
  </div>

  <!-- Totals Row -->
  <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 sm:gap-6">
    <div class="border rounded p-4 bg-white">
      <div class="text-gray-500 text-xs uppercase tracking-wide">Total Purchases</div>
      <div class="text-xl font-semibold text-gray-900 mt-1">${{ number_format($totalPurchases, 2) }}</div>
    </div>
    <div class="border rounded p-4 bg-white">
      <div class="text-gray-500 text-xs uppercase tracking-wide">Total Sales</div>
      <div class="text-xl font-semibold text-gray-900 mt-1">${{ number_format($totalSales, 2) }}</div>
    </div>
    <div class="border rounded p-4 bg-white">
      <div class="text-gray-500 text-xs uppercase tracking-wide">Profit / Loss</div>
      <div class="text-xl font-semibold mt-1 {{ $totalProfit >= 0 ? 'text-green-600' : 'text-red-600' }}">${{ number_format($totalProfit, 2) }}</div>
    </div>
  </div>
</div>
@endsection
