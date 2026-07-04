---
title: Project Documentation Hub
tags:
  - index
---

# Project Documentation Hub

Central hub of the project documentation. Every section is connected via wikilinks — open Graph View in Obsidian to see the whole structure.

## Sections

- [[Backend]] — API, database, services, background jobs
- [[Frontend]] — app, routes, components
- [[Design]] — design system, UI/UX
- [[Marketing]] — marketing and promotion
- [[SEO]] — search engine optimization
- [[Finance]] — finance and budgets
- [[Analytics]] — data and analytics
- [[Planning]] — planning and roadmap
- [[Timeline]] — log: what was done and when

## Code map

Every source file is described by its own note under `code-map/`:

- `code-map/backend/<path-with-dashes>.md` — e.g. `code-map/backend/app-api-v1-auth.md` for `backend/app/api/v1/auth.py`
- `code-map/frontend/<path-with-dashes>.md` — e.g. `code-map/frontend/routes-workspace-index.md`

A file note contains: the file's purpose, its classes and their methods, functions (signature + one-line description), and links to related files via [[wikilinks]].

> [!important] Before writing new code
> Check the code map: a similar function or class may already exist. Adapt existing code instead of creating a duplicate and growing the codebase.

## Conventions

- Note filenames in ASCII (latin letters, dashes); content in any language
- Every section note links back to [[INDEX]]; code map notes link to their section
- New classes/methods are documented in the code map in the same session they are created
- Claude may create new sections when a topic doesn't fit existing ones — add the note and link it from [[INDEX]]
- [[Timeline]] gets a new entry after every working session (newest on top)
