<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Seed departments first
        $this->call(DepartmentSeeder::class);

        // Create or update test users for different roles.
        User::updateOrCreate([
            'email' => 'superadmin@example.com',
        ], [
            'name' => 'Super Admin',
            'user_type' => 'super_admin',
            'department_id' => null,
            'password' => Hash::make('password'),
        ]);

        $departmentAdmins = [
            'registrar' => ['Registrar Admin', 'registrar@example.com'],
            'accounting' => ['Accounting Admin', 'accounting@example.com'],
            'guidance' => ['Guidance Admin', 'guidance@example.com'],
            'it-support' => ['IT Support Admin', 'itsupport@example.com'],
            'scholarship' => ['Scholarship Admin', 'scholarship@example.com'],
            'student-affairs' => ['Student Affairs Admin', 'studentaffairs@example.com'],
        ];

        foreach ($departmentAdmins as $slug => [$name, $email]) {
            $department = \App\Models\Department::where('slug', $slug)->first();

            if (! $department) {
                continue;
            }

            User::updateOrCreate([
                'email' => $email,
            ], [
                'name' => $name,
                'user_type' => 'department_admin',
                'department_id' => $department->id,
                'password' => Hash::make('password'),
            ]);
        }

        User::updateOrCreate([
            'email' => 'student@example.com',
        ], [
            'name' => 'John Doe',
            'user_type' => 'student',
            'department_id' => null,
            'password' => Hash::make('password'),
        ]);
    }
}
