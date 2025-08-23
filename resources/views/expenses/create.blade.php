@extends('layouts.app')

@section('content')
<div class="max-w-2xl mx-auto px-4">
  <h1 class="text-xl font-semibold text-gray-900 mb-3">Add Expense</h1>
  <div class="bg-white rounded border p-4">
    <form method="POST" action="{{ route('expenses.store') }}" class="space-y-4">
      @csrf
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div>
          <label class="block text-sm text-gray-700 mb-1">Category</label>
          <select name="category" class="w-full border rounded px-3 py-2" required>
            <option value="">-- Select --</option>
            @foreach (['water','electricity','waste','salaries','taxes','rent','other'] as $cat)
              <option value="{{ $cat }}" @selected(old('category')===$cat)>{{ ucfirst($cat) }}</option>
            @endforeach
          </select>
          @error('category')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>
        <div>
          <label class="block text-sm text-gray-700 mb-1">Amount</label>
          <input type="number" min="0" step="0.01" name="amount" value="{{ old('amount') }}" class="w-full border rounded px-3 py-2" required />
          @error('amount')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>
        <div>
          <label class="block text-sm text-gray-700 mb-1">Date</label>
          <input type="date" name="expense_date" value="{{ old('expense_date') }}" class="w-full border rounded px-3 py-2" required />
          @error('expense_date')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>
      </div>
      <div>
        <label class="block text-sm text-gray-700 mb-1">Notes</label>
        <textarea name="notes" class="w-full border rounded px-3 py-2" rows="3">{{ old('notes') }}</textarea>
      </div>
      <div class="flex gap-2">
        <button class="px-3 py-2 bg-indigo-600 text-white rounded">Save</button>
        <a href="{{ route('expenses.index') }}" class="px-3 py-2 bg-gray-100 rounded">Cancel</a>
      </div>
    </form>
  </div>
</div>
@endsection
