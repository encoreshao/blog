#!/usr/bin/env python3
"""Flag common AI-writing tells in a generate-article draft (EN or ZH). Warns only, does not rewrite.

Metrics adapted from https://github.com/KKKKhazix/human-writing (check_prose.py), generalized
to English and simplified for blog-length drafts.
"""

from __future__ import annotations

import argparse
import re
import statistics
import sys
from collections import Counter
from pathlib import Path

EN_TRANSITIONS = (
    "however", "moreover", "furthermore", "additionally", "in addition",
    "that said", "on the other hand", "at the same time", "notably",
    "importantly", "ultimately", "in fact", "as a result", "consequently",
)

ZH_CONJUNCTIONS = (
    "因为", "所以", "但是", "然而", "同时", "此外", "而且", "并且", "因此", "不仅",
)

BANNED_PHRASES = (
    "in today's fast-paced world", "game-changer", "leverage", "robust",
    "seamless", "dive deep", "let's explore", "it's worth noting",
    "at the end of the day", "moving forward", "in conclusion",
    "this is a great opportunity", "the good news is", "the bad news is",
    "this is a complex topic", "i hope this was helpful", "delve", "unlock",
    "unleash", "transformative", "cutting-edge", "empower", "in summary",
    "to summarize",
)

EN_PIVOT_PATTERNS = (
    re.compile(r"\bnot\s+just\b[^.?!\n]{0,60}\b(?:it'?s|but|it is)\b", re.I),
    re.compile(r"\bisn'?t\s+(?:just\s+)?about\b[^.?!\n]{0,60}\bit'?s\s+about\b", re.I),
    re.compile(r"\bwasn'?t\s+(?:just\s+)?about\b[^.?!\n]{0,60}\bit\s+was\s+about\b", re.I),
    re.compile(r"[.?!]\s*It'?s not\b[^.?!\n]{0,60}\bit'?s\b", re.I),
)

ZH_PIVOT_PATTERNS = (
    re.compile(r"(?:并)?不是[^。!?\n]{0,90}而是"),
    re.compile(r"并非[^。!?\n]{0,90}而是"),
    re.compile(r"不在于[^。!?\n]{0,90}而在于"),
    re.compile(r"与其说[^。!?\n]{0,90}(?:不如|毋宁|倒不如)"),
    re.compile(r"表面(?:上)?[^。!?\n]{0,90}(?:其实|实际|实则)"),
    re.compile(r"看似[^。!?\n]{0,90}(?:其实|实际|实则)"),
)


def strip_frontmatter_and_code(text: str) -> str:
    text = re.sub(r"\A---\s*\n.*?\n---\s*\n", "", text, flags=re.DOTALL)
    text = re.sub(r"```.*?```", "", text, flags=re.DOTALL)
    text = re.sub(r"`[^`\n]*`", "", text)
    text = re.sub(r"\]\([^\n)]*\)", "", text)
    return text


def han_ratio(text: str) -> float:
    han = len(re.findall(r"[一-鿿]", text))
    letters = len(re.findall(r"[A-Za-z一-鿿]", text))
    return han / letters if letters else 0.0


def sentence_lengths_en(text: str) -> list[int]:
    sentences = re.split(r"(?<=[.!?])\s+", text)
    lengths = [len(re.findall(r"[A-Za-z']+", s)) for s in sentences]
    return [n for n in lengths if n >= 3]


def sentence_lengths_zh(text: str) -> list[int]:
    sentences = re.findall(r"[^。！？\n]+[。！？]", text)
    lengths = [len(re.findall(r"[一-鿿]", s)) for s in sentences]
    return [n for n in lengths if n >= 4]


def coefficient_of_variation(lengths: list[int]) -> float | None:
    if len(lengths) < 8:
        return None
    mean = statistics.mean(lengths)
    if mean == 0:
        return None
    return statistics.pstdev(lengths) / mean


def paragraphs(text: str) -> list[str]:
    return [
        p.strip()
        for p in re.split(r"\n\s*\n", text)
        if p.strip() and not p.strip().startswith(("#", "!", ">", "-", "*"))
    ]


def one_sentence_ratio(paras: list[str], sentence_end: re.Pattern[str]) -> float | None:
    if len(paras) < 6:
        return None
    singles = sum(1 for p in paras if len(sentence_end.findall(p)) <= 1)
    return singles / len(paras)


def repeated_openers(paras: list[str], n_words: int = 2, minimum: int = 3) -> list[tuple[str, int]]:
    openers: Counter[str] = Counter()
    for p in paras:
        words = p.split()[:n_words]
        if words:
            openers[" ".join(words).lower()] += 1
    return [(o, c) for o, c in openers.items() if c >= minimum]


def find_matches(text: str, patterns: tuple[re.Pattern[str], ...]) -> list[str]:
    hits = []
    for pattern in patterns:
        hits.extend(m.group() for m in pattern.finditer(text))
    return hits


def read_text(path: str) -> str:
    if path == "-":
        return sys.stdin.read()
    return Path(path).read_text(encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("path", help="Markdown file to check. Use - to read stdin.")
    args = parser.parse_args()

    try:
        raw = read_text(args.path)
    except (OSError, UnicodeError) as error:
        print(f"Could not read draft: {error}", file=sys.stderr)
        return 2

    text = strip_frontmatter_and_code(raw)
    is_zh = han_ratio(text) > 0.3

    word_count = len(re.findall(r"[A-Za-z']+", text))
    han_count = len(re.findall(r"[一-鿿]", text))
    scale = han_count if is_zh else word_count
    if scale == 0:
        print("No prose detected.", file=sys.stderr)
        return 2

    warnings: list[str] = []

    lengths = sentence_lengths_zh(text) if is_zh else sentence_lengths_en(text)
    variation = coefficient_of_variation(lengths)
    if variation is not None and variation < 0.45:
        warnings.append(
            f"Sentence lengths too uniform (CV={variation:.2f}, target >= 0.45). "
            "Mix short punches with longer sentences — AI prose tends toward same-length sentences."
        )

    em_dashes = text.count("—") + text.count("–")
    if em_dashes and em_dashes * 1000 / scale > (1.5 if is_zh else 3):
        warnings.append(
            f"Em dash overused ({em_dashes} occurrences). Rewrite as separate sentences or commas."
        )

    if is_zh:
        conj_hits = sum(text.count(c) for c in ZH_CONJUNCTIONS)
        if han_count >= 300 and conj_hits * 1000 / han_count > 7:
            warnings.append(
                f"Conjunction density high ({conj_hits * 1000 // han_count}/1000 chars: "
                f"{'、'.join(ZH_CONJUNCTIONS)}). Chinese clauses should connect through word "
                "order and logic, not connective words — cut about half."
            )
        pivots = find_matches(text, ZH_PIVOT_PATTERNS)
    else:
        transitions = sum(
            len(re.findall(r"\b" + re.escape(t) + r"\b", text, re.I)) for t in EN_TRANSITIONS
        )
        if word_count >= 200 and transitions * 1000 / word_count > 8:
            warnings.append(
                f"Transition-word density high ({transitions * 1000 // word_count}/1000 words: "
                "however/moreover/furthermore/etc). Cut half and let sentences connect on their own."
            )
        pivots = find_matches(text, EN_PIVOT_PATTERNS)

    if pivots:
        sample = "; ".join(pivots[:3])
        warnings.append(
            f"Reversal/pivot rhetoric found ({len(pivots)}x), e.g. \"{sample}\". "
            "State the point directly instead of setting up a fake contrast to knock down."
        )

    banned_hits = [p for p in BANNED_PHRASES if p in text.lower()]
    if banned_hits:
        warnings.append(f"Banned AI-flavored phrases found: {', '.join(banned_hits)}.")

    sentence_end = re.compile(r"[。！？]") if is_zh else re.compile(r"[.!?]")
    paras = paragraphs(text)
    ratio = one_sentence_ratio(paras, sentence_end)
    if ratio is not None and ratio >= 0.75:
        warnings.append(
            f"{ratio:.0%} of paragraphs are single-sentence. Staccato rhythm reads as "
            "AI-generated — let some paragraphs breathe."
        )

    repeats = repeated_openers(paras)
    if repeats:
        details = ", ".join(f"'{o}' x{c}" for o, c in repeats)
        warnings.append(f"Repeated paragraph openers: {details}. Vary how paragraphs start.")

    unit = "Chinese characters" if is_zh else "words"
    print(f"{'Chinese' if is_zh else 'English'} draft — {scale} {unit}, {len(paras)} paragraphs, {len(lengths)} sentences.")

    if warnings:
        print("\nFlags (advisory — use judgment, don't chase a mechanical zero):")
        for item in warnings:
            print(f"- {item}")
        return 1

    print("\nNo flags raised by this checker.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
