<?php
// filepath: c:\Users\MSA WIN10 G\Desktop\CascadeProjects\windsurf-project\config\view.php
return [
    'paths' => [
        resource_path('views'),
    ],
    'compiled' => env(
        'VIEW_COMPILED_PATH',
        realpath(storage_path('framework/views'))
    ),
];