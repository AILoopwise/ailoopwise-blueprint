# German Market App Launch — Legal Checklist

## Before App Store Submission
- [ ] **Datenschutzerklärung** (Privacy Policy) — German, accessible in-app and on web
- [ ] **Impressum** — required by DDG §5 (Digitale-Dienste-Gesetz, which replaced the TMG in May 2024) for all German commercial apps
- [ ] **Nutzungsbedingungen** (Terms of Service) — recommended
- [ ] **App Store Privacy Details** — data collection declarations (Apple/Google)
- [ ] **DPAs signed** with all data processors (database, push notifications, CRM, email, analytics)
- [ ] **Consent flow** — first-launch privacy acceptance before processing

## Data Protection
- [ ] EU data residency confirmed (database, storage, functions)
- [ ] EXIF/GPS stripping on photo uploads
- [ ] Secure token storage (Keychain/Keystore)
- [ ] Private storage buckets (signed URLs)
- [ ] API tokens encrypted at rest
- [ ] Row Level Security on all tables

## User Rights (DSGVO)
- [ ] Data export (Art. 15/20) — JSON export available
- [ ] Account deletion (Art. 17) — with 30-day grace period
- [ ] Consent management — toggle per feature (push, tracking, integrations)
- [ ] Profile editing — users can update their data (Art. 16)

## Push Notifications
- [ ] Explicit opt-in before saving tokens
- [ ] Toggle in settings to disable
- [ ] Token cleared on consent withdrawal

## Third-Party Integrations
- [ ] Each integration documented in privacy policy
- [ ] DPA/AVV for each processor
- [ ] User informed about data sharing
- [ ] API tokens encrypted (not plaintext in DB)

## Apple App Store Specific
- [ ] Privacy Nutrition Labels configured (App Privacy in App Store Connect)
- [ ] `ITSAppUsesNonExemptEncryption` set correctly in app config
- [ ] App Tracking Transparency (ATT) prompt if using tracking (IDFA)

## Google Play Store Specific
- [ ] Data Safety section filled in (Play Console)
- [ ] Privacy policy URL provided
- [ ] Permissions justified in store listing
