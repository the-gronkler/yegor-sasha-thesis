import { Head, Link, router } from '@inertiajs/react';
import { ArrowLeftIcon, HeartIcon } from '@heroicons/react/24/outline';
import CustomerLayout from '@/Layouts/CustomerLayout';
import { Restaurant } from '@/types/models';
import { useState, DragEvent } from 'react';
import FavoriteRestaurantCard from '@/Components/Shared/FavoriteRestaurantCard';

interface FavoritesProps {
  favorites: Restaurant[];
}

export default function Favorites({
  favorites: initialFavorites,
}: FavoritesProps) {
  const [favorites, setFavorites] = useState(initialFavorites);
  const [removingId, setRemovingId] = useState<number | null>(null);
  const [draggedId, setDraggedId] = useState<number | null>(null);
  const [isSavingOrder, setIsSavingOrder] = useState(false);

  const handleRemoveFavorite = (restaurantId: number) => {
    if (removingId) return;

    setRemovingId(restaurantId);
    router.post(
      route('restaurants.toggleFavorite', restaurantId),
      {},
      {
        preserveScroll: true,
        preserveState: false, // Let updated props re-init the component
        onFinish: () => setRemovingId(null),
      },
    );
  };

  const handleDragStart = (e: DragEvent<HTMLDivElement>, id: number) => {
    if (isSavingOrder) return;
    setDraggedId(id);
    e.dataTransfer.effectAllowed = 'move';
  };

  const handleDragOver = (e: DragEvent<HTMLDivElement>) => {
    e.preventDefault();
    e.dataTransfer.dropEffect = 'move';
  };

  const handleDrop = (e: DragEvent<HTMLDivElement>, targetId: number) => {
    e.preventDefault();

    if (isSavingOrder) {
      setDraggedId(null);
      return;
    }

    if (draggedId === null || draggedId === targetId) {
      setDraggedId(null);
      return;
    }

    // Reorder the favorites array
    const draggedIndex = favorites.findIndex((r) => r.id === draggedId);
    const targetIndex = favorites.findIndex((r) => r.id === targetId);

    if (draggedIndex === -1 || targetIndex === -1) {
      setDraggedId(null);
      return;
    }

    const newFavorites = [...favorites];
    const [removed] = newFavorites.splice(draggedIndex, 1);
    newFavorites.splice(targetIndex, 0, removed);

    // Update ranks based on new order
    const updatedFavorites = newFavorites.map((restaurant, index) => ({
      ...restaurant,
      rank: index + 1,
    }));

    setFavorites(updatedFavorites);
    setDraggedId(null);

    // Save the new order to the backend
    saveRanks(updatedFavorites);
  };

  const saveRanks = (updatedFavorites: Restaurant[]) => {
    setIsSavingOrder(true);

    const ranks = updatedFavorites.map((restaurant) => ({
      restaurant_id: restaurant.id,
      rank: restaurant.rank,
    }));

    router.put(
      route('profile.favorites.updateRanks'),
      { ranks },
      {
        preserveScroll: true,
        onFinish: () => setIsSavingOrder(false),
      },
    );
  };

  return (
    <CustomerLayout>
      <Head title="My Favorites" />

      <div className="profile-page">
        {/* Header */}
        <div className="profile-header">
          <Link href={route('profile.show')} className="back-button-link">
            <ArrowLeftIcon className="icon" />
            <span>Back</span>
          </Link>
          <h1 className="profile-title">My Favorites</h1>
        </div>

        {isSavingOrder && (
          <div className="saving-indicator">Saving order...</div>
        )}

        {/* Favorites List */}
        {favorites && favorites.length > 0 ? (
          <div className="favorites-grid">
            {favorites.map((restaurant) => (
              <FavoriteRestaurantCard
                key={restaurant.id}
                restaurant={restaurant}
                onRemove={handleRemoveFavorite}
                isRemoving={removingId === restaurant.id}
                onDragStart={handleDragStart}
                onDragOver={handleDragOver}
                onDrop={handleDrop}
                isDragging={draggedId === restaurant.id}
                isSavingOrder={isSavingOrder}
              />
            ))}
          </div>
        ) : (
          <div className="empty-favorites">
            <HeartIcon className="empty-icon" />
            <h2>No favorites yet</h2>
            <p>Start adding your favorite restaurants!</p>
            <Link href={route('restaurants.index')} className="btn-primary">
              Browse Restaurants
            </Link>
          </div>
        )}
      </div>
    </CustomerLayout>
  );
}
