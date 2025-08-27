<?php

use App\Http\Controllers\DashboardController;
use App\Http\Controllers\PurchaseController;
use App\Http\Controllers\SaleController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\PasswordController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\ChartController;
use App\Http\Controllers\ItemController;
use App\Http\Controllers\MeatController;
use App\Http\Controllers\ExpenseController;
use App\Http\Controllers\ReportController;
use App\Http\Controllers\LossController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "web" middleware group. Make something great!
|
*/

// Root: redirect guests to login, authenticated users to home
Route::get('/', function () {
    return auth()->check()
        ? redirect()->route('home')
        : redirect()->route('login');
});

// Authentication Routes (single user)
Route::middleware('guest')->group(function () {
    Route::get('/login', [AuthController::class, 'showLogin'])->name('login');
    Route::post('/login', [AuthController::class, 'login'])->name('login.attempt');
});
Route::post('/logout', [AuthController::class, 'logout'])->middleware('auth')->name('logout');

// Home (formerly Dashboard)
Route::get('/home', [DashboardController::class, 'index'])->middleware(['auth'])->name('home');
// Backward compatibility: redirect /dashboard to /home
Route::get('/dashboard', function () {
    return redirect()->route('home');
})->middleware(['auth']);

// Purchases
Route::resource('purchases', PurchaseController::class)->middleware(['auth']);

// Single-segment alternatives for Purchases
Route::middleware(['auth'])->group(function () {
    Route::get('/purchase-{id}', [PurchaseController::class, 'show'])->whereNumber('id')->name('purchases.show.single');
    Route::get('/purchase-{id}-edit', [PurchaseController::class, 'edit'])->whereNumber('id')->name('purchases.edit.single');
    Route::put('/purchase-{id}', [PurchaseController::class, 'update'])->whereNumber('id')->name('purchases.update.single');
    Route::patch('/purchase-{id}', [PurchaseController::class, 'update'])->whereNumber('id');
    Route::delete('/purchase-{id}-delete', [PurchaseController::class, 'destroy'])->whereNumber('id')->name('purchases.destroy.single');
});

// Sales
Route::resource('sales', SaleController::class)->middleware(['auth']);

// Single-segment alternatives for Sales
Route::middleware(['auth'])->group(function () {
    Route::get('/sale-{id}', [SaleController::class, 'show'])->whereNumber('id')->name('sales.show.single');
    Route::get('/sale-{id}-edit', [SaleController::class, 'edit'])->whereNumber('id')->name('sales.edit.single');
    Route::put('/sale-{id}', [SaleController::class, 'update'])->whereNumber('id')->name('sales.update.single');
    Route::patch('/sale-{id}', [SaleController::class, 'update'])->whereNumber('id');
    Route::delete('/sale-{id}-delete', [SaleController::class, 'destroy'])->whereNumber('id')->name('sales.destroy.single');
});

// Items (catalog)
Route::resource('items', ItemController::class)->middleware(['auth']);
// Friendly singular alias
Route::get('/item', function () {
    return redirect()->route('items.index');
})->middleware(['auth'])->name('item');
// Meat products (separate controller)
Route::get('/meat/create', [MeatController::class, 'create'])->middleware(['auth'])->name('meat.create');
Route::post('/meat', [MeatController::class, 'store'])->middleware(['auth'])->name('meat.store');

// Single-segment alternatives for Items
Route::middleware(['auth'])->group(function () {
    Route::get('/item-{id}', [ItemController::class, 'show'])->whereNumber('id')->name('items.show.single');
    Route::get('/item-{id}-edit', [ItemController::class, 'edit'])->whereNumber('id')->name('items.edit.single');
    Route::put('/item-{id}', [ItemController::class, 'update'])->whereNumber('id')->name('items.update.single');
    Route::patch('/item-{id}', [ItemController::class, 'update'])->whereNumber('id');
    Route::delete('/item-{id}-delete', [ItemController::class, 'destroy'])->whereNumber('id')->name('items.destroy.single');
    // Enable/Disable (soft) instead of delete
    Route::post('/item-{id}-disable', [ItemController::class, 'disable'])->whereNumber('id')->name('items.disable.single');
    Route::post('/item-{id}-enable', [ItemController::class, 'enable'])->whereNumber('id')->name('items.enable.single');
});

// Expenses (operating costs) - Admin only
Route::resource('expenses', ExpenseController::class)->middleware(['auth', 'admin']);

// Single-segment alternatives to avoid blocked nested numeric paths - Admin only
Route::middleware(['auth', 'admin'])->group(function () {
    Route::get('/expense-{id}', [ExpenseController::class, 'show'])->whereNumber('id')->name('expenses.show.single');
    Route::get('/expense-{id}-edit', [ExpenseController::class, 'edit'])->whereNumber('id')->name('expenses.edit.single');
    Route::put('/expense-{id}', [ExpenseController::class, 'update'])->whereNumber('id')->name('expenses.update.single');
    Route::patch('/expense-{id}', [ExpenseController::class, 'update'])->whereNumber('id');
    Route::delete('/expense-{id}-delete', [ExpenseController::class, 'destroy'])->whereNumber('id')->name('expenses.destroy.single');
});

// Password (Change Password)
Route::middleware(['auth'])->group(function () {
    Route::get('/password', [PasswordController::class, 'edit'])->name('password.edit');
    Route::post('/password', [PasswordController::class, 'update'])->name('password.update');
});

// Profile (update name, phone, email)
Route::middleware(['auth'])->group(function () {
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::post('/profile', [ProfileController::class, 'update'])->name('profile.update');
});

// Charts (date-range analytics) - Admin only
Route::middleware(['auth', 'admin'])->group(function () {
    Route::get('/charts', [ChartController::class, 'index'])->name('charts.index');
    Route::get('/reports', [ReportController::class, 'index'])->name('reports.index');
});

// User Management - Admin only
Route::middleware(['auth', 'admin'])->group(function () {
    Route::resource('users', \App\Http\Controllers\UserController::class);
    Route::post('/users/{id}/reset-password', [\App\Http\Controllers\UserController::class, 'resetPassword'])->name('users.reset-password');
});

// Losses (spoilage/expired/damage)
Route::middleware(['auth'])->group(function () {
    Route::get('/losses/create', [LossController::class, 'create'])->name('losses.create');
    Route::post('/losses', [LossController::class, 'store'])->name('losses.store');
    // Single-segment helper paths
    Route::get('/loss-add', [LossController::class, 'create'])->name('losses.create.single');
});

// (removed old /home redirect block)

// Keepalive ping to prevent session expiry (used by layout script)
Route::get('/ping', function () {
    // Return 204 No Content for minimal overhead
    return response('', 204);
})->middleware(['auth']);
