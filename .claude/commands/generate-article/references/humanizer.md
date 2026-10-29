# Humanizer Pass (read after drafting, before the metrics check)

Adapted from the open-source humanizer skill, which is based on Wikipedia's "Signs of AI writing". It is tuned here for first-person blog posts in English and Chinese.

`scripts/check_prose.py` flags the tells a regex can find. This pass catches the ones it can't: staging, forced rhythm, inflated claims. Use it on both drafts.

## Why the tells exist

A language model writes whatever is most likely next, which is the choice that fits the widest range of readers. A person writes for one reader about one subject, so their choices are uneven and specific. Every pattern below is a form of that default choice. Two rules follow:

- Every sentence you keep must add something the reader doesn't already have.
- A tell counts in proportion to how rarely a careful writer would make it on purpose. §1 to §5 justify an edit on a single sighting. Patterns marked *weak alone* need company from other tells in the same passage.

## How to run it

1. **Mark the tells.** Read the whole draft once and mark every pattern below, strongest first. Look at paragraph shape too: a contrast split across two sentences, three parallel examples, or the same kind of closer after every section is the same tell at a larger scale.
2. **Rewrite.** State each point directly instead of patching flagged phrases one at a time. If a sentence stays awkward, rewrite the paragraph around its main point. Vary sentence length.
3. **Do not add facts.** Keep every supported claim. Never add a number, name, quote, error message, or personal incident that isn't in the source or from the user (see `references/material-check.md`). If a sentence wants a detail you don't have, write a simpler sentence. An opinion or reaction is fine where Encore's voice would have one; a factual claim is not.
4. **Audit the rewrite.** Ask what still sounds machine-made. Check that the rewrite didn't drop or invent a fact, number, or ranking. Then re-search for the tells that most often survive: §1 contrasts, §2 closers, §6 triads, §8 dashes, §19 bold labels.
5. **Re-run `check_prose.py`** on the result.

Leave code blocks, inline code, commands, paths, frontmatter, and link targets untouched. Keep a watched phrase when it sits inside a quotation, a title, a proper name, or a passage that discusses the phrase.

## A. Staging instead of stating (act on one sighting)

### 1. Not X but Y
**Watch for:** not X but Y; not just / not only / not merely X, but Y; it's not X, it's Y; X rather than Y; the same contrast split across two sentences ("This doesn't mean X. It means Y."); a clipped tail ("..., no guessing"). Chinese: 不是……而是……, 并非……而是……, 不仅……更……, 与其说……不如说……, 看似……其实……, 表面上……实际上……
**Problem:** The negative half names something nobody claimed, so the positive half sounds bigger. State the point. Keep a contrast only when the negative half corrects a belief the reader actually holds, or both halves carry information.
> Before: It's not just a downloader, it's a whole workflow.
> After: It downloads the video, strips the watermark, and writes the result next to the original.

### 2. One-line closers and dramatic fragments
**Watch for:** a one-sentence paragraph restating the one before; "That's the real win."; "That distinction matters."; "Let that sink in."; the same closer after several sections; a sentence after an example that names what it showed ("This shows the importance of..."); rows of fragments ("No config. No setup. No fuss."); ALL CAPS emphasis. Chinese: 这就是关键。 / 这才是重点。 / 仅此而已。 / 就这么简单。
**Problem:** The line asks the reader to pause on a claim instead of adding to it. Cut a closer that repeats. Keep one only when it adds a fact the example didn't show. Merge fragment rows into one sentence with a specific claim.

### 3. Sayings that sound deep
**Watch for:** the real question is, at its core, what really matters, fundamentally, the heart of the matter, X is the Y of Z, X becomes a trap, X is a mirror. Chinese: 本质上, 说到底, 归根结底, 真正的问题是, 核心在于
**Problem:** An ordinary point dressed as a hidden truth. Replace the saying with the specific claim.

### 4. Staged run-up before the point
**Watch for:** let's dive in, let's break this down, here's what you need to know, here's the thing, the thing is, honestly?, look, real talk, quick note. Chinese: 让我们来看看, 接下来我们, 说实话, 不得不说, 值得一提的是
**Problem:** The writer announces the point instead of making it. Delete the run-up. "Honestly" inside a casual sentence is fine; the tell is the standalone opener before a routine claim.

### 5. Arguing with no one
**Watch for:** this isn't about, I'm not saying, to be clear, don't get me wrong, you might think... but, a tempting approach would be, one might be tempted to.
**Problem:** The text rejects an objection or option that appears nowhere else. Remove it; if it holds a real claim, state the claim.

## B. Rhythm by rule

### 6. Forced triads
Ideas arrive in threes to sound complete: "innovation, inspiration, and insights", three parallel examples, three short facts then a lesson. Check that each item adds a distinct idea. Merge, develop the strongest one, or vary the structure. Keep three when there really are three.

### 7. Repeated sentence or paragraph openings
Several sentences or paragraphs in a row starting with the same word. Merge them, change the subject, or begin with the action. Deliberate repetition for rhythm is fine.

### 8. Dashes as the universal connector
**Rule:** No em dashes (—), en dashes (–), or ` -- ` in prose, in either language. Replace each with a period, comma, colon, or parentheses, or rewrite the sentence. Hyphens in compounds, code, paths, and URLs stay. Recent posts on this blog use none; keep it that way.

### 9. Stacked qualifiers *(weak alone)*
**Watch for:** could potentially, might arguably, to be fair, it's also possible, in some cases it may. Repeated editing piles on hedges until every claim sounds uncertain. Keep one only when the source supports the doubt. State opinions as opinions.

### 10. Hyphenated pairs after the noun *(weak alone)*
Keep `a high-quality report`; write `the report is high quality`. Always-hyphenated words (third-party, cross-functional) keep it everywhere.

### 11. Passive voice and missing subjects *(weak alone)*
Say who does what. "The results are preserved automatically" becomes "The tool saves the results."

## C. Inflation and borrowed authority

The fact underneath is usually fine. Keep it, drop the dressing.

### 12. Overused AI words
**Watch for:** actually, additionally, align with, crucial, deep dive, delve, enduring, enhance, garner, highlight (verb), interplay, intricate, key (adjective), landscape (abstract), meticulous, pivotal, quietly, robust, showcase, tapestry, testament, underscore (verb), valuable, vibrant, streamline, harness, foster, comprehensive, elevate, navigate (figurative), ecosystem (figurative). Chinese: 赋能, 打造, 助力, 深耕, 全方位, 无缝, 生态闭环, 极致, 颠覆
Keep technical uses (a "robust" statistical estimator, an actual software ecosystem).

### 13. Inflated significance
**Watch for:** stands as a testament, a pivotal moment, plays a key role, marks a shift, reflects a broader trend, evolving landscape, the future looks bright, exciting times ahead, a step in the right direction. Chinese: 具有重要意义, 开启了新篇章, 未来可期, 标志着, 引领
**Problem:** An ordinary detail is said to mark a change or promise a future. Keep the fact; drop the significance. End on the last concrete fact.

### 14. Vague connection
"associated with", "in connection with", "linked to". Name the actual relationship the source gives; if the source doesn't say, keep the vague wording rather than inventing one.

### 15. Shallow -ing riders
An -ing phrase bolted onto a simple fact to sound deeper: "..., highlighting its importance", "..., ensuring a seamless experience", "..., fostering collaboration". Keep the fact; cut the rider unless the source supports it.

### 16. Sales language
rich (figurative), profound, groundbreaking, renowned, breathtaking, stunning, diverse array, commitment to, nestled. State what the thing is.

### 17. Borrowed authority
"experts argue", "industry reports show", "many developers", "some critics". Name the source and what it said, or cut the claim.

### 18. Avoiding is, are, has
"serves as", "stands as", "functions as", "boasts", "features", "offers". Write *is*, *are*, *has*.

## D. Formatting by rule

### 19. Bold as decoration
No bold for emphasis, and no `- **Label:** text` lists where the label carries nothing. Turn labeled lists into prose. A genuine reference table or command list is fine.

### 20. Decorative headings
Headings in sentence case, `##` and `###` only (the TOC reads those). No emojis, no arrows, no horizontal rules between sections, no top-level `#` repeating the title. A heading should name what the section holds, not perform ("The decision, on one screen" becomes "How the six options compare").

### 21. Curly quotes *(weak alone)*
Use straight quotes in English prose.

## E. Leftovers from the chat and the draft

### 22. Chatbot residue
I hope this helps, Certainly!, Great question!, Would you like..., let me know, here is a... Remove the wrapper and keep the content. Chinese: 希望对你有帮助, 当然可以, 好的，以下是

### 23. Knowledge-limit disclaimers and guesses
"as of my last update", "details are limited", "likely grew up...". If the source doesn't say, say it doesn't, or cut the sentence. Never fill the gap with a plausible guess.

### 24. A heading repeated in the first sentence
A heading followed by a one-liner that restates it. Delete the line.

### 25. Writing about the document instead of the subject
"This article will cover...", "In this post we'll...", "the table below compares...", "generated from the README". Cut the self-description. Keep a source credit the reader can follow and any caveat that changes what they should do.

## Keep what makes it a person

Removing tells is half the job; the result must still sound like Encore. Keep:

- A specific, odd detail from the source (an exact error message, a real number, an unusual design choice).
- Mixed feelings and unresolved tension ("I like this, and something about it still bothers me").
- A real first-person choice he can explain, or a genuine aside or self-correction.
- Opinions stated as opinions. Don't flatten the voice into neutral, reference-style prose.

Don't invent any of these to seem human. Fabricated texture is the same failure as fabricated facts (see `references/material-check.md`).

## Chinese notes

The patterns are language-independent, but the surface forms differ. For the ZH draft, rewrite from the meaning rather than translating fixes from EN. Watch especially for 不是……而是……, stacked 的 chains, connective words (因此/此外/同时/而且) doing the job word order should do, and four-character idiom pileups (成语堆砌) used to sound weighty. No dashes in Chinese either: use commas or periods.
