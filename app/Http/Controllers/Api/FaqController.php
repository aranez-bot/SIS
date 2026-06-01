<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\DepartmentFaq;
use Illuminate\Http\Request;

class FaqController extends Controller
{
    public function __invoke()
    {
        return response()->json([
            'data' => [
                [
                    'question' => 'How do I submit an inquiry?',
                    'answer' => 'Open Create, choose a department and category, then describe your concern clearly before submitting.',
                ],
                [
                    'question' => 'Where can I track my inquiry status?',
                    'answer' => 'Open Inquiry History or the Dashboard. Each inquiry shows whether it is pending, in progress, answered, resolved, or rejected.',
                ],
                [
                    'question' => 'How will I know if a department replied?',
                    'answer' => 'You will receive a notification alert. Open the inquiry details to read department responses and instructions.',
                ],
                [
                    'question' => 'Can I edit my inquiry?',
                    'answer' => 'You can update your submitted inquiry while it is still visible to your account. Use the edit action in Inquiry History.',
                ],
                [
                    'question' => 'What category should I choose?',
                    'answer' => 'Choose enrollment, grades, scholarship, admission, finance, or registrar based on the main topic of your concern.',
                ],
            ],
        ]);
    }

    public function departmentIndex(Request $request)
    {
        $department = $request->user()->department;

        abort_unless($department, 403);

        return response()->json([
            'data' => $department->faqs()->latest()->get(),
        ]);
    }

    public function storeDepartment(Request $request)
    {
        $department = $request->user()->department;

        abort_unless($department, 403);

        $validated = $request->validate([
            'question' => ['required', 'string', 'max:255'],
            'answer' => ['required', 'string', 'max:5000'],
            'category' => ['nullable', 'string', 'max:80'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $faq = $department->faqs()->create([
            ...$validated,
            'is_active' => $request->boolean('is_active', true),
        ]);

        return response()->json(['data' => $faq], 201);
    }

    public function updateDepartment(Request $request, DepartmentFaq $faq)
    {
        abort_unless($faq->department_id === $request->user()->department_id, 403);

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

        return response()->json(['data' => $faq->fresh()]);
    }

    public function deleteDepartment(Request $request, DepartmentFaq $faq)
    {
        abort_unless($faq->department_id === $request->user()->department_id, 403);

        $faq->delete();

        return response()->json(['message' => 'FAQ deleted.']);
    }
}
