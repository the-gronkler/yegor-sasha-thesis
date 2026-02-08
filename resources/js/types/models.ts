export interface PaginatedResponse<T> {
  data: T[];
  current_page: number;
  first_page_url: string;
  from: number;
  last_page: number;
  last_page_url: string;
  links: { url: string | null; label: string; active: boolean }[];
  next_page_url: string | null;
  path: string;
  per_page: number;
  prev_page_url: string | null;
  to: number;
  total: number;
}

export enum OrderStatusEnum {
  InCart = 1,
  Placed = 2,
  Accepted = 3,
  Declined = 4,
  Preparing = 5,
  Ready = 6,
  Cancelled = 7,
  Fulfilled = 8,
}

export interface User {
  id: number;
  name: string;
  surname: string | null;
  email: string;
  email_verified_at: string | null;
  is_admin: boolean;
  created_at: string;
  updated_at: string;
}

export interface Customer {
  user_id: number;
  payment_method_token: string | null;
  created_at: string;
  updated_at: string;
}

export interface Employee {
  user_id: number;
  restaurant_id: number;
  is_admin: boolean;
  name: string;
  surname: string | null;
  email: string;
  created_at: string;
  updated_at: string;
}

export interface Image {
  id: number;
  url: string;
  description?: string;
  restaurant_id?: number | null;
  menu_item_id?: number | null;
  is_primary_for_restaurant?: boolean;
  is_primary_for_menu_item?: boolean;
  created_at: string;
  updated_at: string;
}

export interface Allergen {
  id: number;
  name: string;
}

export interface MenuItem {
  id: number;
  restaurant_id: number;
  food_type_id: number;
  name: string;
  price: number;
  description: string | null;
  is_available: boolean;
  image_id: number | null;
  image?: Image; // The selected image
  images?: Image[]; // All images (legacy, may not be used)
  allergens?: Allergen[];
  pivot?: {
    quantity: number;
  };
  created_at: string;
  updated_at: string;
}

export interface FoodType {
  id: number;
  name: string;
  menu_items: MenuItem[];
}

export interface Restaurant {
  id: number;
  name: string;
  address: string;
  latitude: number | null;
  longitude: number | null;
  description: string | null;
  rating: number | null;
  reviews_count?: number;
  opening_hours: string | null;
  rank?: number;
  distance?: number | null; // Distance in kilometers when filtered by geolocation
  is_favorited?: boolean; // Whether the current user has favorited this restaurant
  images?: Image[];
  food_types?: FoodType[];
  restaurant_images?: Image[];
  reviews?: Review[];
  employees?: Employee[];
  created_at: string;
  updated_at: string;
}

export interface OrderStatus {
  id: number;
  name: string;
}

export interface Order {
  id: number;
  restaurant_id: number;
  customer_user_id: number;
  order_status_id: number;
  notes: string | null;
  time_placed: string;
  created_at: string;
  updated_at: string;
  restaurant?: Restaurant;
  status?: OrderStatus;
  menu_items?: MenuItem[];
}

export interface Review {
  id: number;
  customer_user_id: number;
  restaurant_id: number;
  rating: number;
  title: string | null;
  content: string | null;
  created_at: string;
  updated_at: string;
  customer?: Customer;
  restaurant?: Restaurant;
  images?: Image[];
  user_name?: string;
}

export interface MapMarker {
  id: number;
  lat: number;
  lng: number;
  name: string;

  // Popup data (optional for user marker)
  address?: string | null;
  openingHours?: string | null;
  rating?: number | null;
  reviewsCount?: number | null;
  distanceKm?: number | null;
  imageUrl?: string | null;
}
