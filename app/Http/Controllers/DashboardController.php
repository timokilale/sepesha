<?php

namespace App\Http\Controllers;

use App\Models\Purchase;
use App\Models\Sale;
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
        
        // Get analytics data
        $totalPurchases = (float) $user->purchases()->sum('cost_price');
        // Compute total sales as price * quantity across all user sales
        $totalSales = (float) $user->sales()->select('selling_price', 'quantity_sold')->get()
            ->sum(function ($sale) {
                return (float) $sale->selling_price * (int) $sale->quantity_sold;
            });
        $totalProfit = $totalSales - $totalPurchases;
        
        // Get recent purchases and sales
        $recentPurchases = $user->purchases()
            ->orderBy('purchase_date', 'desc')
            ->take(5)
            ->get();
            
        $recentSales = $user->sales()
            ->with('purchase')
            ->orderBy('sale_date', 'desc')
            ->take(5)
            ->get();
        
        // Get monthly data for charts
        $monthlyData = $this->getMonthlyData($user);
        
        return view('dashboard', compact(
            'totalPurchases',
            'totalSales', 
            'totalProfit',
            'recentPurchases',
            'recentSales',
            'monthlyData'
        ));
    }
    
    /**
     * Get monthly purchase and sales data for charts.
     */
    private function getMonthlyData($user)
    {
        $months = [];
        $purchases = [];
        $sales = [];
        
        for ($i = 5; $i >= 0; $i--) {
            $date = Carbon::now()->subMonths($i);
            $monthName = $date->format('M Y');
            
            $monthlyPurchases = (float) $user->purchases()
                ->whereYear('purchase_date', $date->year)
                ->whereMonth('purchase_date', $date->month)
                ->sum('cost_price');
                
            $monthlySales = (float) $user->sales()
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
