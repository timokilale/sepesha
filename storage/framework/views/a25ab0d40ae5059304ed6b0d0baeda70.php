<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Login - Business Tracker</title>
  <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="min-h-screen bg-gray-100 flex items-center justify-center p-4">
  <div class="w-full max-w-md bg-white p-8 rounded shadow">
    <h1 class="text-2xl font-bold text-gray-800 mb-6 text-center">Sign in</h1>

    <?php if($errors->any()): ?>
      <div class="mb-4 p-3 rounded bg-red-100 text-red-700 text-sm">
        <?php echo e($errors->first()); ?>

      </div>
    <?php endif; ?>

    <form method="POST" action="<?php echo e(route('login.attempt')); ?>" class="space-y-4">
      <?php echo csrf_field(); ?>

      <div>
        <label class="block text-sm text-gray-700 mb-1">Email</label>
        <input type="email" name="email" value="<?php echo e(old('email')); ?>" required autofocus class="w-full border rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500" />
      </div>

      <div>
        <label class="block text-sm text-gray-700 mb-1">Password</label>
        <input type="password" name="password" required class="w-full border rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500" />
      </div>

      <div class="flex items-center justify-between">
        <label class="inline-flex items-center text-sm text-gray-600">
          <input type="checkbox" name="remember" class="mr-2">
          Remember me
        </label>
        <a href="/" class="text-sm text-gray-500 hover:text-gray-700">Back</a>
      </div>

      <button type="submit" class="w-full bg-indigo-600 hover:bg-indigo-700 text-white rounded px-4 py-2">Sign in</button>
    </form>
  </div>
</body>
</html>
<?php /**PATH C:\Users\MSA WIN10 G\Desktop\CascadeProjects\windsurf-project\resources\views/auth/login.blade.php ENDPATH**/ ?>