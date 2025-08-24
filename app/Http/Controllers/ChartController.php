<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Carbon\CarbonPeriod;
use Carbon\Carbon;

class ChartController extends Controller
{
    public function index(Request $request)
    {
        $user = Auth::user();

        // Parse date range; default: last 6 full months including current month
        $start = $request->input('start_date');
        $end = $request->input('end_date');

        if ($start && $end) {
            $startDate = Carbon::parse($start)->startOfMonth();
            $endDate = Carbon::parse($end)->endOfMonth();
            if ($endDate->lessThan($startDate)) {
                [$startDate, $endDate] = [$endDate->copy()->startOfMonth(), $startDate->copy()->endOfMonth()];
            }
        } else {
            $startDate = Carbon::now()->subMonths(5)->startOfMonth();
            $endDate = Carbon::now()->endOfMonth();
        }

        $period = CarbonPeriod::create($startDate, '1 month', $endDate);

        $labels = [];
        $purchases = [];
        $sales = [];
        $expenses = [];

        foreach ($period as $month) {
            $labels[] = $month->format('M Y');

            // Purchases: unit cost × quantity for the month
            $monthlyPurchases = (float) $user->purchases()
                ->whereYear('purchase_date', $month->year)
                ->whereMonth('purchase_date', $month->month)
                ->get(['cost_price','quantity'])
                ->sum(function ($p) { return (float) $p->cost_price * (int) $p->quantity; });

            $monthlySales = (float) $user->sales()
                ->whereYear('sale_date', $month->year)
                ->whereMonth('sale_date', $month->month)
                ->get(['selling_price', 'quantity_sold'])
                ->sum(function ($sale) {
                    return (float) $sale->selling_price * (int) $sale->quantity_sold;
                });

            // Expenses: sum of expense amounts for the month
            $monthlyExpenses = (float) $user->expenses()
                ->whereYear('expense_date', $month->year)
                ->whereMonth('expense_date', $month->month)
                ->sum('amount');

            $purchases[] = $monthlyPurchases;
            $sales[] = $monthlySales;
            $expenses[] = $monthlyExpenses;
        }

        $range = [
            'start_date' => $startDate->toDateString(),
            'end_date' => $endDate->toDateString(),
        ];

        // Compute dataset bounds (after arrays are populated)
        $allValues = array_merge($purchases, $sales, $expenses);
        $dataMin = !empty($allValues) ? (float) min($allValues) : 0.0;
        $dataMax = !empty($allValues) ? (float) max($allValues) : 0.0;

        // Optional Y axis bounds
        $yMin = $request->filled('y_min') && is_numeric($request->input('y_min'))
            ? (float) $request->input('y_min')
            : null;
        $yMax = $request->filled('y_max') && is_numeric($request->input('y_max'))
            ? (float) $request->input('y_max')
            : null;

        // Safety: if both provided and out of order, swap
        if ($yMin !== null && $yMax !== null && $yMin > $yMax) {
            [$yMin, $yMax] = [$yMax, $yMin];
        }

        // Effective scale the chart will use
        $currentMin = $yMin !== null ? $yMin : 0.0; // we use beginAtZero when unset
        $currentMax = $yMax !== null ? $yMax : $dataMax;

        return view('charts.index', [
            'labels' => $labels,
            'purchases' => $purchases,
            'sales' => $sales,
            'expenses' => $expenses,
            'range' => $range,
            'yMin' => $yMin,
            'yMax' => $yMax,
            'dataMin' => $dataMin,
            'dataMax' => $dataMax,
            'currentMin' => $currentMin,
            'currentMax' => $currentMax,
        ]);
    }
}
