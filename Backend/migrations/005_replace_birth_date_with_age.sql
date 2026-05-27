ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS age integer;

UPDATE profiles
SET age = COALESCE(
    age,
    CASE
        WHEN "birthDate" IS NOT NULL THEN EXTRACT(YEAR FROM age(CURRENT_DATE, "birthDate"))::integer
        ELSE 18
    END
);

ALTER TABLE profiles
ALTER COLUMN age SET NOT NULL;

ALTER TABLE profiles
DROP CONSTRAINT IF EXISTS profiles_age_check;

ALTER TABLE profiles
ADD CONSTRAINT profiles_age_check
CHECK (age BETWEEN 12 AND 120);

ALTER TABLE profiles
DROP COLUMN IF EXISTS "birthDate";
