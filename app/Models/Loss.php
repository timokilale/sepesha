<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Loss extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'item_id',
        'purchase_id',
        'quantity', // base unit: units for unit items, ml for volume, g for weight
        'reason',
        'loss_date',
        'notes',
    ];

    protected $casts = [
        'loss_date' => 'date',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function item()
    {
        return $this->belongsTo(Item::class);
    }

    public function purchase()
    {
        return $this->belongsTo(Purchase::class);
    }
}
