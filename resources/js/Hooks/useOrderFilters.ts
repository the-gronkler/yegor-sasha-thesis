import { useState, useEffect, useMemo } from 'react';
import { AvailableStatus } from '@/types/orders';

interface UseOrderFiltersProps {
  currentFilter: number[];
  defaultActiveStatuses: number[];
  availableStatuses: AvailableStatus[];
  onApplyFilter: (statuses: number[]) => void;
  onShowActive: () => void;
  onShowAll: () => void;
}

export const useOrderFilters = ({
  currentFilter,
  defaultActiveStatuses,
  availableStatuses,
  onApplyFilter,
  onShowActive,
  onShowAll,
}: UseOrderFiltersProps) => {
  const [showFilters, setShowFilters] = useState(false);

  // Ensure currentFilter is always an array (safety check)
  const filterArray = Array.isArray(currentFilter) ? currentFilter : [];

  // Create a stable reference for the filter array
  const filterKey = useMemo(
    () => [...filterArray].sort((a, b) => a - b).join(','),
    [filterArray.join(',')],
  );

  const [selectedStatuses, setSelectedStatuses] =
    useState<number[]>(filterArray);

  // Sync selectedStatuses with currentFilter when it changes (from server response)
  useEffect(() => {
    setSelectedStatuses(filterArray);
  }, [filterKey]);

  // Create stable keys for filter comparisons
  const defaultFilterKey = useMemo(
    () => [...defaultActiveStatuses].sort((a, b) => a - b).join(','),
    [defaultActiveStatuses.join(',')],
  );

  const allStatusIds = useMemo(
    () => availableStatuses.map((s) => s.id),
    [availableStatuses.length],
  );

  const allStatusKey = useMemo(
    () => [...allStatusIds].sort((a, b) => a - b).join(','),
    [allStatusIds.join(',')],
  );

  const isDefaultFilter = filterKey === defaultFilterKey;
  const isAllOrders = filterKey === allStatusKey;

  const handleFilterChange = (statusId: number) => {
    const newStatuses = selectedStatuses.includes(statusId)
      ? selectedStatuses.filter((id) => id !== statusId)
      : [...selectedStatuses, statusId];

    setSelectedStatuses(newStatuses);
  };

  const applyFilter = () => {
    onApplyFilter(selectedStatuses);
    setShowFilters(false);
  };

  const showActiveOnly = () => {
    // Update checkboxes to match active statuses
    setSelectedStatuses(defaultActiveStatuses);
    onShowActive();
    setShowFilters(false);
  };

  const showAllOrders = () => {
    // Update checkboxes to select all statuses
    setSelectedStatuses(allStatusIds);
    onShowAll();
    setShowFilters(false);
  };

  return {
    selectedStatuses,
    showFilters,
    setShowFilters,
    handleFilterChange,
    applyFilter,
    showActiveOnly,
    showAllOrders,
    isDefaultFilter,
    isAllOrders,
    filterArray,
  };
};
