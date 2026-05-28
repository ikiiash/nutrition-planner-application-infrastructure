# Nutrition Planner — Technická dokumentácia

> Tento dokument popisuje celú architektúru, všetky dôležité súbory, tok požiadaviek, ukladanie dát a nasadenie aplikácie Nutrition Planner.

---

## Obsah

1. [Prehľad systému](#1-prehľad-systému)
2. [Štruktúra repozitárov](#2-štruktúra-repozitárov)
3. [Backend — hexagonálna architektúra](#3-backend--hexagonálna-architektúra)
   - [Doménová vrstva (domain)](#31-doménová-vrstva-domain)
   - [API špecifikácia (api-spec)](#32-api-špecifikácia-api-spec)
   - [REST vrstva (inbound-controller-rest)](#33-rest-vrstva-inbound-controller-rest)
   - [JPA vrstva (outbound-repository-jpa)](#34-jpa-vrstva-outbound-repository-jpa)
   - [Springboot modul](#35-springboot-modul)
   - [Konfigurácia (application.yaml)](#36-konfigurácia-applicationyaml)
4. [Databáza](#4-databáza)
   - [Schéma tabuliek](#41-schéma-tabuliek)
   - [Liquibase migrácie](#42-liquibase-migrácie)
5. [Tok požiadaviek](#5-tok-požiadaviek)
   - [Typická autentifikovaná požiadavka](#51-typická-autentifikovaná-požiadavka)
   - [Autentifikačný tok (OAuth2 Code Flow)](#52-autentifikačný-tok-oauth2-code-flow)
   - [AI autofill tok](#53-ai-autofill-tok)
6. [Frontend — Angular 21](#6-frontend--angular-21)
   - [Štruktúra projektu](#61-štruktúra-projektu)
   - [Autentifikácia](#62-autentifikácia)
   - [Stránky a komponenty](#63-stránky-a-komponenty)
   - [API klienti](#64-api-klienti)
7. [Infraštruktúra](#7-infraštruktúra)
   - [Kubernetes workloady](#71-kubernetes-workloady)
   - [Terraform](#72-terraform)
   - [Monitoring](#73-monitoring)
8. [CI/CD pipeline](#8-cicd-pipeline)
9. [Bezpečnosť](#9-bezpečnosť)
10. [Kľúčové algoritmy](#10-kľúčové-algoritmy)

---

## 1. Prehľad systému

Nutrition Planner je full-stack webová aplikácia na plánovanie stravy a sledovanie výživy. Systém je rozdelený do troch samostatných repozitárov, každý s vlastnou zodpovednosťou.

```
┌─────────────────────────────────────────────────────────────────┐
│                        INTERNET / BROWSER                        │
└──────────────────────────────┬──────────────────────────────────┘
                               │ HTTPS (443)
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│              nginx Ingress  (nutrition-planner.net)              │
│   /auth/*  →  Keycloak      /api/*  →  Backend     /* →  Frontend│
└──────┬──────────────────────┬──────────────────────┬────────────┘
       │                      │                      │
       ▼                      ▼                      ▼
┌─────────────┐    ┌─────────────────────┐  ┌──────────────────┐
│  Keycloak   │    │  Spring Boot 4      │  │  Angular 21      │
│  (OAuth2 /  │    │  Java 25            │  │  nginx container │
│   OIDC)     │    │  Port 8080          │  │  Port 80         │
└──────┬──────┘    └──────────┬──────────┘  └──────────────────┘
       │                      │
       │ JWT validation        │ JDBC
       │                      ▼
       │           ┌─────────────────────┐
       │           │  PostgreSQL          │
       │           │  Azure DB for PgSQL  │
       └──────────▶│  Port 5432          │
                   └─────────────────────┘
                              │
                   ┌─────────────────────┐
                   │  OpenAI API         │
                   │  (gpt-4o-mini)      │
                   └─────────────────────┘
```

**Technologický stack:**

| Vrstva | Technológia | Verzia |
|--------|-------------|--------|
| Backend | Spring Boot | 4.0.3 |
| Jazyk | Java | 25 |
| Frontend | Angular | 21.2.7 |
| Jazyk | TypeScript | 5.9.2 |
| Databáza | PostgreSQL | 17 Alpine |
| Identity Provider | Keycloak | 26.5.5 |
| Kontajnerizácia | Kubernetes (AKS) | 1.34 |
| IaC | Terraform | 1.11+ |
| CI/CD | GitLab CI | — |
| AI | OpenAI GPT-4o-mini | — |

---

## 2. Štruktúra repozitárov

Projekt je rozdelený do troch samostatných Git repozitárov:

```
nutrition-planner-application-backend/
├── application/
│   ├── api-spec/                  # OpenAPI YAML kontrakt + generované DTO
│   ├── domain/                    # Čistá business logika (bez Spring/JPA)
│   ├── inbound-controller-rest/   # REST adaptéry (HTTP vrstva)
│   ├── outbound-repository-jpa/   # JPA adaptéry (databázová vrstva)
│   └── springboot/                # Zostavenie aplikácie, Spring konfigurácia
├── .scripts/keycloak/             # Bootstrap skripty pre Keycloak realm
├── docker-compose.yml             # PostgreSQL + Keycloak pre lokálny vývoj
├── .gitlab-ci.yml                 # CI/CD pipeline
└── README.md

nutrition-planner-application-frontend/
├── src/
│   ├── app/
│   │   ├── core/                  # Auth, interceptory, guards, globálne služby
│   │   ├── entities/              # API klienti a doménové modely
│   │   ├── pages/                 # Stránky (route-level komponenty)
│   │   └── shared/                # Zdieľané UI komponenty, pipes, direktívy
│   ├── environments/              # Konfigurácia prostredí
│   └── styles/                    # Globálne SCSS štýly, design tokeny
├── proxy.conf.json                # Dev proxy: /api → localhost:8080
├── angular.json
├── .gitlab-ci.yml
└── README.md

nutrition-planner-application-infrastructure/
├── terraform/                     # Azure infraštruktúra (AKS, ACR, PostgreSQL, DNS)
│   ├── 00-fsa-common/             # Spoločné premenné (subscription, tenant, location)
│   ├── 01-fsa-rg/                 # Resource Group
│   ├── 02-fsa-acr/                # Azure Container Registry
│   ├── 03-fsa-aks/                # AKS cluster (2 node pools)
│   ├── 04-fsa-pip/                # Public IP adresa
│   ├── 05-fsa-psql/               # Azure Database for PostgreSQL
│   ├── 06-fsa-dns/                # DNS zóna (fullstackacademy.sk)
│   └── 07-fsa-automation/         # Azure Automation
├── kubernetes/
│   ├── workload/
│   │   ├── 01-namespace.yaml      # Menné priestory: app, infra, monitoring
│   │   ├── 02-secrets.yaml        # Kubernetes Secrets (DB, Keycloak, OpenAI)
│   │   ├── 03-app-backend/        # Backend Deployment + Service
│   │   ├── 04-app-frontend/       # Frontend Deployment + Service
│   │   ├── 05-ingress/            # Ingress pravidlá pre každú doménu
│   │   ├── 06-grafana-dashboard/  # Grafana dashboard pre monitoring
│   │   └── 07-gitlab-deploy-rbac/ # RBAC pre GitLab Runner deploy
│   └── helm/
│       └── helm-values/           # Helm hodnoty pre Keycloak, nginx, cert-manager, Grafana
└── .gitlab-ci.yml                 # Validácia Terraform + Kubernetes YAML
```

---

## 3. Backend — hexagonálna architektúra

Backend striktne dodržiava **hexagonálnu (Ports & Adapters)** architektúru. Základný princíp: doménová logika nepozná Spring ani JPA — závisí len od Java štandardnej knižnice.

```
┌─────────────────────────────────────────────────────────────┐
│                    INBOUND ADAPTERS                          │
│  REST Controllers  (implements OpenAPI interfaces)           │
└─────────────────────────┬───────────────────────────────────┘
                          │ volá Facade (port)
┌─────────────────────────▼───────────────────────────────────┐
│                      DOMAIN                                  │
│  Services (FoodProductService, MealService, ...)             │
│  Domain Models (FoodProduct, Meal, MealPlan, ...)           │
│  Repository Interfaces (FoodProductRepository, ...)          │
└─────────────────────────┬───────────────────────────────────┘
                          │ implements Repository (port)
┌─────────────────────────▼───────────────────────────────────┐
│                   OUTBOUND ADAPTERS                          │
│  JPA Adapters  →  Spring Data Repositories  →  PostgreSQL    │
└─────────────────────────────────────────────────────────────┘
```

### 3.1 Doménová vrstva (domain)

**Umiestnenie:** `application/domain/src/main/java/sk/posam/fsa/nutrition/`

Táto vrstva neobsahuje žiadne Spring/JPA anotácie. Je to čistá Java.

#### Doménové modely

**`FoodProduct.java`**  
Základná jednotka stravy. Obsahuje:
- Identifikácia: `id`, `ownerUserId` (Keycloak UUID používateľa)
- Základné údaje: `name`, `category`, `grams` (referenčná gramáž), `price`, `photoUrl`
- Makroživiny: `calories`, `protein`, `fat`, `carbohydrates`
- Mikroživiny (všetky voliteľné): `sodiumMg`, `potassiumMg`, `magnesiumMg`, `ironMg`, `calciumMg`, `zincMg`, `vitaminAMcg`, `vitaminCMg`, `vitaminDMcg`, `vitaminEMg`, `vitaminKMcg`, `vitaminB1Mg`, `vitaminB2Mg`, `vitaminB6Mg`, `vitaminB9Mcg`, `vitaminB12Mcg`
- Sledovanie chladničky: `inFridge` (boolean), `fridgeGrams` (Double)

**`Meal.java`**  
Jedlo zložené z potravín:
- `id`, `ownerUserId`, `name`, `servings`
- `ingredients` — zoznam `MealIngredient`

**`MealIngredient.java`**  
Ingrediencia jedla:
- `foodProductId`, `foodProductName`, `grams`
- Uložené hodnoty na gram: `caloriesPerGram`, `proteinPerGram`, `fatPerGram`, `carbohydratesPerGram`, `pricePerGram`
- Mikroživiny na gram: `sodiumMgPerGram`, ..., `vitaminB12McgPerGram`
- Vypočítané hodnoty sú uložené v čase vytvorenia jedla (denormalizácia pre výkon)

**`MealPlan.java`**  
Plán stravovania:
- `id`, `ownerUserId`, `name`, `startDate`, `numberOfDays` (1–30)
- `days` — zoznam `PlanDay`
- `isActive` — boolean, len jeden plán môže byť aktívny
- `activatedAt` — dátum aktivácie (používa sa na výpočet aktuálneho dňa)
- `lastDeductedDayNumber` — sleduje do ktorého dňa boli zásoby odpočítané

**`PlanDay.java`**  
Jeden deň plánu:
- `id`, `dayNumber` (1-based)
- `entries` — zoznam `PlanEntry`

**`PlanEntry.java`**  
Záznam v dni plánu:
- `id`, `mealType` (BREAKFAST / LUNCH / DINNER / SNACK)
- `entryType` (MEAL alebo FOOD_PRODUCT)
- Pre MEAL: `mealId`, `mealName`, `portions`
- Pre FOOD_PRODUCT: `foodProductId`, `foodProductName`, `grams`
- Uložené nutričné hodnoty: `calories`, `protein`, `fat`, `carbohydrates`, `price` + mikroživiny

**`UserProfile.java`**  
Profil používateľa:
- `keycloakUserId`, `email`, `nickname`, `firstName`
- Biometria: `gender` (MALE/FEMALE), `age`, `heightCm`, `weightKg`
- `activityLevel` (SEDENTARY / LIGHTLY_ACTIVE / MODERATELY_ACTIVE / VERY_ACTIVE / EXTRA_ACTIVE)
- `goal` (LOSE_WEIGHT / MAINTAIN_WEIGHT / GAIN_MASS)
- Vypočítané hodnoty: `bmr`, `tdee`, `targetCalories`, `targetProtein`, `targetFat`, `targetCarbohydrates`

**`ChatSession.java`** a **`ChatMessage.java`**  
História chatovacích sedení s AI asistentom:
- `ChatSession`: `id`, `ownerUserId`, `title`, `createdAt`, `messages`
- `ChatMessage`: `role` (user/assistant), `content`, `createdAt`

**`ShoppingListItem.java`**  
Položka nákupného zoznamu:
- `id`, `ownerUserId`, `foodProductId`, `foodProductName`, `grams`
- Uložené hodnoty na 100g: `caloriesPer100g`, `proteinPer100g`, `fatPer100g`, `carbsPer100g`, `pricePer100g`

#### Facade rozhrania (porty)

Každá doménová služba implementuje Facade rozhranie — kontrakt medzi doménou a vonkajším svetom:

- `FoodProductFacade` — CRUD + nastavenie chladničky
- `MealFacade` — CRUD jedál
- `MealPlanFacade` — CRUD plánov + aktivácia + deductFridge
- `UserProfileFacade` — čítanie a aktualizácia profilu
- `AiAssistantFacade` — chat, autofill, správa sedení
- `ShoppingListFacade` — CRUD nákupného zoznamu

#### Repozitárové rozhrania (porty)

Doménová vrstva definuje rozhrania pre prístup k dátam — nevie nič o SQL alebo Spring:

```
FoodProductRepository:
  save(FoodProduct) → FoodProduct
  readAll(ownerUserId) → List<FoodProduct>
  readAll(ownerUserId, name) → List<FoodProduct>   // filtrácia podľa názvu
  readById(ownerUserId, id) → Optional<FoodProduct>
  deleteById(ownerUserId, id)
  readAllInFridge(ownerUserId) → List<FoodProduct>

MealRepository:
  save(Meal) → Meal
  readAll(ownerUserId) → List<Meal>
  readById(ownerUserId, id) → Optional<Meal>
  deleteById(ownerUserId, id)

MealPlanRepository:
  save(MealPlan) → MealPlan
  readAll(ownerUserId) → List<MealPlan>
  readById(ownerUserId, id) → Optional<MealPlan>
  deleteById(ownerUserId, id)
  deactivateAllForUser(ownerUserId)    // pri aktivácii iného plánu

UserProfileRepository:
  readByKeycloakUserId(id) → Optional<UserProfile>
  save(UserProfile) → UserProfile

ChatSessionRepository:
  save(ChatSession) → ChatSession
  readAll(ownerUserId) → List<ChatSession>
  readById(ownerUserId, id) → Optional<ChatSession>
  deleteById(ownerUserId, id)

ShoppingListRepository:
  save(ShoppingListItem) → ShoppingListItem
  readAll(ownerUserId) → List<ShoppingListItem>
  readById(ownerUserId, id) → Optional<ShoppingListItem>
  deleteById(ownerUserId, id)
  deleteAll(ownerUserId)
```

#### Doménové služby

**`FoodProductService.java`**

Implementuje `FoodProductFacade`. Obsahuje:
- `readFoodProducts(ownerUserId, name)` — ak je name null, vrátia sa všetky produkty používateľa; inak filtruje case-insensitive
- `createFoodProduct(ownerUserId, product)` — nastaví `ownerUserId`, uloží
- `readFoodProduct(ownerUserId, id)` — overí vlastníctvo
- `updateFoodProduct(ownerUserId, id, updated)` — overí vlastníctvo, aktualizuje
- `deleteFoodProduct(ownerUserId, id)` — overí vlastníctvo, zmaže
- `setFridgeStatus(ownerUserId, id, inFridge, fridgeGrams)` — aktualizuje len `inFridge` a `fridgeGrams`

**`MealService.java`**

Implementuje `MealFacade`. Kľúčová metóda:
- `enrichIngredients(meal)` — pre každú ingredienciu načíta `FoodProduct` z repozitára a vypočíta hodnoty na gram:
  ```
  caloriesPerGram = foodProduct.calories / foodProduct.grams
  proteinPerGram  = foodProduct.protein  / foodProduct.grams
  ...atď. pre všetky makro- a mikroživiny
  ```
  Tento prístup zabezpečuje, že nutričné hodnoty jedla sú konzistentné aj keď sa produkt neskôr zmení.

**`MealPlanService.java`**

Implementuje `MealPlanFacade`. Kľúčové metódy:
- `activateMealPlan(ownerUserId, planId)`:
  1. Deaktivuje všetky ostatné plány používateľa (`mealPlanRepository.deactivateAllForUser`)
  2. Nastaví `isActive = true`, `activatedAt = LocalDate.now()`
  3. Resetuje `lastDeductedDayNumber = 0`
- `deductFridge(ownerUserId, planId)`:
  1. Vypočíta počet uplynulých dní: `ChronoUnit.DAYS.between(activatedAt, today) + 1`
  2. Obmedzí na `numberOfDays` (maximálne posledný deň plánu)
  3. Nájde záznamy pre dni od `lastDeductedDayNumber + 1` do `currentDay`
  4. Agreguje spotrebu každého `foodProductId`:
     - Pre `FOOD_PRODUCT` záznamy: priamo podľa `grams`
     - Pre `MEAL` záznamy: načíta ingrediencie jedla, vypočíta `grams * ingredient.gramsInMeal / meal.grams`
  5. Pre každý produkt: `fridgeGrams = max(0, fridgeGrams - spotrebovánoGrams)`
  6. Aktualizuje `lastDeductedDayNumber`

**`UserProfileService.java`**

Implementuje `UserProfileFacade`. Kľúčová metóda `updateCurrentUserProfile`:
1. Nájde alebo vytvorí profil pre `keycloakUserId`
2. Uloží biometrické údaje
3. Vypočíta BMR (Mifflin–St Jeor):
   - Muž: `10 * weight + 6.25 * height - 5 * age + 5`
   - Žena: `10 * weight + 6.25 * height - 5 * age - 161`
4. Vypočíta TDEE: `BMR * activityMultiplier`
   ```
   SEDENTARY       → 1.2
   LIGHTLY_ACTIVE  → 1.375
   MODERATELY_ACTIVE → 1.55
   VERY_ACTIVE     → 1.725
   EXTRA_ACTIVE    → 1.9
   ```
5. Vypočíta cieľové kalórie: `TDEE * goalFactor`
   ```
   LOSE_WEIGHT     → 0.85  (deficit 15%)
   MAINTAIN_WEIGHT → 1.0
   GAIN_MASS       → 1.10  (prebytok 10%)
   ```
6. Vypočíta makrocie:
   - Bielkoviny: `weight * 2.0 g/kg` (chudnutie) alebo `weight * 1.8 g/kg`
   - Tuky: `weight * 1.0 g/kg` (chudnutie) alebo `weight * 0.8 g/kg`
   - Sacharidy: `(targetCalories - protein*4 - fat*9) / 4` (zvyšné kalórie)

**`AiAssistantService.java`**

Implementuje `AiAssistantFacade`. Hlavné metódy:
- `chat(ownerUserId, messages)` — odošle správy do OpenAI, predradí systémový prompt
- `autofill(productName)` — vyžiada nutričné hodnoty produktu vo formáte JSON
- `sendMessage(ownerUserId, chatId, content)`:
  1. Načíta celú históriu sedenia
  2. Pridá novú správu používateľa
  3. Zostaví systémový prompt s kontextom používateľa (profil, potraviny, jedlá, plány, nákupný zoznam)
  4. Odošle do OpenAI API
  5. Uloží odpoveď asistenta do histórie
- Systémový prompt obsahuje: profil, zoznam potravín, zoznam jedál, aktívny plán, nákupný zoznam

**`ShoppingListService.java`**

Implementuje `ShoppingListFacade`. Jednoduchý CRUD: `addItem`, `updateItem`, `deleteItem`, `clearAll`, `readAll`.

### 3.2 API špecifikácia (api-spec)

**Umiestnenie:** `application/api-spec/src/main/resources/openapi/nutrition-planner.yaml`

Tento modul obsahuje OpenAPI 3.0.3 kontrakt — **single source of truth** pre všetky REST endpointy. Z YAML sa automaticky generujú:
- Java rozhrania pre controllery (`@Generated`)
- DTO triedy (request/response objekty)

**Kľúčové sekcie YAML:**
- `components/schemas` — definície všetkých DTO
- `components/securitySchemes` — Bearer JWT
- `paths` — každý endpoint s HTTP metódou, parametrami, request body a responses

Generovanie prebieha cez Maven plugin `openapi-generator-maven-plugin` pri `mvn compile`.

**Zoznam všetkých endpointov:**

| Metóda | Cesta | Popis | Rola |
|--------|-------|-------|------|
| GET | `/health` | Health check | verejný |
| GET | `/food-products` | Zoznam produktov (voliteľný filter `?name=`) | USER+ |
| POST | `/food-products` | Vytvorenie produktu | USER+ |
| GET | `/food-products/{id}` | Detail produktu | USER+ |
| PUT | `/food-products/{id}` | Aktualizácia produktu | USER+ |
| DELETE | `/food-products/{id}` | Zmazanie produktu | USER+ |
| PATCH | `/food-products/{id}/fridge` | Nastavenie stavu chladničky | USER+ |
| GET | `/meals` | Zoznam jedál | USER+ |
| POST | `/meals` | Vytvorenie jedla | USER+ |
| GET | `/meals/{id}` | Detail jedla | USER+ |
| PUT | `/meals/{id}` | Aktualizácia jedla | USER+ |
| DELETE | `/meals/{id}` | Zmazanie jedla | USER+ |
| GET | `/meal-plans` | Zoznam plánov | USER+ |
| POST | `/meal-plans` | Vytvorenie plánu | USER+ |
| GET | `/meal-plans/{id}` | Detail plánu | USER+ |
| PUT | `/meal-plans/{id}` | Aktualizácia plánu | USER+ |
| DELETE | `/meal-plans/{id}` | Zmazanie plánu | USER+ |
| PUT | `/meal-plans/{id}/activate` | Aktivácia plánu | USER+ |
| PUT | `/meal-plans/{id}/deactivate` | Deaktivácia plánu | USER+ |
| POST | `/meal-plans/{id}/deduct-fridge` | Odpočet chladničky | USER+ |
| POST | `/meal-plans/{planId}/days/{dayId}/entries` | Pridanie záznamu do dňa | USER+ |
| DELETE | `/meal-plans/{planId}/days/{dayId}/entries/{entryId}` | Zmazanie záznamu | USER+ |
| GET | `/user-profile/me` | Profil aktuálneho používateľa | USER+ |
| PUT | `/user-profile/me` | Aktualizácia profilu | USER+ |
| GET | `/shopping-list` | Nákupný zoznam | USER+ |
| POST | `/shopping-list` | Pridanie položky | USER+ |
| PUT | `/shopping-list/{id}` | Aktualizácia položky | USER+ |
| DELETE | `/shopping-list/{id}` | Zmazanie položky | USER+ |
| DELETE | `/shopping-list` | Vymazanie celého zoznamu | USER+ |
| POST | `/ai/chat` | Jednorázový chat (bez histórie) | PREMIUM+ |
| POST | `/ai/autofill` | AI doplnenie nutričných hodnôt | PREMIUM+ |
| GET | `/ai/chats` | Zoznam chatovacích sedení | PREMIUM+ |
| POST | `/ai/chats` | Vytvorenie nového sedenia | PREMIUM+ |
| GET | `/ai/chats/{id}` | Detail sedenia s históriou | PREMIUM+ |
| DELETE | `/ai/chats/{id}` | Zmazanie sedenia | PREMIUM+ |
| POST | `/ai/chats/{id}/messages` | Odoslanie správy v sedení | PREMIUM+ |

### 3.3 REST vrstva (inbound-controller-rest)

**Umiestnenie:** `application/inbound-controller-rest/src/main/java/sk/posam/fsa/nutritionplanner/`

Táto vrstva implementuje rozhrania vygenerované z OpenAPI. Controllery neobsahujú business logiku — len mapujú HTTP požiadavky na volania Facade.

#### `CurrentUserProvider.java`

Extrahuje identitu používateľa z JWT tokenu:
```java
// Extrahovanie userId z JWT
String userId = jwt.getSubject();               // Keycloak UUID
String email  = jwt.getClaimAsString("email"); // email z tokenu
```
Vyhadzuje `IllegalStateException` ak nie je používateľ autentifikovaný.

#### `SecurityConfiguration.java`

Konfiguruje Spring Security pre OAuth2 Resource Server:
```
/health, /actuator/**               → verejný prístup
/food-products/**                   → ROLE_ADMIN, ROLE_USER, ROLE_PREMIUM_USER
/meals/**                           → ROLE_ADMIN, ROLE_USER, ROLE_PREMIUM_USER
/meal-plans/**                      → ROLE_ADMIN, ROLE_USER, ROLE_PREMIUM_USER
/user-profile/**                    → ROLE_ADMIN, ROLE_USER, ROLE_PREMIUM_USER
/shopping-list/**                   → ROLE_ADMIN, ROLE_USER, ROLE_PREMIUM_USER
/ai/chat, /ai/autofill              → ROLE_ADMIN, ROLE_PREMIUM_USER
/ai/chats/**                        → ROLE_ADMIN, ROLE_PREMIUM_USER
```

JWT konvertor extrahuje roly z `realm_access.roles` poľa v Keycloak tokene a pridáva prefix `ROLE_`.

#### `GlobalExceptionHandler.java`

Centralizovaná obsluha chýb — mapuje výnimky na HTTP odpovede:

| Výnimka | HTTP kód | Popis |
|---------|----------|-------|
| `EntityNotFoundException` | 404 | Záznam nebol nájdený |
| `MethodArgumentNotValidException` | 400 | Validačná chyba (Bean Validation) |
| `HttpMessageNotReadableException` | 400 | Neplatný JSON |
| `DataIntegrityViolationException` | 409 | Konflikt (duplikát) |
| `AccessDeniedException` | 403 | Nedostatočné oprávnenia |
| `AuthenticationException` | 401 | Neautentifikovaný |
| `Exception` (fallback) | 500 | Interná chyba servera |

Všetky chyby sú tiež zaznamenané cez Micrometer counter metriky.

#### Controllery — zodpovednosti

**`FoodProductRestController`** — CRUD potravín + PATCH fridge  
**`MealRestController`** — CRUD jedál  
**`MealPlanRestController`** — CRUD plánov + activate/deactivate + deduct-fridge + entries  
**`UserProfileRestController`** — GET a PUT `/user-profile/me`  
**`ShoppingListRestController`** — CRUD + clear  
**`AiRestController`** — chat + autofill + sessions CRUD + message send  
**`HealthRestController`** — GET `/health` bez autentifikácie

### 3.4 JPA vrstva (outbound-repository-jpa)

**Umiestnenie:** `application/outbound-repository-jpa/src/main/java/`

Táto vrstva implementuje repozitárové rozhrania z domény pomocou Spring Data JPA.

#### Spring Data rozhrania

Každý `SpringDataRepository` rozširuje `JpaRepository<Entity, Long>`:

```java
// Príklad: FoodProductSpringDataRepository
List<FoodProduct> findAllByOwnerUserId(String ownerUserId);
Optional<FoodProduct> findByIdAndOwnerUserId(Long id, String ownerUserId);
List<FoodProduct> findByOwnerUserIdAndNameContainingIgnoreCase(String ownerUserId, String name);
List<FoodProduct> findAllByOwnerUserIdAndInFridgeTrue(String ownerUserId);
```

#### JPA adaptéry

Každý adaptér je `@Repository` bean, ktorý deleguje na Spring Data:

```java
// Príklad: JpaFoodProductRepositoryAdapter
@Repository
public class JpaFoodProductRepositoryAdapter implements FoodProductRepository {
    
    @Override
    public FoodProduct save(FoodProduct fp) {
        return foodProductSpringDataRepository.save(fp);
    }
    
    @Override
    public List<FoodProduct> readAll(String ownerUserId, String name) {
        if (name == null) return foodProductSpringDataRepository.findAllByOwnerUserId(ownerUserId);
        return foodProductSpringDataRepository
            .findByOwnerUserIdAndNameContainingIgnoreCase(ownerUserId, name);
    }
    
    @Override
    public void deleteById(String ownerUserId, Long id) {
        foodProductSpringDataRepository
            .findByIdAndOwnerUserId(id, ownerUserId)
            .ifPresent(foodProductSpringDataRepository::delete);
    }
}
```

#### ORM konfigurácia

**`nutrition-planner-orm.xml`** — mapovanie JPA entít na databázové tabuľky pomocou XML (namiesto anotácií). Obsahuje definície `<entity>`, `<table>`, `<attributes>` s presným mapovaním každého poľa na stĺpec.

### 3.5 Springboot modul

**Umiestnenie:** `application/springboot/`

Tento modul zostavuje všetky ostatné moduly. Zodpovedá za:
- Spustenie aplikácie (`NutritionPlannerApplication.java`)
- Registráciu všetkých Spring beanov (`*BeanConfiguration.java`)
- Liquibase migrácie
- Spring Security konfiguráciu

#### Bean konfigurácia

Každá doménová služba je vytvorená cez `@Bean` metódu — explicitná dependency injection:

```java
// FoodProductBeanConfiguration.java
@Bean
FoodProductFacade foodProductFacade(FoodProductRepository foodProductRepository) {
    return new FoodProductService(foodProductRepository);
}

// MealPlanBeanConfiguration.java
@Bean
MealPlanFacade mealPlanFacade(
    MealPlanRepository mealPlanRepository,
    MealRepository mealRepository,
    FoodProductRepository foodProductRepository
) {
    return new MealPlanService(mealPlanRepository, mealRepository, foodProductRepository);
}

// AiBeanConfiguration.java
@Bean
AiAssistantFacade aiAssistantFacade(
    AiProvider aiProvider,
    UserProfileRepository userProfileRepository,
    FoodProductRepository foodProductRepository,
    MealRepository mealRepository,
    MealPlanRepository mealPlanRepository,
    ChatSessionRepository chatSessionRepository,
    ShoppingListRepository shoppingListRepository
) {
    return new AiAssistantService(
        aiProvider, userProfileRepository, foodProductRepository,
        mealRepository, mealPlanRepository, chatSessionRepository, shoppingListRepository
    );
}
```

#### AI adaptér

**`OpenAiAdapter.java`** — implementuje `AiProvider` rozhranie pomocou `RestClient`:
```java
RestClient.builder()
    .baseUrl("https://api.openai.com/v1")
    .defaultHeader("Authorization", "Bearer " + apiKey)
    .build();
```

Odosielanie správ:
```json
POST /v1/chat/completions
{
  "model": "gpt-4o-mini",
  "messages": [...],
  "temperature": 0.7,
  "max_tokens": 1500
}
```

Pre autofill:
```json
{
  "model": "gpt-4o-mini",
  "messages": [...],
  "temperature": 0.1,
  "max_tokens": 400,
  "response_format": { "type": "json_object" }
}
```

### 3.6 Konfigurácia (application.yaml)

**Umiestnenie:** `application/springboot/src/main/resources/application.yaml`

Súbor obsahuje tri Spring profily:

**Predvolený profil (lokálny vývoj bez Keycloak):**
```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5433/nutrition_planner
    username: admin
    password: admin
  jpa:
    ddl-auto: validate
    mapping-resources:
      - persistence/nutrition-planner-orm.xml
  liquibase:
    change-log: persistence/db/changelog/changelog-master.xml
management:
  endpoints:
    web:
      exposure:
        include: "*"   # všetky Actuator endpointy (health, prometheus, info, ...)
```

**Profil `keycloak` (lokálny vývoj s Keycloak):**
```yaml
spring:
  security:
    oauth2:
      resourceserver:
        jwt:
          issuer-uri: http://localhost:8081/realms/NUTRITION
          jwk-set-uri: http://localhost:8081/realms/NUTRITION/protocol/openid-connect/certs
```

**Profil `kubernetes` (produkcia na AKS):**
```yaml
spring:
  datasource:
    url: ${SPRING_DATASOURCE_URL}        # injektované z K8s Secret
    username: ${SPRING_DATASOURCE_USERNAME}
    password: ${SPRING_DATASOURCE_PASSWORD}
  security:
    oauth2:
      resourceserver:
        jwt:
          issuer-uri: ${SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_ISSUER_URI}
          jwk-set-uri: ${SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_JWK_SET_URI}
openai:
  api-key: ${OPENAI_API_KEY}            # injektované z K8s Secret
```

---

## 4. Databáza

### 4.1 Schéma tabuliek

Databáza PostgreSQL obsahuje 10 tabuliek. Všetky tabuľky s údajmi používateľa majú stĺpec `owner_user_id` (Keycloak UUID) — tým je zabezpečená izolácia dát medzi používateľmi.

```
food_product
├── food_product_id   BIGSERIAL PK
├── owner_user_id     VARCHAR(255) NOT NULL  [INDEX]
├── name              VARCHAR(255) NOT NULL
├── category          VARCHAR(255) NOT NULL
├── grams             DOUBLE PRECISION NOT NULL   (referenčná gramáž)
├── calories          DOUBLE PRECISION NOT NULL
├── protein           DOUBLE PRECISION NOT NULL
├── fat               DOUBLE PRECISION NOT NULL
├── carbohydrates     DOUBLE PRECISION NOT NULL
├── price             DOUBLE PRECISION NOT NULL
├── photo_url         VARCHAR(1024)
├── in_fridge         BOOLEAN NOT NULL DEFAULT false
├── fridge_grams      DOUBLE PRECISION
├── sodium_mg         DOUBLE PRECISION   ─┐
├── potassium_mg      DOUBLE PRECISION    │
├── magnesium_mg      DOUBLE PRECISION    │  Mikroživiny
├── iron_mg           DOUBLE PRECISION    │  (všetky voliteľné)
├── calcium_mg        DOUBLE PRECISION    │
├── zinc_mg           DOUBLE PRECISION    │
├── vitamin_a_mcg     DOUBLE PRECISION    │
├── vitamin_c_mg      DOUBLE PRECISION    │
├── vitamin_d_mcg     DOUBLE PRECISION    │
├── vitamin_e_mg      DOUBLE PRECISION    │
├── vitamin_k_mcg     DOUBLE PRECISION    │
├── vitamin_b1_mg     DOUBLE PRECISION    │
├── vitamin_b2_mg     DOUBLE PRECISION    │
├── vitamin_b6_mg     DOUBLE PRECISION    │
├── vitamin_b9_mcg    DOUBLE PRECISION    │
└── vitamin_b12_mcg   DOUBLE PRECISION   ─┘

user_profile
├── user_profile_id   BIGSERIAL PK
├── keycloak_user_id  VARCHAR(255) NOT NULL UNIQUE
├── email             VARCHAR(255)
├── nickname          VARCHAR(100)
├── first_name        VARCHAR(100)
├── gender            VARCHAR(16)    (MALE / FEMALE)
├── age               INTEGER
├── height_cm         DOUBLE PRECISION
├── weight_kg         DOUBLE PRECISION
├── activity_level    VARCHAR(32)
├── goal              VARCHAR(64)
├── bmr               DOUBLE PRECISION   (vypočítané)
├── tdee              DOUBLE PRECISION   (vypočítané)
├── target_calories   DOUBLE PRECISION   (vypočítané)
├── target_protein    DOUBLE PRECISION   (vypočítané)
├── target_fat        DOUBLE PRECISION   (vypočítané)
└── target_carbohydrates DOUBLE PRECISION (vypočítané)

meal
├── meal_id       BIGSERIAL PK
├── owner_user_id VARCHAR(255) NOT NULL  [INDEX]
├── name          VARCHAR(255) NOT NULL
└── servings      INTEGER NOT NULL

meal_ingredient
├── meal_ingredient_id   BIGSERIAL PK
├── meal_id              BIGINT NOT NULL  FK → meal(meal_id)
├── food_product_id      BIGINT NOT NULL
├── food_product_name    VARCHAR(255) NOT NULL  (denormalizácia)
├── grams                DOUBLE PRECISION NOT NULL
├── calories_per_gram    DOUBLE PRECISION NOT NULL  ─┐
├── protein_per_gram     DOUBLE PRECISION NOT NULL   │
├── fat_per_gram         DOUBLE PRECISION NOT NULL   │  Vypočítané v čase
├── carbohydrates_per_gram DOUBLE PRECISION NOT NULL │  uloženia jedla
├── price_per_gram       DOUBLE PRECISION NOT NULL   │
├── sodium_mg_per_gram   DOUBLE PRECISION           │
└── ...všetky mikroživiny _per_gram                ─┘

meal_plan
├── meal_plan_id          BIGSERIAL PK
├── owner_user_id         VARCHAR(255) NOT NULL  [INDEX]
├── name                  VARCHAR(255) NOT NULL
├── start_date            DATE NOT NULL
├── number_of_days        INTEGER NOT NULL
├── is_active             BOOLEAN NOT NULL DEFAULT false
├── activated_at          DATE
└── last_deducted_day_number INTEGER NOT NULL DEFAULT 0

plan_day
├── plan_day_id  BIGSERIAL PK
├── meal_plan_id BIGINT NOT NULL  FK → meal_plan(meal_plan_id)
└── day_number   INTEGER NOT NULL

plan_entry
├── plan_entry_id    BIGSERIAL PK
├── plan_day_id      BIGINT NOT NULL  FK → plan_day(plan_day_id)
├── meal_type        VARCHAR(32) NOT NULL  (BREAKFAST/LUNCH/DINNER/SNACK)
├── entry_type       VARCHAR(32) NOT NULL  (MEAL / FOOD_PRODUCT)
├── meal_id          BIGINT
├── meal_name        VARCHAR(255)
├── portions         DOUBLE PRECISION
├── food_product_id  BIGINT
├── food_product_name VARCHAR(255)
├── grams            DOUBLE PRECISION
├── calories         DOUBLE PRECISION NOT NULL  ─┐
├── protein          DOUBLE PRECISION NOT NULL   │  Uložené v čase
├── fat              DOUBLE PRECISION NOT NULL   │  pridania záznamu
├── carbohydrates    DOUBLE PRECISION NOT NULL   │
├── price            DOUBLE PRECISION NOT NULL  ─┘
└── ...všetky mikroživiny mg/mcg

chat_session
├── chat_session_id BIGSERIAL PK
├── owner_user_id   VARCHAR(255) NOT NULL  [INDEX]
├── title           VARCHAR(500) NOT NULL
└── created_at      TIMESTAMP NOT NULL

chat_message
├── chat_message_id  BIGSERIAL PK
├── chat_session_id  BIGINT NOT NULL  FK → chat_session(chat_session_id)  [INDEX]
├── role             VARCHAR(20) NOT NULL  (user / assistant)
├── content          TEXT NOT NULL
└── created_at       TIMESTAMP NOT NULL

shopping_list_item
├── shopping_list_item_id BIGSERIAL PK
├── owner_user_id         VARCHAR(255) NOT NULL  [INDEX]
├── food_product_id       BIGINT NOT NULL
├── food_product_name     VARCHAR(255) NOT NULL
├── grams                 DOUBLE PRECISION NOT NULL
├── calories_per_100g     DOUBLE PRECISION NOT NULL
├── protein_per_100g      DOUBLE PRECISION NOT NULL
├── fat_per_100g          DOUBLE PRECISION NOT NULL
├── carbs_per_100g        DOUBLE PRECISION NOT NULL
└── price_per_100g        DOUBLE PRECISION NOT NULL
```

### 4.2 Liquibase migrácie

**Súbory:**
- `changelog-master.xml` — hlavný súbor, len zahŕňa ďalšie súbory
- `nutrition-planner-tables.xml` — všetky `changeSet` definície

Každý `changeSet` má unikátne `id` a `author`. Liquibase sleduje vykonané migrácie v tabuľke `DATABASECHANGELOG`. Pri štarte aplikácie sa automaticky vykonajú iba nové migrície.

**História migrácií:**

| changeSet id | Popis |
|---|---|
| `1.0` | Základná tabuľka `food_product` |
| `1.1` | Tabuľka `user_profile` |
| `1.2` | Pridanie `owner_user_id`, `category`, `grams`, `photo_url` do `food_product` |
| `1.3` | Pridanie `nickname`, `first_name`, `gender`, `activity_level`, `bmr`, `tdee` do `user_profile` |
| `1.4` | Mikroživiny do `food_product` |
| `2.0` | Tabuľka `meal` |
| `2.1` | Tabuľka `meal_ingredient` |
| `2.2` | Mikroživiny do `meal_ingredient` |
| `3.0` | Tabuľka `meal_plan` |
| `3.1` | Tabuľka `plan_day` |
| `3.2` | Tabuľka `plan_entry` |
| `3.3` | Mikroživiny do `plan_entry` |
| `3.4` | Stĺpce `is_active`, `activated_at` do `meal_plan` |
| `4.0` | Tabuľky `chat_session` a `chat_message` |
| `5.0` | Stĺpec `in_fridge` do `food_product` |
| `5.1` | Stĺpec `fridge_grams` do `food_product` |
| `6.0` | Tabuľka `shopping_list_item` |
| `7.0` | Stĺpec `last_deducted_day_number` do `meal_plan` |

---

## 5. Tok požiadaviek

### 5.1 Typická autentifikovaná požiadavka

Príklad: `GET /api/food-products?name=chicken` (zo Stránky Food na fronte)

```
1. BROWSER
   Angular FoodProductsApi.readFoodProducts("chicken")
   → HTTP GET /api/food-products?name=chicken
   → AuthInterceptor pridá hlavičku: Authorization: Bearer <JWT>

2. KUBERNETES INGRESS (nginx)
   Prijme požiadavku na nutrition-planner.net/api/*
   → Presmeruje na Service nutrition-planner-be:8080
   → Odrežie prefix /api/ → /food-products?name=chicken (rewrite)

3. SPRING BOOT — SecurityFilter
   Extrahuje Bearer token z hlavičky
   Overí JWT podpis cez JWK Set URI z Keycloak
   (/auth/realms/NUTRITION/protocol/openid-connect/certs)
   Skontroluje rolu (ROLE_USER, ROLE_ADMIN alebo ROLE_PREMIUM_USER)
   Nastaví SecurityContext

4. SPRING BOOT — FoodProductRestController.readFoodProducts()
   CurrentUserProvider.getUserId() → "abc-123-uuid" z JWT subject
   foodProductFacade.readFoodProducts("abc-123-uuid", "chicken")

5. DOMAIN — FoodProductService.readFoodProducts()
   foodProductRepository.readAll("abc-123-uuid", "chicken")

6. JPA — JpaFoodProductRepositoryAdapter.readAll()
   foodProductSpringDataRepository
     .findByOwnerUserIdAndNameContainingIgnoreCase("abc-123-uuid", "chicken")

7. PostgreSQL
   SELECT * FROM food_product
   WHERE owner_user_id = 'abc-123-uuid'
   AND LOWER(name) LIKE '%chicken%'

8. ODPOVEĎ (opačný smer)
   List<FoodProduct> → JSON (Jackson) → HTTP 200
   → nginx Ingress → Browser
   FoodProductsApi.readFoodProducts() vrátí Observable<FoodProduct[]>
   Angular komponent zobrazí výsledky
```

### 5.2 Autentifikačný tok (OAuth2 Code Flow)

```
1. Používateľ klikne "Login" v Angular aplikácii
   UserService.login() → OAuthService.initLoginFlow()

2. Browser je presmerovaný na Keycloak:
   https://nutrition-planner.net/auth/realms/NUTRITION/protocol/openid-connect/auth
   ?response_type=code
   &client_id=nutrition-planner-client
   &redirect_uri=https://nutrition-planner.net/
   &scope=openid profile email
   &code_challenge=<PKCE>
   &code_challenge_method=S256

3. Keycloak zobrazí prihlasovaciu stránku
   Používateľ zadá meno a heslo

4. Keycloak overí credentials a presmeruje späť:
   https://nutrition-planner.net/?code=<authorization_code>&state=<state>

5. Angular (angular-oauth2-oidc) vymení code za tokeny:
   POST https://nutrition-planner.net/auth/realms/NUTRITION/protocol/openid-connect/token
   Body: grant_type=authorization_code&code=<code>&code_verifier=<PKCE verifier>
   
   Odpoveď:
   {
     "access_token": "<JWT>",
     "refresh_token": "<JWT>",
     "id_token": "<JWT>",
     "expires_in": 300
   }

6. UserService.loadUserProfile()
   Dekóduje JWT claims:
   - sub → userId (Keycloak UUID)
   - email → email
   - realm_access.roles → ["USER"] / ["PREMIUM_USER"] / ["ADMIN"]
   Nastaví user() signal

7. AuthInterceptor automaticky pridáva JWT do každej požiadavky na /api/*
   Authorization: Bearer <access_token>

8. Pri vypršaní tokenu (expires_in = 300s):
   angular-oauth2-oidc automaticky obnoví token cez refresh_token
```

### 5.3 AI autofill tok

```
1. PREMIUM_USER zadá názov produktu "Chicken breast"
   Klikne "AI Fill" v formulári

2. Angular → POST /api/ai/autofill
   Body: { "productName": "Chicken breast" }
   Authorization: Bearer <PREMIUM_USER JWT>

3. Spring Security overí rolu PREMIUM_USER ✓

4. AiRestController.autofill()
   → aiAssistantFacade.autofill("Chicken breast")

5. AiAssistantService.autofill()
   Zostaví prompt:
   "Return average nutritional values per 100g for 'Chicken breast' in JSON format:
    { calories, protein, fat, carbohydrates, sodiumMg, ... }"

6. OpenAiAdapter.chat()
   POST https://api.openai.com/v1/chat/completions
   { model: "gpt-4o-mini", temperature: 0.1, response_format: {type: "json_object"} }

7. OpenAI vráti JSON s hodnotami:
   { "calories": 165, "protein": 31, "fat": 3.6, "carbohydrates": 0, ... }

8. AiAssistantService parsuje odpoveď → AiAutofillResult

9. Angular vyplní formulár hodnotami z odpovede
   Používateľ skontroluje a potvrdí
```

---

## 6. Frontend — Angular 21

### 6.1 Štruktúra projektu

```
src/
├── app/
│   ├── app.html                    # Koreňová šablóna (topbar + drawer + router-outlet)
│   ├── app.ts                      # Koreňový komponent
│   ├── app.routes.ts               # Definícia routes
│   ├── app.config.ts               # Angular providers (HTTP, OAuth, locale, i18n)
│   │
│   ├── core/
│   │   ├── auth/
│   │   │   ├── auth-code-flow.config.ts  # OAuth2 konfigurácia
│   │   │   ├── auth-interceptor.ts       # HTTP interceptor (pridáva JWT)
│   │   │   └── user.service.ts           # Stav prihlásenia, roly, login/logout
│   │   ├── component/
│   │   │   └── page-not-found/           # 404 stránka
│   │   ├── food-page-reuse-strategy.ts  # Custom RouteReuseStrategy pre Food stránku
│   │   └── theme.service.ts              # Prepínanie dark/light témy
│   │
│   ├── entities/
│   │   ├── ai/
│   │   │   ├── api/ai.api.ts             # API klient pre AI endpointy
│   │   │   └── model/                    # ChatSession, ChatMessage, AiAutofillResponse
│   │   ├── food-product/
│   │   │   ├── api/food-products.api.ts  # API klient pre /food-products
│   │   │   └── model/food-product.ts     # FoodProduct interface
│   │   ├── meal/
│   │   │   ├── api/meals.api.ts
│   │   │   └── model/meal.ts
│   │   ├── meal-plan/
│   │   │   ├── api/meal-plans.api.ts
│   │   │   └── model/                    # MealPlan, PlanDay, PlanEntry
│   │   ├── shopping-list/
│   │   │   ├── api/shopping-list.api.ts
│   │   │   └── model/shopping-list-item.ts
│   │   └── user-profile/
│   │       ├── api/user-profile.api.ts
│   │       └── model/user-profile.ts
│   │
│   ├── pages/
│   │   ├── ai-assistant-page/            # Chat s AI asistentom
│   │   ├── finances-page/                # Nákupný zoznam, chladnička, analýza hodnôt
│   │   ├── food-page/                    # Záložky: Products + Meals
│   │   ├── food-products-page/           # Starší CRUD (presmerovaný na /food)
│   │   ├── meal-plan-page/               # Plán stravovania, denné záznamy
│   │   └── profile-page/                 # Profil, BMR/TDEE, mikronutrientné normy
│   │
│   └── shared/
│       ├── count-up.directive.ts         # Animovaný číselný counter
│       ├── feature-placeholder/          # Placeholder pre nedokončené funkcie
│       ├── initials.pipe.ts              # Extrakcia iniciálov z mena
│       └── nav-pill.directive.ts         # Animovaný navigačný pill
│
├── environments/
│   ├── environment.ts                    # Produkcia (window.location.origin)
│   └── environment.development.ts        # Vývoj (localhost:4200)
│
└── styles/
    ├── styles.scss                       # Vstupný bod pre štýly
    └── scss/
        ├── app.scss                      # Všetky globálne štýly, design tokeny, responsive
        └── variables.scss               # Bootstrap premenné override
```

### 6.2 Autentifikácia

**`auth-code-flow.config.ts`**
```typescript
export const authCodeFlowConfig: AuthConfig = {
  issuer:       `${environment.keyCloakUrl}/realms/NUTRITION`,
  redirectUri:  `${environment.appUrl}/`,
  clientId:     'nutrition-planner-client',
  scope:        'openid profile email',
  responseType: 'code',                  // Authorization Code Flow s PKCE
  requireHttps:                     false,  // povolené aj cez HTTP (lokálny vývoj)
  strictDiscoveryDocumentValidation: false,
};
```

**`auth-interceptor.ts`**  
Zachytáva všetky HTTP požiadavky na `/api/` a pridáva JWT Bearer token:
```typescript
// Vzor URL pre pridanie tokenu
const API_PATTERN = /^\/api\/|^https?:\/\/.+\/api\//;

if (API_PATTERN.test(request.url)) {
  const token = oauthService.getAccessToken();
  if (token) {
    return next(request.clone({
      headers: request.headers.set('Authorization', `Bearer ${token}`)
    }));
  }
}
```

**`user.service.ts`**  
Singleton Angular service so Signals API:
```typescript
readonly user = signal<UserModel | undefined>(undefined);

// Po úspešnom prihlásení
const claims = this.oauthService.getIdentityClaims() as any;
this.user.set({
  id:    claims.sub,           // Keycloak UUID
  name:  claims.name || claims.preferred_username,
  email: claims.email,
  roles: claims.realm_access?.roles ?? [],
});
```

**`app.routes.ts`** — definícia routes s ochranou:
```typescript
{ path: '',              redirectTo: 'meal-plan', pathMatch: 'full' },
{ path: 'meal-plan',    component: MealPlanPageComponent,    canActivate: [isLoggedIn] },
{ path: 'food',         component: FoodPageComponent,         canActivate: [isLoggedIn] },
{ path: 'finances',     component: FinancesPageComponent,     canActivate: [isLoggedIn] },
{ path: 'ai-assistant', component: AiAssistantPageComponent,  canActivate: [isLoggedIn] },
{ path: 'profile',      component: ProfilePageComponent,      canActivate: [isLoggedIn] },
{ path: '**',           component: PageNotFoundComponent },
```

### 6.3 Stránky a komponenty

**`ProfilePageComponent`** (`pages/profile-page/`)  
Zobrazuje a umožňuje úpravu profilu používateľa:
- Formulár s reaktívnym `FormGroup` (Angular Reactive Forms)
- Výber aktivity (5 tlačidiel) a cieľa (3 tlačidlá)
- Po uložení zobrazuje vypočítané hodnoty: BMR, TDEE, cieľové kalórie, makrá
- Rozbaľovacia sekcia s mikronutrientnými normami podľa pohlavia
- Používa `CountUpDirective` pre animovaný výpis čísel

**`FoodPageComponent`** (`pages/food-page/`)  
Stránka s dvoma záložkami (Segmented Control):
- **Products tab**: zoznam potravín + detail/formulár na pravej strane (príp. pod na mobile)
  - Vyhľadávanie v reálnom čase, filter kategórie, triedenie A–Z / Z–A
  - Vytvorenie, úprava, zmazanie produktu
  - AI Fill tlačidlo (len PREMIUM_USER)
- **Meals tab**: zoznam jedál + detail s ingredienciami
  - Vytvorenie jedla s pridávaním ingrediencií
  - Zobrazenie celkových hodnôt jedla aj hodnôt na porciu
  - Mikronutrientný prehľad na porciu (rozbaľovacia sekcia)

**`MealPlanPageComponent`** (`pages/meal-plan/`)  
Trojstĺpcové rozloženie (na mobile stohované):
- **Ľavý panel**: zoznam plánov, vytvorenie nového plánu, aktivácia/deaktivácia
- **Stredný panel**: výber dňa (chip-row), záznamy dňa podľa meal type, formulár pridania záznamu
- **Pravý panel**: denné totaly vs. ciele z profilu (progress bary), mikronutrienty, súhrnné hodnoty plánu

**`FinancesPageComponent`** (`pages/finances-page/`)  
Tri záložky:
- **Shopping list**: nákupný zoznam s celkovou cenou a nutričnými hodnotami
  - Pridanie z produktu / jedla / plánu s prepínačom "Consider fridge"
  - Úprava gramáže priamo v tabuľke
- **Fridge**: inventár chladničky
  - Pridanie produktov s množstvom, úprava, zmazanie
- **Summary**: štatistiky výdavkov, analýza hodnoty (kcal/€ ranking), lídri mikroživín, prehľad plánov

**`AiAssistantPageComponent`** (`pages/ai-assistant-page/`)  
Chat rozhranie (len PREMIUM_USER a ADMIN):
- Zoznam chatovacích sedení v bočnom paneli
- Chat rozhranie s bublinami (user/assistant)
- Indikátor písania (tri bodky animácia)
- Odosielanie správ cez Enter alebo tlačidlo
- Neprihlásený ako PREMIUM → uzamknutá obrazovka s informáciou o predplatnom

### 6.4 API klienti

Všetky API klienty používajú Angular `HttpClient` a vracajú `Observable<T>`:

```typescript
// Príklad: food-products.api.ts
@Injectable({ providedIn: 'root' })
export class FoodProductsApi {
  private readonly http = inject(HttpClient);
  private readonly env  = environment;

  readFoodProducts(name?: string): Observable<FoodProduct[]> {
    const params = name ? { name } : {};
    return this.http.get<FoodProduct[]>(`${this.env.beUrl}/food-products`, { params });
  }

  createFoodProduct(payload: CreateFoodProductRequest): Observable<FoodProduct> {
    return this.http.post<FoodProduct>(`${this.env.beUrl}/food-products`, payload);
  }

  setFridgeStatus(id: number, inFridge: boolean, fridgeGrams?: number): Observable<FoodProduct> {
    return this.http.patch<FoodProduct>(
      `${this.env.beUrl}/food-products/${id}/fridge`,
      { inFridge, fridgeGrams }
    );
  }
}
```

**`environment.ts`** — dynamická konfigurácia:
```typescript
export const environment = {
  keyCloakUrl: `${window.location.origin}/auth`,  // Keycloak na rovnakej doméne
  beUrl:       '/api',                             // Relatívna cesta (proxy v dev)
  appUrl:       window.location.origin,            // Pre OAuth2 redirect_uri
};
```

**`proxy.conf.json`** — pre lokálny vývoj presmeruje `/api` na backend:
```json
{
  "/api": {
    "target": "http://localhost:8080",
    "secure": false,
    "pathRewrite": { "^/api": "" },
    "logLevel": "info"
  }
}
```

---

## 7. Infraštruktúra

### 7.1 Kubernetes workloady

Všetky workloady bežia v Azure Kubernetes Service (AKS), región North Europe.

**Menné priestory:**
- `app` — produkčné aplikácie (backend, frontend, Keycloak)
- `infra` — infraštruktúrne služby (GitLab Runner)
- `ingress-nginx` — nginx Ingress Controller
- `cert-manager` — automatická správa TLS certifikátov
- `monitoring` — Prometheus, Grafana, Loki, Grafana Alloy

**Backend Deployment** (`kubernetes/workload/03-app-backend/deployment.yaml`):
```yaml
replicas: 1
image: acrfsakiiashchenkoi.azurecr.io/nutrition-planner-backend:latest
resources:
  requests: { cpu: 100m, memory: 250Mi }
  limits:   { cpu: 500m, memory: 500Mi }
env:
  SPRING_PROFILES_ACTIVE: kubernetes
  DB_URL:          # z postgres-secret
  DB_USERNAME:     # z postgres-secret
  DB_PASSWORD:     # z postgres-secret
  OPENAI_API_KEY:  # z openai-secret
  ISSUER_URI:      https://nutrition-planner.net/auth/realms/NUTRITION
  JWT_SET_URI:     https://nutrition-planner.net/auth/realms/NUTRITION/protocol/openid-connect/certs
probes:
  liveness:  GET /actuator/health/liveness  (delay 90s, period 15s, failureThreshold 5)
  readiness: GET /actuator/health/readiness (delay 60s, period 10s, failureThreshold 3)
annotations:
  prometheus.io/scrape: "true"
  prometheus.io/path:   "/actuator/prometheus"
  prometheus.io/port:   "8080"
```

**Frontend Deployment** (`kubernetes/workload/04-app-frontend/deployment.yaml`):
```yaml
replicas: 1
containers:
  - name: nutrition-planner-fe
    image: acrfsakiiashchenkoi.azurecr.io/nutrition-planner-frontend:latest
    resources:
      requests: { cpu: 100m, memory: 128Mi }
      limits:   { cpu: 250m, memory: 256Mi }
    ports: [ http: 80 ]
  - name: nginx-exporter          # exportuje nginx metriky pre Prometheus
    image: nginx/nginx-prometheus-exporter:1.3
    ports: [ metrics: 9113 ]
annotations:
  prometheus.io/scrape: "true"
  prometheus.io/port:   "9113"
  prometheus.io/path:   "/metrics"
```

**Secrets** (`kubernetes/workload/02-secrets.yaml`):
```yaml
postgres-secret:
  db_username: fsaadmin
  db_password: <heslo>
  db_url:      psql-fsa-kiiashchenkoi.postgres.database.azure.com

keycloak-secret:
  kc_username: admin
  kc_password: <heslo>

openai-secret:
  api_key: <OpenAI API kľúč>
```

**Ingress** (`kubernetes/workload/05-ingress/app-ingress-pip.yaml`):
```yaml
host: nutrition-planner.net
paths:
  /auth  →  nutrition-keycloak-http:80   # Keycloak
  /      →  nutrition-planner-fe:80      # Angular frontend
annotations:
  cert-manager.io/cluster-issuer: letsencrypt-prod  # automatický TLS certifikát
  nginx.ingress.kubernetes.io/ssl-redirect: "true"  # HTTP → HTTPS redirect
  nginx.ingress.kubernetes.io/proxy-buffer-size: "256k"  # pre veľké JWT tokeny

# API ingress (app-api-ingress-pip.yaml):
host: nutrition-planner.net
path: /api(/|$)(.*)  →  nutrition-planner-be:8080
rewrite: /$2          # odstrihnutie /api prefixu
```

**TLS certifikát** — automaticky vydaný Let's Encrypt cez cert-manager:
- Vydavateľ: `letsencrypt-prod`
- Platnosť: 90 dní, automatická obnova po 60 dňoch
- Secret: `nutrition-planner-tls-cert`

### 7.2 Terraform

Terraform spravuje Azure infraštruktúru v 7 samostatných moduloch (adresároch):

| Modul | Zdroje | Popis |
|-------|--------|-------|
| `00-fsa-common` | Backend konfigurácia | Spoločné premenné, Terraform state v Azure Blob |
| `01-fsa-rg` | `azurerm_resource_group` | Resource Group `rg-fsa-common` v North Europe |
| `02-fsa-acr` | `azurerm_container_registry` | ACR `acrfsakiiashchenkoi` (Basic SKU) |
| `03-fsa-aks` | `azurerm_kubernetes_cluster` | AKS cluster s 2 node pools |
| `04-fsa-pip` | `azurerm_public_ip` | Statická verejná IP `20.166.89.50` |
| `05-fsa-psql` | `azurerm_postgresql_flexible_server` | PostgreSQL Flexible Server |
| `06-fsa-dns` | `azurerm_dns_zone` | DNS zóna `fullstackacademy.sk` |

**AKS konfigurácia** (`terraform/03-fsa-aks/main.tf`):
```hcl
resource "azurerm_kubernetes_cluster" {
  oidc_issuer_enabled       = true   # pre Workload Identity
  workload_identity_enabled = true
  
  # Infraštruktúrny node pool (pre Keycloak, GitLab Runner, monitoring)
  default_node_pool "infra" {
    vm_size    = "Standard_*"
    node_labels = { role = "infra" }
  }
  
  # Aplikačný node pool (pre backend, frontend)
  node_pool "app" {
    node_labels = { role = "app" }
  }
  
  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }
}

# AKS môže pull-ovať z ACR
resource "azurerm_role_assignment" {
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}
```

### 7.3 Monitoring

Monitoring stack beží v namespace `monitoring`:

- **Prometheus** — zber metrík z backendu (`/actuator/prometheus`) a frontendu (nginx exporter)
- **Grafana** — vizualizácia metrík, dashboard pre Nutrition Planner
  - URL: `https://grafana.20-166-89-50.nip.io`
- **Loki** — agregácia logov z kontajnerov
- **Grafana Alloy** — agent pre zbieranie logov a metrík

Backend exponuje Spring Boot Actuator metriky:
- `/actuator/health` — zdravotný stav (liveness + readiness)
- `/actuator/prometheus` — Prometheus metriky (JVM, HTTP požiadavky, custom counters)
- `/actuator/info` — informácie o aplikácii

---

## 8. CI/CD pipeline

Oba repozitáre (backend a frontend) majú `.gitlab-ci.yml` s rovnakou trojstupňovou štruktúrou. Pipeliny bežia na GitLab Runneri (`fsa-kiiashchenko` tag) nasadenom v klastri.

```
GitHub (push to main)
        │
        │ Mirror (GitHub Actions → GitLab)
        ▼
GitLab Repository
        │
        ▼
┌───────────────────┐    ┌──────────────────────┐    ┌─────────────────────┐
│   VALIDATE        │───▶│   BUILD              │───▶│   DEPLOY            │
│                   │    │                      │    │                     │
│ Backend:          │    │ docker build         │    │ kubectl set image   │
│   mvn clean verify│    │ docker push          │    │ kubectl rollout      │
│                   │    │   → ACR :version     │    │   status            │
│ Frontend:         │    │   → ACR :latest      │    │                     │
│   npm ci          │    │                      │    │ (len na main branch)│
│   npm run build   │    │ (len na main branch) │    └─────────────────────┘
└───────────────────┘    └──────────────────────┘
```

**Backend pipeline** (`.gitlab-ci.yml`):
```yaml
validate:
  image: maven:3.9.11-eclipse-temurin-25
  script: mvn -B -ntp clean verify          # kompiluje + testuje

build:
  image: docker:28-cli
  services: [docker:28-dind]
  script:
    - docker login $ACR_REGISTRY -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
    - docker build -t $ACR_REGISTRY/nutrition-planner-backend:$IMAGE_VERSION .
    - docker build -t $ACR_REGISTRY/nutrition-planner-backend:latest .
    - docker push $ACR_REGISTRY/nutrition-planner-backend:$IMAGE_VERSION
    - docker push $ACR_REGISTRY/nutrition-planner-backend:latest
  rules:
    - if: '$CI_COMMIT_BRANCH == "main"'

deploy:
  image: mcr.microsoft.com/azure-cli:2.67.0   # Microsoft Container Registry
  before_script:
    - curl -LO "https://dl.k8s.io/release/v1.32.3/bin/linux/amd64/kubectl"
    - chmod +x kubectl && mv kubectl /usr/local/bin/kubectl
    - echo "$KUBECONFIG_BASE64" | base64 -d > ~/.kube/config
  script:
    - kubectl set image deployment/nutrition-planner-be
        nutrition-planner-be=$ACR_REGISTRY/nutrition-planner-backend:latest -n app
    - kubectl rollout status deployment/nutrition-planner-be -n app --timeout=180s
  rules:
    - if: '$CI_COMMIT_BRANCH == "main"'
```

**Frontend pipeline** — rovnaká štruktúra, len iný image name a `npm ci && npm run build` vo validate.

**Premenné GitLab CI (Secrets):**

| Premenná | Popis |
|---------|-------|
| `DOCKER_USERNAME` | Meno používateľa pre prihlásenie do ACR |
| `DOCKER_PASSWORD` | Heslo / Service Principal secret pre ACR |
| `ACR_REGISTRY` | URL ACR registra (`acrfsakiiashchenkoi.azurecr.io`) |
| `KUBECONFIG_BASE64` | Base64-enkódovaný kubeconfig pre kubectl |

---

## 9. Bezpečnosť

### Autentifikácia a autorizácia

- **Identity Provider**: Keycloak (OAuth2/OIDC), realm `NUTRITION`
- **Tok**: Authorization Code Flow s PKCE
- **JWT**: podpísaný RSA kľúčom Keycloak, platnosť 5 minút
- **Overenie**: backend overuje JWT podpis pomocou JWK Set URI z Keycloak (verejný kľúč)
- **Refresh**: angular-oauth2-oidc automaticky obnovuje token pred vypršaním

### Roly

| Rola | Popis | Dostupné funkcie |
|------|-------|------------------|
| `USER` | Štandardný prihlásený používateľ | Potraviny, jedlá, plány, profil, nákupný zoznam |
| `ADMIN` | Administrátor | Všetky funkcie vrátane AI |
| `PREMIUM_USER` | Prémiový používateľ | Všetky funkcie vrátane AI asistenta a AI autofill |

### Izolácia dát

Každý záznam v databáze obsahuje `owner_user_id` (Keycloak UUID). Všetky databázové dotazy filtrujú podľa tohto stĺpca — používateľ nemôže vidieť ani meniť dáta iného používateľa.

### TLS

- Všetka komunikácia je šifrovaná HTTPS (TLS 1.2/1.3)
- Certifikát vydaný Let's Encrypt cez cert-manager
- HTTP je automaticky presmerované na HTTPS (nginx ingress `ssl-redirect: "true"`)

### Secrets management

- Citlivé údaje (DB heslo, OpenAI kľúč) sú uložené v Kubernetes Secrets
- Secrets sú injektované ako environment premenné do kontajnerov
- Nikdy nie sú uložené v Git repozitári

---

## 10. Kľúčové algoritmy

### BMR a TDEE výpočet (Mifflin–St Jeor)

```
# Bazálny metabolizmus (BMR)
MUŽI:   BMR = 10 × hmotnosť(kg) + 6.25 × výška(cm) − 5 × vek + 5
ŽENY:   BMR = 10 × hmotnosť(kg) + 6.25 × výška(cm) − 5 × vek − 161

# Celkový denný výdaj energie (TDEE)
TDEE = BMR × aktivity_faktor

aktivity_faktor:
  SEDENTARY         = 1.2   (kancelárska práca, žiadny šport)
  LIGHTLY_ACTIVE    = 1.375 (ľahký šport 1–3 dni/týždeň)
  MODERATELY_ACTIVE = 1.55  (stredne náročný šport 3–5 dní/týždeň)
  VERY_ACTIVE       = 1.725 (náročný šport 6–7 dní/týždeň)
  EXTRA_ACTIVE      = 1.9   (fyzicky náročná práca + šport)

# Cieľový kalorický príjem
LOSE_WEIGHT     = TDEE × 0.85  (deficit 15%)
MAINTAIN_WEIGHT = TDEE × 1.0
GAIN_MASS       = TDEE × 1.10  (prebytok 10%)

# Makrocie
bielkoviny = hmotnosť × 2.0 g/kg  (pri chudnutí)
           = hmotnosť × 1.8 g/kg  (pri udržaní/naberaní)
tuky       = hmotnosť × 1.0 g/kg  (pri chudnutí)
           = hmotnosť × 0.8 g/kg  (pri udržaní/naberaní)
sacharidy  = (targetCalories − bielkoviny×4 − tuky×9) / 4
```

### Nutričné hodnoty jedla

```
# Hodnoty jedla = suma ingrediencií
# Pre každú ingredienciu sa ukladá hodnota na gram v čase vytvorenia jedla

caloriesPerGram = foodProduct.calories / foodProduct.grams

# Celkové hodnoty jedla
totalCalories = Σ (ingredient.caloriesPerGram × ingredient.grams)
totalProtein  = Σ (ingredient.proteinPerGram  × ingredient.grams)
...

# Na porciu
caloriesPerServing = totalCalories / meal.servings
```

### Odpočet chladničky (deductFridge)

```
# Vstup: aktivovaný plán (activatedAt, numberOfDays, lastDeductedDayNumber)
currentDay    = min(daysSinceActivation + 1, numberOfDays)
daysToProcess = [lastDeductedDayNumber + 1 ... currentDay]

# Pre každý deň v daysToProcess:
FOR entry IN planDay.entries:
  IF entry.type == FOOD_PRODUCT:
    consumed[entry.foodProductId] += entry.grams
  IF entry.type == MEAL:
    FOR ingredient IN meal.ingredients:
      # Prepočet gramáže ingrediencie na základe
      # pomeru (portions × meal.totalGrams / meal.servings)
      consumed[ingredient.foodProductId] += actualGrams

# Odpočet zo zásob
FOR (productId, consumedGrams) IN consumed:
  product.fridgeGrams = max(0, product.fridgeGrams − consumedGrams)

lastDeductedDayNumber = currentDay
```

### Generovanie nákupného zoznamu z plánu

```
# Používateľ pridá celý plán do košíka (frontend)
FOR day IN plan.days:
  FOR entry IN day.entries:
    IF entry.type == FOOD_PRODUCT:
      addToCart(entry.foodProductId, entry.grams)
    IF entry.type == MEAL:
      FOR ingredient IN meal.ingredients:
        addToCart(ingredient.foodProductId,
                  ingredient.grams × entry.portions)

# S prepínačom "Consider fridge":
requiredGrams = totalGrams − (inFridge ? fridgeGrams : 0)
finalGrams    = max(0, requiredGrams)
```
