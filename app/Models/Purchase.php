<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Purchase extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'user_id',
        'item_name',
        'cost_price',
        'purchase_date',
        'description',
        'quantity',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'purchase_date' => 'date',
        'cost_price' => 'decimal:2',
    ];

    /**
     * Get the user that owns the purchase.
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the sales for the purchase.
     */
    public function sales()
    {
        return $this->hasMany(Sale::class);
    }

    /**
     * Get the total quantity sold for this purchase.
     */
    public function getTotalQuantitySoldAttribute()
    {
        return $this->sales->sum('quantity_sold');
    }

    /**
     * Get the remaining quantity for this purchase.
     */
    public function getRemainingQuantityAttribute()
    {
        return $this->quantity - $this->total_quantity_sold;
    }

    /**
     * Get the total revenue from sales of this purchase.
     */
    public function getTotalRevenueAttribute()
    {
        return $this->sales->sum(function ($sale) {
            return $sale->selling_price * $sale->quantity_sold;
        });
    }

    /**
     * Get the profit/loss for this purchase.
     */
    public function getProfitLossAttribute()
    {
        $totalCost = $this->cost_price * $this->total_quantity_sold;
        return $this->total_revenue - $totalCost;
    }
}
