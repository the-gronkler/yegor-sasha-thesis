<?php

namespace App\Enums;

enum OrderStatus: int
{
    case InCart = 1;
    case Placed = 2;
    case Accepted = 3;
    case Declined = 4;
    case Preparing = 5;
    case Ready = 6;
    case Cancelled = 7;
    case Fulfilled = 8;

    public function label(): string
    {
        return match($this) {
            self::InCart => 'in Cart',
            self::Placed => 'Placed',
            self::Accepted => 'Accepted',
            self::Declined => 'Declined',
            self::Preparing => 'Preparing',
            self::Ready => 'Ready',
            self::Cancelled => 'Cancelled',
            self::Fulfilled => 'Fulfilled',
        };
    }
}
