<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Sale extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'user_id',
        'purchase_id',
        'selling_price',
        'sale_date',
        'quantity_sold',
        'notes',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'sale_date' => 'date',
        'selling_price' => 'decimal:2',
    ];

    /**
     * Get the user that owns the sale.
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the purchase that this sale belongs to.
     */
    public function purchase()
    {
        return $this->belongsTo(Purchase::class);
    }

    /**
     * Get the total revenue for this sale.
     */
    public function getTotalRevenueAttribute()
    {
        return $this->selling_price * $this->quantity_sold;
    }

    /**
     * Get the profit for this sale.
     */
    public function getProfitAttribute()
    {
        // Use exact unit cost from the purchase (derived from carton) to avoid rounding drift
        $costPrice = $this->purchase->exact_unit_cost * $this->quantity_sold;
        return $this->total_revenue - $costPrice;
    }

    /**
     * Check if this is a meat/weight-based sale
     */
    public function getIsMeatSaleAttribute()
    {
        return $this->purchase && $this->purchase->item && $this->purchase->item->uom_type === 'weight';
    }

    /**
     * Get display quantity for meat sales (convert grams to kg)
     */
    public function getDisplayQuantityAttribute()
    {
        if ($this->is_meat_sale) {
            return $this->quantity_sold / 1000; // Convert grams to kg
        }
        return $this->quantity_sold;
    }

    /**
     * Get display price for meat sales (convert price per gram to price per kg)
     */
    public function getDisplayPriceAttribute()
    {
        if ($this->is_meat_sale) {
            return $this->selling_price * 1000; // Convert price per gram to price per kg
        }
        return $this->selling_price;
    }

    /**
     * Get display unit for the sale
     */
    public function getDisplayUnitAttribute()
    {
        if ($this->is_meat_sale) {
            return 'kg';
        }
        return 'bottles';
    }
}
