import React from 'react';

interface ToggleProps {
  checked: boolean;
  onChange: (checked: boolean) => void;
  label?: string;
  disabled?: boolean;
}

export default function Toggle({
  checked,
  onChange,
  label,
  disabled = false,
}: ToggleProps) {
  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (!disabled) {
      onChange(e.target.checked);
    }
  };

  return (
    <label className={`toggle-container ${disabled ? 'toggle-disabled' : ''}`}>
      {label && <span className="toggle-label">{label}</span>}
      <div className="toggle-switch-wrapper">
        <input
          type="checkbox"
          className="toggle-checkbox"
          checked={checked}
          onChange={handleChange}
          disabled={disabled}
        />
        <span className="toggle-slider"></span>
      </div>
    </label>
  );
}
