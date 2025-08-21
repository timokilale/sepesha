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

        foreach ($period as $month) {
            $labels[] = $month->format('M Y');

            $monthlyPurchases = (float) $user->purchases()
                ->whereYear('purchase_date', $month->year)
                ->whereMonth('purchase_date', $month->month)
                ->sum('cost_price');

            $monthlySales = (float) $user->sales()
                ->whereYear('sale_date', $month->year)
                ->whereMonth('sale_date', $month->month)
                ->get(['selling_price', 'quantity_sold'])
                ->sum(function ($sale) {
                    return (float) $sale->selling_price * (int) $sale->quantity_sold;
                });

            $purchases[] = $monthlyPurchases;
            $sales[] = $monthlySales;
        }

        $range = [
            'start_date' => $startDate->toDateString(),
            'end_date' => $endDate->toDateString(),
        ];

        return view('charts.index', [
            'labels' => $labels,
            'purchases' => $purchases,
            'sales' => $sales,
            'range' => $range,
        ]);
    }
}
