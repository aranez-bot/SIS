<?php

namespace App\Http\Controllers;

use App\Models\Department;
use App\Models\Inquiry;
use App\Models\Notification;
use App\Services\InquiryNotificationService;
use Illuminate\Http\Request;

class StudentController extends Controller
{
    public function __construct(private InquiryNotificationService $notificationService)
    {
    }

    public function dashboard()
    {
        $student = auth()->user();
        $inquiries = $student->inquiries()->latest()->paginate(10);
        $unreadNotifications = $student->notifications()->where('read_at', null)->count();

        return view('student.dashboard', compact('inquiries', 'unreadNotifications'));
    }

    public function mobileApp()
    {
        $apkPath = public_path('downloads/student-inquiry.apk');
        $apkDownloadUrl = config('mobile.apk_download_url');
        $apkFileName = config('mobile.apk_file_name', 'student-inquiry.apk');
        $usesReleaseAsset = filled($apkDownloadUrl);
        $apkExists = $usesReleaseAsset || file_exists($apkPath);

        return view('student.mobile-app', [
            'apkExists' => $apkExists,
            'apkFileName' => $apkFileName,
            'apkSize' => $usesReleaseAsset
                ? 'GitHub Release'
                : ($apkExists ? $this->formatBytes(filesize($apkPath)) : null),
            'apkUpdatedAt' => $usesReleaseAsset
                ? 'Latest release'
                : ($apkExists ? date('M d, Y h:i A', filemtime($apkPath)) : null),
            'apkSource' => $usesReleaseAsset ? 'GitHub Releases' : 'Local storage',
            'apkDownloadUrl' => $usesReleaseAsset
                ? $apkDownloadUrl
                : route('mobile-app.download'),
        ]);
    }

    public function downloadMobileApp()
    {
        if (filled(config('mobile.apk_download_url'))) {
            return redirect()->away(config('mobile.apk_download_url'));
        }

        $apkPath = public_path('downloads/student-inquiry.apk');

        if (! file_exists($apkPath)) {
            return back()->withErrors([
                'apk' => 'The Android APK is not available yet. Please contact the system administrator.',
            ]);
        }

        return response()->download($apkPath, 'student-inquiry.apk', [
            'Content-Type' => 'application/vnd.android.package-archive',
        ]);
    }

    private function formatBytes(int $bytes): string
    {
        if ($bytes >= 1048576) {
            return round($bytes / 1048576, 1) . ' MB';
        }

        if ($bytes >= 1024) {
            return round($bytes / 1024, 1) . ' KB';
        }

        return $bytes . ' bytes';
    }

    public function createInquiry()
    {
        $departments = Department::where('is_active', true)->get();
        return view('student.inquiry.create', compact('departments'));
    }

    public function storeInquiry(Request $request)
    {
        $validated = $request->validate([
            'department_id' => 'required|exists:departments,id',
            'subject' => 'required|string|max:255',
            'description' => 'required|string|max:5000',
        ]);

        $inquiry = Inquiry::create([
            'student_id' => auth()->id(),
            'department_id' => $validated['department_id'],
            'subject' => $validated['subject'],
            'description' => $validated['description'],
            'status' => 'pending',
        ]);

        $this->notificationService->notifyInquiryCreated($inquiry);

        return redirect()->route('student.inquiry.show', $inquiry)
                        ->with('success', 'Inquiry submitted successfully!');
    }

    public function viewInquiry(Inquiry $inquiry)
    {
        $this->authorize('view', $inquiry);
        $messages = $inquiry->messages()->latest()->paginate(20);
        $unreadMessages = $messages->filter(fn($msg) => !$msg->isRead())->count();

        return view('student.inquiry.show', compact('inquiry', 'messages', 'unreadMessages'));
    }

    public function inquiryHistory()
    {
        $student = auth()->user();
        $baseQuery = $student->inquiries();
        $statuses = [
            'pending' => 'Pending',
            'in_progress' => 'In Progress',
            'answered' => 'Answered',
            'resolved' => 'Resolved',
            'closed' => 'Closed',
            'rejected' => 'Rejected',
        ];
        $departments = Department::where('is_active', true)->orderBy('name')->get();

        $summary = [
            'total' => (clone $baseQuery)->count(),
            'pending' => (clone $baseQuery)->where('status', 'pending')->count(),
            'in_progress' => (clone $baseQuery)->where('status', 'in_progress')->count(),
            'resolved' => (clone $baseQuery)->whereIn('status', ['resolved', 'closed'])->count(),
        ];

        $inquiries = $baseQuery
            ->with('department')
            ->withCount('messages')
            ->when(request('search'), function ($query, $search) {
                $query->where(function ($query) use ($search) {
                    $query->where('subject', 'like', "%{$search}%")
                        ->orWhere('description', 'like', "%{$search}%")
                        ->orWhere('id', $search);
                });
            })
            ->when(request('status'), fn ($query, $status) => $query->where('status', $status))
            ->when(request('department_id'), fn ($query, $departmentId) => $query->where('department_id', $departmentId))
            ->when(request('date_from'), fn ($query, $date) => $query->whereDate('created_at', '>=', $date))
            ->when(request('date_to'), fn ($query, $date) => $query->whereDate('created_at', '<=', $date))
            ->latest()
            ->paginate(12)
            ->withQueryString();

        return view('student.inquiry.history', compact('inquiries', 'summary', 'statuses', 'departments'));
    }

    public function notifications()
    {
        $student = auth()->user();
        $notifications = $student->notifications()->latest()->paginate(20);

        return view('student.notifications', compact('notifications'));
    }

    public function markNotificationRead(Notification $notification)
    {
        $this->authorize('view', $notification);
        $notification->markAsRead();

        return back()->with('success', 'Notification marked as read');
    }
}
