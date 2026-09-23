package com.skinvidhi.core.catalog;

import static org.assertj.core.api.Assertions.assertThat;

import com.skinvidhi.core.PostgresTestConfiguration;
import java.io.IOException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;
import org.springframework.jdbc.core.JdbcTemplate;
import org.testcontainers.junit.jupiter.Testcontainers;

@SpringBootTest
@Import(PostgresTestConfiguration.class)
@Testcontainers(disabledWithoutDocker = true)
class CatalogImporterIntegrationTest {

    private static final String PRODUCTS = """
            gentle-cleanser,Brand A,Gentle Cleanser,cleanser,"Aqua, Glycerin, Fragrance (Parfum), Novel Botanical Extract",https://brand-a.example/img.jpg,https://brand-a.example/cleanser
            """;
    private static final String TWO_OFFERS = """
            gentle-cleanser,target,15.99,16,fl oz,https://target.example/p/1,2026-09-20
            gentle-cleanser,brand,18.00,,,https://brand-a.example/cleanser,2026-09-21
            """;

    @Autowired
    private CatalogImporter importer;

    @Autowired
    private JdbcTemplate jdbc;

    @BeforeEach
    void resetData() {
        jdbc.execute("TRUNCATE products CASCADE");
        jdbc.execute("DELETE FROM ingredient_aliases WHERE source <> 'seed'");
        jdbc.execute("DELETE FROM ingredients WHERE NOT curated");
    }

    private CatalogImporter.Result importCsv(String offers) throws IOException {
        return importer.importCatalog(CatalogCsvReaderTest.read(PRODUCTS, offers));
    }

    @Test
    void importsProductWithIngredientsAndOffers() throws IOException {
        CatalogImporter.Result result = importCsv(TWO_OFFERS);

        assertThat(result).isEqualTo(new CatalogImporter.Result(1, 2, 1));
        assertThat(jdbc.queryForMap("""
                SELECT source, source_id, brand, category, image_url, source_url FROM products
                """)).containsEntry("source", "curated")
                .containsEntry("source_id", "gentle-cleanser")
                .containsEntry("category", "cleanser")
                .containsEntry("source_url", "https://brand-a.example/cleanser");
        assertThat(jdbc.queryForList("""
                SELECT i.inci_name FROM product_ingredients pi JOIN ingredients i ON i.id = pi.ingredient_id
                ORDER BY pi.position
                """, String.class)).containsExactly("Aqua", "Glycerin", "Parfum", "Novel Botanical Extract");

        assertThat(jdbc.queryForList("""
                SELECT concat_ws(' ', retailer, price_cents, size_amount, size_unit,
                                 (checked_at AT TIME ZONE 'UTC')::date)
                FROM product_offers ORDER BY retailer
                """, String.class)).containsExactly(
                "brand 1800 2026-09-21",
                "target 1599 473.18 ml 2026-09-20");
    }

    @Test
    void reimportReplacesOffersFromTheFile() throws IOException {
        importCsv(TWO_OFFERS);
        CatalogImporter.Result second = importCsv(
                "gentle-cleanser,target,13.99,16,fl oz,https://target.example/p/1,2026-09-23\n");

        assertThat(second.ingredientsCreated()).isZero();
        assertThat(jdbc.queryForObject("SELECT count(*) FROM products", Integer.class)).isEqualTo(1);
        assertThat(jdbc.queryForList("SELECT retailer || ':' || price_cents FROM product_offers", String.class))
                .containsExactly("target:1399");
    }
}
