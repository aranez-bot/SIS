<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Inquiry extends Model
{
    protected $fillable = [
        'student_id',
        'department_id',
        'category',
        'assigned_admin_id',
        'subject',
        'description',
        'status',
        'priority',
        'resolution_notes',
        'resolved_at',
        'closed_at',
    ];

    protected $casts = [
        'resolved_at' => 'datetime',
        'closed_at' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    // Relationships

    public function student()
    {
        return $this->belongsTo(User::class, 'student_id');
    }

    public function department()
    {
        return $this->belongsTo(Department::class);
    }

    public function assignedAdmin()
    {
        return $this->belongsTo(User::class, 'assigned_admin_id');
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

    public function isPending()
    {
        return $this->status === 'pending';
    }

    public function isInProgress()
    {
        return $this->status === 'in_progress';
    }

    public function isResolved()
    {
        return $this->status === 'resolved';
    }

    public function isAnswered()
    {
        return $this->status === 'answered';
    }

    public function isRejected()
    {
        return $this->status === 'rejected';
    }

    public function isClosed()
    {
        return $this->status === 'closed';
    }
}
