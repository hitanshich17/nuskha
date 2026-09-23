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
- [ ] **La Roche-Posay Effaclar Medicated Gel Cleanser**: whole product (site blocks automated reading).
  It's an OTC acne product, so put the salicylic acid % in `actives`.
  Search: https://www.laroche-posay.us/our-products/face/face-wash
  id: `la-roche-posay-effaclar-medicated-gel-cleanser`
- [ ] **Vanicream Gentle Facial Cleanser**: price and size (not sold on the brand site).
  Page: https://www.vanicream.com/product/vanicream-facial-cleanser
- [ ] **Neutrogena Oil-Free Acne Wash**: price and size (the page doesn't include a price).
  Page: https://www.neutrogena.com/products/skincare/oil-free-acne-wash-with-salicylic-acid/6811719
- [ ] **Paula's Choice CLEAR Pore Normalizing Cleanser**: ingredients and size (loaded by JavaScript).
  Price on the page: $28. It contains 0.5% salicylic acid; if the label lists it as an active, put it in `actives`.
  Page: https://www.paulaschoice.com/clear-pore-normalizing-cleanser/600.html
  id: `paulas-choice-clear-pore-normalizing-cleanser`
- [ ] **Paula's Choice CALM Ultra-Gentle Cleanser**: ingredients and size (loaded by JavaScript). Price on the page: $28.
  Page: https://www.paulaschoice.com/calm-ultra-gentle-cleanser/9190.html
  id: `paulas-choice-calm-ultra-gentle-cleanser`
- [ ] **Kiehl's Ultra Facial Cleanser**: whole product (site blocks automated reading).
  Page: https://www.kiehls.com/skincare/face-cleansers-scrubs/ultra-facial-cleanser/714.html
  id: `kiehls-ultra-facial-cleanser`
- [ ] **Senka Perfect Whip**: whole product, from the US Walmart listing (no official US store; Japanese
  imports can have a different formula, so use the US listing).
  Page: https://www.walmart.com/ip/Shiseido-Senka-Perfect-Whip-Cream-Face-Wash-4-23-oz/908991070
  id: `senka-perfect-whip`, retailer: `walmart`
- [ ] **Drunk Elephant Beste No. 9 Jelly Cleanser**: price + size. The page shows $18.00 without saying which
  size (possibly the travel size), so check it in the browser.
  Page: https://www.drunkelephant.com/beste-no.-9-jelly-cleanser-812343032415.html
- [ ] **Fresh Soy Face Cleanser**: whole product (site blocks automated reading).
  Page: https://www.fresh.com/us/skincare/categories/cleansers/soy-face-cleanser-H00006238.html
  id: `fresh-soy-face-cleanser`
- [ ] **Youth To The People Superfood Cleanser**: whole product (site blocks automated reading).
  Page: https://www.youthtothepeople.com/skincare/cleansers/superfood-cleanser/YTTP-10100.html
  id: `youth-to-the-people-superfood-cleanser`

## Treatments

- [ ] **Paula's Choice 2% BHA Liquid Exfoliant**: ingredients (loaded by JavaScript) and size. Price on the page: $37.
  Page: https://www.paulaschoice.com/skin-perfecting-2pct-bha-liquid-exfoliant/201-2010.html
  id: `paulas-choice-2-bha-liquid-exfoliant`
- [ ] **Good Molecules Discoloration Correcting Serum**: ingredients (loaded by JavaScript). Then add this offer:
  `good-molecules-discoloration-correcting-serum,brand,12.00,30,ml,https://www.goodmolecules.com/s/good-molecules-discoloration-correcting-serum-30ml,2026-09-23`
  Page: https://www.goodmolecules.com/s/good-molecules-discoloration-correcting-serum-30ml
  id: `good-molecules-discoloration-correcting-serum`
