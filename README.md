# OutMed

**B2B medical supply marketplace** for hospitals, clinics, and verified suppliers.

OutMed is a Flutter app that connects **healthcare buyers** (hospitals / facilities) with **medical suppliers**. It is not a consumer store — purchasing is organization-to-organization: catalog, supplier offers, cart, orders, inventory, and in-app messaging.

> Medical supply, simplified.

---

## Project details

| | |
| --- | --- |
| **Type** | B2B marketplace (buyer ↔ supplier) |
| **Domain** | Medical supplies, PPE, surgical, diagnostic kits |
| **Platform** | Flutter (iOS / Android), English + Arabic (RTL) |
| **State / architecture** | GetX, feature-based (clean architecture folders) |
| **Data** | In-app mock catalog & orders (no live backend yet) |
| **Roles** | **Buyer** (healthcare facility) and **Supplier** (vendor) |

### Buyer (hospital / facility)

- Browse a shared master catalog and compare supplier offers
- Product detail, quantity, add to cart, checkout
- Order history, tracking, and **Buy again**
- Messages with suppliers

### Supplier (vendor)

- Publish **offers** on master products (price, stock, MOQ, lead time)
- **Edit / delete** own offers from inventory
- Stock updates, low-stock alerts
- Incoming orders and status progression (confirm → prepare → ship → deliver)

---

## Mockup

App screens from the current build (iPhone).

### Buyer flow

<p>
  <img src="docs/mockup/01-onboarding-1.png" width="180" alt="Onboarding 1" />
  <img src="docs/mockup/02-onboarding-2.png" width="180" alt="Onboarding 2" />
  <img src="docs/mockup/03-onboarding-3.png" width="180" alt="Onboarding 3" />
  <img src="docs/mockup/04-auth-landing.png" width="180" alt="Join marketplace" />
</p>
<p>
  <img src="docs/mockup/05-buyer-home.png" width="180" alt="Buyer home" />
  <img src="docs/mockup/06-product-detail.png" width="180" alt="Product detail" />
  <img src="docs/mockup/07-cart.png" width="180" alt="Cart" />
  <img src="docs/mockup/08-order-history.png" width="180" alt="Order history" />
</p>
<p>
  <img src="docs/mockup/09-messages.png" width="180" alt="Messages" />
  <img src="docs/mockup/10-order-details.png" width="180" alt="Order details" />
  <img src="docs/mockup/11-chat.png" width="180" alt="Supplier chat" />
</p>

### Supplier flow

<p>
  <img src="docs/mockup/16-supplier-dashboard.jpg" width="180" alt="Supplier dashboard" />
  <img src="docs/mockup/14-supplier-orders.jpg" width="180" alt="Supplier orders" />
  <img src="docs/mockup/15-inventory.jpg" width="180" alt="Inventory" />
  <img src="docs/mockup/13-catalog-search.png" width="180" alt="Catalog search" />
  <img src="docs/mockup/12-add-offer.png" width="180" alt="Add product offer" />
</p>

| Screen | What it shows |
| --- | --- |
| Onboarding | Find suppliers, order securely, track deliveries to the hospital |
| Auth | Join the OutMed **B2B marketplace** (email / Google / Apple) |
| Buyer home | Search, categories, featured products |
| Product / cart | Offer price, VAT, delivery, checkout |
| Order history | Past B2B orders + **Buy again** |
| Messages / chat | Buyer–supplier coordination |
| Supplier dashboard | Today’s orders, revenue, quick actions |
| Orders | Confirm and advance hospital orders |
| Inventory | Own offers; **⋯** menu to update stock, edit, or delete |
| Add offer | Select a master product, then set price / stock |

---

## Run locally

```bash
flutter pub get
flutter run
```

Demo login uses the in-app buyer / supplier profile switch. No backend is required for this mock.

---

## Stack

- Flutter 3 / Dart 3
- GetX (routing, state, i18n)
- `flutter_svg`, `image_picker`
- Feature modules: `auth`, `buyer`, `supplier`, `catalog`, `cart`, `orders`, `messages`, `profile`
