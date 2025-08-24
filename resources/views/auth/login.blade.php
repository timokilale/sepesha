<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Sign in to your shop</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <script defer src="https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js"></script>
</head>
<body class="min-h-screen bg-gray-100 flex items-center justify-center p-4">
  <div class="w-full max-w-md bg-white p-8 rounded shadow">
    <div class="flex justify-center mb-6">
      <img src="{{ asset('images/logo.png') }}" alt="Logo" class="h-16 w-auto" />
    </div>
    <h1 class="text-2xl font-bold text-gray-800 mb-6 text-center">Karibu,</h1>

    @if ($errors->any())
      <div class="mb-4 p-3 rounded bg-red-100 text-red-700 text-sm">
        {{ $errors->first() }}
      </div>
    @endif

    <form method="POST" action="{{ route('login.attempt') }}" class="space-y-4">
      @csrf

      <div>
        <label class="block text-sm text-gray-700 mb-1">Phone</label>
        <input type="tel" name="phone" value="{{ old('phone') }}" required autofocus pattern="^(?:255\d{9}|0\d{8})$" placeholder="e.g. 255714609135" class="w-full border rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500" />
        <p class="text-xs text-gray-500 mt-1">Enter your phone like <strong>255XXXXXXXXX</strong> or <strong>0XXXXXXXX</strong>.</p>
        @error('phone')<p class="text-red-600 text-sm mt-1">{{ $message }}</p>@enderror
      </div>

      <div>
        <label class="block text-sm text-gray-700 mb-1">Password</label>
        <div x-data="{ show: false }" class="relative">
          <input :type="show ? 'text' : 'password'" name="password" required class="w-full border rounded px-3 py-2 pr-10 focus:outline-none focus:ring-2 focus:ring-indigo-500" />
          <button type="button" @click="show = !show" class="absolute inset-y-0 right-2 text-sm text-gray-500 hover:text-gray-700">
            <span x-text="show ? 'Hide' : 'Show'"></span>
          </button>
        </div>
        @error('password')<p class="text-red-600 text-sm mt-1">{{ $message }}</p>@enderror
      </div>

      <div class="flex items-center justify-between">
        <label class="inline-flex items-center text-sm text-gray-600">
          <input type="checkbox" name="remember" class="mr-2">
          Remember me
        </label>
        <a href="/" class="text-sm text-gray-500 hover:text-gray-700">Help</a>
      </div>

      <button type="submit" class="w-full bg-indigo-600 hover:bg-indigo-700 text-white rounded px-4 py-2">Sign in</button>
    </form>
  </div>
</body>
</html>
