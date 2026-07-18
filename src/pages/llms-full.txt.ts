import { getCollection } from 'astro:content';
import type { APIContext } from 'astro';
import type { CollectionEntry } from 'astro:content';

function slug(id: string) {
  return id.replace(/\.md$/, '');
}

function formatDate(date: Date) {
  return date.toISOString().slice(0, 10);
}

function renderPost(post: CollectionEntry<'en' | 'zh'>, lang: 'en' | 'zh', site: string) {
  return [
    `## ${post.data.title}`,
    '',
    `- URL: ${site}/${lang}/${slug(post.id)}`,
    `- Date: ${formatDate(new Date(post.data.date))}`,
    `- Tags: ${post.data.tags.join(', ')}`,
    `- Excerpt: ${post.data.excerpt}`,
    '',
    post.body ?? '',
    '',
    '---',
    '',
  ].join('\n');
}

export async function GET(context: APIContext) {
  const site = context.site!.toString().replace(/\/$/, '');

  const en = (await getCollection('en', ({ data }) => !data.draft)).sort(
    (a, b) => new Date(b.data.date).getTime() - new Date(a.data.date).getTime()
  );
  const zh = (await getCollection('zh', ({ data }) => !data.draft)).sort(
    (a, b) => new Date(b.data.date).getTime() - new Date(a.data.date).getTime()
  );

  const header = [
    '# Encore Shao — Personal Blog (Full Text)',
    '',
    '> Complete text of every article on blog.icmoc.com, in both English and Chinese. Generated automatically at build time from the same source Markdown that powers the site.',
    '',
    '---',
    '',
  ].join('\n');

  const enSection = ['# English Articles', '', ...en.map((post) => renderPost(post, 'en', site))].join(
    '\n'
  );
  const zhSection = ['# 中文文章 (Chinese Articles)', '', ...zh.map((post) => renderPost(post, 'zh', site))].join(
    '\n'
  );

  const body = [header, enSection, zhSection].join('\n');

  return new Response(body, {
    headers: { 'Content-Type': 'text/plain; charset=utf-8' },
  });
}
