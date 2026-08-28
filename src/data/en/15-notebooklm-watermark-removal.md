---
title: "Removing the NotebookLM Watermark Without Wrecking the Slide"
date: 2026-08-28
tags: [AI, Python, Product]
excerpt: "NotebookLM's slide exports look great until you notice every page has its watermark burned into the corner, so I built a tool to remove it properly."
draft: false
---

NotebookLM had just generated a slide deck from a pile of research notes I'd fed it, and it looked genuinely good: clean layout, sensible structure, the kind of thing that would normally take an hour in Keynote. Then I looked at the bottom-right corner of every single page. `Gemini Notebook`. Small, gray, permanent. Fine on a first draft. Not fine on a deck I wanted to hand to someone outside my own head.

I own that content. NotebookLM generates it from my notes, and Google is explicit that it doesn't claim ownership over what the tool produces. So this wasn't a "how do I get around a paywall" problem, it was a "how do I clean up my own export" problem, closer to removing a placeholder logo from a design file than pirating anything.

My first move was the obvious one: draw a white box over it. That works for exactly one kind of slide, a flat white background. NotebookLM's slides use gradients, subtle textures, colored corners, sometimes a border rule running right through where the watermark sits. A solid box looks like a solid box on any of them. And the deck was thirty pages long. Opening each one in Preview, eyeballing the exact background color, and drawing a rectangle by hand thirty separate times isn't a fix, it's a second job. If I wanted this to actually look clean, at that scale, I needed something that understood what was behind the watermark and could rebuild it automatically, once, across the whole file.

![Before: a NotebookLM slide with the Gemini Notebook watermark in the bottom-right corner](https://raw.githubusercontent.com/encoreshao/nlm-unwatermark/main/docs/images/before.png)

![After: the watermark is gone and the background is healed, not just covered](https://raw.githubusercontent.com/encoreshao/nlm-unwatermark/main/docs/images/after.png)

## Detecting a watermark you're not allowed to hardcode

The naive version of "find the watermark" is: crop the bottom-right corner, look for dark pixels, done. That breaks the first time a slide has a dark photo or a colored panel in that corner, and now you're "detecting" real content and mangling it.

What actually worked was combining two weaker signals instead of relying on one strong one. First, a contrast pass against a locally-estimated background (a median blur, so it adapts per-region instead of assuming the whole corner is one color) picks out anything that stands out: text, icon, or a stray dark blob. Second, a template-match pass renders the actual watermark string at a range of plausible sizes and slides it across the search region, checking correlation against the real pixels. Neither one alone is reliable. A contrast blob could be page content. A template match with no supporting contrast could be a coincidental correlation on unrelated text. Requiring both cuts the false positives down to almost nothing.

There's a detail in there I didn't expect to need. The code has to check whether the slide background is light-with-dark-text or dark-with-light-text, sampled from a thin border ring around the search area, because the correlation sign flips depending on polarity. Skip that check and the matcher confidently finds the watermark's own photographic negative sitting somewhere it isn't.

And the part that made me genuinely glad I hadn't hardcoded a single string: my own exports all read `Gemini Notebook`, but partway through building this I ran across older exports still labeled "NotebookLM," Google's original name for the watermark before some internal rebrand. The detector matches both variants, current label first for priority, the legacy one kept around so older files still get cleaned. Had I hardcoded `Gemini Notebook` as the only string, every one of those older exports would've sailed straight through untouched.

## The bug that taught me what "remove" actually means

For PDFs specifically, there are two different ways to "remove" text, and only one of them is real. Overlaying a white rectangle on top of the text, even a perfectly color-matched one, leaves the original text object sitting in the PDF's content stream. Select-all in a PDF viewer, or run it through any text extractor, and the watermark is still there, just visually hidden. That's not removal, it's a sticker.

The actual fix uses PyMuPDF's redaction API: mark the watermark's text rectangle for redaction, apply it with `text=PDF_REDACT_TEXT_REMOVE`, and the text object is deleted from the underlying content stream. The vector background around it, gradients, shapes, whatever, is left completely untouched because redaction only removes what's inside the marked rectangle. It's the difference between painting over a whiteboard and actually erasing it.

The watermark's icon glyph isn't part of the text layer, though, so it survives redaction. That still needs the pixel-level detection-and-heal path, just scoped to a small zone next to where the text used to be.

The bug that actually cost me real time: after building the removal mask, I was intersecting it with only the high-contrast pixels from the detection pass, on the theory that this keeps the mask tight and avoids touching real content. It does, but a lot of these watermarks sit on a faint, semi-transparent pill-shaped chip behind the text, and that chip never crosses the contrast threshold. Erase just the glyph strokes and the chip's ghost stays behind, a soft rectangle where letters used to be, somehow more obvious than the watermark it replaced. The fix was almost insultingly simple once I saw it. Stop trying to be clever about which pixels inside the watermark's bounding box to touch, and just fill the whole box, then heal it as one region.

Healing itself uses a nearby clean patch from the same page rather than generic inpainting. It samples the border ring around candidate source patches, compares that ring against the destination's border ring, and picks whichever nearby tile blends in with the least visible seam, alpha-blending at the edges. Plain `cv2.inpaint` works, but it smears textured or dotted backgrounds into a blur. A real patch from three inches away keeps the grain.

The moment that actually mattered was running it against my own deck. I pointed the CLI at the thirty-page file, and instead of thirty rounds of Preview-and-eyeball, a progress bar ticked through every page in one pass. Thirty different backgrounds, thirty watermarks, no page needing a second look.

## What building it in a day changed

The whole thing came together in one sitting: detection, healing, PDF/PPTX/image handling, a standalone executable build, before/after images for the README, a handful of commits, no drawn-out project. What surprised me wasn't the CV part, which is straightforward once you frame it as "two weak detectors, combined." It was how much of the actual difficulty lived in restraint: not touching content near the watermark, not assuming one background polarity, not trusting a single hardcoded label, not confusing "invisible" with "gone."

I'd expected a watermark remover to be a cropping tool with extra steps. It turned out to be a small image-forensics problem wearing a CLI. The tool that came out the other side handles PDFs, PPTX, and raw image exports, batch-processes a whole folder, and ships as a single executable for people who don't want to touch Python. None of that changes the actual point of it: it exists because a genuinely good export had one flaw, and the flaw was fixable without becoming a bigger problem than the one it solved.

It's on GitHub at [github.com/encoreshao/nlm-unwatermark](https://github.com/encoreshao/nlm-unwatermark), MIT licensed. `pip install -r requirements.txt`, point it at a file or a whole folder, and it's done in less time than it takes to open the first slide in Preview.
