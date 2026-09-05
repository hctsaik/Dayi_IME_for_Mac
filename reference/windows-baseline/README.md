# myDayi_IME

Dayi2 Rime/Weasel user settings, curated common-word dictionaries, and
reproducible article-level regression tests.

## Contents

- Root YAML/dictionary files are the deployable Rime user settings.
- `build_dayi2_single_char_weights.py` builds character weights from the
  Taiwan Sinica, TBCL, MOE, and Rime Essay sources in `lexicon_sources/`.
  Each corpus word contributes its frequency to every Han character it
  contains, measuring character occurrence frequency.
- `lua/` contains the active candidate filter.
- `test/article_regression.py` tests automatic Dayi output against the pinned
  Traditional Chinese Wikipedia article `臺灣`.

## Rebuild settings

```powershell
python build_common_words_table.py
python build_dayi2_single_char_weights.py
```

Copy the resulting YAML files and `lua/` into `%APPDATA%\Rime`, then deploy
the schema with the included `deploy_to_rime.ps1` workflow.

The Sinica word-frequency snapshot is a local personal-use input and is
intentionally not redistributed. Place `sinica_words.json` in
`lexicon_sources/` before rebuilding the character table; the checked-in
generated `dayi2.dict.yaml` remains usable without it.

## Article regression

```powershell
python test\article_regression.py --show-failures 0
```

The test uses continuous Dayi typing by default and isolates the live userdb.
See [test/ARTICLE_REGRESSION.md](test/ARTICLE_REGRESSION.md) for the pinned
Wikipedia revision, attribution, diagnostic spaced-code mode, and KPI details.
