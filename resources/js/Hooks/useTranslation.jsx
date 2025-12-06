import { usePage } from '@inertiajs/react';

export default function useTranslation() {
    const { translations } = usePage().props;

    const t = (key) => {
        return translations[key] || key;
    };

    return { t };
}
