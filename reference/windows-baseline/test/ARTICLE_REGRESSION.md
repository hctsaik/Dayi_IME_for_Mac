# Article-level Dayi regression test

`article_regression.py` uses the Traditional Chinese Wikipedia article
[`Taiwan article`](https://zh.wikipedia.org/wiki/%E8%87%BA%E7%81%A3) as a realistic corpus.
The test is pinned to revision `93857310` (`2026-08-12T01:01:32Z`) so an edit
to Wikipedia cannot silently change the baseline.  The article text is fetched
at runtime with the `zh-tw` variant; it is not copied into the repository.
Wikipedia content is available under the [Wikimedia Terms of Use](https://foundation.wikimedia.org/wiki/Policy:Terms_of_Use).

Run a quick smoke test:

```powershell
python test\article_regression.py --max-cases 200 --show-failures 30
```

The runner copies the active Rime YAML, build, and Lua files into a temporary
directory and uses the installed `rime.dll` through its C API. It types each
derived Dayi code sequence continuously (without inserting a confirming space
between every character), confirms the final candidate, commits the temporary
composition, and compares the resulting text with the article text. `top1` is
the percentage of cases whose automatic result exactly matches the article case.

Use `--spaced-codes` only when explicitly testing the less contextual workflow
where every character code is confirmed before the next code is entered. That
mode is useful diagnostically, but it should not be used as the main KPI.

By default the learned `common_words.userdb` is excluded.  This gives a stable
static-dictionary baseline and never races Weasel's locked LevelDB files.  To
measure the current learned dictionary as well, request a best-effort copy:

```powershell
python test\article_regression.py --include-userdb --max-cases 200
```

Locked userdb metadata is skipped; the command remains read-only with respect
to the live Rime directory.  Once a baseline is accepted, make the test fail
below a chosen floor with `--min-top1`, for example:

```powershell
python test\article_regression.py --min-top1 0.50
```

The corpus intentionally includes both multi-character phrases and individual
characters.  A failure is evidence for improving dictionary/ranking behavior
globally; add a targeted rule only when the failure has a general rationale.

The current static baseline in continuous mode is `top1=85.871%`, with
`phrase_top1=96.338%` and `character_top1=76.934%` over the pinned article.
The previous `54.330% / 39.658% / 66.856%` figures were the diagnostic
spaced-code mode.  After correcting the input simulation, the single-character
frequency blend was recalibrated toward the Taiwan Sinica corpus, then the
loader was corrected to distribute each multi-character corpus word's
frequency across its Han characters. The latter change raised the character
KPI by another 9.484 percentage points without changing the phrase KPI.
