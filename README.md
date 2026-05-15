## Overview

House Finder is a lightweight, offline-first rental discovery platform designed for regions with:

* poor internet connectivity,
* fragmented rental information,
* and non-technical users.

The platform helps tenants quickly discover available rental houses without physically walking through neighborhoods searching for vacancy signs.

Unlike traditional real estate platforms, House Finder focuses on:

* simplicity,
* speed,
* low data usage,
* and reliability on weak mobile networks.

The application enables:

* tenants to browse nearby rental listings,
* landlords or caretakers to post available houses,
* and direct communication between both parties using phone calls or WhatsApp.

---

# Problem Statement

In many cities, especially across Africa, finding rental housing is still a highly manual process:

* tenants walk through neighborhoods searching for “House Available” signs,
* agents repeatedly provide the same information,
* landlords lack digital visibility,
* and existing rental applications are often too heavy or complicated.

This leads to:

* wasted transport costs,
* wasted time,
* poor rental visibility,
* and frustrating user experiences.

House Finder solves this by providing a lightweight digital rental discovery network optimized for low-connectivity environments.

---

# Vision

House Finder aims to become the most accessible and lightweight rental discovery platform optimized for emerging markets and low-connectivity environments.

The mission is to simplify rental discovery while making property visibility accessible to everyone.

---

# Engineering Philosophy

This project prioritizes:

* simplicity,
* performance,
* reliability,
* and low-bandwidth usability.

The architecture intentionally avoids:

* unnecessary microservices,
* heavy frontend frameworks,
* and overly complex infrastructure.

The focus is:

* fast APIs,
* offline-first mobile experiences,
* low infrastructure cost,
* and maintainable backend services.

---

# Core Principles

---

## 1. Offline-First

The application should remain usable even with unstable internet connections.

Users must still be able to:

* open the app,
* browse cached listings,
* access saved properties,
* and view recently opened houses offline.

---

## 2. Low Data Consumption

The platform minimizes:

* API payload sizes,
* image sizes,
* unnecessary requests,
* and background network usage.

---

## 3. Simplicity

Users should understand the application immediately without onboarding tutorials.

The interface should:

* avoid clutter,
* minimize navigation depth,
* and reduce user decisions.

---

## 4. Reliability

The platform prioritizes:

* fast loading,
* stable APIs,
* graceful failure handling,
* and efficient caching.

---

# Target Users

---

## Tenants

People searching for:

* apartments,
* studios,
* single rooms,
* shared apartments,
* or houses.

---

## Landlords

Property owners wanting to:

* advertise vacancies,
* receive direct calls,
* and quickly fill available spaces.

---

## Caretakers / Agents

Individuals managing properties on behalf of landlords.

---

# MVP Features

# Tenant Features

---

## Browse Houses

Users can:

* view available listings,
* browse by neighborhood,
* and see pricing information.

---

## Search & Filter

Filters include:

* location,
* price range,
* room count,
* furnished/unfurnished status.

---

## House Details

Each listing contains:

* images,
* rent amount,
* location,
* room count,
* contact information,
* and property descriptions.

---

## Direct Contact

Users can:

* call landlords directly,
* or contact them through WhatsApp.

No in-app messaging system is included in the MVP.

---

## Favorites

Users can save listings locally for offline viewing.

---

## Recently Viewed

Recently viewed properties remain accessible offline.

---

# Landlord Features

---

## Create Listing

Landlords can:

* upload photos,
* enter rental details,
* provide contact information,
* and publish listings.

---

## Manage Listings

Landlords can:

* update listing details,
* mark properties as rented,
* and remove inactive listings.

---

# Non-Goals (MVP)

The initial version intentionally excludes:

* online payments,
* booking systems,
* AI recommendations,
* video uploads,
* social networking features,
* desktop applications,
* and advanced mapping systems.

These features increase complexity and are not essential for validating the core product.

---

# Technology Stack

# Frontend

---

## Mobile Application

* React Native
* Expo
* TypeScript

### Why React Native?

* Single codebase for Android and iOS
* Faster development cycle
* Excellent ecosystem
* Good offline support

---

## Local Storage

* SQLite

### Used For

* cached listings,
* favorites,
* recent searches,
* and offline browsing.

---

# Backend

---

## Backend Framework

* Rust
* Axum
* Tokio

### Why Rust?

Rust provides:

* high performance,
* low memory usage,
* strong reliability,
* and efficient concurrency.

This makes it ideal for:

* low-cost infrastructure,
* lightweight APIs,
* and mobile-first applications operating in low-bandwidth environments.

---

### Why Axum?

Axum provides:

* async-first architecture,
* modular routing,
* strong type safety,
* and excellent Tokio ecosystem integration.

---

## Database

* PostgreSQL
* SQLx

### Why SQLx?

SQLx provides:

* async PostgreSQL support,
* compile-time query validation,
* lightweight database access,
* and strong Rust async integration.

---

## Cache Layer

* Redis

### Used For

* caching popular listings,
* reducing database load,
* and improving API response times.

---

# Media Storage

---

## Object Storage

* S3-compatible object storage

### Image Strategy

Uploaded images automatically generate:

* thumbnails,
* optimized medium versions,
* and compressed originals.

The mobile application initially loads low-quality thumbnails to minimize bandwidth usage.

---

# System Architecture

```mermaid
flowchart TD

A[React Native Mobile App] --> B[Axum Rust API]

B --> C[PostgreSQL]

B --> D[Redis Cache]

B --> E[Image Processing Service]

E --> F[S3 Object Storage]

A --> G[SQLite Offline Cache]
```

---

# Offline-First Architecture

The application follows an offline-first design strategy.

---

## Cached Data

The mobile application stores:

* recent listings,
* saved properties,
* recently viewed listings,
* and search history locally.

---

## Synchronization Strategy

### When Online

* sync latest listings,
* refresh cached data,
* update saved properties.

### When Offline

* serve cached content,
* queue pending actions,
* retry synchronization automatically.

---

# Backend Architecture

The backend follows a modular architecture to maintain:

* scalability,
* maintainability,
* and separation of concerns.

---

## Backend Structure

```plaintext
backend/
├── src/
│   ├── api/
│   ├── handlers/
│   ├── services/
│   ├── repositories/
│   ├── models/
│   ├── dto/
│   ├── middleware/
│   ├── auth/
│   ├── cache/
│   ├── storage/
│   ├── config/
│   └── main.rs
```

---

## Architectural Layers

### Handlers

Responsible for:

* HTTP request handling,
* response formatting,
* and route coordination.

---

### Services

Contains:

* business logic,
* validation,
* and application workflows.

---

### Repositories

Responsible for:

* database interaction,
* SQLx queries,
* and persistence logic.

---

### DTOs

Handles:

* request payloads,
* response payloads,
* and serialization structures.

---

# API Design Principles

The API is designed to:

* remain lightweight,
* minimize payload size,
* support pagination,
* and avoid unnecessary nested data.

---

## Example Lightweight Response

```json
{
  "id": 12,
  "price": 75000,
  "rooms": 2,
  "location": "Biyem-Assi",
  "thumbnail": "thumb.jpg"
}
```

Detailed property information loads only when the user opens a listing.

---

# Authentication

The platform uses:

* phone number authentication,
* OTP verification,
* JWT access tokens.

### Why?

* easier onboarding,
* better accessibility,
* reduced password complexity.

---

# Image Optimization Pipeline

The image processing system:

* compresses uploads,
* generates thumbnails,
* and optimizes delivery for low-bandwidth environments.

---

## Optimization Goals

* reduce mobile data usage,
* improve loading speed,
* reduce server bandwidth cost.

---

# Backend Performance Optimization

The backend is optimized using Rust async architecture to provide:

* low memory usage,
* fast API response times,
* efficient concurrent request handling,
* and minimal infrastructure costs.

---

## Optimization Strategies

* async request handling using Tokio,
* lightweight JSON responses,
* Redis caching,
* optimized PostgreSQL queries,
* image compression pipelines,
* connection pooling.

---

# Security Considerations

The application includes:

* rate limiting,
* request validation,
* image upload restrictions,
* JWT authentication,
* and API throttling.

---

# Monitoring & Observability

The backend uses structured logging and tracing to improve:

* debugging,
* performance monitoring,
* and operational reliability.

---

## Recommended Tools

* tracing
* tracing-subscriber
* Sentry
* Prometheus
* Grafana

---

# Scalability Strategy

The platform is designed to scale progressively.

---

## Phase 1

Single neighborhood deployment.

---

## Phase 2

Single city deployment.

---

## Phase 3

Multi-city deployment.

---

## Phase 4

National expansion.

---

# Suggested Folder Structure

# Mobile Application

```plaintext
mobile-app/
├── src/
│   ├── components/
│   ├── screens/
│   ├── services/
│   ├── storage/
│   ├── hooks/
│   ├── navigation/
│   ├── utils/
│   └── assets/
```

---

# Backend Development Setup

## Requirements

* Rust
* Cargo
* PostgreSQL
* Redis
* Docker (optional)

---

## Install Rust

Visit:
[Rust Installation Guide](https://www.rust-lang.org/tools/install?utm_source=chatgpt.com)

Or run:

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

---

## Clone Repository

```bash
git clone <repository-url>
cd house-finder
```

---

## Configure Environment Variables

Create a `.env` file:

```env
DATABASE_URL=postgres://postgres:password@localhost/housefinder
REDIS_URL=redis://localhost:6379
JWT_SECRET=your-secret-key
STORAGE_BUCKET=housefinder
```

---

## Run Database Migrations

```bash
sqlx migrate run
```

---

## Run Backend

```bash
cargo run
```

---

## Run Mobile Application

```bash
npm install
npx expo start
```

---

# Docker Setup

## Start Services

```bash
docker compose up --build
```

---

## Services Included

* Rust Backend API
* PostgreSQL
* Redis

---

# CI/CD Pipeline

The CI/CD pipeline includes:

* cargo fmt
* cargo clippy
* cargo test
* Docker image builds
* automated deployments

---

## Pull Request Requirements

All pull requests must:

* pass formatting checks,
* pass linting,
* pass tests,
* and compile successfully.

---

# Deployment Strategy

## Backend Hosting

The Rust backend is designed for lightweight deployment and can run efficiently on:

* small VPS instances,
* low-memory cloud servers,
* or containerized infrastructure.

---

## Deployment Components

* Axum API
* PostgreSQL
* Redis
* NGINX reverse proxy
* S3-compatible object storage

---

# Future Features

Potential future enhancements include:

* landlord verification,
* push notifications,
* smart recommendations,
* map integration,
* rental analytics,
* premium featured listings,
* moving service partnerships.

---

# Monetization Strategy

Potential monetization methods:

* promoted listings,
* featured properties,
* verified landlord badges,
* agency subscriptions,
* advertising partnerships.

The MVP prioritizes:

* user growth,
* listing density,
* and usability before monetization.

---

# Success Metrics

The platform succeeds if users can:

* find houses faster,
* reduce transport costs,
* access listings with poor internet,
* and contact landlords easily.

---

## Key Metrics

* daily active users,
* listing count,
* successful landlord contacts,
* app load speed,
* and user retention.

---

# Contributing

Contributors should prioritize:

* simplicity,
* performance,
* maintainability,
* and offline-first design principles.

Avoid:

* unnecessary abstractions,
* premature microservices,
* and overly complex frontend patterns.

---

# License

This project is licensed under the MIT License.
