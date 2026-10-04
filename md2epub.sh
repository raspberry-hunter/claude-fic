#!/usr/bin/env bash
#
# md2epub.sh — convert Obsidian-flavoured markdown into a clean EPUB via pandoc.
#
# Handles the Obsidian-isms pandoc doesn't know about: wikilinks, embeds,
# callouts, ==highlights==, %%comments%%, ^block-ids, and per-file frontmatter.
#
#   ./md2epub.sh --init                       # write starter metadata.yaml + epub.css
#   ./md2epub.sh -o book.epub Manuscript/     # convert a folder of scene notes
#   ./md2epub.sh -o book.epub 01.md 02.md     # or an explicit, ordered file list
#
# Requires: pandoc 2.x or 3.x, perl, bash.

set -euo pipefail

# ---------------------------------------------------------------- defaults --

OUT="book.epub"
METADATA=""
COVER=""
CSS=""
VAULT=""
SPLIT_LEVEL=1
TOC_DEPTH=2
TITLE_FROM_FILENAME=0
TITLE_FROM_FRONTMATTER=0
TITLE=""
TITLE_FIELD=""
DATE_FIELD="date"
STRIP_TAGS=0
DROP_HEADINGS=""
KEEP_TEMP=0
ORDER_FILE=""
INPUTS=()

usage() {
  sed -n '3,14p' "$0" | sed 's/^# \{0,1\}//'
  cat <<'EOF'

Options:
  -o, --output FILE        Output epub path            (default: book.epub)
  -m, --metadata FILE      YAML metadata file          (default: ./metadata.yaml if present)
  -c, --cover FILE         Cover image (jpg/png)
  -s, --css FILE           Stylesheet                  (default: ./epub.css if present)
      --vault DIR          Vault root, for resolving ![[attachments]]
      --order FILE         Text file listing input files, one per line, in order
      --split-level N      Heading level that starts a new epub file (default: 1)
      --toc-depth N        Depth of the generated table of contents (default: 2)
      --title-from-filename  Prepend an H1 made from each file's name
      --title-from-frontmatter  Use each file's frontmatter title: as its H1,
                           when the body does not already open with one
      --date-field NAME    Frontmatter field to print as a dateline under each
                           chapter title (default: date; skipped where absent)
      --title TEXT         Book title, overriding the one in the metadata file
      --title-field NAME   Take the book title from this frontmatter field, e.g.
                           series. Used only when --title is not given
      --strip-tags         Remove inline #tags from the prose
      --drop-headings RE   Delete heading lines whose text matches perl regex RE
      --keep-temp          Leave the intermediate .md in place for inspection
      --init               Write starter metadata.yaml and epub.css, then exit
  -h, --help               Show this message
EOF
}

# ------------------------------------------------------------------- args ---

while [[ $# -gt 0 ]]; do
  case "$1" in
    -o|--output)            OUT="$2"; shift 2 ;;
    -m|--metadata)          METADATA="$2"; shift 2 ;;
    -c|--cover)             COVER="$2"; shift 2 ;;
    -s|--css)               CSS="$2"; shift 2 ;;
    --vault)                VAULT="$2"; shift 2 ;;
    --order)                ORDER_FILE="$2"; shift 2 ;;
    --split-level)          SPLIT_LEVEL="$2"; shift 2 ;;
    --toc-depth)            TOC_DEPTH="$2"; shift 2 ;;
    --title-from-filename)  TITLE_FROM_FILENAME=1; shift ;;
    --title-from-frontmatter) TITLE_FROM_FRONTMATTER=1; shift ;;
    --date-field)           DATE_FIELD="$2"; shift 2 ;;
    --title)                TITLE="$2"; shift 2 ;;
    --title-field)          TITLE_FIELD="$2"; shift 2 ;;
    --strip-tags)           STRIP_TAGS=1; shift ;;
    --drop-headings)        DROP_HEADINGS="$2"; shift 2 ;;
    --keep-temp)            KEEP_TEMP=1; shift ;;
    --init)                 INIT=1; shift ;;
    -h|--help)              usage; exit 0 ;;
    -*)                     echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
    *)                      INPUTS+=("$1"); shift ;;
  esac
done

# ------------------------------------------------------------------- init ---

if [[ -n "${INIT:-}" ]]; then
  if [[ -e metadata.yaml ]]; then
    echo "metadata.yaml already exists, leaving it alone."
  else
    cat > metadata.yaml <<'EOF'
---
title:
  - type: main
    text: To the Sea My Heart Is Wed
creator:
  - role: author
    text: Your Name
language: en-GB
publisher:
rights: © 2026 Your Name. All rights reserved.
date: 2026
description: |
  A one-paragraph blurb. Shows up in some reading apps.
...
EOF
    echo "Wrote metadata.yaml"
  fi

  if [[ -e epub.css ]]; then
    echo "epub.css already exists, leaving it alone."
  else
    cat > epub.css <<'EOF'
/* Minimal prose-first epub styling. Readers override a lot of this; keep it lean. */

body {
  font-family: serif;
  line-height: 1.5;
  margin: 0 5%;
  text-align: left;       /* justified text + no hyphenation looks terrible on e-ink */
  widows: 2;
  orphans: 2;
}

h1, h2, h3 {
  font-weight: normal;
  line-height: 1.2;
  text-align: left;
  page-break-after: avoid;
  break-after: avoid;
}

h1 {                       /* chapter openers */
  font-size: 1.6em;
  margin: 2em 0 1.5em 0;
  page-break-before: always;
  break-before: page;
}

h2 { font-size: 1.2em; margin: 1.5em 0 0.75em 0; }

p {
  margin: 0;
  text-indent: 1.25em;
}

/* No indent on the first paragraph of a section or after a scene break. */
h1 + p, h2 + p, h3 + p, hr + p, blockquote + p {
  text-indent: 0;
}

/* Scene break: markdown *** becomes <hr>. Render it as a centred ornament. */
hr {
  border: none;
  margin: 1.5em 0;
  text-align: center;
}
hr::after {
  content: "\00A0\00A0\2042\00A0\00A0";   /* asterism */
  color: inherit;
}

blockquote {
  margin: 1em 2em;
  font-style: italic;
}

/* Obsidian callouts flattened to blockquotes keep their bolded label. */
blockquote p:first-child strong { font-style: normal; }

mark { background: none; font-style: italic; }   /* ==highlights== */

img { max-width: 100%; height: auto; }
EOF
    echo "Wrote epub.css"
  fi
  exit 0
fi

# --------------------------------------------------------------- validate ---

command -v pandoc >/dev/null || { echo "pandoc not found on PATH." >&2; exit 1; }

# An .md output name is nearly always a slipped flag. The file would be a real
# epub either way, and dropping one into a vault gets it indexed as a note.
case "$OUT" in
  *.md) echo "Refusing to write an epub to '$OUT' -- that is a markdown name." >&2
        echo "Did you mean: -o ${OUT%.md}.epub" >&2
        exit 1 ;;
esac
command -v perl   >/dev/null || { echo "perl not found on PATH." >&2; exit 1; }

[[ -z "$METADATA" && -f metadata.yaml ]] && METADATA="metadata.yaml"
[[ -z "$CSS"      && -f epub.css      ]] && CSS="epub.css"

# ------------------------------------------------- collect + order sources ---

FILES=()

if [[ -n "$ORDER_FILE" ]]; then
  [[ -f "$ORDER_FILE" ]] || { echo "Order file not found: $ORDER_FILE" >&2; exit 1; }
  while IFS= read -r line; do
    line="${line%%$'\r'}"                       # tolerate CRLF from Windows
    [[ -z "$line" || "$line" == \#* ]] && continue
    FILES+=("$line")
  done < "$ORDER_FILE"
elif [[ ${#INPUTS[@]} -eq 1 && -d "${INPUTS[0]}" ]]; then
  # A file joins the book by carrying a number, and that number fixes its place:
  # 07-Compliance.md, EXTRA-07-Compliance-Feb55.md and "07 Compliance.md" all
  # sort as seven. It is the FIRST number in the name that orders things --
  # anything later is a date or a draft mark (-Feb55, -v2, -b) and means nothing
  # to the sequence. Files carrying no number at all -- Index.md, HANDOFF notes
  # -- are scaffolding and stay out, as does any subfolder: FirstDraft/ is not
  # chapter fifteen.
  SKIPPED=()
  while IFS= read -r f; do
    b="$(basename "$f")"
    if [[ "$b" =~ [0-9] ]]; then
      FILES+=("$f")
    else
      SKIPPED+=("$b")
    fi
  done < <(
    find "${INPUTS[0]}" -maxdepth 1 -type f -name '*.md' | perl -e '
      my @rows;
      while (<STDIN>) {
        chomp;
        my ($b) = m{([^/\\]+)$};
        $b = $_ unless defined $b;
        # -1 for the unnumbered, so they sort to the front and the shell can
        # name them in the skip report rather than dropping them in silence.
        my $n = ($b =~ /(\d+)/) ? $1 + 0 : -1;
        push @rows, [ $n, lc($b), $_ ];
      }
      print "$_->[2]\n"
        for sort { $a->[0] <=> $b->[0] or $a->[1] cmp $b->[1] } @rows;
    '
  )
  if [[ ${#SKIPPED[@]} -gt 0 ]]; then
    echo "Skipped ${#SKIPPED[@]} unnumbered file(s) in ${INPUTS[0]}:"
    printf '  %s\n' "${SKIPPED[@]}"
  fi
elif [[ ${#INPUTS[@]} -gt 0 ]]; then
  FILES=("${INPUTS[@]}")
else
  echo "No input files given." >&2; usage >&2; exit 1
fi

if [[ ${#FILES[@]} -eq 0 ]]; then
  echo "No markdown files to convert." >&2
  if [[ ${#INPUTS[@]} -eq 1 && -d "${INPUTS[0]}" ]]; then
    echo "In a folder, a file joins the book by having a number in its name:" >&2
    echo "  03-Chapter.md, EXTRA-03-Chapter-Sep54.md, \"03 Chapter.md\"" >&2
    echo "Pass the files explicitly, or use --order, to include unnumbered ones." >&2
  fi
  exit 1
fi

for f in "${FILES[@]}"; do
  [[ -f "$f" ]] || { echo "Missing input file: $f" >&2; exit 1; }
done

echo "Found ${#FILES[@]} source file(s)."

# --------------------------------------------------------- concatenate ------

TMPDIR_="$(mktemp -d)"
COMBINED="$TMPDIR_/combined.md"
: > "$COMBINED"

# Per-file preprocessor. It has to read each file's frontmatter before it can
# strip it, so it lives in a script rather than an inline one-liner.
#
# Frontmatter is handled here, per file, deliberately: run over the concatenated
# text instead, no regex can tell a frontmatter fence from a "---" scene break,
# and it will cheerfully delete every other scene as though it were metadata.
PREP="$TMPDIR_/prep.pl"
cat > "$PREP" <<'PERL'
use strict;
use warnings;

local $/;
my $doc = <STDIN>;

my $mode       = $ENV{HEADING_MODE}   // '';   # '', 'filename', 'frontmatter'
my $date_field = $ENV{DATE_FIELD}     // '';
my $fallback   = $ENV{FALLBACK_TITLE} // '';

# --- split off this file's own leading YAML frontmatter ---------------------
my $yaml = '';
if ($doc =~ s/\A(?:\xef\xbb\xbf)?---[ \t]*\r?\n(.*?)\r?\n(?:---|\.\.\.)[ \t]*(?:\r?\n|\z)//s) {
  $yaml = $1;
}
$doc =~ s/\A[ \t]*\r?\n//;   # close the gap the frontmatter left behind

# Flat scalar lookup. Enough for "title: Baseline" and "date: March 1964"; a
# folded or list value is not a chapter heading and is left well alone.
sub field {
  my ($name) = @_;
  return '' if $name eq '';
  return '' unless $yaml =~ /^\Q$name\E:[ \t]*(\S.*)$/m;
  my $v = $1;
  $v =~ s/\s+$//;
  # A block scalar ("note: >", "title: |-") keeps its value on the lines below,
  # not this one. Report it absent rather than printing the indicator itself.
  return '' if $v =~ /\A[>|][+-]?[0-9]*\z/;
  $v =~ s/\A"(.*)"\z/$1/ or $v =~ s/\A'(.*)'\z/$1/;
  return $v;
}

# Probe mode: report one field and stop. Same parser as the rest, so the book
# title sees exactly what a dateline would have seen.
if (($ENV{PRINT_FIELD} // '') ne '') { print field($ENV{PRINT_FIELD}); exit 0; }

my $title = field('title');
my $date  = field($date_field);

# --- chapter heading --------------------------------------------------------
my $has_h1 = ($doc =~ /\A\#[ \t]+\S/);

if ($mode eq 'filename') {
  $doc = "# $fallback\n\n" . $doc if $fallback ne '';
  $has_h1 = 1 if $fallback ne '';
}
elsif ($mode eq 'frontmatter' && !$has_h1) {
  # Only when the body has none of its own, so a file carrying both a title:
  # and a "# Title" does not end up printing the thing twice.
  my $h = $title ne '' ? $title : $fallback;
  if ($h ne '') { $doc = "# $h\n\n" . $doc; $has_h1 = 1; }
}

# --- dateline ---------------------------------------------------------------
if ($date ne '' && $has_h1) {
  my $esc = $date;
  $esc =~ s/&/&amp;/g;
  $esc =~ s/</&lt;/g;
  $esc =~ s/>/&gt;/g;
  my $line = qq{\n<p class="chapter-date">$esc</p>\n};
  $doc =~ s/\A(\#[ \t]+[^\n]*\n)/$1$line/;
}

print $doc;
PERL

HEADING_MODE=""
[[ $TITLE_FROM_FILENAME    -eq 1 ]] && HEADING_MODE="filename"
[[ $TITLE_FROM_FRONTMATTER -eq 1 ]] && HEADING_MODE="frontmatter"

for f in "${FILES[@]}"; do
  base="$(basename "$f" .md)"
  # Strip a leading numeric sort prefix: "03 - Chapter Three" -> "Chapter Three"
  fallback="$(printf '%s' "$base" | perl -pe 's/^\s*\d+[\s._-]+//')"

  HEADING_MODE="$HEADING_MODE" DATE_FIELD="$DATE_FIELD" FALLBACK_TITLE="$fallback" \
    perl "$PREP" < "$f" >> "$COMBINED"
  printf '\n\n' >> "$COMBINED"
done

# ----------------------------------------------------------- book title -----

# A collection usually knows its own name: every scene in it carries the same
# series: line. Take the first one that answers; an outright --title wins.
if [[ -z "$TITLE" && -n "$TITLE_FIELD" ]]; then
  for f in "${FILES[@]}"; do
    probe="$(PRINT_FIELD="$TITLE_FIELD" perl "$PREP" < "$f")"
    if [[ -n "$probe" ]]; then
      TITLE="$probe"
      break
    fi
  done
  if [[ -z "$TITLE" ]]; then
    echo "Warning: no '$TITLE_FIELD:' in any source file; keeping the metadata title." >&2
  fi
fi
[[ -n "$TITLE" ]] && echo "Title: $TITLE"

# ------------------------------------------------- Obsidian -> pandoc md ----

CLEANED="$TMPDIR_/cleaned.md"
VAULT_ARG="$VAULT" STRIP_TAGS_ARG="$STRIP_TAGS" DROP_HEADINGS_ARG="$DROP_HEADINGS" \
perl -0777 -pe '
  my $vault = $ENV{VAULT_ARG} // "";

  # --- per-file YAML frontmatter -------------------------------------------
  # Handled per file at concatenation time, deliberately. A regex run over the
  # combined text cannot tell a frontmatter fence from a "---" scene break, and
  # will happily delete every other scene as though it were metadata.

  # --- comments -------------------------------------------------------------
  s/%%.*?%%//gs;

  # --- embeds: ![[image.png|400]] -> ![](image.png) -------------------------
  s{!\[\[([^\]\|\#]+?)(?:\|[^\]]*)?\]\]}{
    my $t = $1;
    if ($t =~ /\.(png|jpe?g|gif|svg|webp|bmp)$/i) {
      my $p = $t;
      if ($vault ne "" && $t !~ m{/}) { $p = "$vault/$t"; }
      "![]($p)";
    } else {
      # Note transclusion cannot be resolved textually. Leave a visible marker.
      "<!-- UNRESOLVED EMBED: $t -->";
    }
  }ge;

  # --- wikilinks ------------------------------------------------------------
  s/\[\[[^\]\|]*?\|([^\]]+?)\]\]/$1/g;   # [[Target|Display]]  -> Display
  s/\[\[#([^\]\|]+?)\]\]/$1/g;           # [[#Heading]]        -> Heading
  s/\[\[([^\]\|\#]+?)#[^\]\|]*?\]\]/$1/g;# [[Target#Heading]]  -> Target
  s/\[\[([^\]\|]+?)\]\]/$1/g;            # [[Target]]          -> Target

  # --- callouts: "> [!warning] Title" -> "> **Title**" ----------------------
  s{^(\s*>\s*)\[!([A-Za-z-]+)\][+-]?[ \t]*(.*)$}{
    my ($pre, $type, $title) = ($1, $2, $3);
    $title =~ s/\s+$//;
    if ($title eq "") { $title = ucfirst(lc $type); }
    "$pre**$title**";
  }gme;

  # --- highlights and block ids --------------------------------------------
  s/==(?=\S)(.+?)(?<=\S)==/<mark>$1<\/mark>/gs;
  s/[ \t]*\^[A-Za-z0-9-]+[ \t]*$//gm;

  # --- marker headings (optional) ------------------------------------------
  # Merged manuscripts often carry a per-note ID heading ("## 04-EXTRA-Foo")
  # that is scaffolding, not a chapter title. Drop those before pandoc splits
  # on headings, or each one strands itself at the tail of the chapter before.
  if (($ENV{DROP_HEADINGS_ARG} // "") ne "") {
    my $re = qr/$ENV{DROP_HEADINGS_ARG}/;
    s{^(\#{1,6})[ \t]+([^\n]*?)[ \t]*\n}{ $2 =~ $re ? "" : "$1 $2\n" }gme;
  }

  # --- inline tags (optional) ----------------------------------------------
  if ($ENV{STRIP_TAGS_ARG}) { s/(?<![\w&])#[A-Za-z][\w\/-]*//g; }

  # --- tidy -----------------------------------------------------------------
  s/\n{3,}/\n\n/g;
' "$COMBINED" > "$CLEANED"

# Report anything that could not be resolved rather than failing silently.
if grep -q 'UNRESOLVED EMBED' "$CLEANED"; then
  echo "Warning: note-to-note embeds could not be inlined:" >&2
  grep -o 'UNRESOLVED EMBED: [^-]*' "$CLEANED" | sort -u | sed 's/^/  /' >&2
fi

# ------------------------------------------------------------ run pandoc ----

# --split-level replaced --epub-chapter-level in pandoc 3.0.
PANDOC_MAJOR="$(pandoc --version | head -1 | perl -ne 'print $1 if /(\d+)\./')"
if [[ "${PANDOC_MAJOR:-2}" -ge 3 ]]; then
  SPLIT_FLAG="--split-level=$SPLIT_LEVEL"
else
  SPLIT_FLAG="--epub-chapter-level=$SPLIT_LEVEL"
fi

ARGS=(
  --from=markdown+smart-yaml_metadata_block
  --to=epub3
  --toc
  --toc-depth="$TOC_DEPTH"
  --top-level-division=chapter
  "$SPLIT_FLAG"
  --output="$OUT"
)

[[ -n "$METADATA" ]] && ARGS+=(--metadata-file="$METADATA")
[[ -n "$TITLE"    ]] && ARGS+=(--metadata "title=$TITLE")
[[ -n "$COVER"    ]] && ARGS+=(--epub-cover-image="$COVER")
[[ -n "$CSS"      ]] && ARGS+=(--css="$CSS")
[[ -n "$VAULT"    ]] && ARGS+=(--resource-path=".:$VAULT")

pandoc "${ARGS[@]}" "$CLEANED"

echo "Wrote $OUT"

if [[ $KEEP_TEMP -eq 1 ]]; then
  cp "$CLEANED" "./$(basename "${OUT%.epub}").merged.md"
  echo "Kept intermediate markdown at ./$(basename "${OUT%.epub}").merged.md"
fi

rm -rf "$TMPDIR_"
