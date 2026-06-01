<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Department;
use App\Models\Inquiry;
use App\Models\Message;
use App\Models\Notification;
use App\Services\InquiryNotificationService;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class InquiryController extends Controller
{
    public function __construct(private InquiryNotificationService $notificationService)
    {
    }

    public function index(Request $request)
    {
        $query = $this->visibleInquiries($request)
            ->with(['department:id,name', 'student:id,name,email', 'assignedAdmin:id,name']);

        if ($request->filled('status')) {
            $query->where('status', $request->string('status'));
        }

        if ($request->filled('category')) {
            $query->where('category', $request->string('category'));
        }

        if ($request->filled('department_id')) {
            $query->where('department_id', $request->integer('department_id'));
        }

        if ($request->filled('created_from')) {
            $query->whereDate('created_at', '>=', $request->date('created_from'));
        }

        if ($request->filled('created_to')) {
            $query->whereDate('created_at', '<=', $request->date('created_to'));
        }

        if ($request->filled('search')) {
            $search = $request->string('search');
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

        return response()->json([
            'data' => $query->latest()->paginate(15),
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'department_id' => ['required', 'exists:departments,id'],
            'category' => ['required', Rule::in($this->categories())],
            'subject' => ['required', 'string', 'max:255'],
            'description' => ['required', 'string'],
            'priority' => ['nullable', 'integer', 'min:1', 'max:5'],
        ]);

        $inquiry = Inquiry::create([
            ...$validated,
            'student_id' => $request->user()->id,
            'status' => 'pending',
            'priority' => $validated['priority'] ?? 1,
        ]);

        $this->notificationService->notifyInquiryCreated($inquiry);

        return response()->json([
            'data' => $inquiry->load(['department:id,name', 'student:id,name,email']),
        ], 201);
    }

    public function show(Request $request, Inquiry $inquiry)
    {
        $this->authorizeVisible($request, $inquiry);

        return response()->json([
            'data' => $inquiry->load([
                'department:id,name,email',
                'student:id,name,email,user_identifier,phone,address,bio',
                'assignedAdmin:id,name,email',
                'messages.user:id,name,user_type',
            ]),
        ]);
    }

    public function update(Request $request, Inquiry $inquiry)
    {
        $this->authorizeVisible($request, $inquiry);

        $user = $request->user();
        $rules = [
            'subject' => ['sometimes', 'required', 'string', 'max:255'],
            'description' => ['sometimes', 'required', 'string'],
            'department_id' => ['sometimes', 'required', 'exists:departments,id'],
            'category' => ['sometimes', 'required', Rule::in($this->categories())],
            'priority' => ['sometimes', 'integer', 'min:1', 'max:5'],
        ];

        if (! $user->isStudent()) {
            $rules['status'] = ['sometimes', Rule::in($this->statuses())];
            $rules['resolution_notes'] = ['nullable', 'string'];
        }

        $validated = $request->validate($rules);

        if ($user->isStudent() && $inquiry->student_id !== $user->id) {
            abort(403);
        }

        if (isset($validated['status'])) {
            $validated['resolved_at'] = $validated['status'] === 'resolved' ? now() : $inquiry->resolved_at;
            $validated['closed_at'] = $validated['status'] === 'closed' ? now() : $inquiry->closed_at;
            $validated['assigned_admin_id'] = $user->id;
        }

        $inquiry->update($validated);

        if (isset($validated['status'])) {
            $this->notificationService->notifyStudentOfStatusChange($inquiry);
        } elseif ($user->isStudent()) {
            Notification::create([
                'user_id' => $inquiry->student_id,
                'inquiry_id' => $inquiry->id,
                'title' => 'Inquiry updated',
                'message' => "Your inquiry '{$inquiry->subject}' was updated.",
                'type' => 'inquiry_updated',
            ]);
        }

        return response()->json([
            'data' => $inquiry->fresh(['department:id,name', 'student:id,name,email', 'assignedAdmin:id,name']),
        ]);
    }

    public function message(Request $request, Inquiry $inquiry)
    {
        $this->authorizeVisible($request, $inquiry);

        $validated = $request->validate([
            'message' => ['nullable', 'required_without:attachment', 'string', 'max:5000'],
            'attachment' => ['nullable', 'file', 'mimes:pdf,doc,docx,xls,xlsx,csv,txt,jpg,jpeg,png', 'max:5120'],
        ]);

        $attachmentPath = null;

        if ($request->hasFile('attachment')) {
            $attachmentPath = $request->file('attachment')->store('inquiry-attachments', 'public');
        }

        $message = Message::create([
            'inquiry_id' => $inquiry->id,
            'user_id' => $request->user()->id,
            'message' => $validated['message'] ?? 'Attached a file.',
            'attachment_path' => $attachmentPath,
        ]);

        if ($request->user()->isDepartmentAdmin()) {
            $inquiry->update([
                'assigned_admin_id' => $request->user()->id,
                'status' => $inquiry->status === 'pending' ? 'in_progress' : $inquiry->status,
            ]);
        }

        if ($request->user()->isStudent()) {
            $this->notificationService->notifyDepartmentHeadsOfStudentMessage($inquiry, $request->user());
        } else {
            $this->notificationService->notifyStudentOfDepartmentResponse($inquiry, $request->user());
        }

        return response()->json([
            'data' => $message->load('user:id,name,user_type'),
        ], 201);
    }

    public function forward(Request $request, Inquiry $inquiry)
    {
        $this->authorizeVisible($request, $inquiry);
        abort_if($request->user()->isStudent(), 403);

        $validated = $request->validate([
            'department_id' => ['required', 'exists:departments,id'],
            'forward_note' => ['nullable', 'string', 'max:1000'],
        ]);

        if ((int) $validated['department_id'] === (int) $inquiry->department_id) {
            return response()->json(['message' => 'Choose a different department.'], 422);
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
                'user_id' => $request->user()->id,
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
                'message' => "An inquiry was forwarded to your department: {$inquiry->subject}.",
                'type' => 'inquiry_forwarded',
            ]);
        }

        return response()->json([
            'data' => $inquiry->fresh(['department:id,name', 'student:id,name,email', 'assignedAdmin:id,name']),
        ]);
    }

    public function destroy(Request $request, Inquiry $inquiry)
    {
        $this->authorizeVisible($request, $inquiry);

        if ($request->user()->isStudent() && $inquiry->student_id !== $request->user()->id) {
            abort(403);
        }

        $inquiry->delete();

        return response()->json(['message' => 'Inquiry deleted.']);
    }

    private function visibleInquiries(Request $request)
    {
        $user = $request->user();
        $query = Inquiry::query();

        if ($user->isStudent()) {
            $query->where('student_id', $user->id);
        } elseif ($user->isDepartmentAdmin()) {
            $query->where('department_id', $user->department_id);
        }

        return $query;
    }

    private function authorizeVisible(Request $request, Inquiry $inquiry): void
    {
        $user = $request->user();

        if ($user->isSuperAdmin()) {
            return;
        }

        if ($user->isStudent() && $inquiry->student_id === $user->id) {
            return;
        }

        if (
            $user->isDepartmentAdmin()
            && $user->is_active !== false
            && (int) $user->department_id === (int) $inquiry->department_id
        ) {
            return;
        }

        abort(403);
    }

    private function categories(): array
    {
        return ['enrollment', 'grades', 'scholarship', 'admission', 'finance', 'registrar'];
    }

    private function statuses(): array
    {
        return ['pending', 'in_progress', 'resolved', 'closed'];
    }
}
