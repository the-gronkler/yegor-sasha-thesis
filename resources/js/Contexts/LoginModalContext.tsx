import { createContext, useContext, useState, ReactNode } from 'react';
import LoginModal from '@/Components/Auth/LoginModal';

interface LoginModalContextType {
  openLoginModal: () => void;
  closeLoginModal: () => void;
}

const LoginModalContext = createContext<LoginModalContextType | undefined>(
  undefined,
);

export function LoginModalProvider({ children }: { children: ReactNode }) {
  const [isOpen, setIsOpen] = useState(false);

  const openLoginModal = () => setIsOpen(true);
  const closeLoginModal = () => setIsOpen(false);

  return (
    <LoginModalContext.Provider value={{ openLoginModal, closeLoginModal }}>
      {children}
      <LoginModal isOpen={isOpen} onClose={closeLoginModal} />
    </LoginModalContext.Provider>
  );
}

export function useLoginModal() {
  const context = useContext(LoginModalContext);
  if (context === undefined) {
    throw new Error('useLoginModal must be used within a LoginModalProvider');
  }
  return context;
}
