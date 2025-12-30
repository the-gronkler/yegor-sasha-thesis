<?php

// Default seeding configuration values
return [
    'center_lat' => 52.2297, // Warsaw city centre latitude
    'center_lon' => 21.0122, // Warsaw city centre longitude
    'radius' => 10, // km
    'restaurants' => 10,
    'customers' => 5,
    'employees_min' => 2, // Minimum employees per restaurant (excluding admin)
    'employees_max' => 14, // Maximum employees per restaurant (excluding admin)
    'reviews_per_customer' => 2, // Number of reviews each customer creates
    'orders_per_customer' => 4, // Number of orders each customer has
];
