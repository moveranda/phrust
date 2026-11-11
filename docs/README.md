# Phrust docs

The documentation site for [Phrust](https://github.com/moveranda/phrust), built with [Astro](https://astro.build) and [Starlight](https://starlight.astro.build).

Pages live in `src/content/docs/` as `.md` or `.mdx` files. Each file becomes a route based on its path. The sidebar is configured in `astro.config.mjs`.

## Commands

Run from `docs/`:

| Command        | Action                                      |
| :------------- | :------------------------------------------ |
| `pnpm install` | Install dependencies                        |
| `pnpm dev`     | Start the dev server at `localhost:4321`    |
| `pnpm build`   | Build the site to `./dist/`                 |
| `pnpm preview` | Preview the build locally                   |
