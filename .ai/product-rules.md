# Product Rules - Kapada Creation Customer App

## Product Identity

- **Brand**: Kapada Creation
- **Tagline**: We Care What You Wear.

## Product Purpose

Kapada Creation is a boutique engagement platform designed to:
- Inspire customers
- Showcase fashion and boutique designs
- Increase boutique visits
- Build long-term customer relationships
- Provide stitching progress visibility

## E-Commerce Exclusion Rule

Kapada Creation is **NOT** an e-commerce application. Never add without explicit approval:
- Cart
- Checkout
- Payment gateway / online payments
- Shipping
- Delivery / Delivery tracking
- Online ordering
- Online stitching payment

## Multi-Boutique and Branch Rules

- Backend models and data architecture must remain ready for multiple boutiques.
- A boutique may have multiple branches.
- Important records must contain `boutiqueId`.
- Branch-owned records must contain `branchId`.
- Designs are separate per branch and are never automatically shared between branches. The same design in another branch is a separate record.
- Branch selector remains hidden when only one branch exists.
- Customer changes active branch from the app bar.

## Customer Authentication Rules

- Browsing does not require login.
- Google Sign-In is used when authentication is required.
- Login is required for Favorites and My Stitching.
- Each customer receives a permanent UUID-based `customerId`.
- Firebase UID and `customerId` must remain separate identifiers.

## Data Terminology

Use domain terms:
- Design
- Collection
- Section
- Stitching
- Boutique
- Branch

Avoid generic e-commerce terms:
- Product cart
- Buy now
- Checkout
- Shipping status

## Stitching Module Rules

- Stitching is a separate tracking module.
- Admin creates stitching records linked via `customerId`.
- Customer views stitching status in My Stitching.
- Ready-made designs do not show a Request Stitching button.

## Availability Rules

- Available designs appear in browsing.
- Out-of-stock / unavailable designs are hidden from normal browsing.
- Existing favorite items may display an unavailable state.
- Availability is branch-specific.
