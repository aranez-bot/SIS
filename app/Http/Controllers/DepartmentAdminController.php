<?php

namespace App\Http\Controllers;

use App\Models\Inquiry;
use App\Models\Message;
use App\Models\Notification;
use App\Models\Department;
use App\Models\DepartmentFaq;
use App\Services\InquiryNotificationService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class DepartmentAdminController extends Controller
{
    public function __construct(private InquiryNotificationService $notificationService)
    {
    }

    public function dashboard()
    {
        $admin = auth()->user();
        $department = $this->currentDepartment();
        $inquiries = $department->inquiries()->with('student')->latest()->paginate(10);
        $pendingCount = $department->inquiries()->where('status', 'pending')->count();
        $inProgressCount = $department->inquiries()->where('status', 'in_progress')->count();
        $resolvedCount = $department->inquiries()->where('status', 'resolved')->count();
        $closedCount = $department->inquiries()->where('status', 'closed')->count();
        $totalCount = $department->inquiries()->count();
        $unreadNotifications = $admin->notifications()->where('read_at', null)->count();
        $frequentCategories = $department->inquiries()
            ->select('category', DB::raw('COUNT(*) as total'))
            ->groupBy('category')
            ->orderByDesc('total')
            ->limit(5)
            ->get();
        $frequentConcerns = $department->inquiries()
            ->select('subject', DB::raw('COUNT(*) as total'))
            ->groupBy('subject')
            ->orderByDesc('total')
            ->limit(5)
            ->get();
        $recentFaqs = $department->faqs()->latest()->limit(5)->get();

        return view('admin.dashboard', compact(
            'department',
            'inquiries',
            'totalCount',
            'pendingCount',
            'inProgressCount',
            'resolvedCount',
            'closedCount',
            'unreadNotifications',
            'frequentCategories',
            'frequentConcerns',
            'recentFaqs'
        ));
    }

    public function inquiryInbox(Request $request)
    {
        $department = $this->currentDepartment();
        $query = Inquiry::query()
            ->with(['student', 'assignedAdmin', 'department'])
            ->where('department_id', $department->id)
            ->latest();

        if ($request->filled('search')) {
            $search = trim((string) $request->string('search'));
            $query->where(function ($inner) use ($search) {
                $inner->where('subject', 'like', "%{$search}%")
                    ->orWhere('description', 'like', "%{$search}%")
                    ->orWhereHas('student', function ($student) use ($search) {
                        $student->where('name', 'like', "%{$search}%")
                            ->orWhere('email', 'like', "%{$search}%")
                            ->orWhere('user_identifier', 'like', "%{$search}%");
                    });
            });
        }

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        if ($request->filled('category')) {
            $query->where('category', $request->category);
        }

        if ($request->filled('date_from')) {
            $query->whereDate('created_at', '>=', $request->date_from);
        }

        if ($request->filled('date_to')) {
            $query->whereDate('created_at', '<=', $request->date_to);
        }

        $inquiries = $query->paginate(20)->withQueryString();
        $categories = Inquiry::query()
            ->select('category')
            ->where('department_id', $department->id)
            ->whereNotNull('category')
            ->distinct()
            ->orderBy('category')
            ->pluck('category');
        $statuses = $this->inquiryStatuses();

        return view('admin.inquiry.inbox', compact('inquiries', 'categories', 'statuses'));
    }

    public function viewInquiry(Inquiry $inquiry)
    {
        $this->authorize('viewAdmin', $inquiry);
        $inquiry->load(['student', 'department']);
        $messages = $inquiry->messages()->with('user')->oldest()->paginate(20);
        $departments = Department::where('is_active', true)
            ->whereKeyNot($inquiry->department_id)
            ->orderBy('name')
            ->get();
        $statuses = $this->inquiryStatuses();

        return view('admin.inquiry.show', compact('inquiry', 'messages', 'departments', 'statuses'));
    }

    public function updateInquiryStatus(Request $request, Inquiry $inquiry)
    {
        $this->authorize('updateAdmin', $inquiry);

        $validated = $request->validate([
            'status' => 'required|in:pending,in_progress,resolved,closed',
            'resolution_notes' => 'nullable|string|max:5000',
        ]);

        $inquiry->update([
            'status' => $validated['status'],
            'resolution_notes' => $validated['resolution_notes'] ?? $inquiry->resolution_notes,
            'assigned_admin_id' => auth()->id(),
            'resolved_at' => $validated['status'] === 'resolved' ? ($inquiry->resolved_at ?? now()) : null,
            'closed_at' => $validated['status'] === 'closed' ? ($inquiry->closed_at ?? now()) : null,
        ]);

        $this->notificationService->notifyStudentOfStatusChange($inquiry);

        return back()->with('success', 'Inquiry status updated successfully!');
    }

    public function forwardInquiry(Request $request, Inquiry $inquiry)
    {
        $this->authorize('updateAdmin', $inquiry);

        $validated = $request->validate([
            'department_id' => ['required', 'exists:departments,id'],
            'forward_note' => ['nullable', 'string', 'max:1000'],
        ]);

        if ((int) $validated['department_id'] === (int) $inquiry->department_id) {
            return back()->withErrors(['department_id' => 'Choose a different department to forward this inquiry.']);
        }

        $oldDepartment = $inquiry->department->name;
        $newDepartment = Department::with('admins')->findOrFail($validated['department_id']);
        $inquiry->update([
            'department_id' => $newDepartment->id,
            'assigned_admin_id' => null,
            'status' => 'pending',
            'resolved_at' => null,
            'closed_at' => null,
        ]);

        if (!empty($validated['forward_note'])) {
            Message::create([
                'inquiry_id' => $inquiry->id,
                'user_id' => auth()->id(),
                'message' => "Forward note from {$oldDepartment} to {$newDepartment->name}: {$validated['forward_note']}",
            ]);
        }

        Notification::create([
            'user_id' => $inquiry->student_id,
            'inquiry_id' => $inquiry->id,
            'title' => 'Inquiry forwarded',
            'message' => "Your inquiry was forwarded from {$oldDepartment} to {$newDepartment->name}.",
            'type' => 'inquiry_forwarded',
        ]);

        foreach ($newDepartment->admins as $admin) {
            Notification::create([
                'user_id' => $admin->id,
                'inquiry_id' => $inquiry->id,
                'title' => 'Forwarded inquiry received',
                'message' => "An inquiry was forwarded to your department: {$inquiry->subject}."
                    . (!empty($validated['forward_note']) ? " Note: {$validated['forward_note']}" : ''),
                'type' => 'inquiry_forwarded',
            ]);
        }

        return redirect()->route('admin.inquiry.inbox')->with('success', 'Inquiry forwarded successfully.');
    }

    public function statistics()
    {
        $department = $this->currentDepartment();

        $stats = [
            'total' => $department->inquiries()->count(),
            'pending' => $department->inquiries()->where('status', 'pending')->count(),
            'in_progress' => $department->inquiries()->where('status', 'in_progress')->count(),
            'resolved' => $department->inquiries()->where('status', 'resolved')->count(),
            'closed' => $department->inquiries()->where('status', 'closed')->count(),
        ];
        $frequentCategories = $department->inquiries()
            ->select('category', DB::raw('COUNT(*) as total'))
            ->groupBy('category')
            ->orderByDesc('total')
            ->get();
        $frequentConcerns = $department->inquiries()
            ->select('subject', DB::raw('COUNT(*) as total'))
            ->groupBy('subject')
            ->orderByDesc('total')
            ->limit(10)
            ->get();

        return view('admin.statistics', compact('stats', 'frequentCategories', 'frequentConcerns'));
    }

    public function notifications()
    {
        $admin = auth()->user();
        $notifications = $admin->notifications()->latest()->paginate(20);

        return view('admin.notifications', compact('notifications'));
    }

    public function faqs()
    {
        $department = $this->currentDepartment();
        $faqs = $department->faqs()->latest()->paginate(15);

        return view('admin.faqs.index', compact('department', 'faqs'));
    }

    public function storeFaq(Request $request)
    {
        $department = $this->currentDepartment();

        $validated = $request->validate([
            'question' => ['required', 'string', 'max:255'],
            'answer' => ['required', 'string', 'max:5000'],
            'category' => ['nullable', 'string', 'max:80'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $department->faqs()->create([
            ...$validated,
            'is_active' => $request->boolean('is_active', true),
        ]);

        return back()->with('success', 'FAQ added successfully.');
    }

    public function updateFaq(Request $request, DepartmentFaq $faq)
    {
        abort_unless($faq->department_id === auth()->user()->department_id, 403);

        $validated = $request->validate([
            'question' => ['required', 'string', 'max:255'],
            'answer' => ['required', 'string', 'max:5000'],
            'category' => ['nullable', 'string', 'max:80'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $faq->update([
            ...$validated,
            'is_active' => $request->boolean('is_active'),
        ]);

        return back()->with('success', 'FAQ updated successfully.');
    }

    public function deleteFaq(DepartmentFaq $faq)
    {
        abort_unless($faq->department_id === auth()->user()->department_id, 403);

        $faq->delete();

        return back()->with('success', 'FAQ deleted successfully.');
    }

    private function currentDepartment(): Department
    {
        $department = auth()->user()->department;

        abort_unless($department, 403, 'Your admin account is not assigned to a department.');

        return $department;
    }

    private function inquiryStatuses(): array
    {
        return [
            'pending' => 'Pending',
            'in_progress' => 'In Progress',
            'resolved' => 'Resolved',
            'closed' => 'Closed',
        ];
    }

}
