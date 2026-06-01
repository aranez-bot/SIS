<?php

namespace Database\Seeders;

use App\Models\Department;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DepartmentSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $departments = [
            [
                'name' => 'Registrar',
                'slug' => 'registrar',
                'email' => 'registrar@school.edu',
                'description' => 'Handles student records, transcripts, and enrollment',
                'phone' => '+1-555-0101',
                'office_hours' => 'Monday - Friday, 8:00 AM - 5:00 PM',
            ],
            [
                'name' => 'Accounting',
                'slug' => 'accounting',
                'email' => 'accounting@school.edu',
                'description' => 'Manages student fees, payments, and financial matters',
                'phone' => '+1-555-0102',
                'office_hours' => 'Monday - Friday, 9:00 AM - 4:00 PM',
            ],
            [
                'name' => 'Guidance Office',
                'slug' => 'guidance',
                'email' => 'guidance@school.edu',
                'description' => 'Provides counseling and student support services',
                'phone' => '+1-555-0103',
                'office_hours' => 'Monday - Friday, 8:00 AM - 5:00 PM',
            ],
            [
                'name' => 'IT Support',
                'slug' => 'it-support',
                'email' => 'itsupport@school.edu',
                'description' => 'Technical support for students and systems',
                'phone' => '+1-555-0104',
                'office_hours' => 'Monday - Friday, 7:00 AM - 6:00 PM',
            ],
            [
                'name' => 'Scholarship Office',
                'slug' => 'scholarship',
                'email' => 'scholarship@school.edu',
                'description' => 'Manages scholarships, grants, and financial aid',
                'phone' => '+1-555-0105',
                'office_hours' => 'Monday - Friday, 9:00 AM - 4:00 PM',
            ],
            [
                'name' => 'Student Affairs',
                'slug' => 'student-affairs',
                'email' => 'affairs@school.edu',
                'description' => 'Oversees student activities and campus life',
                'phone' => '+1-555-0106',
                'office_hours' => 'Monday - Friday, 8:00 AM - 5:00 PM',
            ],
        ];

        foreach ($departments as $dept) {
            Department::updateOrCreate(
                ['slug' => $dept['slug']],
                $dept,
            );
        }
    }
}
