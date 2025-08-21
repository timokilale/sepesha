# Kashier (Laravel)

A simple full-stack web app to track purchases and sales with a clean dashboard, profit/loss analytics, and charts. Built with Laravel, Blade + Tailwind CSS, and MySQL by default.

## Features
- Authenticated single-user login/logout
- Manage Purchases (name, cost price, date, quantity, notes)
- Manage Sales (link to purchase, selling price, date, quantity, notes)
- Dashboard totals: Total Purchases, Total Sales, Profit/Loss
- 6-month bar chart (Sales vs Purchases) using Chart.js
- Responsive UI with Tailwind CSS

## Tech Stack
- Backend: Laravel 10 (PHP 8.1+)
- Frontend: Blade + Tailwind CSS (CDN)
- Database: MySQL (default)

## Getting Started

### Prerequisites
- PHP 8.1+
- Composer
- Node.js is NOT required (Tailwind via CDN)

### Setup
1. Install PHP dependencies:
   ```bash
   composer install
   ```

2. Create environment file:
   ```bash
   copy .env.example .env   # Windows PowerShell: cp .env.example .env
   ```

3. Configure database (MySQL):
   - Ensure MySQL is running locally.
   - Create database `businezz` (using MySQL client or GUI):
     ```sql
     CREATE DATABASE IF NOT EXISTS businezz CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
     ```
   - In `.env`, set:
     ```env
     DB_CONNECTION=mysql
     DB_HOST=127.0.0.1
     DB_PORT=3306
     DB_DATABASE=businezz
     DB_USERNAME=root
     DB_PASSWORD=your_password
     ```

4. Generate app key:
   ```bash
   php artisan key:generate
   ```

5. Run migrations and seed initial user:
   ```bash
   php artisan migrate --force
   php artisan db:seed --class=DatabaseSeeder
   ```

6. Serve the app:
   ```bash
   php artisan serve --port=8000
   ```

7. Login
   - Email: `admin@example.com`
   - Password: `password123`

## Usage
- Dashboard: `/dashboard`
- Purchases: `/purchases`
- Sales: `/sales`

## Code Structure Highlights
- Models: `app/Models/{Purchase.php, Sale.php, User.php}`
- Controllers: `app/Http/Controllers/{DashboardController.php, PurchaseController.php, SaleController.php, AuthController.php}`
- Routes: `routes/web.php`
- Views: `resources/views` (Blade templates)
- Migrations: `database/migrations`
- Seeders: `database/seeders`

## Customization
- Switch DB driver in `config/database.php` and `.env`
- Tailwind customization: update `resources/views/layouts/app.blade.php` (currently using CDN)

## Security
- Registration disabled; single seeded user.
- CSRF protection enabled for forms.

## Notes
- Default DB is MySQL. You can switch to SQLite/PostgreSQL by updating `.env` and `config/database.php` and running migrations.
- Chart.js is loaded via CDN.

## License
MIT
