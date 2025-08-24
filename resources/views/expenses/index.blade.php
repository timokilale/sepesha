@extends('layouts.app')

@section('content')
<div class="max-w-4xl mx-auto px-4">
  <div class="flex items-center justify-between mb-1">
    <h1 class="text-xl font-semibold text-gray-900">Expenses</h1>
    <a href="{{ route('expenses.create') }}" class="px-3 py-2 bg-indigo-600 text-white rounded">Add Expense</a>
  </div>
  <p class="text-xs text-gray-500 mb-3">Track money you spent (rent, transport, etc.).</p>
  <div class="bg-white rounded border">
    <table class="w-full text-sm">
      <thead>
        <tr class="text-left border-b">
          <th class="p-3">Date</th>
          <th class="p-3">Category</th>
          <th class="p-3">Amount</th>
          <th class="p-3"></th>
        </tr>
      </thead>
      <tbody>
        @forelse($expenses as $expense)
        <tr class="border-b">
          <td class="p-3">{{ $expense->expense_date?->format('Y-m-d') }}</td>
          <td class="p-3">{{ ucfirst($expense->category) }}</td>
          <td class="p-3">{{ number_format($expense->amount, 0) }}</td>
          <td class="p-3 text-right">
            <a class="text-indigo-600" href="{{ route('expenses.show.single', $expense) }}">View</a>
            <span class="mx-1">·</span>
            <a class="text-gray-700" href="{{ route('expenses.edit.single', $expense) }}">Edit</a>
            <span class="mx-1">·</span>
            <form action="{{ route('expenses.destroy.single', $expense) }}" method="POST" class="inline" onsubmit="return confirm('Delete this expense?')">
              @csrf
              @method('DELETE')
              <button class="text-red-600">Delete</button>
            </form>
          </td>
        </tr>
        @empty
        <tr><td colspan="4" class="p-3 text-center text-gray-500">No expenses yet.</td></tr>
        @endforelse
      </tbody>
    </table>
  </div>
  <div class="mt-3">{{ $expenses->links() }}</div>
</div>
@endsection
