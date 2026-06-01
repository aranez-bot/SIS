<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class DepartmentFaq extends Model
{
    protected $fillable = [
        'department_id',
        'question',
        'answer',
        'category',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];

    public function department()
    {
        return $this->belongsTo(Department::class);
    }
}
