<?php

return [
    /*
    |--------------------------------------------------------------------------
    | Distance Calculation Formula
    |--------------------------------------------------------------------------
    |
    | Determines which formula to use for calculating distances between coordinates.
    |
    | Options:
    |   - 'st_distance_sphere' (recommended): Uses MariaDB's ST_Distance_Sphere function
    |                                         Returns meters, converted to km automatically
    |   - 'haversine': Fallback trigonometric formula with NaN protection
    |                  Use if ST_Distance_Sphere is unavailable
    |
    */
    'distance_formula' => env('DISTANCE_FORMULA', 'st_distance_sphere'),
];
