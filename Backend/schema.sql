CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS users (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    email text NOT NULL UNIQUE,
    password_hash text NOT NULL,
    is_verified boolean NOT NULL DEFAULT false,
    verification_code text,
    code_expires_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS auth_sessions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "userID" uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    auth_token_hash text NOT NULL UNIQUE,
    refresh_token_hash text NOT NULL UNIQUE,
    created_at timestamptz NOT NULL DEFAULT NOW(),
    expires_at timestamptz NOT NULL
);

CREATE INDEX IF NOT EXISTS auth_sessions_user_id_idx
    ON auth_sessions ("userID");

CREATE TABLE IF NOT EXISTS profiles (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "userID" uuid NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    "firstName" text NOT NULL,
    "lastName" text NOT NULL,
    age integer NOT NULL CHECK (age BETWEEN 12 AND 120),
    gender text NOT NULL CHECK (gender IN ('male', 'female', 'other')),
    "skinType" text NOT NULL,
    condition text DEFAULT 'Not specified',
    sensitivity text DEFAULT 'Not specified',
    allergies text[] NOT NULL DEFAULT ARRAY[]::text[],
    "updatedAt" timestamptz NOT NULL DEFAULT NOW()
);

ALTER TABLE profiles
    ADD COLUMN IF NOT EXISTS condition text DEFAULT 'Not specified',
    ADD COLUMN IF NOT EXISTS sensitivity text DEFAULT 'Not specified',
    ADD COLUMN IF NOT EXISTS "updatedAt" timestamptz NOT NULL DEFAULT NOW();

CREATE TABLE IF NOT EXISTS products (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name text NOT NULL,
    brand text NOT NULL DEFAULT 'Unknown',
    "priceText" text NOT NULL DEFAULT '',
    "imageURL" text,
    barcode text NOT NULL UNIQUE,
    "createdAt" timestamptz NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS ingredients (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name text NOT NULL UNIQUE,
    detail text NOT NULL DEFAULT '',
    "riskNote" text NOT NULL DEFAULT '',
    "riskLevel" text NOT NULL DEFAULT 'low'
        CHECK ("riskLevel" IN ('low', 'medium', 'high'))
);

CREATE TABLE IF NOT EXISTS product_ingredients (
    "productID" uuid NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    "ingredientID" uuid NOT NULL REFERENCES ingredients(id) ON DELETE CASCADE,
    position integer NOT NULL DEFAULT 0,
    PRIMARY KEY ("productID", "ingredientID")
);

CREATE TABLE IF NOT EXISTS scans (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "userID" uuid REFERENCES users(id) ON DELETE SET NULL,
    "productID" uuid NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    barcode text NOT NULL,
    source text NOT NULL DEFAULT 'barcode' CHECK (source IN ('barcode', 'ocr', 'manual', 'photo')),
    score numeric(4, 3) NOT NULL,
    "safetyLevel" text NOT NULL CHECK ("safetyLevel" IN ('safe', 'mostlySafe', 'risky')),
    "scannedAt" timestamptz NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS saved_reviews (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "userID" uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    "productID" uuid NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    status text NOT NULL CHECK (status IN ('safe', 'mostlySafe', 'risky')),
    "savedAt" timestamptz NOT NULL DEFAULT NOW(),
    UNIQUE ("userID", "productID")
);

CREATE TABLE IF NOT EXISTS recommendations (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "userID" uuid REFERENCES users(id) ON DELETE CASCADE,
    title text NOT NULL,
    subtitle text NOT NULL DEFAULT '',
    "createdAt" timestamptz NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS email_change_requests (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "userID" uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    "currentEmail" text NOT NULL,
    "newEmail" text NOT NULL,
    "currentCode" text NOT NULL,
    "newCode" text,
    "currentVerifiedAt" timestamptz,
    "expiresAt" timestamptz NOT NULL,
    "createdAt" timestamptz NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS email_change_requests_user_id_idx
    ON email_change_requests ("userID");

INSERT INTO recommendations (title, subtitle)
VALUES
    ('Ingredient of the Day', 'Glycerin supports skin hydration.'),
    ('Why Avoid Fragrance?', 'Fragrance can irritate sensitive skin.')
ON CONFLICT DO NOTHING;
