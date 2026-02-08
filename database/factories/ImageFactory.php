<?php

namespace Database\Factories;

use App\Models\Image;
use Illuminate\Database\Eloquent\Factories\Factory;

class ImageFactory extends Factory
{
    protected $model = Image::class;

    /**
     * Array of real image URLs for seeding.
     */
    protected static array $realImageUrls = [
        'https://media.istockphoto.com/id/1433432507/photo/healthy-eating-plate-with-vegan-or-vegetarian-food-in-woman-hands-healthy-plant-based-diet.jpg?s=612x612&w=0&k=20&c=kQBPg4xNIiDMZ-Uu2r37OHZDQSaRroZlxo_YLioh5tA=',
        'https://media.istockphoto.com/id/1189709277/photo/pasta-penne-with-roasted-tomato-sauce-mozzarella-cheese-grey-stone-background-top-view.jpg?s=612x612&w=0&k=20&c=5ro7Cvwx79tWpyN1r2hy3DwplFi5FuPrD_4DYD8tZpg=',
        'https://media.istockphoto.com/id/1175505781/photo/arabic-and-middle-eastern-dinner-table-hummus-tabbouleh-salad-fattoush-salad-pita-meat-kebab.jpg?s=612x612&w=0&k=20&c=N4PkdbA7Bf-WNKf2VRNz9mtZP4sxrdcsMwZ7P981ZIY=',
        'https://media.istockphoto.com/id/1165399909/photo/delicious-meal-on-a-black-plate-top-view-copy-space.jpg?s=612x612&w=0&k=20&c=vrMzS4pY_QjiDtCzpVE3ClKqbU636fb4CKH0nlsduC4=',
        'https://media.istockphoto.com/id/1143191120/photo/traditional-moroccan-tajine-of-chicken-with-dried-fruits-and-spices.jpg?s=612x612&w=0&k=20&c=KTNBlSpeS18SGMNacLGxPbVh0MRRnlPrEKL1jJAZ-es=',
        'https://media.istockphoto.com/id/104704117/photo/restaurant-plates.jpg?s=612x612&w=0&k=20&c=MhFdN_qVgzoHov-kgFx0qWSW0nZht4lZV1zinC3Ea44=',
        'https://media.istockphoto.com/id/2148684016/photo/fresh-salads-overhead-flat-lay-shot-of-an-assortment-variety-of-plates.jpg?s=612x612&w=0&k=20&c=dheesH4cORG6bq0luwwWds6KZ6_4ABqSq_i2dwmPAQc=',
        'https://media.istockphoto.com/id/643847438/photo/restaurant-chilling-out-classy-lifestyle-reserved-concept.jpg?s=612x612&w=0&k=20&c=Rjw88cVSVaEIlCqBOizOGpqxp0kcYdoDRLwfv5Cn6Sw=',
        'https://media.istockphoto.com/id/1150368715/photo/duck-leg-confit.jpg?s=612x612&w=0&k=20&c=7Q2w6FbQpJWkZqGRDF6jeTQrYc_V3IiUcRAc4nSFNZs=',
        'https://media.istockphoto.com/id/1159204281/photo/healthy-food-for-balanced-flexitarian-mediterranean-diet-concept.jpg?s=612x612&w=0&k=20&c=6QdOXtmOuhCyzEEURu9tcO1AJ1E8QJLqs2qErWJH-mU=',
        'https://media.istockphoto.com/id/2156642133/photo/variety-of-gourmet-dishes-displayed-on-a-table-showcasing-an-array-of-colors-and-textures.jpg?s=612x612&w=0&k=20&c=QPUK8edq-zbami60YvZiBOpI3RP4nwqJ43BtN11j0l0=',
        'https://media.istockphoto.com/id/665380564/photo/brunch-choice-crowd-dining-food-options-eating-concept.jpg?s=612x612&w=0&k=20&c=tmgKmbVIDTGY1LC8ATnCQtuMPJoySbZ_HAJETS2jv2E=',
        'https://media.istockphoto.com/id/1411606505/photo/waiter-adding-sauce-on-mussels-during-catering.jpg?s=612x612&w=0&k=20&c=sLY1ILsEs4knFb7VECSWUBHqr1zEpIg6JK2eE_FWVvA=',
        'https://media.istockphoto.com/id/1481644034/photo/backyard-dinner-table-with-tasty-grilled-barbecue-meat-fresh-vegetables-and-salads-happy.jpg?s=612x612&w=0&k=20&c=D6r3rg5p-54-NljBjohI-JbPqDqlR_rScMYN_UgESS0=',
        'https://media.istockphoto.com/id/1164983166/photo/traditional-georgian-cuisine-background-khinkali-phali-chahokhbili-lobio-cheese-eggplant.jpg?s=612x612&w=0&k=20&c=QeQ3SGIwmBh-uOdZf8APuOU_CFoS_z7kUj6pezzZjYs=',
    ];

    public function definition(): array
    {
        return [
            'image' => self::$realImageUrls[array_rand(self::$realImageUrls)],
            'description' => $this->faker->sentence(),
            'restaurant_id' => null,
            'is_primary_for_restaurant' => false,
        ];
    }
}
