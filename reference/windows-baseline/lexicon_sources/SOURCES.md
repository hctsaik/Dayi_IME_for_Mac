# Sources for the generated Dayi2 common-word dictionary

These local copies make the 40,000-word build reproducible without relying on
whatever an upstream URL happens to contain later.

## Historical Taiwan frequency reference

- File: `85rest02.csv`
- Publisher: Ministry of Education, Taiwan
- Dataset: 85年常用語詞調查報告之各項統計表 — 詞頻總表
- URL: https://language.moe.gov.tw/001/Upload/files/SITE_CONTENT/M0001/85NEWS/download/85rest02.csv
- Dataset page: https://data.nat.gov.tw/dataset/45518
- License: Government Open Data License v1
- Downloaded SHA-256: `8ade7cd812e50ed9d0acc396f5b493d40014e00571b6cd424ae9d812bd1042de`

This older frequency table is retained as an audit reference.  The current
40,000-entry build instead uses the newer Taiwan balanced-corpus frequency
snapshot below as its main ranking source.

## Modern vocabulary supplement

- File: `essay.txt`
- Project: Rime Essay shared vocabulary and language model
- URL: https://github.com/rime/rime-essay
- Pinned source commit: `e9b1a374a6ea015fca5bdd04318924b4483ac35a`
- License: LGPL-3.0-or-later; copied license and authorship files are retained
  in this directory.

`build_common_words_40k.py` normalizes the Essay source through OpenCC's
Taiwan phrase conversion before selecting vocabulary. It never copies user
learning data into the static list.

The build also uses Jieba's MIT-licensed part-of-speech model only as a
quality gate for exact general-word entries; it is not used by the input
method at runtime.

## Taiwan proficiency reference

- File: `tbcl.csv`
- Publisher/source: Taiwan Benchmarks for the Chinese Language (TBCL), National
  Academy for Educational Research
- Official reference: https://coct.naer.edu.tw/TBCL/
- Reproducible parsed snapshot: https://github.com/ivankra/tocfl
- Downloaded SHA-256: `0778e1d648944b1e64cbc2b640f00e488fec5c4ed06101cd5e93cab29346ce22`

TBCL is used only as a positive Taiwan-language ranking signal.  It does not
override the reviewed core list, and variant rows are not guessed or expanded
automatically.

## Taiwan balanced-corpus frequency source (local personal use)

- File: `sinica_words.json`
- Corpus: Academia Sinica Balanced Corpus of Modern Chinese, parsed word
  frequencies and POS tags
- Dataset card: https://huggingface.co/datasets/zetavg/tw-sinica-corpus-word-frequency
- Original reference: https://elearning.ling.sinica.edu.tw/
- Downloaded SHA-256: `3a33290775b0993f180df27cc0610c328f9f1cefb7b3c11f747a6c62c566ad5f`
- Stated source condition: personal research use only

This source is used only for this user's local, personal IME configuration. It
must not be redistributed or packaged into an installer without separately
confirming the source's permission.
