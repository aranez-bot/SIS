<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('inquiries', function (Blueprint $table) {
            $table->string('category', 50)->default('registrar')->after('department_id');
        });

        if (DB::getDriverName() === 'mysql') {
            DB::statement("ALTER TABLE inquiries MODIFY status VARCHAR(32) NOT NULL DEFAULT 'pending'");
        }
    }

    public function down(): void
    {
        if (DB::getDriverName() === 'mysql') {
            DB::statement("ALTER TABLE inquiries MODIFY status ENUM('pending', 'in_progress', 'resolved', 'closed') NOT NULL DEFAULT 'pending'");
        }

        Schema::table('inquiries', function (Blueprint $table) {
            $table->dropColumn('category');
        });
    }
};
