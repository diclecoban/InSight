DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'profiles'
          AND column_name = 'birthdate'
    ) AND NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'profiles'
          AND column_name = 'birthDate'
    ) THEN
        ALTER TABLE profiles RENAME COLUMN birthdate TO "birthDate";
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'profiles'
          AND column_name = 'birthDate'
    ) THEN
        ALTER TABLE profiles ADD COLUMN "birthDate" date;
    END IF;
END $$;

UPDATE profiles
SET "birthDate" = DATE '1970-01-01'
WHERE "birthDate" IS NULL;

ALTER TABLE profiles
ALTER COLUMN "birthDate" SET NOT NULL;
