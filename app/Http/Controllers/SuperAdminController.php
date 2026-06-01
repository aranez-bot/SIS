<?php

namespace App\Http\Controllers;

use App\Models\Department;
use App\Models\Inquiry;
use App\Models\Notification;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class SuperAdminController extends Controller
{
    public function dashboard(Request $request)
    {
        $overdueHours = 48;
        $now = now();

        $totalUsers = User::count();
        $totalStudents = User::where('user_type', 'student')->count();
        $totalAdmins = User::where('user_type', 'department_admin')->count();
        $totalDepartments = Department::count();
        $totalInquiries = Inquiry::count();
        $pendingInquiries = Inquiry::where('status', 'pending')->count();
        $inProgressInquiries = Inquiry::where('status', 'in_progress')->count();
        $resolvedInquiries = Inquiry::where('status', 'resolved')->count();
        $resolvedToday = Inquiry::where('status', 'resolved')
            ->whereDate('resolved_at', today())
            ->count();
        $overdueInquiries = Inquiry::whereIn('status', ['pending', 'in_progress'])
            ->where('created_at', '<=', $now->copy()->subHours($overdueHours))
            ->count();

        $inquiryQuery = Inquiry::with(['student', 'department', 'messages.user'])
            ->latest();

        if ($request->filled('department_id')) {
            $inquiryQuery->where('department_id', $request->department_id);
        }

        if ($request->filled('status')) {
            $inquiryQuery->where('status', $request->status);
        }

        if ($request->filled('date_from')) {
            $inquiryQuery->whereDate('created_at', '>=', $request->date_from);
        }

        if ($request->filled('date_to')) {
            $inquiryQuery->whereDate('created_at', '<=', $request->date_to);
        }

        if ($request->filled('category')) {
            $keywords = match ($request->category) {
                'Enrollment' => ['enroll', 'admission', 'registration'],
                'Grades' => ['grade', 'transcript', 'record'],
                'Finance' => ['payment', 'tuition', 'fee', 'balance'],
                'Records' => ['record', 'certificate', 'document'],
                default => [],
            };

            if ($keywords) {
                $inquiryQuery->where(function ($query) use ($keywords) {
                    foreach ($keywords as $keyword) {
                        $query->orWhere('subject', 'like', "%{$keyword}%")
                            ->orWhere('description', 'like', "%{$keyword}%");
                    }
                });
            }
        }

        $inquiries = $inquiryQuery->paginate(10)->withQueryString();
        $departments = Department::withCount('inquiries')->get();
        $users = User::with('department')->latest()->limit(8)->get();
        $studentsCount = User::where('user_type', 'student')->count();
        $departmentHeadsCount = User::where('user_type', 'department_admin')->count();

        $departmentPerformance = Department::with(['inquiries.messages.user'])
            ->withCount([
                'inquiries as total_received',
                'inquiries as pending_count' => fn ($query) => $query->where('status', 'pending'),
                'inquiries as resolved_count' => fn ($query) => $query->where('status', 'resolved'),
            ])
            ->get()
            ->map(function ($department) use ($overdueHours) {
                $responseTimes = $department->inquiries
                    ->map(fn ($inquiry) => $this->responseTimeHours($inquiry))
                    ->filter(fn ($hours) => !is_null($hours));

                $avgResponseTime = $responseTimes->count() ? round($responseTimes->avg(), 1) : null;
                $hasOverdue = $department->inquiries->contains(fn ($inquiry) => $this->isOverdue($inquiry, $overdueHours));

                return [
                    'id' => $department->id,
                    'name' => $department->name,
                    'total_received' => $department->total_received,
                    'pending' => $department->pending_count,
                    'resolved' => $department->resolved_count,
                    'avg_response_time' => $avgResponseTime,
                    'status' => $hasOverdue ? 'Overdue' : ($avgResponseTime && $avgResponseTime > 24 ? 'Slow' : 'Good'),
                ];
            });

        $flaggedInquiries = Inquiry::with(['student', 'department'])
            ->whereIn('status', ['pending', 'in_progress'])
            ->where('created_at', '<=', $now->copy()->subHours($overdueHours))
            ->latest()
            ->limit(5)
            ->get();

        $volumeByDay = Inquiry::selectRaw('DATE(created_at) as day, COUNT(*) as total')
            ->where('created_at', '>=', $now->copy()->subDays(13)->startOfDay())
            ->groupBy('day')
            ->orderBy('day')
            ->get();

        $byDepartment = Inquiry::select('departments.name', DB::raw('COUNT(*) as total'))
            ->join('departments', 'departments.id', '=', 'inquiries.department_id')
            ->groupBy('departments.name')
            ->orderByDesc('total')
            ->get();

        $resolvedCount = Inquiry::where('status', 'resolved')->count();
        $resolutionRate = $totalInquiries > 0 ? round(($resolvedCount / $totalInquiries) * 100, 1) : 0;

        $archivedInquiries = Inquiry::with(['student', 'department'])
            ->whereIn('status', ['resolved', 'closed'])
            ->latest()
            ->limit(5)
            ->get();

        return view('superadmin.dashboard', compact(
            'totalUsers',
            'totalStudents',
            'totalAdmins',
            'totalDepartments',
            'totalInquiries',
            'pendingInquiries',
            'inProgressInquiries',
            'resolvedInquiries',
            'resolvedToday',
            'overdueInquiries',
            'overdueHours',
            'inquiries',
            'departments',
            'users',
            'studentsCount',
            'departmentHeadsCount',
            'departmentPerformance',
            'flaggedInquiries',
            'volumeByDay',
            'byDepartment',
            'resolutionRate',
            'archivedInquiries'
        ));
    }

    private function responseTimeHours(Inquiry $inquiry): ?float
    {
        $firstAdminMessage = $inquiry->messages
            ->first(fn ($message) => $message->user && $message->user->isDepartmentAdmin());

        if (!$firstAdminMessage) {
            return null;
        }

        return round($inquiry->created_at->diffInMinutes($firstAdminMessage->created_at) / 60, 1);
    }

    private function isOverdue(Inquiry $inquiry, int $overdueHours): bool
    {
        return in_array($inquiry->status, ['pending', 'in_progress'], true)
            && $inquiry->created_at->lte(now()->subHours($overdueHours));
    }

    public function manageDepartments()
    {
        $departments = Department::paginate(15);
        return view('superadmin.departments.index', compact('departments'));
    }

    public function createDepartment()
    {
        return view('superadmin.departments.create');
    }

    public function storeDepartment(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|unique:departments',
            'email' => 'required|email|unique:departments',
            'description' => 'nullable|string',
            'phone' => 'nullable|string',
            'office_hours' => 'nullable|string',
        ]);

        $validated['slug'] = str($validated['name'])->slug();
        Department::create($validated);

        return redirect()->route('superadmin.departments.index')
                        ->with('success', 'Department created successfully!');
    }

    public function editDepartment(Department $department)
    {
        return view('superadmin.departments.edit', compact('department'));
    }

    public function updateDepartment(Request $request, Department $department)
    {
        $validated = $request->validate([
            'name' => 'required|string|unique:departments,name,' . $department->id,
            'email' => 'required|email|unique:departments,email,' . $department->id,
            'description' => 'nullable|string',
            'phone' => 'nullable|string',
            'office_hours' => 'nullable|string',
            'is_active' => 'boolean',
        ]);

        $department->update($validated);

        return redirect()->route('superadmin.departments.index')
                        ->with('success', 'Department updated successfully!');
    }

    public function deleteDepartment(Department $department)
    {
        if ($department->inquiries()->exists()) {
            return redirect()->route('superadmin.departments.index')
                            ->withErrors(['department' => 'This department has inquiries and cannot be deleted. Deactivate it instead.']);
        }

        $department->delete();

        return redirect()->route('superadmin.departments.index')
                        ->with('success', 'Department deleted successfully!');
    }

    public function manageUsers()
    {
        $users = User::with('department')->paginate(15);
        return view('superadmin.users.index', compact('users'));
    }

    public function createUser()
    {
        $departments = Department::where('is_active', true)->orderBy('name')->get();

        return view('superadmin.users.create', compact('departments'));
    }

    public function storeUser(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'user_identifier' => 'nullable|string|max:50|unique:users,user_identifier',
            'email' => 'required|email|max:255|unique:users,email',
            'user_type' => 'required|in:student,department_admin,super_admin',
            'department_id' => 'nullable|required_if:user_type,department_admin|exists:departments,id',
            'password' => 'required|confirmed|min:8',
            'is_active' => 'nullable|boolean',
        ]);

        if ($validated['user_type'] !== 'department_admin') {
            $validated['department_id'] = null;
        }

        User::create([
            'name' => $validated['name'],
            'user_identifier' => $validated['user_identifier'] ?? null,
            'email' => $validated['email'],
            'department_id' => $validated['department_id'] ?? null,
            'password' => Hash::make($validated['password']),
            'user_type' => $validated['user_type'],
            'is_active' => $request->boolean('is_active', true),
        ]);

        return redirect()->route('superadmin.users.index')
                        ->with('success', 'User account created successfully!');
    }

    public function createAdmin()
    {
        $departments = Department::where('is_active', true)->get();
        return view('superadmin.users.create-admin', compact('departments'));
    }

    public function storeAdmin(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'user_identifier' => 'required|string|max:50|unique:users,user_identifier',
            'email' => 'required|email|max:255|unique:users,email',
            'department_id' => 'required|exists:departments,id',
            'password' => 'required|confirmed|min:8',
        ]);

        User::create([
            'name' => $validated['name'],
            'user_identifier' => $validated['user_identifier'],
            'email' => $validated['email'],
            'department_id' => $validated['department_id'],
            'password' => Hash::make($validated['password']),
            'user_type' => 'department_admin',
        ]);

        return redirect()->route('superadmin.users.index')
                        ->with('success', 'Admin created successfully!');
    }

    public function editUser(User $user)
    {
        $departments = Department::all();
        return view('superadmin.users.edit', compact('user', 'departments'));
    }

    public function updateUser(Request $request, User $user)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'user_identifier' => 'nullable|string|max:50|unique:users,user_identifier,' . $user->id,
            'email' => 'required|email|unique:users,email,' . $user->id,
            'user_type' => 'required|in:student,department_admin,super_admin',
            'is_active' => 'nullable|boolean',
            'department_id' => 'nullable|required_if:user_type,department_admin|exists:departments,id',
        ]);

        if ($validated['user_type'] !== 'department_admin') {
            $validated['department_id'] = null;
        }

        $validated['is_active'] = $request->boolean('is_active');

        $user->update($validated);

        return redirect()->route('superadmin.users.index')
                        ->with('success', 'User updated successfully!');
    }

    public function deleteUser(User $user)
    {
        if ($user->id === auth()->id()) {
            return back()->withErrors(['user' => 'You cannot delete your own account.']);
        }

        $user->delete();
        return redirect()->route('superadmin.users.index')
                        ->with('success', 'User deleted successfully!');
    }

    public function toggleUserStatus(User $user)
    {
        if ($user->id === auth()->id()) {
            return back()->withErrors(['user' => 'You cannot deactivate your own account.']);
        }

        $user->update(['is_active' => ! $user->is_active]);

        return back()->with('success', $user->is_active ? 'User reactivated successfully.' : 'User deactivated successfully.');
    }

    public function analytics()
    {
        $inquiries = Inquiry::with('messages.user')->get();
        $totalInquiries = $inquiries->count();
        $pendingInquiries = $inquiries->where('status', 'pending')->count();
        $resolvedInquiries = $inquiries->where('status', 'resolved')->count();
        $responseTimes = $inquiries
            ->map(fn ($inquiry) => $this->responseTimeHours($inquiry))
            ->filter(fn ($hours) => !is_null($hours));
        $averageResponseTime = $responseTimes->count() ? round($responseTimes->avg(), 1) : null;
        $byStatus = $inquiries->groupBy('status')->map->count();
        $byDepartment = Inquiry::with('department')
            ->get()
            ->groupBy('department.name')
            ->map->count();
        $departmentPerformance = Department::with(['inquiries.messages.user'])
            ->withCount([
                'inquiries as total_received',
                'inquiries as pending_count' => fn ($query) => $query->where('status', 'pending'),
                'inquiries as resolved_count' => fn ($query) => $query->where('status', 'resolved'),
            ])
            ->orderBy('name')
            ->get()
            ->map(function ($department) {
                $responseTimes = $department->inquiries
                    ->map(fn ($inquiry) => $this->responseTimeHours($inquiry))
                    ->filter(fn ($hours) => !is_null($hours));

                return [
                    'name' => $department->name,
                    'total_received' => $department->total_received,
                    'pending' => $department->pending_count,
                    'resolved' => $department->resolved_count,
                    'avg_response_time' => $responseTimes->count() ? round($responseTimes->avg(), 1) : null,
                    'resolution_rate' => $department->total_received > 0
                        ? round(($department->resolved_count / $department->total_received) * 100, 1)
                        : 0,
                ];
            });

        return view('superadmin.analytics', compact(
            'totalInquiries',
            'pendingInquiries',
            'resolvedInquiries',
            'averageResponseTime',
            'byStatus',
            'byDepartment',
            'departmentPerformance'
        ));
    }

    public function notifications()
    {
        $superAdmin = auth()->user();
        $notifications = $superAdmin->notifications()->latest()->paginate(20);

        return view('superadmin.notifications', compact('notifications'));
    }

    public function systemSettings()
    {
        $settings = [
            'statuses' => ['pending', 'in_progress', 'answered', 'resolved', 'rejected', 'closed'],
            'categories' => ['registrar', 'enrollment', 'grades', 'scholarship', 'admission', 'finance'],
            'notifications' => ['inquiry_new', 'status_changed', 'message_new', 'inquiry_forwarded'],
        ];

        return view('superadmin.system-settings', compact('settings'));
    }

    public function rolePermissions()
    {
        $roles = [
            'User / Student' => [
                'Submit and track inquiries',
                'View department responses',
                'Update own profile',
                'Receive notifications',
            ],
            'Department Admin' => [
                'View assigned department inquiries',
                'Respond and update inquiry status',
                'Forward inquiries to another department',
                'Manage department FAQs and reports',
            ],
            'Superadmin' => [
                'Manage users, admins, and departments',
                'Monitor all inquiries',
                'View reports, analytics, audit logs, and backups',
                'Configure system status labels, categories, and notifications',
            ],
        ];

        return view('superadmin.role-permissions', compact('roles'));
    }

    public function auditLogs()
    {
        $recentUsers = User::latest()->limit(10)->get();
        $recentInquiries = Inquiry::with(['student', 'department'])->latest()->limit(10)->get();
        $recentNotifications = Notification::with('user')->latest()->limit(10)->get();

        return view('superadmin.audit-logs', compact('recentUsers', 'recentInquiries', 'recentNotifications'));
    }

    public function maintenance()
    {
        $summary = [
            'users' => User::count(),
            'departments' => Department::count(),
            'inquiries' => Inquiry::count(),
            'notifications' => Notification::count(),
        ];

        return view('superadmin.maintenance', compact('summary'));
    }

    public function downloadBackup()
    {
        $payload = [
            'generated_at' => now()->toIso8601String(),
            'users' => User::all(),
            'departments' => Department::all(),
            'inquiries' => Inquiry::all(),
            'notifications' => Notification::all(),
        ];

        return response()->streamDownload(function () use ($payload) {
            echo json_encode($payload, JSON_PRETTY_PRINT);
        }, 'inquiry-system-backup-'.now()->format('Ymd-His').'.json', [
            'Content-Type' => 'application/json',
        ]);
    }

    public function markNotificationRead(Notification $notification)
    {
        $this->authorize('view', $notification);
        $notification->markAsRead();

        return back()->with('success', 'Notification marked as read');
    }
}
