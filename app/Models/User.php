<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    /** @use HasFactory<UserFactory> */
    use HasApiTokens, HasFactory, Notifiable;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'name',
        'user_identifier',
        'email',
        'password',
        'user_type',
        'is_active',
        'department_id',
        'profile_photo_path',
        'phone',
        'address',
        'bio',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'is_active' => 'boolean',
        ];
    }

    // Relationships

    public function department()
    {
        return $this->belongsTo(Department::class);
    }

    public function inquiries()
    {
        return $this->hasMany(Inquiry::class, 'student_id');
    }

    public function assignedInquiries()
    {
        return $this->hasMany(Inquiry::class, 'assigned_admin_id');
    }

    public function messages()
    {
        return $this->hasMany(Message::class);
    }

    public function notifications()
    {
        return $this->hasMany(Notification::class);
    }

    // Helper methods

    public function isStudent()
    {
        return $this->user_type === 'student';
    }

    public function isDepartmentAdmin()
    {
        return $this->user_type === 'department_admin';
    }

    public function isSuperAdmin()
    {
        return $this->user_type === 'super_admin';
    }
}
