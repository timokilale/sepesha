<?php $__env->startSection('content'); ?>
<div class="max-w-lg mx-auto px-4 sm:px-6 lg:px-8">
  <div class="bg-white rounded shadow p-6" x-data="{ show: false }">
    <div class="flex items-center justify-between mb-4">
      <h1 class="text-xl font-semibold text-gray-800">Change Password</h1>
      <button type="button" @click="show = !show" class="text-sm text-gray-600 hover:text-gray-800">
        <span x-text="show ? 'Hide all' : 'Show all'"></span>
      </button>
    </div>

    <form method="POST" action="<?php echo e(route('password.update')); ?>" class="space-y-4">
      <?php echo csrf_field(); ?>

      <div>
        <label class="block text-sm text-gray-700 mb-1">Current password</label>
        <input :type="show ? 'text' : 'password'" name="current_password" class="w-full border rounded px-3 py-2" required />
        <?php $__errorArgs = ['current_password'];
$__bag = $errors->getBag($__errorArgs[1] ?? 'default');
if ($__bag->has($__errorArgs[0])) :
if (isset($message)) { $__messageOriginal = $message; }
$message = $__bag->first($__errorArgs[0]); ?><p class="text-red-600 text-sm"><?php echo e($message); ?></p><?php unset($message);
if (isset($__messageOriginal)) { $message = $__messageOriginal; }
endif;
unset($__errorArgs, $__bag); ?>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label class="block text-sm text-gray-700 mb-1">New password</label>
          <input :type="show ? 'text' : 'password'" name="password" class="w-full border rounded px-3 py-2" required />
          <?php $__errorArgs = ['password'];
$__bag = $errors->getBag($__errorArgs[1] ?? 'default');
if ($__bag->has($__errorArgs[0])) :
if (isset($message)) { $__messageOriginal = $message; }
$message = $__bag->first($__errorArgs[0]); ?><p class="text-red-600 text-sm"><?php echo e($message); ?></p><?php unset($message);
if (isset($__messageOriginal)) { $message = $__messageOriginal; }
endif;
unset($__errorArgs, $__bag); ?>
        </div>
        <div>
          <label class="block text-sm text-gray-700 mb-1">Confirm new password</label>
          <input :type="show ? 'text' : 'password'" name="password_confirmation" class="w-full border rounded px-3 py-2" required />
        </div>
      </div>

      <div class="flex flex-col sm:flex-row gap-2 sm:gap-3">
        <button class="px-4 py-2 bg-indigo-600 text-white rounded">Update Password</button>
        <a href="<?php echo e(route('dashboard')); ?>" class="px-4 py-2 bg-gray-100 rounded text-center">Cancel</a>
      </div>
    </form>
  </div>
</div>
<?php $__env->stopSection(); ?>

<?php echo $__env->make('layouts.app', \Illuminate\Support\Arr::except(get_defined_vars(), ['__data', '__path']))->render(); ?><?php /**PATH C:\Users\MSA WIN10 G\Desktop\CascadeProjects\windsurf-project\resources\views/auth/password.blade.php ENDPATH**/ ?>