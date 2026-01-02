import { FormEventHandler, useState } from 'react';
import AppLayout from '@/Layouts/AppLayout';
import { Head, Link, useForm, router } from '@inertiajs/react';
import {
  ArrowLeftIcon,
  UserIcon,
  PlusIcon,
  TrashIcon,
  PencilIcon,
} from '@heroicons/react/24/outline';
import { Employee } from '@/types/models';
import { PageProps } from '@/types';
import Button from '@/Components/UI/Button';

interface WorkersProps extends PageProps {
  employees: Employee[];
}

export default function Workers({ employees }: WorkersProps) {
  const [showAddForm, setShowAddForm] = useState(false);
  const [editingEmployee, setEditingEmployee] = useState<Employee | null>(null);

  const { data, setData, post, processing, errors, reset } = useForm({
    name: '',
    surname: '',
    email: '',
    password: '',
    password_confirmation: '',
    is_admin: false,
  });

  const {
    data: editData,
    setData: setEditData,
    put,
    processing: editProcessing,
    errors: editErrors,
    reset: resetEdit,
  } = useForm({
    name: '',
    surname: '',
    email: '',
    is_admin: false,
  });

  const handleAddWorker: FormEventHandler = (e) => {
    e.preventDefault();
    post(route('employee.establishment.workers.store'), {
      onSuccess: () => {
        reset();
        setShowAddForm(false);
      },
    });
  };

  const handleEditClick = (employee: Employee) => {
    setEditingEmployee(employee);
    setEditData({
      name: employee.name || '',
      surname: employee.surname || '',
      email: employee.email || '',
      is_admin: employee.is_admin,
    });
  };

  const handleCancelEdit = () => {
    setEditingEmployee(null);
    resetEdit();
  };

  const handleUpdateWorker: FormEventHandler = (e) => {
    e.preventDefault();
    if (!editingEmployee) return;

    put(
      route('employee.establishment.workers.update', editingEmployee.user_id),
      {
        preserveScroll: true,
        onSuccess: () => {
          setEditingEmployee(null);
          resetEdit();
        },
      },
    );
  };

  const handleRemoveWorker = (userId: number) => {
    if (!window.confirm('Are you sure you want to remove this employee?')) {
      return;
    }

    router.delete(route('employee.establishment.workers.destroy', userId));
  };

  return (
    <AppLayout>
      <Head title="Manage Workers" />

      <div className="profile-page">
        {/* Header */}
        <div className="profile-header">
          <Link
            href={route('employee.establishment.index')}
            className="back-button-link"
          >
            <ArrowLeftIcon className="icon" />
            <span>Back</span>
          </Link>
          <h1 className="profile-title">Manage Workers</h1>
        </div>

        {/* Add Worker Button */}
        <div className="profile-card">
          <div className="section-header">
            <h3 className="section-title">Current Employees</h3>
            <button
              type="button"
              onClick={() => setShowAddForm(!showAddForm)}
              className="btn-icon btn-add"
              aria-label="Add new employee"
            >
              <PlusIcon className="icon" />
            </button>
          </div>

          {/* Add Worker Form */}
          {showAddForm && (
            <form
              onSubmit={handleAddWorker}
              className="profile-form add-worker-form"
            >
              <div className="form-group">
                <label htmlFor="name">First Name</label>
                <input
                  id="name"
                  type="text"
                  className="form-input"
                  value={data.name}
                  onChange={(e) => setData('name', e.target.value)}
                  placeholder="Enter first name"
                  required
                />
                {errors.name && <p className="error-message">{errors.name}</p>}
              </div>

              <div className="form-group">
                <label htmlFor="surname">Last Name (Optional)</label>
                <input
                  id="surname"
                  type="text"
                  className="form-input"
                  value={data.surname}
                  onChange={(e) => setData('surname', e.target.value)}
                  placeholder="Enter last name"
                />
                {errors.surname && (
                  <p className="error-message">{errors.surname}</p>
                )}
              </div>

              <div className="form-group">
                <label htmlFor="email">Email Address</label>
                <input
                  id="email"
                  type="email"
                  className="form-input"
                  value={data.email}
                  onChange={(e) => setData('email', e.target.value)}
                  placeholder="Enter email address"
                  required
                />
                {errors.email && (
                  <p className="error-message">{errors.email}</p>
                )}
              </div>

              <div className="form-group">
                <label htmlFor="password">Password</label>
                <input
                  id="password"
                  type="password"
                  className="form-input"
                  value={data.password}
                  onChange={(e) => setData('password', e.target.value)}
                  placeholder="Enter password (min. 8 characters)"
                  required
                />
                {errors.password && (
                  <p className="error-message">{errors.password}</p>
                )}
              </div>

              <div className="form-group">
                <label htmlFor="password_confirmation">Confirm Password</label>
                <input
                  id="password_confirmation"
                  type="password"
                  className="form-input"
                  value={data.password_confirmation}
                  onChange={(e) =>
                    setData('password_confirmation', e.target.value)
                  }
                  placeholder="Confirm password"
                  required
                />
                {errors.password_confirmation && (
                  <p className="error-message">
                    {errors.password_confirmation}
                  </p>
                )}
              </div>

              <div className="form-group checkbox-group">
                <label className="checkbox-label">
                  <input
                    type="checkbox"
                    checked={data.is_admin}
                    onChange={(e) => setData('is_admin', e.target.checked)}
                  />
                  <span>Grant admin privileges</span>
                </label>
              </div>

              <div className="form-actions">
                <button
                  type="button"
                  onClick={() => {
                    setShowAddForm(false);
                    reset();
                  }}
                  className="btn-secondary"
                >
                  Cancel
                </button>
                <Button type="submit" disabled={processing}>
                  Add Employee
                </Button>
              </div>
            </form>
          )}

          {/* Workers List */}
          <div className="workers-list">
            {employees.map((employee) => (
              <div key={employee.user_id}>
                {editingEmployee?.user_id === employee.user_id ? (
                  // Edit Form
                  <form
                    onSubmit={handleUpdateWorker}
                    className="profile-form edit-worker-form"
                  >
                    <div className="form-group">
                      <label htmlFor="edit-name">First Name</label>
                      <input
                        id="edit-name"
                        type="text"
                        className="form-input"
                        value={editData.name}
                        onChange={(e) => setEditData('name', e.target.value)}
                        required
                      />
                      {editErrors.name && (
                        <p className="error-message">{editErrors.name}</p>
                      )}
                    </div>

                    <div className="form-group">
                      <label htmlFor="edit-surname">Last Name</label>
                      <input
                        id="edit-surname"
                        type="text"
                        className="form-input"
                        value={editData.surname}
                        onChange={(e) => setEditData('surname', e.target.value)}
                      />
                      {editErrors.surname && (
                        <p className="error-message">{editErrors.surname}</p>
                      )}
                    </div>

                    <div className="form-group">
                      <label htmlFor="edit-email">Email Address</label>
                      <input
                        id="edit-email"
                        type="email"
                        className="form-input"
                        value={editData.email}
                        onChange={(e) => setEditData('email', e.target.value)}
                        required
                      />
                      {editErrors.email && (
                        <p className="error-message">{editErrors.email}</p>
                      )}
                    </div>

                    <div className="form-group checkbox-group">
                      <label className="checkbox-label">
                        <input
                          type="checkbox"
                          checked={editData.is_admin}
                          onChange={(e) =>
                            setEditData('is_admin', e.target.checked)
                          }
                        />
                        <span>Admin privileges</span>
                      </label>
                    </div>

                    <div className="form-actions">
                      <button
                        type="button"
                        onClick={handleCancelEdit}
                        className="btn-secondary"
                      >
                        Cancel
                      </button>
                      <Button type="submit" disabled={editProcessing}>
                        Save Changes
                      </Button>
                    </div>
                  </form>
                ) : (
                  // Worker Item Display
                  <div className="worker-item">
                    <div className="worker-avatar">
                      <UserIcon className="icon" />
                    </div>
                    <div className="worker-info">
                      <h4 className="worker-name">
                        {employee.name} {employee.surname}
                      </h4>
                      <p className="worker-email">{employee.email}</p>
                      {employee.is_admin && (
                        <span className="worker-badge">Admin</span>
                      )}
                    </div>
                    <div className="worker-actions">
                      <button
                        type="button"
                        onClick={() => handleEditClick(employee)}
                        className="btn-icon btn-edit"
                        aria-label="Edit employee"
                      >
                        <PencilIcon className="icon" />
                      </button>
                      <button
                        type="button"
                        onClick={() => handleRemoveWorker(employee.user_id)}
                        className="btn-icon btn-delete"
                        aria-label="Remove employee"
                      >
                        <TrashIcon className="icon" />
                      </button>
                    </div>
                  </div>
                )}
              </div>
            ))}

            {employees.length === 0 && (
              <div className="empty-state">
                <UserIcon className="empty-icon" />
                <p className="empty-text">No employees yet</p>
                <p className="empty-description">
                  Add employees to help manage your restaurant
                </p>
              </div>
            )}
          </div>
        </div>
      </div>
    </AppLayout>
  );
}
