<?php

namespace Tests\Feature;

use App\Models\Department;
use App\Models\Inquiry;
use App\Models\Message;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ApiInquiryTest extends TestCase
{
    use RefreshDatabase;

    public function test_student_can_login_and_manage_inquiries_through_api(): void
    {
        $department = Department::create([
            'name' => 'Registrar',
            'slug' => 'registrar',
            'email' => 'registrar@example.com',
            'is_active' => true,
        ]);

        $user = User::factory()->create([
            'email' => 'student@example.com',
            'user_type' => 'student',
        ]);

        $token = $this->postJson('/api/login', [
            'email' => 'student@example.com',
            'password' => 'password',
        ])->assertOk()->json('token');

        $headers = ['Authorization' => "Bearer {$token}"];

        $inquiryId = $this->withHeaders($headers)->postJson('/api/inquiries', [
            'department_id' => $department->id,
            'category' => 'registrar',
            'subject' => 'Transcript request',
            'description' => 'I need a copy of my transcript.',
            'priority' => 2,
        ])->assertCreated()->json('data.id');

        $this->withHeaders($headers)
            ->getJson('/api/inquiries')
            ->assertOk()
            ->assertJsonPath('data.data.0.subject', 'Transcript request');

        $this->withHeaders($headers)->putJson("/api/inquiries/{$inquiryId}", [
            'department_id' => $department->id,
            'category' => 'registrar',
            'subject' => 'Updated transcript request',
            'description' => 'I need two transcript copies.',
            'priority' => 3,
        ])->assertOk()->assertJsonPath('data.subject', 'Updated transcript request');

        $this->withHeaders($headers)
            ->deleteJson("/api/inquiries/{$inquiryId}")
            ->assertOk();

        $this->assertDatabaseMissing('inquiries', [
            'id' => $inquiryId,
            'student_id' => $user->id,
        ]);
    }

    public function test_student_can_update_profile_details_through_api(): void
    {
        User::factory()->create([
            'email' => 'student@example.com',
            'user_type' => 'student',
        ]);

        $token = $this->postJson('/api/login', [
            'email' => 'student@example.com',
            'password' => 'password',
        ])->assertOk()->json('token');

        $this->withHeaders(['Authorization' => "Bearer {$token}"])
            ->putJson('/api/profile', [
                'name' => 'Updated Student',
                'user_identifier' => 'STU-2026-001',
                'email' => 'updated.student@example.com',
                'phone' => '09171234567',
                'address' => 'Manila City',
                'bio' => 'BSIT student',
            ])
            ->assertOk()
            ->assertJsonPath('user.name', 'Updated Student')
            ->assertJsonPath('user.user_identifier', 'STU-2026-001')
            ->assertJsonPath('user.email', 'updated.student@example.com');

        $this->assertDatabaseHas('users', [
            'name' => 'Updated Student',
            'user_identifier' => 'STU-2026-001',
            'email' => 'updated.student@example.com',
        ]);
    }

    public function test_department_admin_api_only_sees_selected_department_inquiries_and_messages(): void
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
        $student = User::factory()->create([
            'name' => 'Maria Student',
            'user_type' => 'student',
        ]);

        $registrarInquiry = Inquiry::create([
            'student_id' => $student->id,
            'department_id' => $registrar->id,
            'category' => 'registrar',
            'subject' => 'Transcript request',
            'description' => 'I need a copy of my transcript.',
            'status' => 'pending',
            'priority' => 2,
        ]);
        $financeInquiry = Inquiry::create([
            'student_id' => $student->id,
            'department_id' => $finance->id,
            'category' => 'finance',
            'subject' => 'Tuition receipt',
            'description' => 'I need my payment receipt.',
            'status' => 'pending',
            'priority' => 1,
        ]);

        Message::create([
            'inquiry_id' => $registrarInquiry->id,
            'user_id' => $student->id,
            'message' => 'Student registrar message',
        ]);
        Message::create([
            'inquiry_id' => $financeInquiry->id,
            'user_id' => $student->id,
            'message' => 'Finance only message',
        ]);

        Sanctum::actingAs($registrarHead);

        $this->getJson('/api/dashboard')
            ->assertOk()
            ->assertJsonPath('counts.total', 1)
            ->assertJsonFragment(['subject' => 'Transcript request'])
            ->assertJsonMissing(['subject' => 'Tuition receipt']);

        $this->getJson('/api/inquiries')
            ->assertOk()
            ->assertJsonFragment(['subject' => 'Transcript request'])
            ->assertJsonMissing(['subject' => 'Tuition receipt']);

        $this->getJson("/api/inquiries/{$financeInquiry->id}")
            ->assertForbidden();

        $this->postJson("/api/inquiries/{$financeInquiry->id}/messages", [
            'message' => 'This should not be allowed.',
        ])->assertForbidden();

        $this->getJson("/api/inquiries/{$registrarInquiry->id}")
            ->assertOk()
            ->assertJsonFragment(['message' => 'Student registrar message'])
            ->assertJsonMissing(['message' => 'Finance only message']);

        $this->postJson("/api/inquiries/{$registrarInquiry->id}/messages", [
            'message' => 'Registrar can help with this.',
        ])->assertCreated();

        $this->assertDatabaseHas('messages', [
            'inquiry_id' => $registrarInquiry->id,
            'user_id' => $registrarHead->id,
            'message' => 'Registrar can help with this.',
        ]);
        $this->assertDatabaseMissing('messages', [
            'inquiry_id' => $financeInquiry->id,
            'user_id' => $registrarHead->id,
            'message' => 'This should not be allowed.',
        ]);
    }

    public function test_department_admin_can_send_attachment_with_response_through_api(): void
    {
        Storage::fake('public');

        $department = Department::create([
            'name' => 'IT Support',
            'slug' => 'it-support',
            'email' => 'it@example.com',
            'is_active' => true,
        ]);
        $departmentHead = User::factory()->create([
            'name' => 'IT Support Admin',
            'user_type' => 'department_admin',
            'department_id' => $department->id,
        ]);
        $student = User::factory()->create([
            'name' => 'Maria Student',
            'user_type' => 'student',
        ]);
        $inquiry = Inquiry::create([
            'student_id' => $student->id,
            'department_id' => $department->id,
            'category' => 'registrar',
            'subject' => 'Account access',
            'description' => 'I cannot open my account.',
            'status' => 'pending',
            'priority' => 2,
        ]);

        Sanctum::actingAs($departmentHead);

        $this->post("/api/inquiries/{$inquiry->id}/messages", [
            'message' => 'Please see the attached guide.',
            'attachment' => UploadedFile::fake()->create('guide.pdf', 120, 'application/pdf'),
        ])->assertCreated()
            ->assertJsonPath('data.message', 'Please see the attached guide.');

        $message = Message::where('inquiry_id', $inquiry->id)
            ->where('user_id', $departmentHead->id)
            ->firstOrFail();

        $this->assertNotNull($message->attachment_path);
        Storage::disk('public')->assertExists($message->attachment_path);
    }
}
