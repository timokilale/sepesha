<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DailySale extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'item_id',
        'item_name',
        'sale_date',
        'total_quantity',
        'total_revenue',
    ];

    protected $casts = [
        'sale_date' => 'date',
        'total_revenue' => 'decimal:2',
    ];

    public static function upsertAggregate(int $userId, ?int $itemId, string $itemName, string $saleDate, int $qty, float $revenue): void
    {
        $instance = static::firstOrNew([
            'user_id' => $userId,
            'item_id' => $itemId,
            'item_name' => $itemName,
            'sale_date' => $saleDate,
        ]);
        $instance->total_quantity = (int) ($instance->total_quantity ?? 0) + $qty;
        $instance->total_revenue = (float) ($instance->total_revenue ?? 0) + $revenue;
        $instance->save();
    }
}
