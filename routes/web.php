<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\StudentController;
use App\Http\Controllers\DepartmentAdminController;
use App\Http\Controllers\SuperAdminController;
use App\Http\Controllers\MessageController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\PageController;
use Illuminate\Support\Facades\Route;

Route::middleware('guest')->group(function () {
    Route::get('/login', [AuthController::class, 'showLogin'])->name('login');
    Route::post('/login', [AuthController::class, 'login']);
    Route::get('/register', [AuthController::class, 'showRegister'])->name('register');
    Route::post('/register', [AuthController::class, 'register']);
});

Route::post('/logout', [AuthController::class, 'logout'])->middleware('auth')->name('logout');

Route::get('/', [PageController::class, 'welcome']);

Route::get('/mobile-app', [StudentController::class, 'mobileApp'])->name('mobile-app');
Route::get('/mobile-app/download', [StudentController::class, 'downloadMobileApp'])->name('mobile-app.download');

Route::middleware('auth')->group(function () {
    Route::get('/dashboard', [DashboardController::class, 'index'])->name('dashboard');
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::put('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::put('/settings/profile', [ProfileController::class, 'updateDetails'])->name('settings.profile.update');
    Route::put('/settings/profile-photo', [ProfileController::class, 'updatePhoto'])->name('settings.photo.update');
    Route::put('/settings/email', [ProfileController::class, 'updateEmail'])->name('settings.email.update');
    Route::put('/settings/contact-number', [ProfileController::class, 'updatePhone'])->name('settings.phone.update');
    Route::put('/settings/password', [ProfileController::class, 'updatePassword'])->name('settings.password.update');
    Route::get('/settings', [PageController::class, 'settings'])->name('settings');
    Route::get('/about-us', [PageController::class, 'about'])->name('about');
    Route::get('/faqs', [PageController::class, 'faqs'])->name('faqs');

    // Student Routes
    Route::middleware('user.type:student')->group(function () {
        Route::get('/student/dashboard', [StudentController::class, 'dashboard'])->name('student.dashboard');
        Route::get('/student/mobile-app', [StudentController::class, 'mobileApp'])->name('student.mobile-app');
        Route::get('/student/mobile-app/download', [StudentController::class, 'downloadMobileApp'])->name('student.mobile-app.download');
        Route::get('/student/inquiry/create', [StudentController::class, 'createInquiry'])->name('student.inquiry.create');
        Route::post('/student/inquiry', [StudentController::class, 'storeInquiry'])->name('student.inquiry.store');
        Route::get('/student/inquiry/{inquiry}', [StudentController::class, 'viewInquiry'])->name('student.inquiry.show');
        Route::get('/student/inquiry-history', [StudentController::class, 'inquiryHistory'])->name('student.inquiry.history');
        Route::get('/student/notifications', [StudentController::class, 'notifications'])->name('student.notifications');
        Route::post('/student/notifications/{notification}/read', [StudentController::class, 'markNotificationRead'])->name('notification.mark-read');
    });

    // Department Head Routes
    Route::middleware('user.type:department_admin')->group(function () {
        Route::get('/department/dashboard', [DepartmentAdminController::class, 'dashboard'])->name('admin.dashboard');
        Route::get('/department/inquiry/inbox', [DepartmentAdminController::class, 'inquiryInbox'])->name('admin.inquiry.inbox');
        Route::get('/department/inquiry/{inquiry}', [DepartmentAdminController::class, 'viewInquiry'])->name('admin.inquiry.show');
        Route::put('/department/inquiry/{inquiry}/status', [DepartmentAdminController::class, 'updateInquiryStatus'])->name('admin.inquiry.update-status');
        Route::put('/department/inquiry/{inquiry}/forward', [DepartmentAdminController::class, 'forwardInquiry'])->name('admin.inquiry.forward');
        Route::get('/department/statistics', [DepartmentAdminController::class, 'statistics'])->name('admin.statistics');
        Route::get('/department/faqs', [DepartmentAdminController::class, 'faqs'])->name('admin.faqs.index');
        Route::post('/department/faqs', [DepartmentAdminController::class, 'storeFaq'])->name('admin.faqs.store');
        Route::put('/department/faqs/{faq}', [DepartmentAdminController::class, 'updateFaq'])->name('admin.faqs.update');
        Route::delete('/department/faqs/{faq}', [DepartmentAdminController::class, 'deleteFaq'])->name('admin.faqs.delete');
        Route::get('/department/notifications', [DepartmentAdminController::class, 'notifications'])->name('admin.notifications');
    });

    // Admin Routes
    Route::middleware('user.type:super_admin')->group(function () {
        Route::get('/admin/dashboard', [SuperAdminController::class, 'dashboard'])->name('superadmin.dashboard');
        Route::get('/admin/inquiry/{inquiry}', [DepartmentAdminController::class, 'viewInquiry'])->name('superadmin.inquiry.show');
        Route::put('/admin/inquiry/{inquiry}/status', [DepartmentAdminController::class, 'updateInquiryStatus'])->name('superadmin.inquiry.update-status');

        // Departments Management
        Route::get('/admin/departments', [SuperAdminController::class, 'manageDepartments'])->name('superadmin.departments.index');
        Route::get('/admin/departments/create', [SuperAdminController::class, 'createDepartment'])->name('superadmin.departments.create');
        Route::post('/admin/departments', [SuperAdminController::class, 'storeDepartment'])->name('superadmin.departments.store');
        Route::get('/admin/departments/{department}/edit', [SuperAdminController::class, 'editDepartment'])->name('superadmin.departments.edit');
        Route::put('/admin/departments/{department}', [SuperAdminController::class, 'updateDepartment'])->name('superadmin.departments.update');
        Route::delete('/admin/departments/{department}', [SuperAdminController::class, 'deleteDepartment'])->name('superadmin.departments.delete');

        // Users Management
        Route::get('/admin/users', [SuperAdminController::class, 'manageUsers'])->name('superadmin.users.index');
        Route::get('/admin/users/create', [SuperAdminController::class, 'createUser'])->name('superadmin.users.create');
        Route::post('/admin/users', [SuperAdminController::class, 'storeUser'])->name('superadmin.users.store');
        Route::get('/admin/users/create-admin', [SuperAdminController::class, 'createAdmin'])->name('superadmin.users.create-admin');
        Route::post('/admin/users/create-admin', [SuperAdminController::class, 'storeAdmin'])->name('superadmin.users.store-admin');
        Route::get('/admin/users/{user}/edit', [SuperAdminController::class, 'editUser'])->name('superadmin.users.edit');
        Route::put('/admin/users/{user}', [SuperAdminController::class, 'updateUser'])->name('superadmin.users.update');
        Route::patch('/admin/users/{user}/status', [SuperAdminController::class, 'toggleUserStatus'])->name('superadmin.users.toggle-status');
        Route::delete('/admin/users/{user}', [SuperAdminController::class, 'deleteUser'])->name('superadmin.users.delete');

        // Analytics
        Route::get('/admin/analytics', [SuperAdminController::class, 'analytics'])->name('superadmin.analytics');
        Route::get('/admin/system-settings', [SuperAdminController::class, 'systemSettings'])->name('superadmin.system-settings');
        Route::get('/admin/role-permissions', [SuperAdminController::class, 'rolePermissions'])->name('superadmin.role-permissions');
        Route::get('/admin/audit-logs', [SuperAdminController::class, 'auditLogs'])->name('superadmin.audit-logs');
        Route::get('/admin/maintenance', [SuperAdminController::class, 'maintenance'])->name('superadmin.maintenance');
        Route::get('/admin/maintenance/backup', [SuperAdminController::class, 'downloadBackup'])->name('superadmin.maintenance.backup');
    });

    // Shared Message Routes
    Route::post('/inquiry/{inquiry}/message', [MessageController::class, 'store'])->name('message.store');
    Route::get('/inquiry/{inquiry}/messages', [MessageController::class, 'getMessages'])->name('message.get');
    Route::get('/message/{message}/download', [MessageController::class, 'downloadAttachment'])->name('message.download');
    Route::post('/message/{message}/read', [MessageController::class, 'markAsRead'])->name('message.mark-read');
});
