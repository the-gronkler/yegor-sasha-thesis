import { AvailableStatus } from '@/types/orders';

interface FilterPanelProps {
  showFilters: boolean;
  onClose: () => void;
  selectedStatuses: number[];
  onFilterChange: (statusId: number) => void;
  onApply: () => void;
  onShowActive: () => void;
  onShowAll: () => void;
  availableStatuses: AvailableStatus[];
  isDefaultFilter: boolean;
  isAllOrders: boolean;
}

export default function OrdersFilterPanel({
  showFilters,
  onClose,
  selectedStatuses,
  onFilterChange,
  onApply,
  onShowActive,
  onShowAll,
  availableStatuses,
  isDefaultFilter,
  isAllOrders,
}: FilterPanelProps) {
  if (!showFilters) return null;

  return (
    <div className="filter-panel">
      <div className="filter-header">
        <h3 className="filter-title">Filter Orders</h3>
      </div>

      <div className="filter-quick-actions">
        <button
          type="button"
          onClick={onShowActive}
          className={`filter-quick-btn ${isDefaultFilter ? 'active' : ''}`}
        >
          Active Orders
        </button>
        <button
          type="button"
          onClick={onShowAll}
          className={`filter-quick-btn ${isAllOrders ? 'active' : ''}`}
        >
          All Orders
        </button>
      </div>

      <div className="filter-statuses">
        <p className="filter-label">Or select specific statuses:</p>
        {availableStatuses.map((status) => (
          <label key={status.id} className="filter-checkbox">
            <input
              type="checkbox"
              checked={selectedStatuses.includes(status.id)}
              onChange={() => onFilterChange(status.id)}
            />
            <span className="checkbox-label">{status.name}</span>
            {status.isActive && (
              <span className="active-indicator">(Active)</span>
            )}
          </label>
        ))}
      </div>

      <div className="filter-actions">
        <button type="button" onClick={onClose} className="btn-secondary">
          Cancel
        </button>
        <button
          type="button"
          onClick={onApply}
          className="btn-primary"
          disabled={selectedStatuses.length === 0}
        >
          Apply Filter
        </button>
      </div>
    </div>
  );
}
