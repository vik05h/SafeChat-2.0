# Privacy Policy

**Effective Date:** [TO BE SET ON LAUNCH]
**Last Updated:** November 2026

---

## Important Notice

This is a template Privacy Policy generated as part of the SafeChat project foundation. Before SafeChat launches publicly, this document must be reviewed by a qualified legal professional familiar with the jurisdictions in which SafeChat operates (India under DPDP Act, EU under GDPR, US under various state laws). Do not deploy this verbatim to production.

---

## 1. Introduction

SafeChat ("we", "us", "our") is a social media platform that uses artificial intelligence to detect and block bullying, harassment, and toxic content in real time. This Privacy Policy explains how we collect, use, share, and protect your personal information when you use our services.

By using SafeChat, you agree to the practices described in this policy. If you do not agree, please do not use our services.

---

## 2. Information We Collect

### 2.1 Information You Provide

| Category | Examples |
|---|---|
| Account information | Email address, username, display name, password (hashed), profile picture |
| Profile information | Bio, profile picture |
| Content you create | Posts, comments, stories, direct messages, media uploads |
| Communications | Messages with other users, reports you submit |
| Settings and preferences | Privacy settings, notification preferences |

### 2.2 Information We Collect Automatically

| Category | Examples |
|---|---|
| Device information | Device type, operating system, browser version, app version |
| Usage information | Features used, screens viewed, actions taken, timestamps |
| Network information | IP address (used for rate limiting and abuse prevention) |
| Diagnostic information | Crash reports, performance metrics |

### 2.3 Information from Third Parties

If you sign in using Google, we receive your name, email address, and profile picture from Google.

### 2.4 What We Do NOT Collect

- Precise location data (GPS coordinates)
- Contacts from your device
- Photos beyond what you choose to upload
- Browsing history outside SafeChat

---

## 3. How We Use Your Information

We use your information to:

1. **Provide the service** — display your profile, deliver your messages, show your posts in others' feeds
2. **Moderate content** — run AI moderation on text and images you submit to detect bullying and harassment
3. **Prevent abuse** — detect spam, automated accounts, and platform misuse
4. **Improve the service** — analyze how features are used to improve them
5. **Communicate with you** — send notifications, security alerts, and service announcements
6. **Comply with legal obligations** — respond to lawful requests from authorities
7. **Enforce our terms** — investigate reports and take action against violations

---

## 4. AI-Powered Content Moderation

A core feature of SafeChat is automated content moderation. Here's how it works:

### What is moderated

Every piece of user-generated content — text messages, posts, comments, stories, image captions, profile information — is automatically analyzed for potentially harmful content before being delivered or displayed.

### How content is analyzed

Content passes through a multi-layer system that includes:
- Pattern matching against known harmful terms
- Analysis by third-party AI moderation services (OpenAI, Google Gemini, Google Cloud Vision)
- Internal logic to detect bypass attempts

### What happens with your content during moderation

- Content is transmitted to AI moderation services for classification
- These third-party services act as data processors under our instruction
- They do not use your content to train their models per their API terms
- We do not store raw content in moderation logs — only cryptographic hashes
- Moderation happens in real time; content is not stored for moderation review beyond classification

### Your rights regarding automated moderation

- You may request human review of any moderation decision
- You may appeal blocked content through the in-app reporting system
- We do not use automated moderation to make decisions that produce legal effects

---

## 5. How We Share Your Information

We share your information only in the following circumstances:

### With other users
- Your username, display name, profile picture, and bio are visible to all users
- Posts, comments, and stories you publish are visible per your privacy settings
- Messages you send are visible to the recipient(s)

### With service providers
We use third-party services that process data on our behalf:

| Service | Purpose | Data shared |
|---|---|---|
| Google Firebase | Authentication, database, storage, push notifications | All operational data |
| Google Cloud Run | Backend hosting | All data passing through API |
| OpenAI | Content moderation | Text content for classification |
| Google Gemini | Content moderation | Text and image content for classification |
| Google Cloud Vision | Image moderation | Images for safety classification |
| Agora (when calls are available) | Voice and video calls | Call signaling and media streams |
| Sentry | Error monitoring | Error metadata, may include user UID |

All service providers are bound by contractual obligations to protect your information.

### For legal reasons
We may disclose information if required by law, court order, or government request, or if we believe in good faith that disclosure is necessary to:
- Comply with legal obligations
- Protect the rights, property, or safety of SafeChat, our users, or others
- Investigate fraud, security issues, or violations of our terms

### In business transfers
If SafeChat is involved in a merger, acquisition, or sale of assets, your information may be transferred. We will notify you before your information is transferred and becomes subject to a different privacy policy.

### With your consent
We share information in other ways only with your explicit consent.

---

## 6. Data Retention

We retain your information as long as necessary to provide the service and as required by law.

| Data type | Retention period |
|---|---|
| Account information | Until you delete your account |
| Posts, comments, stories | Until you or we delete them |
| Direct messages | Until the chat is deleted by both parties or one party deletes account |
| Stories | 24 hours, then automatically expired |
| Moderation logs | 90 days (content hashes only, no raw content) |
| Diagnostic logs | 30 days |
| Backups | 7 days after deletion |
| Reports | Until resolution + 90 days for audit |

When you delete your account, your data is removed within 7 days, with backup expiration completing within 30 days.

---

## 7. Your Rights

Depending on your location, you have the following rights:

### All users
- **Access** — request a copy of the personal data we hold about you
- **Correction** — update inaccurate information in your profile
- **Deletion** — delete your account and associated data
- **Portability** — request your data in a machine-readable format
- **Restriction** — limit how we process your data in certain circumstances
- **Objection** — object to specific processing activities

### EU users (GDPR)
You have additional rights including the right to lodge a complaint with your local data protection authority.

### Indian users (DPDP Act)
You have rights as a Data Principal including the right to nominate someone to exercise rights on your behalf in case of death or incapacity.

### Exercising your rights
To exercise any of these rights, email us at **privacy@safechat.app** (TO BE SET UP). We respond to verified requests within 30 days.

---

## 8. Children's Privacy

SafeChat is not directed at children under 13 years old (or the equivalent minimum age in your jurisdiction). We do not knowingly collect personal information from children. If we learn we have collected information from a child, we will delete it.

If you are a parent or guardian and believe your child has provided us with information, contact us at **privacy@safechat.app**.

---

## 9. International Data Transfers

SafeChat operates globally. Your information may be stored and processed in countries other than your own, including the United States and the European Union, where data protection laws may differ.

We use appropriate safeguards for international transfers, including:
- Standard Contractual Clauses for transfers from the EU
- Data Processing Agreements with all service providers
- Encryption in transit and at rest

---

## 10. Security

We implement industry-standard security measures:

- **Encryption in transit** — all data transmitted via HTTPS/TLS
- **Encryption at rest** — all stored data encrypted using AES-256
- **Authentication** — Firebase Authentication with optional multi-factor authentication
- **Access controls** — strict employee access controls with audit logging
- **Monitoring** — automated systems detect unusual activity
- **Regular audits** — security reviews of code and infrastructure

No security measure is perfect. We will notify you of significant security incidents affecting your data within 72 hours of discovery, as required by applicable law.

---

## 11. Cookies and Similar Technologies

The SafeChat web app uses:

- **Essential cookies** for authentication and session management
- **Functional cookies** to remember your preferences
- **Analytics cookies** (Firebase Analytics) to understand usage patterns

You can control cookies through your browser settings. Disabling essential cookies will prevent the app from working.

The mobile app uses similar local storage mechanisms for the same purposes.

---

## 12. Third-Party Links

SafeChat may contain links to third-party websites or services. We are not responsible for their privacy practices. Review their privacy policies before sharing information.

---

## 13. Changes to This Policy

We may update this Privacy Policy from time to time. When we make material changes:

- We will post the updated policy with a new "Last Updated" date
- We will notify you via email or in-app notification
- For significant changes, we will request fresh consent where required by law

Continued use of SafeChat after a policy update constitutes acceptance of the updated policy.

---

## 14. Contact Us

For privacy questions, concerns, or to exercise your rights:

**Email:** privacy@safechat.app (TO BE SET UP)
**Postal Address:** [TO BE SET ON LAUNCH]

**Data Protection Officer:** [TO BE APPOINTED IF REQUIRED BY LAW]

For EU residents, you may also contact your local data protection authority.

For Indian residents, you may file complaints with the Data Protection Board of India.

---

## 15. Jurisdiction-Specific Disclosures

### For California Residents (CCPA/CPRA)

[Section to be completed with CCPA-specific disclosures including categories of personal information sold or shared, which we do not currently do.]

### For European Economic Area Residents (GDPR)

[Section to be completed with GDPR-specific information including legal bases for processing, data controller identity, and rights under GDPR.]

### For Indian Residents (DPDP Act 2023)

[Section to be completed with DPDP-specific disclosures including grievance officer details and consent management.]

---

*This privacy policy was last updated on November 2026. Material changes will be communicated prominently before taking effect.*
