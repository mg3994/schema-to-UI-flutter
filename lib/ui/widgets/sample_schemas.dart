class SampleSchemas {
  static const String productJson = '''{
  "@context": "https://schema.org/",
  "@type": "Product",
  "name": "Sony WH-1000XM5 Wireless Headphones",
  "image": [
    "https://images.unsplash.com/photo-1505740420928-5e560c06d30e",
    "https://images.unsplash.com/photo-1484704849700-f032a568e944"
  ],
  "description": "Industry-leading noise canceling headphones with two processors and 8 microphones for unprecedented sound quality.",
  "sku": "WH1000XM5/B",
  "mpn": "9278292",
  "brand": {
    "@type": "Brand",
    "name": "Sony"
  },
  "review": {
    "@type": "Review",
    "reviewRating": {
      "@type": "Rating",
      "ratingValue": "5",
      "bestRating": "5"
    },
    "author": {
      "@type": "Person",
      "name": "Alex Tech Reviews"
    },
    "reviewBody": "Phenomenal active noise cancellation and super comfortable lightweight design."
  },
  "aggregateRating": {
    "@type": "AggregateRating",
    "ratingValue": "4.8",
    "reviewCount": "894"
  },
  "offers": {
    "@type": "Offer",
    "url": "https://example.com/sony-wh1000xm5",
    "priceCurrency": "USD",
    "price": "398.00",
    "priceValidUntil": "2026-12-31",
    "itemCondition": "https://schema.org/NewCondition",
    "availability": "https://schema.org/InStock",
    "seller": {
      "@type": "Organization",
      "name": "TechStore Express"
    }
  }
}''';

  static const String productGroupJson = '''{
  "@context": "https://schema.org/",
  "@type": "ProductGroup",
  "name": "Pro Pro-Series Custom Laptop & Addons",
  "description": "Customizable high-performance flagship laptop with nested variant configurations and official accessory addons.",
  "brand": {
    "@type": "Brand",
    "name": "ProTech"
  },
  "variesBy": [
    "https://schema.org/color",
    "https://schema.org/size"
  ],
  "hasVariant": [
    {
      "@type": "Product",
      "name": "Pro-Series Laptop (Space Gray / 16GB RAM)",
      "color": "Space Gray",
      "size": "16GB RAM / 512GB SSD",
      "image": "https://images.unsplash.com/photo-1517336714731-489689fd1ca8",
      "offers": {
        "@type": "Offer",
        "price": 1299.00,
        "priceCurrency": "USD"
      }
    },
    {
      "@type": "Product",
      "name": "Pro-Series Laptop (Silver / 32GB RAM)",
      "color": "Silver",
      "size": "32GB RAM / 1TB SSD",
      "image": "https://images.unsplash.com/photo-1611186871348-b1ce696e52c9",
      "offers": {
        "@type": "Offer",
        "price": 1699.00,
        "priceCurrency": "USD"
      }
    }
  ],
  "isRelatedTo": [
    {
      "@type": "Product",
      "name": "ProCare Extended 2-Year Warranty Protection",
      "description": "Accidental damage coverage and 24/7 priority support",
      "offers": {
        "@type": "Offer",
        "price": 149.00,
        "priceCurrency": "USD"
      }
    },
    {
      "@type": "Product",
      "name": "ProDock USB-C Thunderbolt 4 Docking Station",
      "description": "Dual 4K display output and 100W power delivery",
      "offers": {
        "@type": "Offer",
        "price": 199.00,
        "priceCurrency": "USD"
      }
    }
  ]
}''';

  static const String recipeJson = '''{
  "@context": "https://schema.org/",
  "@type": "Recipe",
  "name": "Classic Italian Margherita Pizza",
  "image": "https://images.unsplash.com/photo-1604382354936-07c5d9983bd3",
  "author": {
    "@type": "Person",
    "name": "Chef Marco"
  },
  "datePublished": "2026-03-15",
  "description": "Authentic Neapolitan pizza with fresh mozzarella, ripe tomatoes, and fragrant basil.",
  "prepTime": "PT20M",
  "cookTime": "PT15M",
  "totalTime": "PT35M",
  "keywords": "pizza, italian, margherita, dinner",
  "recipeYield": "4 servings",
  "recipeCategory": "Main Course",
  "recipeCuisine": "Italian",
  "nutrition": {
    "@type": "NutritionInformation",
    "calories": "280 calories"
  },
  "recipeIngredient": [
    "2 1/2 cups All-Purpose Flour",
    "1 tsp Active Dry Yeast",
    "1 cup Warm Water",
    "1/2 cup Fresh Tomato Sauce",
    "200g Fresh Mozzarella Cheese",
    "Fresh Basil Leaves",
    "2 tbsp Extra Virgin Olive Oil"
  ]
}''';

  static const String articleJson = '''{
  "@context": "https://schema.org",
  "@type": "Article",
  "headline": "The Future of AI and Flutter Cross-Platform Development",
  "image": [
    "https://images.unsplash.com/photo-1518770660439-4636190af475"
  ],
  "datePublished": "2026-08-10T08:00:00+00:00",
  "dateModified": "2026-08-12T09:20:00+00:00",
  "author": {
    "@type": "Person",
    "name": "Sarah Connor",
    "jobTitle": "Lead Flutter Engineer",
    "worksFor": {
      "@type": "Organization",
      "name": "Dart Tech Labs"
    }
  },
  "publisher": {
    "@type": "Organization",
    "name": "Tech Trends Daily",
    "logo": {
      "@type": "ImageObject",
      "url": "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe"
    }
  },
  "description": "Discover how modern AI engines and JSON-LD schema parsers elevate cross-platform Flutter user interfaces.",
  "articleBody": "Cross-platform frameworks like Flutter have revolutionized mobile and web application development. By combining strong typing, reactive state engines, and dynamic JSON-LD metadata, developers can render rich context-aware user interfaces automatically for thousands of Schema.org types."
}''';

  static const String eventJson = '''{
  "@context": "https://schema.org",
  "@type": "Event",
  "name": "Global Flutter & Dart Summit 2026",
  "startDate": "2026-10-15T09:00:00-07:00",
  "endDate": "2026-10-17T18:00:00-07:00",
  "eventStatus": "https://schema.org/EventScheduled",
  "eventAttendanceMode": "https://schema.org/MixedEventAttendanceMode",
  "location": {
    "@type": "Place",
    "name": "Moscone Center",
    "address": {
      "@type": "PostalAddress",
      "streetAddress": "747 Howard St",
      "addressLocality": "San Francisco",
      "postalCode": "94103",
      "addressRegion": "CA",
      "addressCountry": "US"
    }
  },
  "image": [
    "https://images.unsplash.com/photo-1540575467063-178a50c2df87"
  ],
  "description": "The premiere annual conference for Flutter and Dart developers worldwide featuring keynotes, workshops, and networking.",
  "organizer": {
    "@type": "Organization",
    "name": "Flutter Community Foundation",
    "url": "https://flutter.dev"
  },
  "offers": {
    "@type": "Offer",
    "url": "https://example.com/tickets",
    "price": "299.00",
    "priceCurrency": "USD",
    "availability": "https://schema.org/InStock"
  }
}''';

  static const String nestedOrgJson = '''{
  "@context": "https://schema.org",
  "@type": "Corporation",
  "name": "Apex Global Technologies",
  "url": "https://apexglobal.example.com",
  "logo": "https://images.unsplash.com/photo-1560179707-f14e90ef3623",
  "description": "Leading global provider of cloud compute and cross-platform mobile ecosystem solutions.",
  "founders": [
    {
      "@type": "Person",
      "name": "Elena Rostova",
      "jobTitle": "Co-Founder & CEO",
      "email": "elena@apexglobal.example.com"
    },
    {
      "@type": "Person",
      "name": "David Vance",
      "jobTitle": "Co-Founder & CTO",
      "email": "david@apexglobal.example.com"
    }
  ],
  "address": {
    "@type": "PostalAddress",
    "streetAddress": "100 Innovation Way",
    "addressLocality": "Austin",
    "addressRegion": "TX",
    "postalCode": "78701",
    "addressCountry": "USA"
  },
  "department": [
    {
      "@type": "Organization",
      "name": "Apex AI Research Lab",
      "member": {
        "@type": "Person",
        "name": "Dr. Alan Turing Jr.",
        "jobTitle": "Principal AI Researcher"
      }
    },
    {
      "@type": "Organization",
      "name": "Apex Mobile Engineering",
      "member": {
        "@type": "Person",
        "name": "Sofia Chen",
        "jobTitle": "Lead Flutter Architect"
      }
    }
  ]
}''';

  static final Map<String, String> presets = {
    "Product (E-Commerce)": productJson,
    "Product Group & Addons": productGroupJson,
    "Recipe (Culinary)": recipeJson,
    "Article (News / Blog)": articleJson,
    "Event (Conference)": eventJson,
    "Deeply Nested Organization": nestedOrgJson,
  };
}
