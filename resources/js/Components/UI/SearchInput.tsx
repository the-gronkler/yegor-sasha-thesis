import { ChangeEvent } from 'react';
import { MagnifyingGlassIcon, XMarkIcon } from '@heroicons/react/24/outline';

interface SearchInputProps {
  value: string;
  onChange: (value: string) => void;
  placeholder?: string;
  className?: string;
  ariaLabel?: string;
}

export default function SearchInput({
  value,
  onChange,
  placeholder = 'Search...',
  className = '',
  ariaLabel = 'Search input',
}: SearchInputProps) {
  const handleChange = (e: ChangeEvent<HTMLInputElement>) => {
    onChange(e.target.value);
  };

  const handleClear = () => {
    onChange('');
  };

  return (
    <div className={`search-input-wrapper ${className}`}>
      <MagnifyingGlassIcon className="search-icon" aria-hidden="true" />
      <input
        type="text"
        value={value}
        onChange={handleChange}
        placeholder={placeholder}
        className="search-input"
        aria-label={ariaLabel}
      />
      {value.length > 0 && (
        <button
          type="button"
          onClick={handleClear}
          className="clear-button"
          aria-label="Clear search"
        >
          <XMarkIcon className="clear-icon" />
        </button>
      )}
    </div>
  );
}
