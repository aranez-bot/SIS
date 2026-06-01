<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Department extends Model
{
    protected $fillable = [
        'name',
        'slug',
        'email',
        'description',
        'phone',
        'office_hours',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];

    // Relationships

    public function admins()
    {
        return $this->hasMany(User::class)->where('user_type', 'department_admin');
    }

    public function inquiries()
    {
        return $this->hasMany(Inquiry::class);
    }

    public function faqs()
    {
        return $this->hasMany(DepartmentFaq::class);
    }

    public function users()
    {
        return $this->hasMany(User::class);
    }
}
