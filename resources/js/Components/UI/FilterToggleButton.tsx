import { FunnelIcon } from '@heroicons/react/24/outline';

interface FilterToggleButtonProps {
  onClick: () => void;
  showBadge: boolean;
}

export default function FilterToggleButton({
  onClick,
  showBadge,
}: FilterToggleButtonProps) {
  return (
    <button type="button" onClick={onClick} className="filter-toggle-btn">
      <FunnelIcon className="filter-icon" />
      <span>Filter</span>
      {showBadge && <span className="filter-badge">•</span>}
    </button>
  );
}
