ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS gender text NOT NULL DEFAULT 'other';

ALTER TABLE profiles
DROP CONSTRAINT IF EXISTS profiles_gender_check;

ALTER TABLE profiles
ADD CONSTRAINT profiles_gender_check
CHECK (gender IN ('male', 'female', 'other'));
