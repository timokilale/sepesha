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

## Deployment

Follow these steps to deploy to production (Apache/cPanel or Nginx/VPS):

1. Server requirements
   - PHP 8.1+ with extensions enabled: OpenSSL, PDO, Mbstring, Tokenizer, XML, Ctype, JSON, BCMath, Fileinfo
   - Web server: Apache (mod_rewrite) or Nginx
   - Database: MySQL or MariaDB

2. Code and dependencies
   - Upload the project to the server
   - Run Composer in the project root:
     ```bash
     composer install --no-dev --optimize-autoloader
     ```

3. Environment
   - Create and configure `.env` based on `.env.example`
   - Generate app key:
     ```bash
     php artisan key:generate --ansi
     ```
   - Ensure:
     - `APP_ENV=production`
     - `APP_DEBUG=false`

4. Web root
   - Point your vhost/document root to `project_root/public/`
   - Apache: `public/.htaccess` is included and handles pretty URLs

5. Permissions
   - Make these writable by the web server user:
     - `storage/`
     - `bootstrap/cache/`

6. Database
   - Set DB credentials in `.env`
   - Migrate and (optionally) seed:
     ```bash
     php artisan migrate --force
     php artisan db:seed --class=DatabaseSeeder --force
     ```

7. Storage symlink and caches
   ```bash
   php artisan storage:link
   php artisan config:cache
   php artisan route:cache
   php artisan view:cache
   ```

### Apache (cPanel/shared hosting)
- Set the domain/subdomain document root to `.../sepesha/public`
- If you cannot change the document root, create a new subdomain and point it to `public/` (recommended)

### Nginx (VPS) sample server block
```nginx
server {
    listen 80;
    server_name your-domain.com;
    root /var/www/sepesha/public;

    index index.php index.html;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.1-fpm.sock; # adjust to your PHP-FPM socket
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

## License
MIT
