<?php

namespace App\Http\Controllers;

use App\Models\Expense;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class ExpenseController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
    }

    public function index()
    {
        $expenses = Auth::user()->expenses()->orderBy('expense_date', 'desc')->paginate(10);
        return view('expenses.index', compact('expenses'));
    }

    public function create()
    {
        return view('expenses.create');
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'category' => 'required|string|max:100',
            'amount' => 'required|numeric|min:0',
            'expense_date' => 'required|date',
            'notes' => 'nullable|string',
        ]);
        $validated['user_id'] = Auth::id();
        Expense::create($validated);
        return redirect()->route('expenses.index')->with('success', 'Expense recorded');
    }

    public function show(Expense $expense)
    {
        abort_if($expense->user_id !== Auth::id(), 403);
        return view('expenses.show', compact('expense'));
    }

    public function edit(Expense $expense)
    {
        abort_if($expense->user_id !== Auth::id(), 403);
        return view('expenses.edit', compact('expense'));
    }

    public function update(Request $request, Expense $expense)
    {
        abort_if($expense->user_id !== Auth::id(), 403);
        $validated = $request->validate([
            'category' => 'required|string|max:100',
            'amount' => 'required|numeric|min:0',
            'expense_date' => 'required|date',
            'notes' => 'nullable|string',
        ]);
        $expense->update($validated);
        return redirect()->route('expenses.index')->with('success', 'Expense updated');
    }

    public function destroy(Expense $expense)
    {
        abort_if($expense->user_id !== Auth::id(), 403);
        $expense->delete();
        return redirect()->route('expenses.index')->with('success', 'Expense deleted');
    }
}
