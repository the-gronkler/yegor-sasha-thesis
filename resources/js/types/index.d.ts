import { User } from './models';
import { Config } from 'ziggy-js';

export type PageProps<
  T extends Record<string, unknown> = Record<string, unknown>,
> = T & {
  auth: {
    user: User;
  };
  errors: Record<string, string>;
  flash: {
    success?: string;
    error?: string;
  };
  ziggy: Config & { location: string };
};
