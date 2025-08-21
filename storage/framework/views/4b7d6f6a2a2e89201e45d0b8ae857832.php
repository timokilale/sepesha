<!DOCTYPE html>
<html lang="<?php echo e(str_replace('_', '-', app()->getLocale())); ?>">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="<?php echo e(csrf_token()); ?>">

    <title><?php echo e(config('app.name', 'Kashier')); ?></title>

    <!-- Fonts: Raleway -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Raleway:wght@400;500;600;700&display=swap" rel="stylesheet">

    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    
    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    
    <!-- Alpine.js -->
    <script defer src="https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js"></script>
</head>
<body class="antialiased bg-gray-50" style="font-family: 'Raleway', sans-serif;">
    <div class="min-h-screen">
        <!-- Navigation -->
        <nav class="bg-white border-b">
            <div class="max-w-7xl mx-auto px-4">
                <div class="flex justify-between h-14">
                    <div class="flex">
                        <!-- Logo -->
                        <div class="shrink-0 flex items-center">
                            <a href="<?php echo e(route('home')); ?>" class="inline-flex items-center">
                                <img src="<?php echo e(asset('images/logo.png')); ?>" alt="Logo" class="h-8 w-auto" />
                            </a>
                        </div>

                        <!-- Navigation Links -->
                        <div class="hidden space-x-8 sm:-my-px sm:ml-10 sm:flex">
                            <a href="<?php echo e(route('home')); ?>" 
                               class="inline-flex items-center px-1 pt-1 border-b-2 <?php echo e(request()->routeIs('home') ? 'border-indigo-400 text-gray-900' : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'); ?> text-sm font-medium">
                                Home
                            </a>
                            <a href="<?php echo e(route('purchases.index')); ?>" 
                               class="inline-flex items-center px-1 pt-1 border-b-2 <?php echo e(request()->routeIs('purchases.*') ? 'border-indigo-400 text-gray-900' : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'); ?> text-sm font-medium">
                                Purchases
                            </a>
                            <a href="<?php echo e(route('sales.index')); ?>" 
                               class="inline-flex items-center px-1 pt-1 border-b-2 <?php echo e(request()->routeIs('sales.*') ? 'border-indigo-400 text-gray-900' : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'); ?> text-sm font-medium">
                                Sales
                            </a>
                            <a href="<?php echo e(route('charts.index')); ?>" 
                               class="inline-flex items-center px-1 pt-1 border-b-2 <?php echo e(request()->routeIs('charts.index') ? 'border-indigo-400 text-gray-900' : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'); ?> text-sm font-medium">
                                Charts
                            </a>
                        </div>
                    </div>

                    <!-- Quick Add removed (available on Home) -->
                    <div class="hidden sm:flex items-center gap-2 mr-3"></div>

                    <!-- User Menu -->
                    <div class="hidden sm:flex sm:items-center sm:ml-0">
                        <div class="ml-3 relative" x-data="{ open: false }">
                            <div>
                                <button @click="open = !open" class="flex text-sm rounded-full focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
                                    <span class="sr-only">Open user menu</span>
                                    <div class="h-8 w-8 rounded-full bg-indigo-500 flex items-center justify-center text-white font-medium">
                                        <?php echo e(substr(Auth::user()->name, 0, 1)); ?>

                                    </div>
                                </button>
                            </div>

                            <div x-show="open" @click.away="open = false" 
                                 class="origin-top-right absolute right-0 mt-2 w-48 rounded-md bg-white border z-50">
                                <div class="py-1">
                                    <a href="<?php echo e(route('profile.edit')); ?>" class="block w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">
                                        Profile
                                    </a>
                                    <form method="POST" action="<?php echo e(route('logout')); ?>">
                                        <?php echo csrf_field(); ?>
                                        <button type="submit" class="block w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">
                                            Logout
                                        </button>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Menu button (mobile) -->
                    <div class="-mr-2 flex items-center gap-2 sm:hidden" x-data="{ open: false }">
                        <button @click="open = !open" class="inline-flex items-center justify-center px-3 py-1.5 rounded-md border text-sm text-gray-700 hover:bg-gray-100 focus:outline-none">
                            Menu
                        </button>
                        
                        <!-- Mobile menu -->
                        <div x-show="open" @click.away="open = false" 
                             class="absolute top-14 right-4 mt-2 w-48 rounded-md bg-white border z-50">
                            <div class="py-1">
                                <!-- Business management -->
                                <a href="<?php echo e(route('home')); ?>" 
                                   class="block px-4 py-2 text-sm <?php echo e(request()->routeIs('home') ? 'text-gray-900 bg-gray-100' : 'text-gray-700 hover:bg-gray-100'); ?>">
                                    Home
                                </a>
                                <a href="<?php echo e(route('purchases.index')); ?>" 
                                   class="block px-4 py-2 text-sm <?php echo e(request()->routeIs('purchases.*') ? 'text-gray-900 bg-gray-100' : 'text-gray-700 hover:bg-gray-100'); ?>">
                                    Purchases
                                </a>
                                <a href="<?php echo e(route('sales.index')); ?>" 
                                   class="block px-4 py-2 text-sm <?php echo e(request()->routeIs('sales.*') ? 'text-gray-900 bg-gray-100' : 'text-gray-700 hover:bg-gray-100'); ?>">
                                    Sales
                                </a>
                                <a href="<?php echo e(route('charts.index')); ?>" 
                                   class="block px-4 py-2 text-sm <?php echo e(request()->routeIs('charts.index') ? 'text-gray-900 bg-gray-100' : 'text-gray-700 hover:bg-gray-100'); ?>">
                                    Charts
                                </a>
                                <div class="border-t border-gray-200 my-1"></div>
                                <!-- Profile / auth -->
                                <a href="<?php echo e(route('profile.edit')); ?>" 
                                   class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">
                                    Profile
                                </a>
                                <form method="POST" action="<?php echo e(route('logout')); ?>">
                                    <?php echo csrf_field(); ?>
                                    <button type="submit" class="block w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">
                                        Logout
                                    </button>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </nav>

        <!-- Page Content -->
        <main class="py-5">
            <style>
              :root {
                --radius: 0.375rem; /* rounded */
                --sep: 1px solid #e5e7eb; /* gray-200 */
              }
              table.data-table tbody tr:hover { background-color: #f9fafb; } /* gray-50 */
            </style>
            <?php if(session('success')): ?>
                <div x-data="{ show: true }" x-init="setTimeout(() => show = false, 3000)" x-show="show" class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 mb-4">
                    <div class="flex items-center gap-2 border-l-4 border-green-500 bg-green-50 text-green-700 px-3 py-2" role="alert">
                        <span class="text-sm"><?php echo e(session('success')); ?></span>
                    </div>
                </div>
            <?php endif; ?>

            <?php if(session('error')): ?>
                <div x-data="{ show: true }" x-init="setTimeout(() => show = false, 5000)" x-show="show" class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 mb-4">
                    <div class="flex items-center gap-2 border-l-4 border-red-500 bg-red-50 text-red-700 px-3 py-2" role="alert">
                        <span class="text-sm"><?php echo e(session('error')); ?></span>
                    </div>
                </div>
            <?php endif; ?>

            <?php echo $__env->yieldContent('content'); ?>
        </main>
    </div>
</body>
</html>
<?php /**PATH C:\Users\MSA WIN10 G\Desktop\CascadeProjects\windsurf-project\resources\views/layouts/app.blade.php ENDPATH**/ ?>