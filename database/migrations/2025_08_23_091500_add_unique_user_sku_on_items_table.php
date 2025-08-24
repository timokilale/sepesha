<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Ensure existing data is compatible with the new unique index
        $items = DB::table('items')->orderBy('id')->get(['id','user_id','sku']);
        $seen = [];
        foreach ($items as $item) {
            $userId = (int) $item->user_id;
            if (!isset($seen[$userId])) {
                $seen[$userId] = [];
            }
            $sku = $item->sku;
            if ($sku === null || $sku === '') {
                $sku = 'ITEM-' . $item->id;
            }
            if (isset($seen[$userId][$sku])) {
                $sku = $sku . '-' . $item->id;
            }
            if ($sku !== $item->sku) {
                DB::table('items')->where('id', $item->id)->update(['sku' => $sku]);
            }
            $seen[$userId][$sku] = true;
        }

        Schema::table('items', function (Blueprint $table) {
            $table->unique(['user_id', 'sku'], 'items_user_sku_unique');
        });
    }

    public function down(): void
    {
        Schema::table('items', function (Blueprint $table) {
            $table->dropUnique('items_user_sku_unique');
        });
    }
};
