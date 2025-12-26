<?php

namespace App\Services\Results;

use App\Models\Review;

readonly class ReviewOperationResult
{
    public function __construct(
        public Review $review,
        public array $uploadErrors = []
    ) {}
}
