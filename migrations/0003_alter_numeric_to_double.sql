-- Fix type mismatch: SQLx's default Postgres driver maps NUMERIC/DECIMAL
-- to Decimal/BigDecimal, not f64. Changing the columns to DOUBLE PRECISION
-- lets us keep the existing Rust model (f64) without adding extra dependencies.

ALTER TABLE houses ALTER COLUMN price TYPE DOUBLE PRECISION;
ALTER TABLE houses ALTER COLUMN bathrooms TYPE DOUBLE PRECISION;
