<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('daily_sales', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('item_id')->nullable()->constrained('items')->nullOnDelete();
            $table->string('item_name');
            $table->date('sale_date');
            $table->integer('total_quantity')->default(0);
            $table->decimal('total_revenue', 12, 2)->default(0);
            $table->timestamps();
            $table->unique(['user_id','item_id','item_name','sale_date'], 'daily_sales_unique_row');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('daily_sales');
    }
};
