import { CameraIcon, XMarkIcon } from '@heroicons/react/24/outline';
import { ChangeEvent, useEffect, useState } from 'react';

interface FilePreviewProps {
  file: File;
  onRemove: () => void;
}

function FilePreview({ file, onRemove }: FilePreviewProps) {
  const [previewUrl, setPreviewUrl] = useState<string>('');

  useEffect(() => {
    const url = URL.createObjectURL(file);
    setPreviewUrl(url);

    return () => {
      URL.revokeObjectURL(url);
    };
  }, [file]);

  if (!previewUrl) return null;

  return (
    <div className="image-preview-item">
      <img src={previewUrl} alt="Preview" className="preview-image" />
      <button type="button" className="remove-image-btn" onClick={onRemove}>
        <XMarkIcon className="icon" />
      </button>
    </div>
  );
}

export interface ExistingImage {
  id: number;
  url: string;
}

interface Props {
  /** New files selected for upload */
  files: File[];
  /** Already uploaded images (for editing) */
  existingImages?: ExistingImage[];
  /** Callback when new files are added */
  onAddFiles: (files: File[]) => void;
  /** Callback when a new file is removed */
  onRemoveFile: (index: number) => void;
  /** Callback when an existing image is removed */
  onRemoveExisting?: (id: number) => void;
  /** Maximum total images allowed */
  maxImages?: number;
  /** Error message to display */
  error?: string;
}

export default function ImageUploader({
  files,
  existingImages = [],
  onAddFiles,
  onRemoveFile,
  onRemoveExisting,
  maxImages = 5,
  error,
}: Props) {
  const totalImages = files.length + existingImages.length;

  const handleFileChange = (e: ChangeEvent<HTMLInputElement>) => {
    if (e.target.files) {
      const newFiles = Array.from(e.target.files);
      if (totalImages + newFiles.length > maxImages) {
        alert(`You can only upload a maximum of ${maxImages} images.`);
        return;
      }
      onAddFiles(newFiles);
    }
  };

  return (
    <div className="image-upload-container">
      <div className="image-preview-list">
        {/* Existing Images */}
        {existingImages.map((image) => (
          <div key={`existing-${image.id}`} className="image-preview-item">
            <img src={image.url} alt="Preview" className="preview-image" />
            {onRemoveExisting && (
              <button
                type="button"
                className="remove-image-btn"
                onClick={() => onRemoveExisting(image.id)}
              >
                <XMarkIcon className="icon" />
              </button>
            )}
          </div>
        ))}

        {/* New Files */}
        {files.map((file, index) => (
          <FilePreview
            key={`new-${index}`}
            file={file}
            onRemove={() => onRemoveFile(index)}
          />
        ))}

        {/* Add Button */}
        {totalImages < maxImages && (
          <label className="add-image-btn">
            <input
              type="file"
              accept="image/*"
              multiple
              onChange={handleFileChange}
              className="hidden-input"
            />
            <CameraIcon className="icon" />
            <span>Add Photo</span>
          </label>
        )}
      </div>
      {error && <div className="form-error">{error}</div>}
    </div>
  );
}
