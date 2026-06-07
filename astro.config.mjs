// astro.config.mjs
import { defineConfig } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
  site: 'https://blog.icmoc.com',
  vite: {
    plugins: [tailwindcss()],
  },
});
