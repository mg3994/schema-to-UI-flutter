# Universal Schema.org JSON-LD Flutter UI Engine

A production-grade, highly extensible Flutter web & mobile application that dynamically parses, indexes, and renders any standard, nested, or custom **Schema.org JSON-LD** payload. Built using **BLoC Signals** state management (`signals_flutter` / `bloc_signals_flutter`), **Kaisel** responsive design, and the full official **Schema.org Ontology Graph** (`schemaorg-current-https.jsonld`).

---

## 🌟 Key Features & Capabilities

### 1. 🧬 Universal Socket-BLoC Component Architecture ("Female Socket" ➔ "Male Plug")
- **Dynamic Male Plugs**: Pluggable component slots (`SchemaWidgetSocket`) that inspect child node types and subclass hierarchies using the official Schema.org graph to automatically slot nested data.
- **Dedicated Socket Plugins**:
  - `SellerSocketPlugin`: Renders `Person`, `LocalBusiness`, `Organization`, or `Store` as rich contact badge cards.
  - `OfferSocketPlugin`: Renders `Offer` / `AggregateOffer` pricing, currencies, and availability.
  - `RatingSocketPlugin`: Formats `Rating` and `AggregateRating` into visual star indicators.
  - `PlaceSocketPlugin`: Formats `Place`, `PostalAddress`, and `AdministrativeArea` into location chips.
  - `QuantitativeValueSocketPlugin`: Formats physical specs (`weight`, `height`, `width`), inventory levels, and delivery lead times.
  - `Model3DSocketPlugin`: Interactive 3D Model / AR Camera preview button for `3DModel` media objects.
  - `CertificationSocketPlugin`: Visual compliance badges for certifications (e.g. `EPREL`).
  - `EnumSocketPlugin`: Color-coded status badges for Schema.org enums (`InStock`, `InStoreOnly`, `PreOrder`, `NewCondition`, `EventScheduled`, etc.).

### 2. ⚡ Dynamic Ontology Subclass Routing
- Uses `SchemaOntologyService.isSubclassOf(childType, parentType)` to dynamically match any present or future subclass without hardcoding type names (e.g., `NewsArticle` or `BlogPosting` automatically resolve to `Article` UI; `Store` or `LocalBusiness` resolve to `Organization` UI).

### 3. 🛍️ Specialized High-Fidelity Rich Views
- **ProductGroup & Variant Customization**: E-Commerce variant selector chips (`variesBy` color, size, material), variant-specific `addOn` offer services (gift wrapping, custom embroidery, cap accessories) with live total price calculations.
- **Product View**: E-Commerce pricing, stock status badges, reviews, ratings, and merchant info.
- **Recipe View**: Culinary stats (prep/cook times, yield), nutrition info, and interactive ingredient check-lists.
- **Article / Blog View**: Publisher logo headers, author avatars, and publication dates.
- **Event View**: Start/end dates, location maps, organizer badges, and ticket offer actions.
- **Organization / Corporation View**: Executive team listings, logo, contact points, and address details.
- **HowTo View**: Step-by-step instructions, supply/tool chips, and visual step thumbnails.
- **Place View**: Interactive location cards with geo-coordinates and phone actions.
- **Universal Adaptive Renderer**: Recursive fallback for generic, obscure, or deeply nested Schema.org types with expandable accordions and formatted key-value grids.

### 4. 🌍 Multilingual `@value` & Active Locale Switcher
- **SchemaLocaleTextExtractor**: Parses `@value` and `@language` lists (e.g. `[{"@value": "Running Shoes", "@language": "en-US"}, ...]`) and dynamically extracts the best matching string based on the active Flutter locale, system device locales in order, or available fallbacks.
- **Active Locale Dropdown**: Interactive toolbar selector (`en-US`, `es-ES`, `fr-FR`, `hi-IN`) to test live multilingual re-rendering.
- **SchemaDateFormatter**: Localized ISO date/time formatting via `package:intl/intl.dart`.

### 5. 🛠️ Studio Dashboard & Schema Explorer
- **Studio Dashboard**:
  - **Tab 1: Rich UI Render Canvas**: Live graphical interface.
  - **Tab 2: JSON-LD Studio Editor & Hierarchy Inspector**: Code editor paired with a searchable, highlighted schema node inspector.
  - **Tab 3: Socket Component Inspector**: Real-time diagnostic panel listing active female sockets and plugged male component types.
- **Schema.org Class Explorer**: Searchable catalog of thousands of official Schema.org classes with one-click JSON-LD sample template generation.

---

## 🚀 GitHub Actions Deployment

Includes `.github/workflows/deploy.yml` configured to build and deploy the Flutter Web application to **GitHub Pages** automatically on pushes to all branches (`"**"`).

---

## 🧪 Testing & Quality Assurance

Run tests and analysis commands in your terminal:

```bash
# Static analysis
flutter analyze

# Run unit & widget test suites
flutter test test/parser_test.dart test/ui_rendering_test.dart

# Build Web release
flutter build web --base-href=/schema-to-UI-flutter/
```
