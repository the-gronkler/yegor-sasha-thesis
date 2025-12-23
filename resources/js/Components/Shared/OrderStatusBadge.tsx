import { OrderStatusEnum } from '@/types/models';

interface Props {
  statusId: number;
  statusName?: string;
  className?: string;
}

export default function OrderStatusBadge({
  statusId,
  statusName,
  className = '',
}: Props) {
  const getStatusModifier = (id: number) => {
    switch (id) {
      case OrderStatusEnum.Placed:
      case OrderStatusEnum.Accepted:
        return 'pending';
      case OrderStatusEnum.Preparing:
        return 'preparing';
      case OrderStatusEnum.Ready:
      case OrderStatusEnum.Fulfilled:
        return 'ready';
      case OrderStatusEnum.Cancelled:
      case OrderStatusEnum.Declined:
        return 'cancelled';
      default:
        return 'completed';
    }
  };

  const modifier = getStatusModifier(statusId);

  return (
    <span className={`status-badge status-badge--${modifier} ${className}`}>
      {statusName || 'Unknown'}
    </span>
  );
}
