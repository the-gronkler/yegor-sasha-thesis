export default function Button({ className = '', disabled, children, ...props }) {
    return (
        <button
            {...props}
            className={`btn-primary ${disabled ? 'disabled' : ''} ${className}`}
            disabled={disabled}
        >
            {children}
        </button>
    );
}
