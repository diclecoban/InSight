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
