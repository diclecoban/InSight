ALTER TABLE scans
ADD COLUMN IF NOT EXISTS source text NOT NULL DEFAULT 'barcode';

ALTER TABLE scans
DROP CONSTRAINT IF EXISTS scans_source_check;

ALTER TABLE scans
ADD CONSTRAINT scans_source_check
CHECK (source IN ('barcode', 'ocr', 'manual', 'photo'));
