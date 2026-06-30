-- Track moderation and rental status for landlord-created listings.

ALTER TABLE houses
ADD COLUMN IF NOT EXISTS availability_status VARCHAR(40) NOT NULL DEFAULT 'available';

CREATE INDEX IF NOT EXISTS idx_houses_availability_status
ON houses(availability_status);
