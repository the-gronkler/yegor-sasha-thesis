import React from 'react';
import { Head, Link } from '@inertiajs/react';
import CustomerLayout from '@/Layouts/CustomerLayout';
import StarRating from '@/Components/Shared/StarRating';
import MenuItemCard from '@/Components/Shared/MenuItemCard';
import useTranslation from '@/Hooks/useTranslation';

export default function RestaurantShow({ restaurant }) {
    const { t } = useTranslation();
    const primaryImage = restaurant.restaurant_images.find(img => img.is_primary_for_restaurant) || restaurant.restaurant_images[0];
    const bannerUrl = primaryImage ? `/storage/${primaryImage.url}` : null;

    return (
        <CustomerLayout>
            <Head title={restaurant.name} />

            <div className="restaurant-show-page">
                {/* Banner */}
                <div
                    className="restaurant-banner"
                    style={bannerUrl ? { backgroundImage: `url(${bannerUrl})` } : {}}
                >
                    <div className="banner-actions">
                        <Link href={route('restaurants.index')} className="back-button">
                            ←
                        </Link>
                    </div>
                </div>

                {/* Info Card */}
                <div className="restaurant-info-card">
                    <h1 className="restaurant-name">{restaurant.name}</h1>
                    <div className="favorite-button">♡</div>

                    <div style={{ display: 'flex', justifyContent: 'center', marginBottom: '0.5rem' }}>
                        <StarRating rating={restaurant.rating} />
                    </div>

                    <div className="info-row">
                        <span>{t('Open')} 12:00 - 21:00</span> {/* Placeholder data */}
                        <span>~3km</span> {/* Placeholder data */}
                    </div>

                    <p className="restaurant-description">
                        {restaurant.description || t('DefaultRestaurantDescription')}
                    </p>
                </div>

                {/* Search */}
                <div className="menu-search">
                    <input type="text" placeholder={t('SearchMenu')} />
                </div>

                {/* Menu Categories */}
                {restaurant.food_types.map((category) => (
                    <div key={category.id} className="menu-category">
                        <h3 className="category-title">{category.name}</h3>

                        <div className="menu-items-list">
                            {category.menu_items.map((item) => (
                                <MenuItemCard key={item.id} item={item} />
                            ))}
                        </div>
                    </div>
                ))}
            </div>
        </CustomerLayout>
    );
}
