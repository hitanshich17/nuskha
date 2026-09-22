-- Curated canonical ingredients and their synonyms.
--
-- Repeatable migration: Flyway re-runs this file whenever it changes (after all V__ migrations),
-- so every statement must be safe to run again. Edit freely; do not move this data into a V__ file.
--
-- is_common_irritant is a *prior* for culprit ranking (well-known contact allergens and irritants,
-- e.g. EU-labelled fragrance allergens, isothiazolinones, formaldehyde releasers). It is not a verdict:
-- most people tolerate these fine.
--
-- alias_normalized must match IngredientNames.normalize(alias): lowercase, no accents, single spaces,
-- no spaces around '/', no trailing punctuation. SeedIngredientsIntegrationTest checks this.

CREATE TEMP TABLE seed_ingredients (
    inci_name          TEXT PRIMARY KEY,
    common_name        TEXT,
    functions          TEXT[],
    is_common_irritant BOOLEAN
) ON COMMIT DROP;

INSERT INTO seed_ingredients (inci_name, common_name, functions, is_common_irritant) VALUES
    -- Base, solvents, humectants
    ('Aqua',                               'Water',                 '{solvent}',                    FALSE),
    ('Glycerin',                           'Glycerin',              '{humectant}',                  FALSE),
    ('Butylene Glycol',                    NULL,                    '{humectant,solvent}',          FALSE),
    ('Propylene Glycol',                   NULL,                    '{humectant,solvent}',          TRUE),
    ('Alcohol',                            'Ethanol',               '{solvent}',                    TRUE),
    ('Alcohol Denat.',                     'Denatured alcohol',     '{solvent}',                    TRUE),
    ('Sodium Hyaluronate',                 NULL,                    '{humectant}',                  FALSE),
    ('Hyaluronic Acid',                    NULL,                    '{humectant}',                  FALSE),
    ('Urea',                               NULL,                    '{humectant}',                  FALSE),
    ('Panthenol',                          'Provitamin B5',         '{humectant,soothing}',         FALSE),
    ('Allantoin',                          NULL,                    '{soothing}',                   FALSE),
    -- Emollients, oils, butters
    ('Paraffinum Liquidum',                'Mineral oil',           '{emollient}',                  FALSE),
    ('Caprylic/Capric Triglyceride',       NULL,                    '{emollient}',                  FALSE),
    ('Dimethicone',                        NULL,                    '{emollient}',                  FALSE),
    ('Squalane',                           NULL,                    '{emollient}',                  FALSE),
    ('Cetearyl Alcohol',                   NULL,                    '{emollient,emulsifier}',       FALSE),
    ('Butyrospermum Parkii Butter',        'Shea butter',           '{emollient}',                  FALSE),
    ('Cocos Nucifera Oil',                 'Coconut oil',           '{emollient}',                  FALSE),
    ('Prunus Amygdalus Dulcis Oil',        'Sweet almond oil',      '{emollient}',                  FALSE),
    ('Simmondsia Chinensis Seed Oil',      'Jojoba oil',            '{emollient}',                  FALSE),
    ('Argania Spinosa Kernel Oil',         'Argan oil',             '{emollient}',                  FALSE),
    ('Lanolin',                            'Wool wax',              '{emollient}',                  TRUE),
    ('Ceramide NP',                        'Ceramide 3',            '{skin conditioning}',          FALSE),
    -- Surfactants
    ('Sodium Lauryl Sulfate',              'SLS',                   '{surfactant}',                 TRUE),
    ('Sodium Laureth Sulfate',             'SLES',                  '{surfactant}',                 FALSE),
    ('Cocamidopropyl Betaine',             NULL,                    '{surfactant}',                 TRUE),
    -- Preservatives
    ('Phenoxyethanol',                     NULL,                    '{preservative}',               FALSE),
    ('Sodium Benzoate',                    NULL,                    '{preservative}',               FALSE),
    ('Potassium Sorbate',                  NULL,                    '{preservative}',               FALSE),
    ('Methylparaben',                      NULL,                    '{preservative}',               FALSE),
    ('Propylparaben',                      NULL,                    '{preservative}',               FALSE),
    ('Benzyl Alcohol',                     NULL,                    '{preservative,fragrance}',     TRUE),
    ('Methylisothiazolinone',              'MI',                    '{preservative}',               TRUE),
    ('Methylchloroisothiazolinone',        'MCI',                   '{preservative}',               TRUE),
    ('Formaldehyde',                       NULL,                    '{preservative}',               TRUE),
    ('DMDM Hydantoin',                     NULL,                    '{preservative}',               TRUE),
    ('Imidazolidinyl Urea',                NULL,                    '{preservative}',               TRUE),
    ('Diazolidinyl Urea',                  NULL,                    '{preservative}',               TRUE),
    ('Quaternium-15',                      NULL,                    '{preservative}',               TRUE),
    ('Methyldibromo Glutaronitrile',       NULL,                    '{preservative}',               TRUE),
    -- Fragrance and the EU-labelled fragrance allergens
    ('Parfum',                             'Fragrance',             '{fragrance}',                  TRUE),
    ('Limonene',                           NULL,                    '{fragrance}',                  TRUE),
    ('Linalool',                           NULL,                    '{fragrance}',                  TRUE),
    ('Citronellol',                        NULL,                    '{fragrance}',                  TRUE),
    ('Geraniol',                           NULL,                    '{fragrance}',                  TRUE),
    ('Citral',                             NULL,                    '{fragrance}',                  TRUE),
    ('Eugenol',                            NULL,                    '{fragrance}',                  TRUE),
    ('Isoeugenol',                         NULL,                    '{fragrance}',                  TRUE),
    ('Coumarin',                           NULL,                    '{fragrance}',                  TRUE),
    ('Cinnamal',                           NULL,                    '{fragrance}',                  TRUE),
    ('Cinnamyl Alcohol',                   NULL,                    '{fragrance}',                  TRUE),
    ('Hydroxycitronellal',                 NULL,                    '{fragrance}',                  TRUE),
    ('Farnesol',                           NULL,                    '{fragrance}',                  TRUE),
    ('Benzyl Benzoate',                    NULL,                    '{fragrance}',                  TRUE),
    ('Benzyl Salicylate',                  NULL,                    '{fragrance}',                  TRUE),
    ('Benzyl Cinnamate',                   NULL,                    '{fragrance}',                  TRUE),
    ('Amyl Cinnamal',                      NULL,                    '{fragrance}',                  TRUE),
    ('Hexyl Cinnamal',                     NULL,                    '{fragrance}',                  TRUE),
    ('Alpha-Isomethyl Ionone',             NULL,                    '{fragrance}',                  TRUE),
    ('Butylphenyl Methylpropional',        'Lilial',                '{fragrance}',                  TRUE),
    ('Evernia Prunastri Extract',          'Oakmoss extract',       '{fragrance}',                  TRUE),
    ('Melaleuca Alternifolia Leaf Oil',    'Tea tree oil',          '{fragrance,antimicrobial}',    TRUE),
    ('Lavandula Angustifolia Oil',         'Lavender oil',          '{fragrance}',                  TRUE),
    -- Hair dye
    ('p-Phenylenediamine',                 'PPD',                   '{hair dye}',                   TRUE),
    ('Toluene-2,5-Diamine',                NULL,                    '{hair dye}',                   TRUE),
    -- UV filters
    ('Octocrylene',                        NULL,                    '{uv filter}',                  TRUE),
    ('Benzophenone-3',                     'Oxybenzone',            '{uv filter}',                  TRUE),
    ('Ethylhexyl Methoxycinnamate',        'Octinoxate',            '{uv filter}',                  FALSE),
    ('Butyl Methoxydibenzoylmethane',      'Avobenzone',            '{uv filter}',                  FALSE),
    ('Titanium Dioxide',                   NULL,                    '{uv filter,colorant}',         FALSE),
    ('Zinc Oxide',                         NULL,                    '{uv filter}',                  FALSE),
    -- Actives
    ('Niacinamide',                        'Vitamin B3',            '{skin conditioning}',          FALSE),
    ('Retinol',                            'Vitamin A',             '{skin conditioning}',          TRUE),
    ('Ascorbic Acid',                      'Vitamin C',             '{antioxidant}',                FALSE),
    ('Tocopherol',                         'Vitamin E',             '{antioxidant}',                FALSE),
    ('Tocopheryl Acetate',                 'Vitamin E acetate',     '{antioxidant}',                FALSE),
    ('Salicylic Acid',                     'BHA',                   '{exfoliant}',                  FALSE),
    ('Glycolic Acid',                      'AHA',                   '{exfoliant}',                  TRUE),
    ('Lactic Acid',                        NULL,                    '{exfoliant,ph adjuster}',      FALSE),
    ('Benzoyl Peroxide',                   NULL,                    '{anti-acne}',                  TRUE),
    -- Botanicals common in Indian products
    ('Aloe Barbadensis Leaf Juice',        'Aloe vera',             '{soothing}',                   FALSE),
    ('Curcuma Longa Root Extract',         'Turmeric',              '{antioxidant}',                FALSE),
    ('Azadirachta Indica Leaf Extract',    'Neem',                  '{antimicrobial}',              FALSE),
    ('Santalum Album Oil',                 'Sandalwood oil',        '{fragrance}',                  FALSE),
    ('Rosa Damascena Flower Water',        'Rose water',            '{fragrance,soothing}',         FALSE),
    -- Everyday formulation helpers
    ('Citric Acid',                        NULL,                    '{ph adjuster}',                FALSE),
    ('Sodium Chloride',                    'Salt',                  '{viscosity}',                  FALSE),
    ('Xanthan Gum',                        NULL,                    '{viscosity}',                  FALSE),
    ('Sodium Hydroxide',                   NULL,                    '{ph adjuster}',                FALSE),
    ('Disodium EDTA',                      NULL,                    '{chelating}',                  FALSE);

-- Extra spellings. Each ingredient's own INCI name is added automatically below.
CREATE TEMP TABLE seed_aliases (
    alias            TEXT NOT NULL,
    alias_normalized TEXT PRIMARY KEY,
    inci_name        TEXT NOT NULL
) ON COMMIT DROP;

INSERT INTO seed_aliases (alias, alias_normalized, inci_name) VALUES
    ('Water',                        'water',                        'Aqua'),
    ('Eau',                          'eau',                          'Aqua'),
    ('Purified Water',               'purified water',               'Aqua'),
    ('Deionized Water',              'deionized water',              'Aqua'),
    ('Glycerine',                    'glycerine',                    'Glycerin'),
    ('Glycerol',                     'glycerol',                     'Glycerin'),
    ('Ethanol',                      'ethanol',                      'Alcohol'),
    ('Denatured Alcohol',            'denatured alcohol',            'Alcohol Denat.'),
    ('Mineral Oil',                  'mineral oil',                  'Paraffinum Liquidum'),
    ('Huile Minerale',               'huile minerale',               'Paraffinum Liquidum'),
    ('Liquid Paraffin',              'liquid paraffin',              'Paraffinum Liquidum'),
    ('Caprylic/Capric Triglycerides','caprylic/capric triglycerides','Caprylic/Capric Triglyceride'),
    ('Shea Butter',                  'shea butter',                  'Butyrospermum Parkii Butter'),
    ('Coconut Oil',                  'coconut oil',                  'Cocos Nucifera Oil'),
    ('Sweet Almond Oil',             'sweet almond oil',             'Prunus Amygdalus Dulcis Oil'),
    ('Jojoba Oil',                   'jojoba oil',                   'Simmondsia Chinensis Seed Oil'),
    ('Argan Oil',                    'argan oil',                    'Argania Spinosa Kernel Oil'),
    ('Ceramide 3',                   'ceramide 3',                   'Ceramide NP'),
    ('SLS',                          'sls',                          'Sodium Lauryl Sulfate'),
    ('SLES',                         'sles',                         'Sodium Laureth Sulfate'),
    ('Fragrance',                    'fragrance',                    'Parfum'),
    ('Perfume',                      'perfume',                      'Parfum'),
    ('Tea Tree Oil',                 'tea tree oil',                 'Melaleuca Alternifolia Leaf Oil'),
    ('Lavender Oil',                 'lavender oil',                 'Lavandula Angustifolia Oil'),
    ('PPD',                          'ppd',                          'p-Phenylenediamine'),
    ('Paraphenylenediamine',         'paraphenylenediamine',         'p-Phenylenediamine'),
    ('Oxybenzone',                   'oxybenzone',                   'Benzophenone-3'),
    ('Octinoxate',                   'octinoxate',                   'Ethylhexyl Methoxycinnamate'),
    ('Avobenzone',                   'avobenzone',                   'Butyl Methoxydibenzoylmethane'),
    ('CI 77891',                     'ci 77891',                     'Titanium Dioxide'),
    ('CI 77947',                     'ci 77947',                     'Zinc Oxide'),
    ('Nicotinamide',                 'nicotinamide',                 'Niacinamide'),
    ('Vitamin E',                    'vitamin e',                    'Tocopherol'),
    ('D-Panthenol',                  'd-panthenol',                  'Panthenol'),
    ('Dexpanthenol',                 'dexpanthenol',                 'Panthenol'),
    ('Aloe Vera',                    'aloe vera',                    'Aloe Barbadensis Leaf Juice'),
    ('Turmeric Extract',             'turmeric extract',             'Curcuma Longa Root Extract'),
    ('Neem Extract',                 'neem extract',                 'Azadirachta Indica Leaf Extract'),
    ('Sandalwood Oil',               'sandalwood oil',               'Santalum Album Oil'),
    ('Rose Water',                   'rose water',                   'Rosa Damascena Flower Water');

INSERT INTO seed_aliases (alias, alias_normalized, inci_name)
SELECT inci_name, regexp_replace(lower(inci_name), '[^a-z0-9)]+$', ''), inci_name
FROM seed_ingredients
ON CONFLICT (alias_normalized) DO NOTHING;

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM seed_aliases a
               LEFT JOIN seed_ingredients i ON i.inci_name = a.inci_name
               WHERE i.inci_name IS NULL) THEN
        RAISE EXCEPTION 'seed alias points to an ingredient missing from seed_ingredients';
    END IF;
END $$;

-- 1. Upsert curated ingredients.
INSERT INTO ingredients (inci_name, common_name, functions, is_common_irritant, curated)
SELECT inci_name, common_name, functions, is_common_irritant, TRUE
FROM seed_ingredients
ON CONFLICT (inci_name) DO UPDATE SET
    common_name        = EXCLUDED.common_name,
    functions          = EXCLUDED.functions,
    is_common_irritant = EXCLUDED.is_common_irritant,
    curated            = TRUE;

-- 2. An import may already have auto-created an ingredient for a name we now curate
--    (e.g. "SQUALANE" before Squalane was in this file). Merge it into the curated one.
CREATE TEMP TABLE ingredient_merges ON COMMIT DROP AS
SELECT DISTINCT ON (a.ingredient_id) a.ingredient_id AS from_id, i.id AS to_id
FROM seed_aliases s
JOIN ingredient_aliases a ON a.alias_normalized = s.alias_normalized
JOIN ingredients i        ON i.inci_name = s.inci_name
JOIN ingredients old      ON old.id = a.ingredient_id
WHERE a.ingredient_id <> i.id
  AND NOT old.curated
ORDER BY a.ingredient_id, i.id;

-- A product may end up listing the same ingredient twice; keep its earliest position.
WITH mapped AS (
    SELECT pi.product_id, pi.position, COALESCE(m.to_id, pi.ingredient_id) AS target_id
    FROM product_ingredients pi
    LEFT JOIN ingredient_merges m ON m.from_id = pi.ingredient_id
    WHERE pi.product_id IN (SELECT x.product_id FROM product_ingredients x
                            JOIN ingredient_merges mm ON mm.from_id = x.ingredient_id)
), ranked AS (
    SELECT product_id, position,
           row_number() OVER (PARTITION BY product_id, target_id ORDER BY position) AS rn
    FROM mapped
)
DELETE FROM product_ingredients pi
USING ranked r
WHERE pi.product_id = r.product_id AND pi.position = r.position AND r.rn > 1;

UPDATE product_ingredients pi SET ingredient_id = m.to_id
FROM ingredient_merges m WHERE pi.ingredient_id = m.from_id;

UPDATE ingredient_aliases a SET ingredient_id = m.to_id
FROM ingredient_merges m WHERE a.ingredient_id = m.from_id;

DELETE FROM ingredients WHERE id IN (SELECT from_id FROM ingredient_merges);

-- 3. Upsert curated aliases (the curated list wins over anything learned from labels).
INSERT INTO ingredient_aliases (ingredient_id, alias, alias_normalized, source)
SELECT i.id, s.alias, s.alias_normalized, 'seed'
FROM seed_aliases s
JOIN ingredients i ON i.inci_name = s.inci_name
ON CONFLICT (alias_normalized) DO UPDATE SET
    ingredient_id = EXCLUDED.ingredient_id,
    alias         = EXCLUDED.alias,
    source        = 'seed';
