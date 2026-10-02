# GDPR/DSGVO Audit Checklist

Use this checklist to audit any app for GDPR compliance.

## 1. Data Inventory
- [ ] List all personal data collected (names, emails, phones, photos, tokens, IPs)
- [ ] Document where each data type is stored (database tables, storage buckets, third parties)
- [ ] Identify data flow: client → backend → third parties
- [ ] Check for indirect personal data (GPS in photos, device IDs, timestamps that create movement profiles)

## 2. Legal Basis (Art. 6 DSGVO)
- [ ] Document legal basis for each data processing activity
- [ ] Contract fulfillment (Art. 6(1)(b)) — employment data, service delivery
- [ ] Consent (Art. 6(1)(a)) — push notifications, tracking, optional features
- [ ] Legitimate interest (Art. 6(1)(f)) — CRM sync, analytics
- [ ] Ensure consent is freely given, specific, informed, unambiguous

## 3. Transparency (Art. 13/14 DSGVO)
- [ ] Privacy policy (Datenschutzerklärung) exists and is accessible
- [ ] Privacy policy covers: who, what, why, how long, who receives data, user rights
- [ ] Impressum exists (required by German DDG §5 (formerly TMG §5))
- [ ] Privacy policy is in the user's language

## 4. User Rights Implementation
- [ ] Right to access (Art. 15) — data export function
- [ ] Right to rectification (Art. 16) — users can edit their data
- [ ] Right to erasure (Art. 17) — account deletion with cascade
- [ ] Right to data portability (Art. 20) — structured export (JSON/CSV)
- [ ] Right to withdraw consent (Art. 7(3)) — toggle for each consent

## 5. Consent Management
- [ ] First-launch consent screen before data processing
- [ ] Separate opt-in for each purpose (push, tracking, third-party sync)
- [ ] Consent timestamp stored in database
- [ ] Easy way to withdraw consent (settings screen)
- [ ] No pre-checked boxes

## 6. Data Processing Agreements
- [ ] DPA/AVV with database provider (e.g., Supabase)
- [ ] DPA/AVV with push notification provider (e.g., Expo)
- [ ] DPA/AVV with CRM/third-party integrations (e.g., Pipedrive)
- [ ] DPA/AVV with email provider (e.g., Resend, SendGrid)
- [ ] DPA/AVV with analytics provider (if any)

## 7. Data Security (Art. 32 DSGVO)
- [ ] Encryption at rest (AES-256)
- [ ] Encryption in transit (TLS/HTTPS)
- [ ] Row Level Security / access control
- [ ] Auth tokens in secure storage (Keychain/Keystore, not AsyncStorage)
- [ ] EXIF stripping on photo uploads
- [ ] API tokens encrypted (not stored plaintext)
- [ ] Storage buckets private (signed URLs)

## 8. Data Minimization & Retention
- [ ] Only collect data that is necessary
- [ ] Data retention policy documented
- [ ] Automatic cleanup of expired data (logs, tokens)
- [ ] Soft delete with grace period before hard delete

## 9. EU Data Residency
- [ ] Database hosted in EU (Frankfurt preferred)
- [ ] Storage in EU
- [ ] Edge functions in EU
- [ ] Third-party transfers: adequate guarantees (SCCs, DPF)

## 10. Incident Response
- [ ] Data breach notification process documented (72-hour requirement)
- [ ] Contact info for supervisory authority
- [ ] Internal incident log
