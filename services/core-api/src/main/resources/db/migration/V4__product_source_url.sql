-- The page a product's data (name, ingredients) was taken from, so every product can be checked.
ALTER TABLE products ADD COLUMN source_url TEXT;
