import { PageProps } from '@/types';

export interface OrderItem {
  id: number;
  name: string;
  quantity: number;
  price: number;
}

export interface Order {
  id: number;
  customer_name: string;
  customer_email: string;
  status_id: number;
  status_name: string;
  time_placed: string;
  notes: string | null;
  items: OrderItem[];
  total: number;
}

export interface OrdersByStatus {
  new: Order[];
  accepted: Order[];
  declined: Order[];
  preparing: Order[];
  ready: Order[];
  cancelled: Order[];
  fulfilled: Order[];
}

export interface AvailableStatus {
  id: number;
  name: string;
  isActive: boolean;
}

export interface OrdersProps extends PageProps {
  orders: Order[];
  ordersByStatus: OrdersByStatus;
  availableStatuses: AvailableStatus[];
  currentFilter: number[];
  defaultActiveStatuses: number[];
}
