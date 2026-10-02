# SEO Checklist

Use this checklist to validate any content intended to rank in search engines. Every item has a specific threshold. Mark each as PASS, FAIL, or WARN.

---

## Title Tag

| Check | Threshold | Status |
|---|---|---|
| Title tag exists | Must be present | |
| Character count | 50-60 characters (Google truncates at ~60) | |
| Primary keyword placement | In the first 4 words | |
| Unique across site | No other page shares this exact title tag | |
| Click-worthy | Contains a benefit, number, or compelling modifier — not just a keyword | |
| No keyword stuffing | Keyword appears once, not repeated | |

**How to fix a failing title tag:**
- Too long: cut modifiers, remove brand name, or restructure. Prioritize keyword + core promise.
- Too short: add a benefit or specificity. "Onboarding Guide" becomes "SaaS Onboarding Guide: 5 Fixes That Cut Churn by 20%."
- Keyword not in first 4 words: restructure so the keyword leads. "The Ultimate Guide to SaaS Onboarding" becomes "SaaS Onboarding: The Complete Guide for 2025."

---

## Meta Description

| Check | Threshold | Status |
|---|---|---|
| Meta description exists | Must be present | |
| Character count | 150-160 characters (Google truncates at ~160) | |
| Contains primary keyword | At least once, naturally | |
| Contains a CTA verb | "Learn," "discover," "find out," "get," "see," "try," "compare" | |
| Unique per page | Not duplicated from another page or from the body | |
| Specific to content | Describes what THIS page delivers, not generic promises | |

**How to fix a failing meta description:**
- Too long: remove filler words, cut to one sentence + CTA.
- No CTA verb: end with an action. "...See the 5 fixes that work." or "...Get the free template."
- Too generic: add a specific number, result, or audience. "Learn about marketing" becomes "See how 3 B2B teams doubled trial conversions with one onboarding change."

---

## H1 Tag

| Check | Threshold | Status |
|---|---|---|
| Exactly one H1 | One and only one per page | |
| Matches or mirrors title tag | Same core phrase, can differ slightly for readability | |
| Contains primary keyword | At least once | |
| Not identical to title tag | Slight variation prevents redundancy in SERPs | |

---

## Heading Hierarchy (H2-H6)

| Check | Threshold | Status |
|---|---|---|
| Proper nesting | No skipped levels (no H1 directly to H3) | |
| H2s cover major sections | Every major topic or subtopic has an H2 | |
| Keywords in headings | Primary or secondary keyword in at least one H2 | |
| Headings are descriptive | Reader can skim headings alone and understand the article structure | |
| No empty or decorative headings | Every heading introduces a real section with content below it | |
| No duplicate headings | No two headings on the page have the same text | |

---

## Keyword Density

| Check | Threshold | Status |
|---|---|---|
| Primary keyword density | 0.5-2.5% of total word count | |
| Primary keyword in first 100 words | Must appear at least once | |
| Primary keyword in last 100 words | Should appear at least once | |
| Secondary keywords present | Each secondary keyword appears at least once in the body | |
| No keyword stuffing | Reads naturally — a human reader would not notice the keyword placement | |
| Keyword in at least one H2 | Primary or close variant | |

**How to calculate keyword density:**
Count the number of times the exact primary keyword phrase appears. Divide by total word count. Multiply by 100. Example: "SaaS onboarding" appears 12 times in a 1,500-word article = 0.8% density.

---

## Content Length

| Check | Threshold | Status |
|---|---|---|
| Meets competitor average | Word count equals or exceeds the average of the top 5 ranking pages | |
| Minimum floor | At least 1,200 words for any blog post or article | |
| No padding | Every section provides genuine value — no filler to hit a number | |
| Appropriate for intent | Informational queries need depth; transactional pages can be shorter | |

---

## Internal Links

| Check | Threshold | Status |
|---|---|---|
| Minimum count | 3-5 internal links per page | |
| Descriptive anchor text | Anchor describes the destination, not "click here" or "this article" | |
| Relevant destinations | Links point to genuinely related content | |
| No orphan status | The page itself is linked to from at least one other page on the site | |
| No broken internal links | All internal links resolve to live pages | |

---

## External Links

| Check | Threshold | Status |
|---|---|---|
| Minimum count | 2-3 external links per article | |
| Authoritative sources | Links point to recognized, high-authority domains | |
| Relevant to claims | External links support specific claims or statistics in the content | |
| No broken external links | All external links resolve to live pages | |
| Open in new tab | External links should open in a new tab to keep users on site | |
| No competitor links | Do not link to direct competitors unless genuinely comparing products | |

---

## Image Optimization

| Check | Threshold | Status |
|---|---|---|
| All images have alt text | Every img tag includes a non-empty alt attribute | |
| Alt text is descriptive | Describes the image content, not just "image" or "photo" | |
| Keyword in alt text | Primary keyword in at least one image alt tag where natural | |
| File names are descriptive | Hyphened descriptive names, not "IMG_4521.jpg" | |
| Images are compressed | File size appropriate for web (under 200KB for standard images) | |
| Appropriate format | JPEG for photos, PNG for graphics/screenshots, WebP where supported | |
| Responsive sizing | Images scale properly on mobile, no overflow | |

---

## URL Structure

| Check | Threshold | Status |
|---|---|---|
| Includes primary keyword | The keyword or close variant appears in the URL slug | |
| Short and readable | 3-5 words in the slug, no unnecessary words | |
| Uses hyphens | Words separated by hyphens, not underscores or spaces | |
| No parameters or IDs | Clean URL without ?id=123 or session strings | |
| Lowercase only | No mixed case in the URL | |
| No dates unless time-sensitive | /blog/saas-onboarding not /blog/2025/01/saas-onboarding (unless content is date-dependent) | |

---

## Schema Markup

| Check | Threshold | Status |
|---|---|---|
| Schema present | Structured data exists on the page | |
| Correct type for content | Article for blog posts, FAQ for Q&A sections, HowTo for tutorials, Product for product pages | |
| Valid markup | No errors when validated against schema.org specifications | |
| Required fields populated | headline, datePublished, author, image for Article; name, acceptedAnswer for FAQ | |
| Rich snippet eligible | Markup qualifies for Google rich results (FAQ snippets, how-to steps, review stars) | |

**Schema type recommendations by page type:**
- Blog post: Article (always) + FAQ (if FAQ section exists)
- Tutorial/guide: Article + HowTo
- Product page: Product + Review/AggregateRating
- Landing page: Organization or WebPage
- Local business: LocalBusiness

---

## Page Speed and Core Web Vitals

| Check | Threshold | Status |
|---|---|---|
| Largest Contentful Paint (LCP) | Under 2.5 seconds | |
| First Input Delay (FID) | Under 100 milliseconds | |
| Cumulative Layout Shift (CLS) | Under 0.1 | |
| Interaction to Next Paint (INP) | Under 200 milliseconds | |
| Total page size | Under 3MB | |
| Render-blocking resources | Minimized — no unnecessary CSS or JS blocking first paint | |

---

## Mobile Usability

| Check | Threshold | Status |
|---|---|---|
| Responsive layout | Content adapts to screen width without horizontal scrolling | |
| Readable text | Font size at least 16px on mobile, no pinch-to-zoom required | |
| Tap targets | Buttons and links at least 48x48px with adequate spacing | |
| No intrusive interstitials | No full-screen popups that block content on mobile | |
| Viewport configured | Meta viewport tag present with width=device-width | |
| Images scale properly | No images overflowing the viewport | |

---

## Canonical and Indexing

| Check | Threshold | Status |
|---|---|---|
| Self-referencing canonical | Page has a canonical tag pointing to itself | |
| No conflicting canonicals | No other page claims to be the canonical for this URL | |
| In XML sitemap | The page URL appears in the site's sitemap.xml | |
| Not blocked by robots.txt | robots.txt does not disallow crawling of this page | |
| No noindex tag | Page does not have a noindex meta tag (unless intentionally excluded) | |
| Sitemap references in robots.txt | robots.txt includes a Sitemap: directive | |
