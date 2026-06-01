<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Inquiry;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    public function __invoke(Request $request)
    {
        $query = $this->visibleInquiries($request);

        return response()->json([
            'counts' => [
                'total' => (clone $query)->count(),
                'pending' => (clone $query)->where('status', 'pending')->count(),
                'in_progress' => (clone $query)->where('status', 'in_progress')->count(),
                'answered' => (clone $query)->where('status', 'answered')->count(),
                'resolved' => (clone $query)->where('status', 'resolved')->count(),
                'rejected' => (clone $query)->where('status', 'rejected')->count(),
                'closed' => (clone $query)->where('status', 'closed')->count(),
            ],
            'unread_notifications' => $request->user()->notifications()->whereNull('read_at')->count(),
            'recent_notifications' => $request->user()->notifications()
                ->with('inquiry:id,subject,status')
                ->latest()
                ->limit(5)
                ->get(),
            'recent' => (clone $query)
                ->with(['department:id,name', 'student:id,name'])
                ->latest()
                ->limit(5)
                ->get(),
        ]);
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
}
