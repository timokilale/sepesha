<?php

use App\Http\Controllers\DashboardController;
use App\Http\Controllers\PurchaseController;
use App\Http\Controllers\SaleController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\PasswordController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\ChartController;
use App\Http\Controllers\ItemController;
use App\Http\Controllers\ExpenseController;
use App\Http\Controllers\ReportController;
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
Route::get('/home', [DashboardController::class, 'index'])->middleware(['auth','single.session'])->name('home');
// Backward compatibility: redirect /dashboard to /home
Route::get('/dashboard', function () {
    return redirect()->route('home');
})->middleware(['auth','single.session']);

// Purchases
Route::resource('purchases', PurchaseController::class)->middleware(['auth','single.session']);

// Sales
Route::resource('sales', SaleController::class)->middleware(['auth','single.session']);

// Items (catalog)
Route::resource('items', ItemController::class)->middleware(['auth','single.session']);

// Expenses (operating costs)
Route::resource('expenses', ExpenseController::class)->middleware(['auth','single.session']);

// Password (Change Password)
Route::middleware(['auth','single.session'])->group(function () {
    Route::get('/password', [PasswordController::class, 'edit'])->name('password.edit');
    Route::post('/password', [PasswordController::class, 'update'])->name('password.update');
});

// Profile (update name, phone, email)
Route::middleware(['auth','single.session'])->group(function () {
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::post('/profile', [ProfileController::class, 'update'])->name('profile.update');
});

// Charts (date-range analytics)
Route::middleware(['auth','single.session'])->group(function () {
    Route::get('/charts', [ChartController::class, 'index'])->name('charts.index');
    Route::get('/reports', [ReportController::class, 'index'])->name('reports.index');
});

// (removed old /home redirect block)
