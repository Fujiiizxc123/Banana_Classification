<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ScanHistoryController;

// Public routes
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login',    [AuthController::class, 'login']);

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout',           [AuthController::class, 'logout']);
    Route::get('/user',              [AuthController::class, 'user']);

    // Scan History
    Route::get('/history',           [ScanHistoryController::class, 'index']);
    Route::post('/history',          [ScanHistoryController::class, 'store']);
    Route::delete('/history/{id}',   [ScanHistoryController::class, 'destroy']);
});