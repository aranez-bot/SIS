<?php

namespace Tests\Feature;

use App\Models\Department;
use App\Models\DepartmentFaq;
use App\Models\Inquiry;
use App\Models\Message;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class DepartmentAdminDashboardTest extends TestCase
{
    use RefreshDatabase;

    public function test_department_admin_can_use_dashboard_inquiry_workflows(): void
    {
        $registrar = Department::create([
            'name' => 'Registrar',
            'slug' => 'registrar',
            'email' => 'registrar@example.com',
            'is_active' => true,
        ]);
        $finance = Department::create([
            'name' => 'Finance',
            'slug' => 'finance',
            'email' => 'finance@example.com',
            'is_active' => true,
        ]);

        $admin = User::factory()->create([
            'name' => 'Registrar Admin',
            'email' => 'registrar.admin@example.com',
            'user_type' => 'department_admin',
            'department_id' => $registrar->id,
        ]);
        $financeAdmin = User::factory()->create([
            'name' => 'Finance Admin',
            'email' => 'finance.admin@example.com',
            'user_type' => 'department_admin',
            'department_id' => $finance->id,
        ]);
        $student = User::factory()->create([
            'name' => 'Maria Student',
            'email' => 'maria@example.com',
            'user_identifier' => 'STU-2026-001',
            'phone' => '09171234567',
            'address' => 'Manila City',
            'bio' => 'BSIT student',
            'user_type' => 'student',
        ]);

        $registrarInquiry = Inquiry::create([
            'student_id' => $student->id,
            'department_id' => $registrar->id,
            'category' => 'records',
            'subject' => 'Transcript request',
            'description' => 'I need my transcript.',
            'status' => 'pending',
            'priority' => 2,
        ]);
        Inquiry::create([
            'student_id' => $student->id,
            'department_id' => $finance->id,
            'category' => 'payments',
            'subject' => 'Tuition receipt',
            'description' => 'I need my receipt.',
            'status' => 'pending',
            'priority' => 1,
        ]);

        $this->actingAs($admin)
            ->get(route('admin.dashboard'))
            ->assertOk()
            ->assertSee('Registrar Dashboard')
            ->assertSee('Recent Inquiries')
            ->assertDontSee('Department Admin Dashboard Functions');

        $this->get(route('admin.inquiry.inbox'))
            ->assertOk()
            ->assertSee('Transcript request')
            ->assertDontSee('Tuition receipt');

        $this->get(route('admin.inquiry.inbox', ['search' => 'Maria', 'status' => 'pending', 'category' => 'records']))
            ->assertOk()
            ->assertSee('Transcript request');

        $this->post(route('message.store', $registrarInquiry), [
            'message' => 'Your transcript request is being checked.',
        ])->assertRedirect();

        $registrarInquiry->refresh();
        $this->assertSame('in_progress', $registrarInquiry->status);
        $this->assertSame($admin->id, $registrarInquiry->assigned_admin_id);
        $this->assertDatabaseHas('messages', [
            'inquiry_id' => $registrarInquiry->id,
            'user_id' => $admin->id,
            'message' => 'Your transcript request is being checked.',
        ]);

        $this->put(route('admin.inquiry.update-status', $registrarInquiry), [
            'status' => 'resolved',
            'resolution_notes' => 'Transcript was released to the student.',
        ])->assertRedirect();

        $this->assertDatabaseHas('inquiries', [
            'id' => $registrarInquiry->id,
            'status' => 'resolved',
            'resolution_notes' => 'Transcript was released to the student.',
        ]);

        $this->post(route('admin.faqs.store'), [
            'question' => 'How do I request a transcript?',
            'answer' => 'Submit a records inquiry with your student ID.',
            'category' => 'records',
            'is_active' => '1',
        ])->assertRedirect();

        $faq = DepartmentFaq::firstOrFail();
        $this->put(route('admin.faqs.update', $faq), [
            'question' => 'How can I request a transcript?',
            'answer' => 'Send a records inquiry and wait for confirmation.',
            'category' => 'records',
            'is_active' => '1',
        ])->assertRedirect();

        $this->assertDatabaseHas('department_faqs', [
            'id' => $faq->id,
            'question' => 'How can I request a transcript?',
        ]);

        $this->put(route('admin.inquiry.forward', $registrarInquiry), [
            'department_id' => $finance->id,
            'forward_note' => 'This is related to payment clearance.',
        ])->assertRedirect(route('admin.inquiry.inbox'));

        $this->assertDatabaseHas('inquiries', [
            'id' => $registrarInquiry->id,
            'department_id' => $finance->id,
            'assigned_admin_id' => null,
            'status' => 'pending',
        ]);
        $this->assertTrue(
            Message::where('inquiry_id', $registrarInquiry->id)
                ->where('message', 'like', '%payment clearance%')
                ->exists()
        );
        $this->assertDatabaseHas('notifications', [
            'user_id' => $financeAdmin->id,
            'inquiry_id' => $registrarInquiry->id,
            'type' => 'inquiry_forwarded',
        ]);
    }

    public function test_new_inquiries_are_visible_only_to_selected_department_heads(): void
    {
        $registrar = Department::create([
            'name' => 'Registrar',
            'slug' => 'registrar',
            'email' => 'registrar@example.com',
            'is_active' => true,
        ]);
        $finance = Department::create([
            'name' => 'Finance',
            'slug' => 'finance',
            'email' => 'finance@example.com',
            'is_active' => true,
        ]);

        $registrarHead = User::factory()->create([
            'name' => 'Registrar Head',
            'user_type' => 'department_admin',
            'department_id' => $registrar->id,
        ]);
        $financeHead = User::factory()->create([
            'name' => 'Finance Head',
            'user_type' => 'department_admin',
            'department_id' => $finance->id,
        ]);
        $student = User::factory()->create([
            'name' => 'Maria Student',
            'user_type' => 'student',
        ]);

        $this->actingAs($student)
            ->post(route('student.inquiry.store'), [
                'department_id' => $registrar->id,
                'subject' => 'Enrollment concern',
                'description' => 'I need help with my enrollment record.',
            ])
            ->assertRedirect();

        $inquiry = Inquiry::firstOrFail();

        $this->assertDatabaseHas('notifications', [
            'user_id' => $registrarHead->id,
            'inquiry_id' => $inquiry->id,
            'type' => 'inquiry_new',
        ]);
        $this->assertDatabaseMissing('notifications', [
            'user_id' => $financeHead->id,
            'inquiry_id' => $inquiry->id,
            'type' => 'inquiry_new',
        ]);

        $this->assertDatabaseHas('notifications', [
            'user_id' => $student->id,
            'inquiry_id' => $inquiry->id,
            'type' => 'inquiry_received',
        ]);

        $this->actingAs($financeHead)
            ->get(route('admin.inquiry.show', $inquiry))
            ->assertForbidden();

        $this->post(route('message.store', $inquiry), [
            'message' => 'We can help coordinate this with Registrar.',
        ])->assertForbidden();

        $this->assertDatabaseMissing('messages', [
            'inquiry_id' => $inquiry->id,
            'user_id' => $financeHead->id,
        ]);

        $this->actingAs($registrarHead)
            ->get(route('admin.inquiry.show', $inquiry))
            ->assertOk()
            ->assertSee('Enrollment concern');

        $this->post(route('message.store', $inquiry), [
            'message' => 'Registrar can help with this.',
        ])->assertRedirect();

        $this->assertDatabaseHas('messages', [
            'inquiry_id' => $inquiry->id,
            'user_id' => $registrarHead->id,
            'message' => 'Registrar can help with this.',
        ]);
    }
}
