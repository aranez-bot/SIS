<?php

namespace App\Services;

use App\Models\Inquiry;
use App\Models\Notification;
use App\Models\User;
use Illuminate\Database\Eloquent\Collection;

class InquiryNotificationService
{
    public function notifyInquiryCreated(Inquiry $inquiry): void
    {
        $inquiry->loadMissing(['department', 'student']);

        Notification::create([
            'user_id' => $inquiry->student_id,
            'inquiry_id' => $inquiry->id,
            'title' => 'Inquiry received',
            'message' => "Your inquiry '{$inquiry->subject}' was received by {$inquiry->department->name}.",
            'type' => 'inquiry_received',
        ]);

        foreach ($this->activeDepartmentHeads($inquiry->department_id) as $departmentHead) {
            Notification::create([
                'user_id' => $departmentHead->id,
                'inquiry_id' => $inquiry->id,
                'title' => 'New inquiry',
                'message' => "{$inquiry->student->name} submitted a new inquiry for {$inquiry->department->name}: {$inquiry->subject}.",
                'type' => 'inquiry_new',
            ]);
        }
    }

    public function notifyDepartmentHeadsOfStudentMessage(Inquiry $inquiry, User $student): void
    {
        foreach ($this->activeDepartmentHeads($inquiry->department_id) as $departmentHead) {
            Notification::create([
                'user_id' => $departmentHead->id,
                'inquiry_id' => $inquiry->id,
                'title' => 'New message',
                'message' => "{$student->name} replied to inquiry: {$inquiry->subject}.",
                'type' => 'message_new',
            ]);
        }
    }

    public function notifyStudentOfDepartmentResponse(Inquiry $inquiry, User $departmentHead): void
    {
        Notification::create([
            'user_id' => $inquiry->student_id,
            'inquiry_id' => $inquiry->id,
            'title' => 'New message',
            'message' => "{$departmentHead->name} replied to your inquiry: {$inquiry->subject}.",
            'type' => 'message_new',
        ]);
    }

    public function notifyStudentOfStatusChange(Inquiry $inquiry): void
    {
        Notification::create([
            'user_id' => $inquiry->student_id,
            'inquiry_id' => $inquiry->id,
            'title' => 'Inquiry status updated',
            'message' => "Your inquiry '{$inquiry->subject}' is now " . ucfirst(str_replace('_', ' ', $inquiry->status)) . '.',
            'type' => 'status_changed',
        ]);
    }

    private function activeDepartmentHeads(?int $departmentId = null): Collection
    {
        $query = User::query()
            ->where('user_type', 'department_admin')
            ->where('is_active', true);

        if ($departmentId !== null) {
            $query->where('department_id', $departmentId);
        }

        return $query->get();
    }
}
