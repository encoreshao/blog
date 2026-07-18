import { getCollection } from 'astro:content';
import type { APIContext } from 'astro';

function slug(id: string) {
  return id.replace(/\.md$/, '');
}

export async function GET(context: APIContext) {
  const site = context.site!.toString().replace(/\/$/, '');

  const en = (await getCollection('en', ({ data }) => !data.draft)).sort(
    (a, b) => new Date(b.data.date).getTime() - new Date(a.data.date).getTime()
  );
  const zh = (await getCollection('zh', ({ data }) => !data.draft)).sort(
    (a, b) => new Date(b.data.date).getTime() - new Date(a.data.date).getTime()
  );

  const lines = [
    '# Encore Shao — Personal Blog',
    '',
    '> Personal blog of Encore Shao, a full-stack engineer and AI researcher based in Shanghai. Writing on Rails/Ruby engineering, agentic AI systems, open-source gems, and lessons from shipping production software.',
    '',
    'This is a bilingual site (English and Chinese). Each article below is a standalone Markdown-rendered page. See /llms-full.txt for the complete text of every article in one file.',
    '',
    '## Articles (English)',
    '',
    ...en.map(
      (post) => `- [${post.data.title}](${site}/en/${slug(post.id)}): ${post.data.excerpt}`
    ),
    '',
    '## 中文 (Chinese)',
    '',
    ...zh.map(
      (post) => `- [${post.data.title}](${site}/zh/${slug(post.id)}): ${post.data.excerpt}`
    ),
    '',
    '## Optional',
    '',
    `- [Full text of every article](${site}/llms-full.txt): all EN/ZH posts inlined in one file`,
    `- [English RSS feed](${site}/rss.xml)`,
    `- [Chinese RSS feed](${site}/zh/rss.xml)`,
    `- [Sitemap](${site}/sitemap-index.xml)`,
    '',
  ];

  return new Response(lines.join('\n'), {
    headers: { 'Content-Type': 'text/plain; charset=utf-8' },
  });
}
