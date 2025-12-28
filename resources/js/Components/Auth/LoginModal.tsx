import Modal from '@/Components/UI/Modal';
import LoginForm from '@/Components/Auth/LoginForm';
import AuthFooter from '@/Components/Auth/AuthFooter';

interface LoginModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export default function LoginModal({ isOpen, onClose }: LoginModalProps) {
  return (
    <Modal isOpen={isOpen} onClose={onClose} title="Sign In">
      <LoginForm onSuccess={onClose} canResetPassword={false} />
      <AuthFooter target="register" onClick={onClose} />
    </Modal>
  );
}
