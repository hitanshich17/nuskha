package com.skinvidhi.core.catalog;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.catchThrowableOfType;

import com.skinvidhi.core.catalog.CatalogCsvReader.Active;
import com.skinvidhi.core.catalog.CatalogCsvReader.Catalog;
import com.skinvidhi.core.catalog.CatalogCsvReader.CatalogOffer;
import com.skinvidhi.core.catalog.CatalogCsvReader.CatalogProduct;
import com.skinvidhi.core.catalog.CatalogCsvReader.InvalidCatalogException;
import java.io.IOException;
import java.io.StringReader;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import org.junit.jupiter.api.Test;

class CatalogCsvReaderTest {

    private static final LocalDate TODAY = LocalDate.of(2026, 9, 23);
    private static final String PRODUCTS_HEADER = "id,brand,name,category,actives,ingredients,image_url,source_url,import\n";
    private static final String OFFERS_HEADER = "product_id,retailer,price_usd,size,unit,url,checked_on\n";
    private static final String CLEANSER =
            "gentle-cleanser,Brand A,Gentle Cleanser,cleanser,,\"Aqua, Glycerin, Cetearyl Alcohol\",,https://brand-a.example/cleanser\n";

    static Catalog read(String products, String offers) throws IOException {
        return CatalogCsvReader.read(new StringReader(PRODUCTS_HEADER + products),
                new StringReader(OFFERS_HEADER + offers), TODAY);
    }

    private static List<String> errors(String products, String offers) {
        return catchThrowableOfType(InvalidCatalogException.class, () -> read(products, offers)).errors();
    }

    @Test
    void readsValidCatalog() throws IOException {
        Catalog catalog = read(CLEANSER, """
                gentle-cleanser,target,15.99,16,fl oz,https://target.example/p/1,2026-09-20
                gentle-cleanser,brand,18,,,https://brand-a.example/cleanser,2026-09-23
                """);

        assertThat(catalog.products()).singleElement().satisfies(p -> {
            assertThat(p.id()).isEqualTo("gentle-cleanser");
            assertThat(p.ingredients()).isEqualTo("Aqua, Glycerin, Cetearyl Alcohol");
            assertThat(p.imageUrl()).isNull();
        });
        assertThat(catalog.offers()).containsExactly(
                new CatalogOffer("gentle-cleanser", "target", 1599, new Size(new BigDecimal("473.18"), "ml"),
                        "https://target.example/p/1", LocalDate.of(2026, 9, 20)),
                new CatalogOffer("gentle-cleanser", "brand", 1800, null,
                        "https://brand-a.example/cleanser", TODAY));
    }

    @Test
    void reportsEveryProductProblemWithItsLine() {
        assertThat(errors("""
                Bad Id,Brand,Name,cleanser,,"Aqua, Glycerin",,https://x.example/a
                ok-id,,Name,toner,,"Aqua",,not-a-link
                ok-id-2,Brand,Name,serum,,,,https://x.example/b
                """, "")).containsExactlyInAnyOrder(
                "products.csv:2: id must be lowercase words joined by '-', e.g. cerave-hydrating-cleanser",
                "products.csv:3: brand is empty",
                "products.csv:3: category must be one of cleanser, moisturizer, sunscreen, treatment",
                "products.csv:3: source_url must be a web link starting with https://",
                "products.csv:4: ingredients is empty",
                "products.csv:4: category must be one of cleanser, moisturizer, sunscreen, treatment");
    }

    @Test
    void reportsEveryOfferProblemWithItsLine() {
        assertThat(errors(CLEANSER, """
                unknown-product,target,15.99,16,fl oz,https://t.example/1,2026-09-20
                gentle-cleanser,Target,$15.99,16,,https://t.example/1,2026-09-20
                gentle-cleanser,ulta,12.5,2,cups,https://u.example/1,2027-01-01
                """)).containsExactlyInAnyOrder(
                "offers.csv:2: product_id 'unknown-product' is not in products.csv",
                "offers.csv:3: retailer must be lowercase, e.g. target, ulta, brand",
                "offers.csv:3: price_usd must be a positive amount like 15.99, not '$15.99'",
                "offers.csv:3: size and unit must be filled in together",
                "offers.csv:4: unit must be one of ml, g, fl oz, oz: 'cups'",
                "offers.csv:4: checked_on is in the future: 2027-01-01");
    }

    @Test
    void readsActivesWithPercentages() throws IOException {
        Catalog catalog = read("""
                acne-wash,Brand B,Acne Wash,cleanser,Benzoyl Peroxide 4%,"Water, Glycerin",,https://b.example/wash
                mineral-spf,Brand C,Mineral SPF 30,sunscreen,Zinc Oxide 9%; Titanium Dioxide 3.5 %,"Water, Glycerin",,https://c.example/spf
                """, "");

        assertThat(catalog.products()).extracting(CatalogProduct::actives).containsExactly(
                List.of(new Active("Benzoyl Peroxide", new BigDecimal("4"))),
                List.of(new Active("Zinc Oxide", new BigDecimal("9")), new Active("Titanium Dioxide", new BigDecimal("3.5"))));
    }

    @Test
    void readsImportFlag() throws IOException {
        Catalog catalog = read("""
                korean-spf,Brand K,Sun Cream,sunscreen,,"Water, Glycerin",,https://k.example/sun,yes
                """, "");

        assertThat(catalog.products()).singleElement().extracting(CatalogProduct::imported).isEqualTo(true);
    }

    @Test
    void usSunscreenNeedsActivesAndImportMustBeYes() {
        assertThat(errors("""
                us-spf,Brand U,Sun Lotion,sunscreen,,"Water, Glycerin",,https://u.example/sun,
                other-spf,Brand U,Sun Gel,sunscreen,Zinc Oxide 9%,"Water, Glycerin",,https://u.example/gel,true
                """, "")).containsExactly(
                "products.csv:2: a US sunscreen must list its UV filters in actives, e.g. 'Zinc Oxide 9%' (or set import to 'yes')",
                "products.csv:3: import must be 'yes' or empty, not 'true'");
    }

    @Test
    void rejectsActivesWithoutPercentage() {
        assertThat(errors("""
                acne-wash,Brand B,Acne Wash,cleanser,Benzoyl Peroxide; Salicylic Acid 120%; Zinc Oxide 5%; zinc oxide 6%,"Water, Glycerin",,https://b.example/wash
                """, "")).containsExactly(
                "products.csv:2: actives must look like 'Benzoyl Peroxide 4%; Zinc Oxide 9%', not 'Benzoyl Peroxide'",
                "products.csv:2: actives must look like 'Benzoyl Peroxide 4%; Zinc Oxide 9%', not 'Salicylic Acid 120%'",
                "products.csv:2: active 'zinc oxide' is listed twice");
    }

    @Test
    void lineNumbersHoldWithoutTrailingNewline() {
        assertThat(errors(CLEANSER, "gentle-cleanser,target,abc,,,https://t.example/1,2026-09-20"))
                .containsExactly("offers.csv:2: price_usd must be a positive amount like 15.99, not 'abc'");
    }

    @Test
    void rejectsDuplicates() {
        assertThat(errors(CLEANSER + CLEANSER, """
                gentle-cleanser,target,15.99,16,fl oz,https://t.example/1,2026-09-20
                gentle-cleanser,target,14.99,16,fl oz,https://t.example/1,2026-09-21
                """)).containsExactly(
                "products.csv:3: duplicate id 'gentle-cleanser'",
                "offers.csv:3: duplicate offer for 'gentle-cleanser' at target in this size");
    }

    @Test
    void rejectsMissingColumns() {
        List<String> errors = catchThrowableOfType(InvalidCatalogException.class, () -> CatalogCsvReader.read(
                new StringReader("id,brand,name\nx,y,z\n"), new StringReader(OFFERS_HEADER), TODAY)).errors();

        assertThat(errors).containsExactly(
                "products.csv: header must contain id,brand,name,category,actives,ingredients,image_url,source_url,import");
    }
}
