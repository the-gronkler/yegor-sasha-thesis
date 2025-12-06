import { Link } from '@inertiajs/react';
import useTranslation from '@/Hooks/useTranslation';

export default function CustomerLayout({ children }) {
    const { t } = useTranslation();

    return (
        <div className="customer-layout">
            <main className="main-content">{children}</main>

            <nav className="bottom-nav">
                <Link href={route('restaurants.index')} className="nav-item">
                    <span className="icon">📍</span>
                    <span className="label">{t('Explore')}</span>
                </Link>
                <Link href="#" className="nav-item">
                    <span className="icon">🛒</span>
                    <span className="label">{t('Orders')}</span>
                </Link>
                <Link href="#" className="nav-item">
                    <span className="icon">👤</span>
                    <span className="label">{t('Profile')}</span>
                </Link>
            </nav>
        </div>
    );
}
