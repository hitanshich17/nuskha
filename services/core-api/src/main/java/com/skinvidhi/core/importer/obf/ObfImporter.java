package com.skinvidhi.core.importer.obf;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.skinvidhi.core.ingredient.IngredientListParser;
import com.skinvidhi.core.ingredient.IngredientResolver;
import com.skinvidhi.core.ingredient.LabelIngredient;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;
import java.util.zip.GZIPInputStream;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.support.TransactionTemplate;

/**
 * Imports products from the Open Beauty Facts JSONL dump (one JSON product per line, optionally gzipped).
 *
 * <p>The file is streamed line by line, so the ~1 GB uncompressed dump never sits in memory.
 * Re-running is safe: products are upserted by barcode and their ingredient lists replaced.
 * Uses plain JDBC rather than JPA because this is a bulk load; there is no entity state to manage.
 */
@Service
public class ObfImporter {

    public enum Outcome { IMPORTED, NO_BARCODE, NO_NAME, NO_INGREDIENTS, UNPARSEABLE, FAILED }

    static final String SOURCE = "open_beauty_facts";

    private static final Logger log = LoggerFactory.getLogger(ObfImporter.class);
    private static final int MAX_LOGGED_FAILURES = 20;

    private final JdbcTemplate jdbc;
    private final TransactionTemplate tx;
    private final ObjectMapper mapper;

    public ObfImporter(JdbcTemplate jdbc, TransactionTemplate tx, ObjectMapper mapper) {
        this.jdbc = jdbc;
        this.tx = tx;
        this.mapper = mapper;
    }

    public ImportStats importFile(Path file) throws IOException {
        try (InputStream raw = Files.newInputStream(file);
             InputStream in = file.toString().endsWith(".gz") ? new GZIPInputStream(raw, 1 << 16) : raw) {
            return importStream(in);
        }
    }

    public ImportStats importStream(InputStream in) throws IOException {
        IngredientResolver resolver = new IngredientResolver(jdbc);
        Map<Outcome, Integer> outcomes = new EnumMap<>(Outcome.class);
        int lines = 0;

        BufferedReader reader = new BufferedReader(new InputStreamReader(in, StandardCharsets.UTF_8));
        String line;
        while ((line = reader.readLine()) != null) {
            if (line.isBlank()) {
                continue;
            }
            lines++;
            Outcome outcome;
            try {
                outcome = importLine(line, resolver);
            } catch (IOException | RuntimeException e) {
                outcome = Outcome.FAILED;
                if (outcomes.getOrDefault(Outcome.FAILED, 0) < MAX_LOGGED_FAILURES) {
                    log.warn("Line {} failed: {}", lines, e.getMessage());
                }
            }
            outcomes.merge(outcome, 1, Integer::sum);
            if (lines % 10_000 == 0) {
                log.info("{} lines read, {} products imported", lines, outcomes.getOrDefault(Outcome.IMPORTED, 0));
            }
        }
        return new ImportStats(lines, outcomes, resolver.ingredientsCreated());
    }

    private Outcome importLine(String line, IngredientResolver resolver) throws IOException {
        ObfProduct p = mapper.readValue(line, ObfProduct.class);
        String code = firstNonBlank(p.code());
        String name = firstNonBlank(p.productNameEn(), p.productName());
        String ingredientsText = firstNonBlank(p.ingredientsTextEn(), p.ingredientsText());
        if (code == null) {
            return Outcome.NO_BARCODE;
        }
        if (ingredientsText == null) {
            return Outcome.NO_INGREDIENTS;
        }
        if (name == null) {
            return Outcome.NO_NAME;
        }
        List<LabelIngredient> parsed = IngredientListParser.parse(ingredientsText);
        if (parsed.isEmpty()) {
            return Outcome.UNPARSEABLE;
        }

        // Resolve outside the product transaction: new ingredients are kept even if saving this product
        // fails, which keeps the resolver's in-memory cache in step with the database.
        List<Long> ingredientIds = parsed.stream()
                .flatMap(i -> resolver.resolve(i).stream()).distinct().toList();

        tx.executeWithoutResult(status -> save(code, name, firstBrand(p.brands()),
                ObfCategories.categorize(p.categoriesTags()), ingredientsText, ingredientIds));
        return Outcome.IMPORTED;
    }

    private void save(String code, String name, String brand, String category, String ingredientsText,
                      List<Long> ingredientIds) {
        Long productId = jdbc.queryForObject("""
                INSERT INTO products (brand, name, category, source, source_id, ingredients_raw)
                VALUES (?, ?, ?, ?, ?, ?)
                ON CONFLICT (source, source_id) DO UPDATE SET
                    brand = EXCLUDED.brand,
                    name = EXCLUDED.name,
                    category = EXCLUDED.category,
                    ingredients_raw = EXCLUDED.ingredients_raw
                RETURNING id
                """, Long.class, brand, name, category, SOURCE, code, ingredientsText);

        jdbc.update("DELETE FROM product_ingredients WHERE product_id = ?", productId);
        List<Object[]> rows = new ArrayList<>();
        for (int i = 0; i < ingredientIds.size(); i++) {
            rows.add(new Object[] {productId, i + 1, ingredientIds.get(i)});
        }
        jdbc.batchUpdate("INSERT INTO product_ingredients (product_id, position, ingredient_id) VALUES (?, ?, ?)",
                rows);
    }

    /** OBF can list several brands ("Johnson & Johnson, Neutrogena"); we keep the first. */
    private static String firstBrand(String brands) {
        return brands == null ? null : firstNonBlank(brands.split(",")[0]);
    }

    private static String firstNonBlank(String... values) {
        for (String v : values) {
            if (v != null && !v.isBlank()) {
                return v.strip();
            }
        }
        return null;
    }
}
