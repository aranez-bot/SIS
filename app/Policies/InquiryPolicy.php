<?php

namespace App\Policies;

use App\Models\Inquiry;
use App\Models\User;
use Illuminate\Auth\Access\Response;

class InquiryPolicy
{
    /**
     * Determine whether the user can view any models.
     */
    public function viewAny(User $user): bool
    {
        return false;
    }

    /**
     * Determine whether the user can view the model.
     */
    public function view(User $user, Inquiry $inquiry): bool
    {
        return $user->id === $inquiry->student_id;
    }

    /**
     * Determine whether a department admin can view the model.
     */
    public function viewAdmin(User $user, Inquiry $inquiry): bool
    {
        if ($user->isSuperAdmin()) {
            return true;
        }

        return $user->isDepartmentAdmin()
            && $user->is_active !== false
            && (int) $user->department_id === (int) $inquiry->department_id;
    }

    /**
     * Determine whether the user can create models.
     */
    public function create(User $user): bool
    {
        return $user->isStudent();
    }

    /**
     * Determine whether the user can update the model.
     */
    public function update(User $user, Inquiry $inquiry): bool
    {
        return $user->id === $inquiry->student_id && $inquiry->status === 'pending';
    }

    /**
     * Determine whether a department admin can update the model.
     */
    public function updateAdmin(User $user, Inquiry $inquiry): bool
    {
        if ($user->isSuperAdmin()) {
            return true;
        }

        return $user->isDepartmentAdmin()
            && $user->is_active !== false
            && (int) $user->department_id === (int) $inquiry->department_id;
    }

    /**
     * Determine whether the user can delete the model.
     */
    public function delete(User $user, Inquiry $inquiry): bool
    {
        return false;
    }

    /**
     * Determine whether user can send messages on this inquiry.
     */
    public function sendMessage(User $user, Inquiry $inquiry): bool
    {
        if ($user->isStudent()) {
            return $user->id === $inquiry->student_id;
        } elseif ($user->isDepartmentAdmin()) {
            return $user->is_active !== false
                && (int) $user->department_id === (int) $inquiry->department_id;
        } elseif ($user->isSuperAdmin()) {
            return true;
        }

        return false;
    }

    /**
     * Determine whether the user can restore the model.
     */
    public function restore(User $user, Inquiry $inquiry): bool
    {
        return false;
    }

    /**
     * Determine whether the user can permanently delete the model.
     */
    public function forceDelete(User $user, Inquiry $inquiry): bool
    {
        return false;
    }
}
