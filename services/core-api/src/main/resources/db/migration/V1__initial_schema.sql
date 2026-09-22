-- Nuskha initial schema.
-- Core idea: every ingredient name variant ("Aqua", "Water", "Eau") maps to ONE canonical ingredient,
-- so reaction analysis compares real ingredients, not spellings.

CREATE EXTENSION IF NOT EXISTS vector;   -- used later for product similarity (replacements)

-- Canonical ingredients (INCI = the standardized international ingredient naming system)
CREATE TABLE ingredients (
    id                 BIGSERIAL PRIMARY KEY,
    inci_name          TEXT NOT NULL UNIQUE,
    common_name        TEXT,
    functions          TEXT[] NOT NULL DEFAULT '{}',   -- e.g. {emollient, preservative}
    is_common_irritant BOOLEAN NOT NULL DEFAULT FALSE,  -- prior used by culprit ranking
    created_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Every spelling / synonym seen on real labels, pointing to its canonical ingredient
CREATE TABLE ingredient_aliases (
    id               BIGSERIAL PRIMARY KEY,
    ingredient_id    BIGINT NOT NULL REFERENCES ingredients(id) ON DELETE CASCADE,
    alias            TEXT NOT NULL,
    alias_normalized TEXT NOT NULL UNIQUE      -- lowercased, trimmed, punctuation-cleaned
);
CREATE INDEX idx_ingredient_aliases_ingredient ON ingredient_aliases(ingredient_id);

CREATE TABLE products (
    id          BIGSERIAL PRIMARY KEY,
    brand       TEXT,
    name        TEXT NOT NULL,
    category    TEXT,                 -- cleanser, moisturizer, serum, sunscreen...
    source      TEXT NOT NULL,        -- 'open_beauty_facts', 'user_scan', ...
    source_id   TEXT,                 -- barcode or external id
    price_cents INTEGER,
    currency    CHAR(3),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (source, source_id)
);

-- Ingredient order matters: earlier = higher concentration
CREATE TABLE product_ingredients (
    product_id    BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    position      INTEGER NOT NULL CHECK (position >= 1),
    ingredient_id BIGINT NOT NULL REFERENCES ingredients(id),
    PRIMARY KEY (product_id, position)
);
CREATE INDEX idx_product_ingredients_ingredient ON product_ingredients(ingredient_id);

CREATE TABLE users (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email      TEXT NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- What the culprit engine learns from: "this product broke me out" vs "this one is fine"
CREATE TABLE user_product_reports (
    id          BIGSERIAL PRIMARY KEY,
    user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    product_id  BIGINT NOT NULL REFERENCES products(id),
    verdict     TEXT NOT NULL CHECK (verdict IN ('reacted', 'safe')),
    reaction    TEXT,                 -- breakouts, redness, itching, dryness...
    notes       TEXT,
    reported_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (user_id, product_id)
);
