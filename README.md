# InSight

## Project and backend details

InSight is an iOS application that helps users understand cosmetic or skincare
products by scanning product information and classifying the result into three
safety levels: `safe`, `mostlySafe`, and `risky`.

### Current architecture

| Area | Current choice |
| --- | --- |
| Backend runtime | Node.js with Express |
| Database | PostgreSQL |
| Database driver | `pg` |
| Authentication | Email/password, OTP verification, auth token, refresh token |
| Password hashing | `bcrypt` |
| Email delivery | `nodemailer` |
| Client | iOS app built with Swift and SwiftUI |
| Client networking | `URLSession` |
| Local API base URL | `http://192.168.1.135:3000` in the current iOS configuration |

### Core data flows

- **Registration:** The client sends email, password, profile, skin type, and allergy data to `POST /auth/register`.
- **OTP verification:** The user verifies the emailed code through `POST /auth/verify-otp`.
- **Login:** The backend validates credentials through `POST /auth/login` and returns `authToken` and `refreshToken`.
- **Logout:** The client sends the token pair to `POST /auth/logout`, and the backend removes the matching session.
- **Profile:** The client reads and updates user profile data through `/profiles/:userID`.
- **Scan analysis:** The client sends a barcode to `POST /scan/analyze`; the backend resolves or creates the product, maps ingredients, calculates a score, and returns a safety level.
- **Content:** The client manages saved reviews and recommendations through `/content/:userID/*`.

### HTTP header strategy

Use these headers as the baseline for client-server communication.

#### Request headers

| Header | Example | Purpose |
| --- | --- | --- |
| `Authorization` | `Bearer <authToken>` | Required for protected user-specific endpoints. |
| `Content-Type` | `application/json` | Required for JSON request bodies. |
| `Accept` | `application/json` | Tells the backend the client expects JSON. |
| `Accept-Language` | `tr-TR` | Used for localized errors, ingredient details, and future multi-language support. |
| `X-API-Version` | `1` | Allows backend behavior to be versioned while mobile clients roll out gradually. |
| `X-Client-Platform` | `ios` | Helps logging, analytics, and platform-specific debugging. |
| `X-Client-Version` | `1.0.0` | Helps identify client version-specific issues. |
| `X-Request-ID` | UUID value | Correlates iOS-side errors with backend logs. |
| `X-Scan-Source` | `barcode`, `ocr`, `manual`, `photo` | Identifies how the product analysis input was produced. |

#### Response headers

| Header | Example | Purpose |
| --- | --- | --- |
| `Content-Type` | `application/json; charset=utf-8` | Ensures API responses are interpreted as JSON. |
| `Cache-Control` | `no-store` | Prevents token and private user data from being cached. |
| `Pragma` | `no-cache` | Legacy no-cache support for auth responses. |
| `X-Content-Type-Options` | `nosniff` | Prevents content-type sniffing. |
| `Content-Security-Policy` | `default-src 'none'; frame-ancestors 'none'` | Restricts browser execution if an API response is opened directly. |
| `X-Frame-Options` | `DENY` | Reduces clickjacking risk for browser-accessed surfaces. |
| `Referrer-Policy` | `no-referrer` | Prevents referrer leakage. |
| `Strict-Transport-Security` | `max-age=31536000; includeSubDomains` | Enables HTTPS-only browser behavior in production. Use only after HTTPS is active. |
| `X-Request-ID` | Same request UUID | Returns the correlation id back to the client. |

### Protected endpoint policy

The backend currently creates token-backed sessions in the `auth_sessions` table.
The next security step is to add middleware that validates
`Authorization: Bearer <authToken>` against `auth_sessions.auth_token_hash` and
attaches the authenticated user to `req.user`.

Recommended protected endpoints:

- `GET /profiles/:userID`
- `PATCH /profiles/:userID`
- `GET /content/:userID/saved-reviews`
- `POST /content/:userID/saved-reviews`
- `DELETE /content/:userID/saved-reviews/:reviewID`
- `GET /content/:userID/recommendations`
- `POST /scan/analyze` when scan history should be tied to a signed-in user

The backend should not trust `userID` from the URL or body by itself. For
protected requests, compare the route/body `userID` with the user resolved from
the bearer token.

## Backend endpoints

The backend runs at `http://localhost:3000` by default.

### Auth

- `POST /auth/register`
- `POST /auth/login`
- `POST /auth/verify-otp`

### Profile

- `GET /profiles/:userID`
- `PATCH /profiles/:userID`

### Content

- `GET /content/:userID/saved-reviews`
- `POST /content/:userID/saved-reviews`
  - Body: `{ "productID": "...", "status": "safe|mostlySafe|risky" }`
- `DELETE /content/:userID/saved-reviews/:reviewID`
- `GET /content/:userID/recommendations`

### Scan

- `POST /scan/analyze`
  - Body: `{ "barcode": "8691234567890", "userID": "optional-user-id" }`

### Database setup

Database connection values are read from `Backend/.env`. Use either the `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, and `DB_PASSWORD` values or a single `DATABASE_URL`.

Run migrations before using the backend:

```sh
cd Backend
npm run migrate
```

Check migration status with:

```sh
cd Backend
npm run migrate:status
```

Add future migrations as ordered SQL files in `Backend/migrations`, for example `002_add_product_flags.sql`.

### Email verification setup

Registration sends the OTP code by email. Create `Backend/.env` from `Backend/.env.example` and fill the SMTP values:

- `SMTP_HOST`
- `SMTP_PORT`
- `SMTP_SECURE`
- `SMTP_USER`
- `SMTP_PASS`
- `MAIL_FROM`

For Gmail, use an app password instead of your normal account password:

```env
SMTP_HOST=smtp.gmail.com
SMTP_PORT=465
SMTP_SECURE=true
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-google-app-password
MAIL_FROM="InSight <your-email@gmail.com>"
```

Verify the SMTP login:

```sh
cd Backend
npm run email:verify
```

Send a test OTP email:

```sh
cd Backend
npm run email:verify -- your-email@gmail.com
```
