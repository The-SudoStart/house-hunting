# 🏠 House Finder

A mobile-first platform that helps people quickly discover available rental houses nearby.

House Finder is being built to solve a common problem in Cameroon and many other African countries: finding available rental houses is often slow, stressful, and relies heavily on word of mouth or physically walking around neighborhoods looking for "House for Rent" signs.

The goal of this project is to provide a simple, fast, and reliable way for users to discover available houses, view essential information, and contact landlords directly from their mobile devices.

---

# Vision

To become the most trusted platform for discovering rental properties by providing accurate listings, verified landlords, and a seamless mobile experience.

---

# MVP Goals

The first version of the application focuses on one simple user journey:

1. Open the app.
2. Browse nearby houses.
3. View house details.
4. Call the landlord.

The MVP intentionally excludes user authentication and landlord self-registration to ensure all listings remain curated and trustworthy while the product is validated.

---

# Planned Features

## MVP

* Browse available houses
* View house details
* Browse house images
* Search by neighborhood
* View rental prices
* Contact landlords directly via phone
* Display nearby houses based on location

---

## Future Features

* Landlord accounts
* Property management dashboard
* Passkey authentication
* Favorite houses
* Reviews and ratings
* House availability status
* Push notifications
* Advanced search and filters
* In-app messaging
* Verified landlords
* Property verification
* Report fraudulent listings

---

# Technology Stack

## Mobile

* Flutter
* Dart

## Backend

* Rust
* Axum
* SQLx

## Database

* PostgreSQL

## Maps

* OpenStreetMap

## Storage

* Object Storage (planned)

---

# Project Structure

```text
lib/
│
├── app/
├── core/
├── features/
├── models/
├── assets/
└── main.dart
```

The application follows a feature-based architecture to keep the codebase modular and maintainable as the project grows.

---

# Design Principles

* Mobile-first
* Simple user experience
* Fast performance
* Reliable data
* Scalable architecture
* Clean code
* Feature-based organization

---

# Development Philosophy

This project follows an iterative development approach.

Rather than attempting to build a complete real estate platform from day one, the focus is on shipping a small, functional MVP that solves a real problem and can be improved based on user feedback.

Each feature should:

* Solve a real user problem.
* Be independently testable.
* Be production-ready before moving to the next feature.

---

# Roadmap

## Phase 1

* Project setup
* Backend API
* Database
* Home screen
* House details
* Phone call integration

## Phase 2

* GPS integration
* Search
* Better image gallery
* Improved UI

## Phase 3

* Landlord accounts
* Authentication
* Listing management
* Property approval workflow

## Phase 4

* Passkey authentication
* Reviews
* Favorites
* Notifications
* Property verification

---

# Authentication Strategy

Authentication is intentionally excluded from the MVP.

Initially, only administrators will be able to create property listings, ensuring the platform contains only trusted and verified information while validating the product.

Future releases will introduce:

* Verified landlord accounts
* Phone number verification
* Passkey authentication
* Administrative approval for new listings

This approach prioritizes trust and helps reduce fraudulent property listings.

---

# Contributing

Contributions, ideas, and feedback are always welcome.

If you'd like to contribute:

1. Fork the repository.
2. Create a feature branch.
3. Commit your changes.
4. Open a pull request.

---

# License

This project is licensed under the MIT License.

---

> **Our mission is simple:** make finding a house as easy as opening an app.
