@extends('layouts.app')

@section('content')
<div class="max-w-2xl mx-auto px-4">
  <h1 class="text-xl font-semibold text-gray-900 mb-3">Expense</h1>
  <div class="bg-white rounded border p-4 space-y-2">
    <div><span class="text-gray-600">Category:</span> <span class="font-medium">{{ ucfirst($expense->category) }}</span></div>
    <div><span class="text-gray-600">Amount:</span> <span class="font-medium">{{ number_format($expense->amount, 0) }}</span></div>
    <div><span class="text-gray-600">Date:</span> <span class="font-medium">{{ $expense->expense_date?->format('Y-m-d') }}</span></div>
    <div><span class="text-gray-600">Notes:</span> <span class="font-medium">{{ $expense->notes }}</span></div>
  </div>
  <div class="mt-3">
    <a href="{{ route('expenses.edit', $expense) }}" class="px-3 py-2 bg-gray-100 rounded">Edit</a>
    <a href="{{ route('expenses.index') }}" class="px-3 py-2">Back</a>
  </div>
</div>
@endsection
