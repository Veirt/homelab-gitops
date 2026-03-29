# docs

This directory contains the documentation site for the homelab.

It is a small Next.js application built with Fumadocs. The content itself lives
in `content/docs/`, which makes it easy to keep the docs close to the repo they
are describing.

## Development

Run the docs locally:

```bash
bun run dev
```

Then open `http://localhost:3000`.

## Content layout

Most of the writing lives in:

- `content/docs/` for MDX pages
- `src/app/docs/` for the docs layout and route handling
- `src/lib/` for shared site config and source loading

## Writing docs

When adding or updating pages, keep the docs focused on:

- how the homelab is structured
- how the repo is organized
- how changes are made and debugged
- what services are running and why they matter

The tone should stay friendly, technical, and practical.

## Learn more

Useful references:

- [Next.js Documentation](https://nextjs.org/docs)
- [Fumadocs Documentation](https://fumadocs.dev)
