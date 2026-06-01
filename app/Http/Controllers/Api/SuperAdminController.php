<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Department;
use App\Models\Inquiry;
use App\Models\Notification;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;

class SuperAdminController extends Controller
{
    public function users(Request $request)
    {
        $this->authorizeSuperAdmin($request);

        return response()->json([
            'data' => User::with('department:id,name')
                ->latest()
                ->get(),
            'departments' => Department::orderBy('name')->get(['id', 'name']),
        ]);
    }

    public function storeUser(Request $request)
    {
        $this->authorizeSuperAdmin($request);

        $validated = $request->validate($this->userRules());
        $validated['password'] = Hash::make($validated['password']);
        $validated['is_active'] = $request->boolean('is_active', true);
        $validated['department_id'] = $validated['user_type'] === 'department_admin'
            ? $validated['department_id']
            : null;

        $user = User::create($validated);

        return response()->json(['data' => $user->load('department:id,name')], 201);
    }

    public function updateUser(Request $request, User $user)
    {
        $this->authorizeSuperAdmin($request);

        $rules = $this->userRules($user);
        $rules['password'] = ['nullable', 'confirmed', 'min:8'];
        $validated = $request->validate($rules);

        if (empty($validated['password'])) {
            unset($validated['password']);
        } else {
            $validated['password'] = Hash::make($validated['password']);
        }

        $validated['is_active'] = $request->boolean('is_active');
        $validated['department_id'] = $validated['user_type'] === 'department_admin'
            ? $validated['department_id']
            : null;

        $user->update($validated);

        return response()->json(['data' => $user->fresh('department:id,name')]);
    }

    public function toggleUser(Request $request, User $user)
    {
        $this->authorizeSuperAdmin($request);

        if ($user->id === $request->user()->id) {
            abort(422, 'You cannot deactivate your own account.');
        }

        $user->update(['is_active' => ! $user->is_active]);

        return response()->json(['data' => $user->fresh('department:id,name')]);
    }

    public function deleteUser(Request $request, User $user)
    {
        $this->authorizeSuperAdmin($request);

        if ($user->id === $request->user()->id) {
            abort(422, 'You cannot delete your own account.');
        }

        $user->delete();

        return response()->json(['message' => 'User deleted.']);
    }

    public function departments(Request $request)
    {
        $this->authorizeSuperAdmin($request);

        return response()->json([
            'data' => Department::withCount(['admins', 'inquiries'])
                ->orderBy('name')
                ->get(),
        ]);
    }

    public function storeDepartment(Request $request)
    {
        $this->authorizeSuperAdmin($request);

        $validated = $request->validate($this->departmentRules());
        $validated['slug'] = str($validated['name'])->slug();
        $validated['is_active'] = $request->boolean('is_active', true);

        return response()->json(['data' => Department::create($validated)], 201);
    }

    public function updateDepartment(Request $request, Department $department)
    {
        $this->authorizeSuperAdmin($request);

        $validated = $request->validate($this->departmentRules($department));
        $validated['slug'] = str($validated['name'])->slug();
        $validated['is_active'] = $request->boolean('is_active');

        $department->update($validated);

        return response()->json(['data' => $department->fresh()]);
    }

    public function deleteDepartment(Request $request, Department $department)
    {
        $this->authorizeSuperAdmin($request);

        if ($department->inquiries()->exists()) {
            abort(422, 'Departments with inquiries cannot be deleted.');
        }

        $department->delete();

        return response()->json(['message' => 'Department deleted.']);
    }

    public function analytics(Request $request)
    {
        $this->authorizeSuperAdmin($request);

        $inquiries = Inquiry::with(['messages.user', 'department'])->get();
        $responseTimes = $inquiries
            ->map(function (Inquiry $inquiry) {
                $firstAdminMessage = $inquiry->messages
                    ->first(fn ($message) => $message->user && $message->user->isDepartmentAdmin());

                return $firstAdminMessage
                    ? round($inquiry->created_at->diffInMinutes($firstAdminMessage->created_at) / 60, 1)
                    : null;
            })
            ->filter(fn ($hours) => ! is_null($hours));

        return response()->json([
            'summary' => [
                'total_inquiries' => $inquiries->count(),
                'pending_inquiries' => $inquiries->where('status', 'pending')->count(),
                'resolved_inquiries' => $inquiries->where('status', 'resolved')->count(),
                'average_response_time' => $responseTimes->count() ? round($responseTimes->avg(), 1) : null,
            ],
            'by_status' => $inquiries->groupBy('status')->map->count()->values(),
            'status_labels' => $inquiries->groupBy('status')->keys()->values(),
            'departments' => Department::withCount([
                'inquiries as total',
                'inquiries as pending' => fn ($query) => $query->where('status', 'pending'),
                'inquiries as resolved' => fn ($query) => $query->where('status', 'resolved'),
            ])->orderBy('name')->get(['id', 'name']),
        ]);
    }

    public function roles(Request $request)
    {
        $this->authorizeSuperAdmin($request);

        return response()->json([
            'data' => [
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
            ],
        ]);
    }

    public function settings(Request $request)
    {
        $this->authorizeSuperAdmin($request);

        return response()->json([
            'data' => [
                'statuses' => ['pending', 'in_progress', 'answered', 'resolved', 'rejected', 'closed'],
                'categories' => ['registrar', 'enrollment', 'grades', 'scholarship', 'admission', 'finance'],
                'notifications' => ['inquiry_new', 'status_changed', 'message_new', 'inquiry_forwarded'],
            ],
        ]);
    }

    public function auditLogs(Request $request)
    {
        $this->authorizeSuperAdmin($request);

        return response()->json([
            'users' => User::latest()->limit(10)->get(['id', 'name', 'email', 'user_type', 'created_at', 'updated_at']),
            'inquiries' => Inquiry::with(['student:id,name', 'department:id,name'])
                ->latest()
                ->limit(10)
                ->get(),
            'notifications' => Notification::with('user:id,name')
                ->latest()
                ->limit(10)
                ->get(),
        ]);
    }

    public function backup(Request $request)
    {
        $this->authorizeSuperAdmin($request);

        return response()->json([
            'generated_at' => now()->toIso8601String(),
            'summary' => [
                'users' => User::count(),
                'departments' => Department::count(),
                'inquiries' => Inquiry::count(),
                'notifications' => Notification::count(),
            ],
            'data' => [
                'users' => User::with('department:id,name')->get(),
                'departments' => Department::all(),
                'inquiries' => Inquiry::with(['student:id,name,email', 'department:id,name'])->get(),
                'notifications' => Notification::latest()->limit(100)->get(),
            ],
        ]);
    }

    private function userRules(?User $user = null): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'user_identifier' => ['nullable', 'string', 'max:50', Rule::unique('users', 'user_identifier')->ignore($user)],
            'email' => ['required', 'email', 'max:255', Rule::unique('users', 'email')->ignore($user)],
            'user_type' => ['required', Rule::in(['student', 'department_admin', 'super_admin'])],
            'department_id' => ['nullable', 'required_if:user_type,department_admin', 'exists:departments,id'],
            'password' => [$user ? 'nullable' : 'required', 'confirmed', 'min:8'],
            'is_active' => ['nullable', 'boolean'],
        ];
    }

    private function departmentRules(?Department $department = null): array
    {
        return [
            'name' => ['required', 'string', 'max:255', Rule::unique('departments', 'name')->ignore($department)],
            'email' => ['required', 'email', 'max:255', Rule::unique('departments', 'email')->ignore($department)],
            'description' => ['nullable', 'string'],
            'phone' => ['nullable', 'string', 'max:50'],
            'office_hours' => ['nullable', 'string', 'max:255'],
            'is_active' => ['nullable', 'boolean'],
        ];
    }

    private function authorizeSuperAdmin(Request $request): void
    {
        if (! $request->user()?->isSuperAdmin()) {
            abort(403);
        }
    }
}
