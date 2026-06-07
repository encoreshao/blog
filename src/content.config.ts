import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';

const postSchema = z.object({
  title: z.string(),
  date: z.coerce.date(),
  tags: z.array(z.string()),
  excerpt: z.string(),
  draft: z.boolean().default(false),
});

const en = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/data/en' }),
  schema: postSchema,
});

const zh = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/data/zh' }),
  schema: postSchema,
});

export const collections = { en, zh };
