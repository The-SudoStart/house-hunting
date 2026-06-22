-- Create the houses table to store property listings
-- Supports all information required by the MVP while remaining flexible for future enhancements

CREATE TABLE IF NOT EXISTS houses (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(12, 2) NOT NULL,
    bedrooms INTEGER,
    bathrooms DECIMAL(3, 1),
    square_feet INTEGER,
    property_type VARCHAR(50),
    address VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100),
    zip_code VARCHAR(20),
    country VARCHAR(100) DEFAULT 'Cameroon',
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    landlord_phone VARCHAR(20) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for efficient querying by creation date (newest first)
CREATE INDEX IF NOT EXISTS idx_houses_created_at ON houses(created_at DESC);

-- Index for city-based searches
CREATE INDEX IF NOT EXISTS idx_houses_city ON houses(city);

-- Index for price range queries
CREATE INDEX IF NOT EXISTS idx_houses_price ON houses(price);

-- Index for location-based (geo) searches
CREATE INDEX IF NOT EXISTS idx_houses_location ON houses(latitude, longitude);

-- Index for landlord phone lookups
CREATE INDEX IF NOT EXISTS idx_houses_landlord_phone ON houses(landlord_phone);
