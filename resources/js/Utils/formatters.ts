//  TODO: implement localization here
export const formatDateTime = (dateString: string): string => {
  return new Date(dateString).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: 'numeric',
    minute: '2-digit',
  });
};

export const formatCurrency = (amount: number): string => {
  return `€${amount.toFixed(2)}`;
};
