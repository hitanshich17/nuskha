-- Active ingredients of US over-the-counter drug products (acne treatments, every sunscreen), which
-- labels list separately from the other ingredients, with their concentration.
-- An ingredient is "in" a product if it is in product_ingredients or product_actives.
CREATE TABLE product_actives (
    product_id    BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    ingredient_id BIGINT NOT NULL REFERENCES ingredients(id),
    percent       NUMERIC(5, 2) NOT NULL CHECK (percent > 0 AND percent <= 100),
    PRIMARY KEY (product_id, ingredient_id)
);
CREATE INDEX idx_product_actives_ingredient ON product_actives(ingredient_id);
