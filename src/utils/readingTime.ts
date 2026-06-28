const EN_WPM = 200;
const ZH_CPM = 350;

function stripMarkdown(text: string): string {
  return text
    .replace(/```[\s\S]*?```/g, '')
    .replace(/`[^`\n]*`/g, '')
    .replace(/!\[.*?\]\(.*?\)/g, '')
    .replace(/\[([^\]]*)\]\([^)]*\)/g, '$1')
    .replace(/^---[\s\S]*?---/m, '')
    .replace(/[#*_~>|]/g, '')
    .trim();
}

function humanizeEn(mins: number): string {
  if (mins <= 1) return '1 min read';
  if (mins <= 3) return `${mins} min read`;
  if (mins <= 9) return `~${mins} min read`;
  if (mins <= 20) return `~${mins} min`;
  return `${mins}+ min`;
}

function humanizeZh(mins: number): string {
  if (mins <= 1) return '速读';
  if (mins <= 4) return `约 ${mins} 分钟`;
  if (mins <= 12) return `约 ${mins} 分钟阅读`;
  return `长文 · ${mins}+ 分钟`;
}

export function getReadingTime(body: string, lang: 'en' | 'zh'): string {
  const clean = stripMarkdown(body);

  if (lang === 'zh') {
    const chars = clean.replace(/\s/g, '').length;
    const mins = Math.max(1, Math.round(chars / ZH_CPM));
    return humanizeZh(mins);
  }

  const words = clean.split(/\s+/).filter(Boolean).length;
  const mins = Math.max(1, Math.round(words / EN_WPM));
  return humanizeEn(mins);
}
