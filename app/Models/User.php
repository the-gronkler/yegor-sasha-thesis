<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

/**
 * @property int $id
 * @property bool $is_admin
 */
class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'surname',
        'email',
        'password',
        'is_admin',
        'email_verified_at',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    /**
     * Get the customer profile for this user (if applicable).
     */
    public function customer(): HasOne
    {
        return $this->hasOne(Customer::class, 'user_id');
    }

    /**
     * Get the employee profile for this user (if applicable).
     */
    public function employee(): HasOne
    {
        return $this->hasOne(Employee::class, 'user_id');
    }

    /**
     * Determine if the user is a customer.
     */
    public function isCustomer(): bool
    {
        return $this->customer()->exists();
    }

    /**
     * Determine if the user is an employee.
     */
    public function isEmployee(): bool
    {
        return $this->employee()->exists();
    }
}
