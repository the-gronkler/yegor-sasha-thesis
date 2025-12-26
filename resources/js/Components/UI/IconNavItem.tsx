import { Link } from '@inertiajs/react';

interface BaseIconNavProps {
  active?: boolean;
  icon: React.ElementType;
  label: string;
  badge?: number;
}

interface LinkIconNavProps extends BaseIconNavProps {
  as?: 'link';
  href: string;
  onClick?: (e: React.MouseEvent) => void;
}

interface ButtonIconNavProps extends BaseIconNavProps {
  as: 'button';
  onClick: () => void;
  href?: never;
}

export type IconNavItemProps = LinkIconNavProps | ButtonIconNavProps;

/**
 * A polymorphic navigation item that renders either an Inertia Link or a button.
 *
 * - Use `as="link"` (default) with `href` for navigation.
 * - Use `as="button"` with `onClick` for actions (e.g., Login).
 */
export default function IconNavItem(props: IconNavItemProps) {
  const { active, icon: Icon, label, badge } = props;

  const content = (
    <>
      <div className="nav-icon-wrapper">
        <Icon className="icon" aria-hidden="true" />
        {badge !== undefined && badge > 0 && (
          <span className="nav-badge">{badge > 99 ? '99+' : badge}</span>
        )}
      </div>
      <span className="label">{label}</span>
    </>
  );

  if (props.as === 'button') {
    return (
      <button
        type="button"
        className={`icon-nav-item ${active ? 'active' : ''}`}
        onClick={props.onClick}
      >
        {content}
      </button>
    );
  }

  return (
    <Link
      href={props.href}
      className={`icon-nav-item ${active ? 'active' : ''}`}
      onClick={props.onClick}
    >
      {content}
    </Link>
  );
}
