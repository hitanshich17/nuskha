# Data to fill in by hand

Sites below block automated reading or don't show the value, so copy it from the page in your browser.
When done, delete the line here. Validate with `cd services/core-api && ./mvnw -q test -Dtest=CatalogFilesTest`.

Conventions: prices as `15.99`; size + unit as on the label (`ml`, `g`, `fl oz`, `oz`; liquids sold in "oz" count
as `fl oz`); ingredients copied exactly; OTC active ingredients go in `actives` as `Name N%; Name N%`.

## Cleansers

- [ ] **Cetaphil Gentle Skin Cleanser**: price and size (add a row to offers.csv).
  Page: https://www.cetaphil.com/us/products/product-categories/all-cleansers/cetaphil-gentle-skin-cleanser/302990110227.html
  (no price on the brand site, so use a retailer and set `retailer` to e.g. `target`)
- [ ] **La Roche-Posay Toleriane Hydrating Gentle Cleanser**: whole product (row in products.csv and offers.csv).
  Page: https://www.laroche-posay.us/our-products/face/face-wash/toleriane-hydrating-gentle-facial-cleanser-tolerianehydratinggentlefacialcleanser.html
  id: `la-roche-posay-toleriane-hydrating-gentle-cleanser`
