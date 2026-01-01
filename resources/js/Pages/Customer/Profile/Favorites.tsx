import { Head, Link, router } from '@inertiajs/react';
import { ArrowLeftIcon, HeartIcon } from '@heroicons/react/24/outline';
import AppLayout from '@/Layouts/AppLayout';
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
  const [dragOverId, setDragOverId] = useState<number | null>(null);
  const [dropPosition, setDropPosition] = useState<'before' | 'after' | null>(
    null,
  );
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
        onSuccess: () => {
          // Update local state + re-rank immediately for better UX
          setFavorites((prev) =>
            prev
              .filter((r) => r.id !== restaurantId)
              .map((r, i) => ({ ...r, rank: i + 1 })),
          );
        },
        onFinish: () => setRemovingId(null),
      },
    );
  };

  const handleDragStart = (e: DragEvent<HTMLDivElement>, id: number) => {
    if (isSavingOrder) return;
    setDraggedId(id);
    e.dataTransfer.effectAllowed = 'move';
  };

  const handleDragOver = (e: DragEvent<HTMLDivElement>, targetId: number) => {
    e.preventDefault();
    e.dataTransfer.dropEffect = 'move';

    if (isSavingOrder || draggedId === null || draggedId === targetId) {
      if (dragOverId !== null) setDragOverId(null);
      if (dropPosition !== null) setDropPosition(null);
      return;
    }

    const rect = e.currentTarget.getBoundingClientRect();
    const isBefore = e.clientY < rect.top + rect.height / 2;
    const nextPos: 'before' | 'after' = isBefore ? 'before' : 'after';

    // Avoid extra re-renders while dragover fires repeatedly
    if (dragOverId !== targetId) setDragOverId(targetId);
    if (dropPosition !== nextPos) setDropPosition(nextPos);
  };

  const handleDragLeave = (e: DragEvent<HTMLDivElement>, targetId: number) => {
    // If we moved into a child element, ignore (common with dragleave)
    const related = e.relatedTarget as Node | null;
    if (related && e.currentTarget.contains(related)) return;

    if (dragOverId === targetId) {
      setDragOverId(null);
      setDropPosition(null);
    }
  };

  const handleDrop = (e: DragEvent<HTMLDivElement>, targetId: number) => {
    e.preventDefault();

    if (isSavingOrder) {
      setDraggedId(null);
      setDragOverId(null);
      setDropPosition(null);
      return;
    }

    if (draggedId === null || draggedId === targetId) {
      setDraggedId(null);
      setDragOverId(null);
      setDropPosition(null);
      return;
    }

    const draggedIndex = favorites.findIndex((r) => r.id === draggedId);
    const targetIndex = favorites.findIndex((r) => r.id === targetId);

    if (draggedIndex === -1 || targetIndex === -1) {
      setDraggedId(null);
      setDragOverId(null);
      setDropPosition(null);
      return;
    }

    const newFavorites = [...favorites];
    const [removed] = newFavorites.splice(draggedIndex, 1);

    // compute insertion index depending on before/after
    const targetIndexAfterRemoval = newFavorites.findIndex(
      (r) => r.id === targetId,
    );
    const insertAt =
      dropPosition === 'after'
        ? targetIndexAfterRemoval + 1
        : targetIndexAfterRemoval;

    newFavorites.splice(insertAt, 0, removed);

    const updatedFavorites = newFavorites.map((restaurant, index) => ({
      ...restaurant,
      rank: index + 1,
    }));

    setFavorites(updatedFavorites);
    setDraggedId(null);
    setDragOverId(null);
    setDropPosition(null);

    saveRanks(updatedFavorites);
  };

  // _e is unused but is there to match the FavoriteRestaurantCard interface signature, standard practice :P
  const handleDragEnd = (_e: DragEvent<HTMLDivElement>) => {
    setDraggedId(null);
    setDragOverId(null);
    setDropPosition(null);
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
    <AppLayout>
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
                onDragLeave={handleDragLeave}
                onDrop={handleDrop}
                onDragEnd={handleDragEnd}
                isDragging={draggedId === restaurant.id}
                isDropTarget={dragOverId === restaurant.id}
                dropPosition={
                  dragOverId === restaurant.id ? dropPosition : null
                }
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
    </AppLayout>
  );
}
