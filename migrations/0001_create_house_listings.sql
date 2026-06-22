-- Create the house_listings table to store property listings

CREATE TABLE IF NOT EXISTS house_listings (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(12, 2),
    location VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for efficient querying by creation date
CREATE INDEX IF NOT EXISTS idx_house_listings_created_at ON house_listings(created_at DESC);

-- Index for location-based searches
CREATE INDEX IF NOT EXISTS idx_house_listings_location ON house_listings(location);
