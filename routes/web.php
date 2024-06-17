<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/he', [\App\Http\Controllers\UserController::class, 'index']);

Route::get('/hel', [\App\Http\Controllers\UserController::class, 'store']);
