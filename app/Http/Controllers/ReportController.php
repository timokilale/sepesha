<?php

namespace App\Http\Controllers;

use App\Models\Purchase;
use Illuminate\Support\Facades\Auth;

class ReportController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
    }

    public function index()
    {
        $user = Auth::user();

        // Load purchases with sales and optional item
        $purchases = $user->purchases()->with(['sales', 'item'])->get();

        $perItem = [];

        foreach ($purchases as $purchase) {
            $key = $purchase->item?->id ? ('item:' . $purchase->item->id) : ('name:' . $purchase->item_name);
            $label = $purchase->item?->name ?? $purchase->item_name;

            if (!isset($perItem[$key])) {
                $perItem[$key] = [
                    'label' => $label,
                    'units_purchased' => 0,
                    'units_sold' => 0,
                    'revenue' => 0.0,
                    'cogs' => 0.0,
                    'profit' => 0.0,
                ];
            }

            $unitsPurchased = (int) $purchase->quantity;
            $unitsSold = (int) $purchase->sales->sum('quantity_sold');
            $revenue = (float) $purchase->sales->sum(function ($s) { return $s->selling_price * $s->quantity_sold; });
            $cogs = (float) ($purchase->cost_price * $unitsSold);

            $perItem[$key]['units_purchased'] += $unitsPurchased;
            $perItem[$key]['units_sold'] += $unitsSold;
            $perItem[$key]['revenue'] += $revenue;
            $perItem[$key]['cogs'] += $cogs;
            $perItem[$key]['profit'] = $perItem[$key]['revenue'] - $perItem[$key]['cogs'];
        }

        // Expenses summary
        $expenses = $user->expenses()->get();
        $expenseTotals = [
            'total' => (float) $expenses->sum('amount'),
            'by_category' => $expenses->groupBy('category')->map(fn($g) => (float) $g->sum('amount')),
        ];

        // You likely have a view to render; if not, you can return JSON for now.
        if (view()->exists('reports.index')) {
            return view('reports.index', [
                'perItem' => $perItem,
                'expenseTotals' => $expenseTotals,
            ]);
        }

        return response()->json([
            'perItem' => array_values($perItem),
            'expenses' => [
                'total' => $expenseTotals['total'],
                'by_category' => $expenseTotals['by_category'],
            ],
        ]);
    }
}
