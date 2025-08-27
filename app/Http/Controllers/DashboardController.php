<?php

namespace App\Http\Controllers;

use App\Models\Purchase;
use App\Models\Sale;
use App\Models\Expense;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Carbon\Carbon;

class DashboardController extends Controller
{
    /**
     * Create a new controller instance.
     */
    public function __construct()
    {
        $this->middleware('auth');
    }

    /**
     * Show the application dashboard.
     */
    public function index()
    {
        $user = Auth::user();
        
        // Get analytics data (totals are global and visible to all users; charts/monthly only for admins)
        $monthlyData = ['months' => [], 'purchases' => [], 'sales' => []];

        // Purchases: use total_cost attribute which handles both carton-based and direct cost purchases
        $totalPurchases = (float) \App\Models\Purchase::query()
            ->get()
            ->sum(function ($p) {
                return $p->total_cost; // This accessor handles both carton-based and meat purchases
            });
        // Sales: price × quantity across all sales
        $totalSales = (float) \App\Models\Sale::query()->select('selling_price', 'quantity_sold')->get()
            ->sum(function ($sale) {
                return (float) $sale->selling_price * (int) $sale->quantity_sold;
            });
        // Expenses: sum of expense amounts
        $totalExpenses = (float) Expense::query()->sum('amount');
        // Profit: sales − purchases − expenses
        $totalProfit = $totalSales - $totalPurchases - $totalExpenses;

        if ($user->isAdmin()) {
            // Get monthly data for charts
            $monthlyData = $this->getMonthlyData();
        }
        
        // Get recent purchases and sales
        $recentPurchases = \App\Models\Purchase::orderBy('purchase_date', 'desc')
            ->take(5)
            ->get();
            
        $recentSales = \App\Models\Sale::with('purchase')
            ->orderBy('sale_date', 'desc')
            ->take(5)
            ->get();

        // Products for homepage grid
        $items = \App\Models\Item::with(['purchases.sales'])->orderBy('name')->get();
        // Compute stock per item
        $items = $items->map(function ($item) {
            $purchased = (int) $item->purchases->sum('quantity');
            $sold = (int) $item->purchases->flatMap->sales->sum('quantity_sold');
            $item->stock_remaining = max(0, $purchased - $sold);
            return $item;
        });
        
        return view('dashboard', compact(
            'totalPurchases',
            'totalSales', 
            'totalProfit',
            'recentPurchases',
            'recentSales',
            'monthlyData',
            'items'
        ));
    }
    
    /**
     * Get monthly purchase and sales data for charts.
     */
    private function getMonthlyData()
    {
        $months = [];
        $purchases = [];
        $sales = [];
        
        for ($i = 5; $i >= 0; $i--) {
            $date = Carbon::now()->subMonths($i);
            $monthName = $date->format('M Y');
            
            // Sum total costs for the month (handles both carton-based and direct cost purchases)
            $monthlyPurchases = (float) \App\Models\Purchase::query()
                ->whereYear('purchase_date', $date->year)
                ->whereMonth('purchase_date', $date->month)
                ->get()
                ->sum(function ($p) {
                    return $p->total_cost; // This accessor handles both carton-based and meat purchases
                });
                
            $monthlySales = (float) \App\Models\Sale::query()
                ->whereYear('sale_date', $date->year)
                ->whereMonth('sale_date', $date->month)
                ->get(['selling_price', 'quantity_sold'])
                ->sum(function ($sale) {
                    return (float) $sale->selling_price * (int) $sale->quantity_sold;
                });
            
            $months[] = $monthName;
            $purchases[] = (float) $monthlyPurchases;
            $sales[] = (float) $monthlySales;
        }
        
        return [
            'months' => $months,
            'purchases' => $purchases,
            'sales' => $sales
        ];
    }
}
