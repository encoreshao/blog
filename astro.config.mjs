// astro.config.mjs
import { defineConfig } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';
import sitemap from '@astrojs/sitemap';

export default defineConfig({
  site: 'https://blog.icmoc.com',
  integrations: [sitemap()],
  vite: {
    plugins: [tailwindcss()],
  },
});
