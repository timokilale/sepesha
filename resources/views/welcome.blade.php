<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Welcome</title>
  <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="min-h-screen bg-gradient-to-br from-indigo-50 to-white">
  <div class="max-w-3xl mx-auto p-8">
    <header class="text-center mb-10">
      <div class="flex justify-center mb-3">
        <img src="{{ asset('images/logo.png') }}" alt="Logo" class="h-10 w-auto" />
      </div>
      <p class="text-gray-600 mt-2">Track purchases, sales, and profit with a clean interface.</p>
    </header>

    <div class="bg-white rounded shadow p-6">
      <h2 class="text-xl font-semibold text-gray-800 mb-4">Get Started</h2>
      <p class="text-gray-600 mb-6">Sign in to access your dashboard.</p>
      <a href="{{ route('login') }}" class="inline-flex items-center px-4 py-2 bg-indigo-600 text-white rounded hover:bg-indigo-700">Sign in</a>
    </div>
  </div>
</body>
</html>
