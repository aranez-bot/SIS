<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\DashboardController;
use App\Http\Controllers\Api\DepartmentController;
use App\Http\Controllers\Api\FaqController;
use App\Http\Controllers\Api\InquiryController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\ProfileController;
use App\Http\Controllers\Api\SuperAdminController;
use Illuminate\Support\Facades\Route;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::get('/departments', [DepartmentController::class, 'index']);
Route::get('/faqs', FaqController::class);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);
    Route::get('/dashboard', DashboardController::class);
    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::post('/notifications/{notification}/read', [NotificationController::class, 'markAsRead']);
    Route::put('/profile', [ProfileController::class, 'update']);
    Route::post('/inquiries/{inquiry}/messages', [InquiryController::class, 'message']);
    Route::put('/inquiries/{inquiry}/forward', [InquiryController::class, 'forward']);
    Route::apiResource('/inquiries', InquiryController::class);
    Route::get('/department/faqs', [FaqController::class, 'departmentIndex']);
    Route::post('/department/faqs', [FaqController::class, 'storeDepartment']);
    Route::put('/department/faqs/{faq}', [FaqController::class, 'updateDepartment']);
    Route::delete('/department/faqs/{faq}', [FaqController::class, 'deleteDepartment']);

    Route::prefix('superadmin')->group(function () {
        Route::get('/users', [SuperAdminController::class, 'users']);
        Route::post('/users', [SuperAdminController::class, 'storeUser']);
        Route::put('/users/{user}', [SuperAdminController::class, 'updateUser']);
        Route::patch('/users/{user}/status', [SuperAdminController::class, 'toggleUser']);
        Route::delete('/users/{user}', [SuperAdminController::class, 'deleteUser']);

        Route::get('/departments', [SuperAdminController::class, 'departments']);
        Route::post('/departments', [SuperAdminController::class, 'storeDepartment']);
        Route::put('/departments/{department}', [SuperAdminController::class, 'updateDepartment']);
        Route::delete('/departments/{department}', [SuperAdminController::class, 'deleteDepartment']);

        Route::get('/analytics', [SuperAdminController::class, 'analytics']);
        Route::get('/roles', [SuperAdminController::class, 'roles']);
        Route::get('/settings', [SuperAdminController::class, 'settings']);
        Route::get('/audit-logs', [SuperAdminController::class, 'auditLogs']);
        Route::get('/backup', [SuperAdminController::class, 'backup']);
    });
});
