-- What kind of ingredient something is (fragrance, nut, retinoid, ...), so quiz answers can filter
-- products. Computed from ingredient names by IngredientTag rules and rewritten after every import.
CREATE TABLE ingredient_tags (
    ingredient_id BIGINT NOT NULL REFERENCES ingredients(id) ON DELETE CASCADE,
    tag           TEXT   NOT NULL,
    PRIMARY KEY (ingredient_id, tag)
);
CREATE INDEX idx_ingredient_tags_tag ON ingredient_tags(tag);
