import { ButtonHTMLAttributes } from "react";

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
    className?: string;
}

export default function Button({
    className = "",
    disabled,
    children,
    ...props
}: ButtonProps) {
    return (
        <button
            {...props}
            className={`btn-primary ${disabled ? "disabled" : ""} ${className}`}
            disabled={disabled}
        >
            {children}
        </button>
    );
}
