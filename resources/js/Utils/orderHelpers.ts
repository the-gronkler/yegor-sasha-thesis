import { MenuItem } from '@/types/models';

export const calculateOrderTotal = (items: MenuItem[] | undefined): number => {
  if (!items) return 0;
  return items.reduce((total, item) => {
    return total + item.price * (item.pivot?.quantity || 0);
  }, 0);
};

export const calculateOrderItemCount = (
  items: MenuItem[] | undefined,
): number => {
  if (!items) return 0;
  return items.reduce((sum, item) => {
    return sum + (item.pivot?.quantity || 0);
  }, 0);
};
