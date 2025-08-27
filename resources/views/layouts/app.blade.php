<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">

    <title>{{ config('app.name', 'Olomitu') }}</title>
    <meta name="theme-color" content="#4f46e5" />
    <link rel="manifest" href="{{ asset('manifest.webmanifest') }}">

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
                            <a href="{{ route('home') }}" class="inline-flex items-center">
                                <img src="{{ asset('images/logo.png') }}" alt="Logo" class="h-12 w-auto" />
                            </a>
                        </div>

                        <!-- Navigation Links -->
                        <div class="hidden space-x-8 sm:-my-px sm:ml-10 sm:flex">
                            <a href="{{ route('home') }}" 
                               class="inline-flex items-center px-1 pt-1 border-b-2 {{ request()->routeIs('home') ? 'border-indigo-400 text-gray-900' : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300' }} text-sm font-medium">
                                Home
                            </a>
                            <a href="{{ route('purchases.index') }}" 
                               class="inline-flex items-center px-1 pt-1 border-b-2 {{ request()->routeIs('purchases.*') ? 'border-indigo-400 text-gray-900' : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300' }} text-sm font-medium">
                                Buy Stock
                            </a>
                            <a href="{{ route('sales.index') }}" 
                               class="inline-flex items-center px-1 pt-1 border-b-2 {{ request()->routeIs('sales.*') ? 'border-indigo-400 text-gray-900' : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300' }} text-sm font-medium">
                                Sell Stock
                            </a>
                            <a href="{{ route('item') }}" 
                               class="inline-flex items-center px-1 pt-1 border-b-2 {{ (request()->routeIs('items.*') || request()->routeIs('item')) ? 'border-indigo-400 text-gray-900' : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300' }} text-sm font-medium">
                                Products
                            </a>
                            @if(auth()->user()->isAdmin())
                            <a href="{{ route('charts.index') }}" 
                               class="inline-flex items-center px-1 pt-1 border-b-2 {{ request()->routeIs('charts.index') ? 'border-indigo-400 text-gray-900' : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300' }} text-sm font-medium">
                                Insights
                            </a>
                            <a href="{{ route('expenses.index') }}" 
                               class="inline-flex items-center px-1 pt-1 border-b-2 {{ request()->routeIs('expenses.*') ? 'border-indigo-400 text-gray-900' : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300' }} text-sm font-medium">
                                Expenses
                            </a>
                            <a href="{{ route('users.index') }}" 
                               class="inline-flex items-center px-1 pt-1 border-b-2 {{ request()->routeIs('users.*') ? 'border-indigo-400 text-gray-900' : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300' }} text-sm font-medium">
                                Users
                            </a>
                            @endif
                            <button id="install-app-desktop" type="button" class="inline-flex items-center px-2 py-1.5 ml-4 border rounded text-sm text-gray-700 hover:bg-gray-100 hidden">Install Olomitu</button>
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
                                        {{ substr(Auth::user()->name, 0, 1) }}
                                    </div>
                                </button>
                            </div>

                            <div x-show="open" @click.away="open = false" 
                                 class="origin-top-right absolute right-0 mt-2 w-48 rounded-md bg-white border z-50">
                                <div class="py-1">
                                    <div class="px-4 py-2 text-xs text-gray-500 border-b">
                                        {{ Auth::user()->name }}
                                        <span class="inline-block px-2 py-0.5 text-xs rounded {{ Auth::user()->isAdmin() ? 'bg-blue-100 text-blue-800' : 'bg-green-100 text-green-800' }}">
                                            {{ ucfirst(Auth::user()->role) }}
                                        </span>
                                    </div>
                                    <a href="{{ route('profile.edit') }}" class="block w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">
                                        Profile
                                    </a>
                                    <form method="POST" action="{{ route('logout') }}">
                                        @csrf
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
                                <a href="{{ route('home') }}" 
                                   class="block px-4 py-2 text-sm {{ request()->routeIs('home') ? 'text-gray-900 bg-gray-100' : 'text-gray-700 hover:bg-gray-100' }}">
                                    Home
                                </a>
                                <a href="{{ route('purchases.index') }}" 
                                   class="block px-4 py-2 text-sm {{ request()->routeIs('purchases.*') ? 'text-gray-900 bg-gray-100' : 'text-gray-700 hover:bg-gray-100' }}">
                                    Buy Stock
                                </a>
                                <a href="{{ route('sales.index') }}" 
                                   class="block px-4 py-2 text-sm {{ request()->routeIs('sales.*') ? 'text-gray-900 bg-gray-100' : 'text-gray-700 hover:bg-gray-100' }}">
                                    Sell Stock
                                </a>
                                <a href="{{ route('item') }}" 
                                   class="block px-4 py-2 text-sm {{ (request()->routeIs('items.*') || request()->routeIs('item')) ? 'text-gray-900 bg-gray-100' : 'text-gray-700 hover:bg-gray-100' }}">
                                    Products
                                </a>
                                @if(auth()->user()->isAdmin())
                                <a href="{{ route('charts.index') }}" 
                                   class="block px-4 py-2 text-sm {{ request()->routeIs('charts.index') ? 'text-gray-900 bg-gray-100' : 'text-gray-700 hover:bg-gray-100' }}">
                                    Insights
                                </a>
                                <a href="{{ route('expenses.index') }}" 
                                   class="block px-4 py-2 text-sm {{ request()->routeIs('expenses.*') ? 'text-gray-900 bg-gray-100' : 'text-gray-700 hover:bg-gray-100' }}">
                                    Expenses
                                </a>
                                <a href="{{ route('users.index') }}" 
                                   class="block px-4 py-2 text-sm {{ request()->routeIs('users.*') ? 'text-gray-900 bg-gray-100' : 'text-gray-700 hover:bg-gray-100' }}">
                                    Users
                                </a>
                                @endif
                                <button id="install-app-mobile" type="button" class="block w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 hidden">Install Olomitu</button>
                                <div class="border-t border-gray-200 my-1"></div>
                                <!-- Profile / auth -->
                                <a href="{{ route('profile.edit') }}" 
                                   class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">
                                    Profile
                                </a>
                                <form method="POST" action="{{ route('logout') }}">
                                    @csrf
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
            @if (session('success'))
                <div x-data="{ show: true, pwd: null }" x-init="
                        // auto-hide after 15s
                        setTimeout(() => show = false, 15000);
                        // extract password from message text
                        (() => { const t = $refs.msg?.innerText || ''; const m = t.match(/Password:\s*([A-Za-z0-9]+)/); pwd = m ? m[1] : null; })();
                    " x-show="show" class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 mb-4">
                    <div class="flex items-center gap-3 border-l-4 border-green-500 bg-green-50 text-green-700 px-3 py-2" role="alert">
                        <span x-ref="msg" class="text-sm">{{ session('success') }}</span>
                        <div class="ml-auto flex items-center gap-2" x-show="pwd">
                            <button @click="navigator.clipboard.writeText(pwd); $refs.copied?.classList.remove('hidden'); setTimeout(() => $refs.copied?.classList.add('hidden'), 1500);"
                                    type="button"
                                    class="inline-flex items-center gap-1 px-2 py-1 text-xs font-medium text-green-700 bg-white/70 hover:bg-white border border-green-200 rounded">
                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-4 h-4">
                                    <path d="M6 2a2 2 0 00-2 2v8a2 2 0 002 2h5a2 2 0 002-2V7.414A2 2 0 0012.414 6L9.586 3.172A2 2 0 008.172 2H6z" />
                                    <path d="M8 3h.172A2 2 0 019.586 3.586L12.414 6.414A2 2 0 0113 7.828V8a2 2 0 012 2v4a2 2 0 01-2 2H8a1 1 0 110-2h5a1 1 0 001-1v-4a1 1 0 00-1-1h-1a2 2 0 01-2-2V3a1 1 0 10-2 0z" />
                                </svg>
                                Copy password
                            </button>
                            <span x-ref="copied" class="text-xs text-green-700 hidden">Copied</span>
                        </div>
                    </div>
                </div>
            @endif

            @if (session('error'))
                <div x-data="{ show: true }" x-init="setTimeout(() => show = false, 15000)" x-show="show" class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 mb-4">
                    <div class="flex items-center gap-2 border-l-4 border-red-500 bg-red-50 text-red-700 px-3 py-2" role="alert">
                        <span class="text-sm">{{ session('error') }}</span>
                    </div>
                </div>
            @endif

            @yield('content')
        </main>
    </div>
<script>
  // Register service worker for PWA
  if ('serviceWorker' in navigator) {
    window.addEventListener('load', () => {
      navigator.serviceWorker.register('{{ asset('service-worker.js') }}').catch(() => {});
    });
  }
  // Handle PWA install prompt
  (function installPromptHandler(){
    let deferredPrompt = null;
    const btnDesktop = document.getElementById('install-app-desktop');
    const btnMobile = document.getElementById('install-app-mobile');

    const hideButtons = () => {
      if (btnDesktop) btnDesktop.classList.add('hidden');
      if (btnMobile) btnMobile.classList.add('hidden');
    };
    const showButtons = () => {
      if (btnDesktop) btnDesktop.classList.remove('hidden');
      if (btnMobile) btnMobile.classList.remove('hidden');
    };
    // If already installed (standalone), keep hidden
    const isStandalone = window.matchMedia('(display-mode: standalone)').matches || window.navigator.standalone === true;
    if (isStandalone) hideButtons();

    window.addEventListener('beforeinstallprompt', (e) => {
      e.preventDefault();
      deferredPrompt = e;
      showButtons();
    });

    const triggerInstall = async () => {
      if (!deferredPrompt) return;
      deferredPrompt.prompt();
      try { await deferredPrompt.userChoice; } catch (_) {}
      deferredPrompt = null;
      hideButtons();
    };
    if (btnDesktop) btnDesktop.addEventListener('click', triggerInstall);
    if (btnMobile) btnMobile.addEventListener('click', triggerInstall);

    window.addEventListener('appinstalled', () => {
      deferredPrompt = null;
      hideButtons();
    });
  })();
  // Keep session alive to reduce 419 (CSRF/Session expired)
  (function keepAlive(){
    const ping = () => fetch('{{ url('/ping') }}', { credentials: 'same-origin', cache: 'no-store' }).catch(() => {});
    // Ping every 10 minutes
    setInterval(ping, 10 * 60 * 1000);
  })();
</script>
</body>
</html>
