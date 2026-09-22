-- Support for importing products from Open Beauty Facts and normalizing their ingredient lists.

-- Curated ingredients come from our seed list (R__seed_ingredients.sql). Everything else was created
-- automatically from label text and may be a misspelling or OCR error, so later steps can trust it less.
ALTER TABLE ingredients ADD COLUMN curated BOOLEAN NOT NULL DEFAULT FALSE;

-- Where an alias came from:
--   'seed'   curated synonym list
--   'label'  the name as written on a label, for an auto-created ingredient
-- Synonyms read on labels ("Parfum (Fragrance)") are never saved as aliases: label text is too noisy,
-- and a wrong alias would turn one ingredient into another everywhere. See IngredientResolver.
ALTER TABLE ingredient_aliases
    ADD COLUMN source TEXT NOT NULL DEFAULT 'seed'
        CHECK (source IN ('seed', 'label'));

-- Keep the original label text so ingredients can be re-parsed when the parser improves,
-- without downloading the dataset again.
ALTER TABLE products ADD COLUMN ingredients_raw TEXT;

-- Two label names can resolve to the same canonical ingredient ("Aqua, ..., Water").
-- A product lists each ingredient once, at its first (highest-concentration) position.
ALTER TABLE product_ingredients
    ADD CONSTRAINT uq_product_ingredients_product_ingredient UNIQUE (product_id, ingredient_id);
