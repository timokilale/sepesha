@extends('layouts.app')

@section('content')
<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8" x-data="{ open: false, adv: false }">
  <div class="flex items-center justify-between mb-2">
    <h1 class="text-lg font-semibold text-gray-800">Insights</h1>
    <button type="button" @click="open = !open" class="inline-flex items-center gap-1 px-3 py-1.5 rounded border text-sm text-gray-700 hover:bg-gray-100">
      Filters
      <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M5.23 7.21a.75.75 0 011.06.02L10 10.94l3.71-3.71a.75.75 0 111.06 1.06l-4.24 4.24a.75.75 0 01-1.06 0L5.21 8.29a.75.75 0 01.02-1.08z" clip-rule="evenodd"/></svg>
    </button>
  </div>

  <form method="GET" action="{{ route('charts.index') }}" x-show="open" x-transition class="bg-white border rounded p-4 mb-4 grid grid-cols-1 sm:grid-cols-6 gap-3" x-data="{ err: '' }" @submit.prevent="
      const minVal = parseFloat($refs.ymin.value);
      const maxVal = parseFloat($refs.ymax.value);
      const hasMin = !Number.isNaN(minVal);
      const hasMax = !Number.isNaN(maxVal);
      if (hasMin && hasMax && minVal > maxVal) { err = 'Start amount cannot be greater than End amount.'; return; }
      err = '';
      open = false;
      $nextTick(() => $el.submit());
    ">
    <div class="sm:col-span-2">
      <label class="block text-xs text-gray-600 mb-1">Start date</label>
      <input type="month" name="start_date" value="{{ substr($range['start_date'],0,7) }}" class="w-full border rounded px-3 py-2" />
    </div>
    <div class="sm:col-span-2">
      <label class="block text-xs text-gray-600 mb-1">End date</label>
      <input type="month" name="end_date" value="{{ substr($range['end_date'],0,7) }}" class="w-full border rounded px-3 py-2" />
    </div>
    <div class="sm:col-span-2 flex items-end">
      <button type="button" @click="adv = !adv" class="px-3 py-2 border rounded text-sm text-gray-700 hover:bg-gray-50" x-text="adv ? 'Hide advanced' : 'Show advanced'"></button>
    </div>
    <div class="sm:col-span-3" x-show="adv">
      <label class="block text-xs text-gray-600 mb-1">Start amount</label>
      <input x-ref="ymin" type="number" step="0.01" name="y_min" value="{{ $yMin !== null ? $yMin : '' }}" placeholder="{{ number_format($currentMin, 2, '.', ',') }}" class="w-full border rounded px-3 py-2" />
      <p class="mt-1 text-[11px] text-gray-500">Current start: {{ number_format($currentMin, 2, '.', ',') }} | Data min: {{ number_format($dataMin, 2, '.', ',') }}</p>
    </div>
    <div class="sm:col-span-3" x-show="adv">
      <label class="block text-xs text-gray-600 mb-1">End amount</label>
      <input x-ref="ymax" type="number" step="0.01" name="y_max" value="{{ $yMax !== null ? $yMax : '' }}" placeholder="{{ number_format($currentMax, 2, '.', ',') }}" class="w-full border rounded px-3 py-2" />
      <p class="mt-1 text-[11px] text-gray-500">Current end: {{ number_format($currentMax, 2, '.', ',') }} | Data max: {{ number_format($dataMax, 2, '.', ',') }}</p>
    </div>
    <div class="sm:col-span-6">
      <template x-if="err">
        <div class="mb-2 text-sm text-red-600">{{ '{' }}{ err }{{ '}' }}</div>
      </template>
      <div class="flex items-center justify-end gap-2">
        <a href="{{ route('charts.index') }}" class="px-4 py-2 border rounded text-sm text-gray-700 hover:bg-gray-50">Reset</a>
        <button type="submit" class="px-4 py-2 bg-indigo-600 text-white rounded hover:bg-indigo-700">Apply</button>
      </div>
    </div>
  </form>

  <section class="border rounded p-4 bg-white">
    <div class="flex items-center justify-between mb-3">
      <h2 class="text-sm font-medium text-gray-700">Income vs Expenses</h2>
    </div>
    <canvas id="rangeChart" height="160"></canvas>
    <!-- Mobile month navigator (below chart) -->
    <div class="sm:hidden mt-3 flex items-center justify-between">
      <button type="button" id="prevMonthBtn" class="px-3 py-1.5 text-xs border rounded"></button>
      <button type="button" id="nextMonthBtn" class="px-3 py-1.5 text-xs border rounded"></button>
    </div>
  </section>
</div>

<script>
  const canvas = document.getElementById('rangeChart');
  const ctx = canvas.getContext('2d');
  const yMin = @json($yMin);
  const yMax = @json($yMax);

  // Prepare datasets and labels; trim for mobile
  const rawLabels = @json($labels);
  const rawPurchases = @json($purchases);
  const rawSales = @json($sales);
  const rawExpenses = @json($expenses);

  const isMobile = window.matchMedia('(max-width: 639px)').matches; // Tailwind sm breakpoint
  let labels = rawLabels;
  let purchases = rawPurchases;
  let sales = rawSales;
  let expenses = rawExpenses;
  if (isMobile) {
    const start = Math.max(0, rawLabels.length - 1);
    labels = rawLabels.slice(start);
    purchases = rawPurchases.slice(start);
    sales = rawSales.slice(start);
    expenses = rawExpenses.slice(start);
    // Increase height for readability on mobile
    canvas.height = 300;
  }

  new Chart(ctx, {
    type: 'bar',
    data: {
      labels,
      datasets: [
        { label: 'Purchases', backgroundColor: '#ef4444', data: purchases },
        { label: 'Sales', backgroundColor: '#22c55e', data: sales },
        { label: 'Expenses', backgroundColor: '#3b82f6', data: expenses }
      ]
    },
    options: {
      responsive: true,
      scales: {
        y: {
          beginAtZero: yMin === null && yMax === null,
          min: yMin ?? undefined,
          max: yMax ?? undefined,
        }
      }
    }
  });

  // Mobile month navigation: adjusts start/end months and reloads
  if (isMobile) {
    const startDateStr = @json($range['start_date']); // e.g., '2025-01-01'
    const endDateStr = @json($range['end_date']);
    // Use end date as the current month cursor
    function yyyymm(date) {
      const y = date.getFullYear();
      const m = (date.getMonth() + 1).toString().padStart(2, '0');
      return `${y}-${m}`;
    }
    function shiftMonth(isoDateStr, delta) {
      const d = new Date(isoDateStr);
      d.setMonth(d.getMonth() + delta);
      return yyyymm(d);
    }
    function monthName(isoDateStr) {
      const d = new Date(isoDateStr);
      return d.toLocaleString(undefined, { month: 'long', year: 'numeric' });
    }
    function goToMonth(ym) {
      const params = new URLSearchParams(window.location.search);
      // Lock to a single month: start = end = ym
      params.set('start_date', ym);
      params.set('end_date', ym);
      window.location.search = params.toString();
    }
    const currentYM = yyyymm(new Date(endDateStr));
    const prevBtn = document.getElementById('prevMonthBtn');
    const nextBtn = document.getElementById('nextMonthBtn');
    if (prevBtn && nextBtn) {
      // Set button labels with month names
      const prevYM = shiftMonth(`${currentYM}-01`, -1);
      const nextYM = shiftMonth(`${currentYM}-01`, 1);
      prevBtn.textContent = `← ${monthName(`${prevYM}-01`)}`;
      nextBtn.textContent = `${monthName(`${nextYM}-01`)} →`;

      prevBtn.addEventListener('click', () => {
        const prev = shiftMonth(`${currentYM}-01`, -1);
        goToMonth(prev);
      });
      nextBtn.addEventListener('click', () => {
        const next = shiftMonth(`${currentYM}-01`, 1);
        goToMonth(next);
      });
    }
  }
</script>
@endsection
