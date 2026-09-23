-- Products sold in the US only as imports. For sunscreens this means they are not FDA-approved OTC drugs
-- (their UV filters are not allowed in US sunscreens), so the app must flag them.
ALTER TABLE products ADD COLUMN imported BOOLEAN NOT NULL DEFAULT FALSE;
