-- Where a product can be bought and for how much. A product can have several offers (different
-- retailers or sizes), so the app can show the cheapest one and compare retailers.
CREATE TABLE product_offers (
    id           BIGSERIAL PRIMARY KEY,
    product_id   BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    retailer     TEXT NOT NULL,                        -- 'target', 'ulta', 'brand' (the brand's own store), ...
    price_cents  INTEGER NOT NULL CHECK (price_cents > 0),
    currency     CHAR(3) NOT NULL DEFAULT 'USD',
    -- Size in metric units (fl oz / oz are converted on the way in), used for the monthly cost estimate.
    size_amount  NUMERIC(8, 2) CHECK (size_amount > 0),
    size_unit    TEXT CHECK (size_unit IN ('ml', 'g')),
    url          TEXT NOT NULL,
    in_stock     BOOLEAN,                              -- NULL = unknown
    checked_at   TIMESTAMPTZ NOT NULL DEFAULT now(),   -- when this price was last seen
    CHECK ((size_amount IS NULL) = (size_unit IS NULL)),
    -- One offer per retailer and size; importers upsert on this.
    UNIQUE NULLS NOT DISTINCT (product_id, retailer, size_amount, size_unit)
);
CREATE INDEX idx_product_offers_product ON product_offers(product_id);

-- Prices now live on offers.
ALTER TABLE products DROP COLUMN price_cents, DROP COLUMN currency;

ALTER TABLE products ADD COLUMN image_url TEXT;
