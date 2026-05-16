#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

export PYTHONIOENCODING=utf-8
export PYTHONUTF8=1
export LC_ALL=C.UTF-8
export LANG=C.UTF-8

PYTHON="${PYTHON:-}"
if [ -n "$PYTHON" ] && { command -v "$PYTHON" >/dev/null 2>&1 || [ -x "$PYTHON" ]; }; then
	:
else
	PYTHON=
fi
if [ -z "$PYTHON" ]; then
	if command -v python >/dev/null 2>&1; then
		PYTHON=python
	elif command -v py >/dev/null 2>&1; then
		PYTHON="py -3"
	else
		for base in /c /cygdrive/c; do
			shopt -s nullglob
			for candidate in "$base"/Users/*/AppData/Local/Programs/Python/Python*/python.exe; do
				PYTHON="$candidate"
				break 2
			done
			shopt -u nullglob
		done
		if [ -z "$PYTHON" ] && command -v cmd >/dev/null 2>&1; then
			winpath=$(cmd //c "where python" 2>/dev/null | head -n1 | tr -d '\r')
			if [ -n "$winpath" ]; then
				PYTHON=$(echo "$winpath" | sed 's|\\|/|g' | sed 's|^\([A-Za-z]\):|/\1|')
			fi
		fi
		if [ -z "$PYTHON" ] && [ -x /c/Windows/py.exe ]; then
			PYTHON="py -3"
		fi
	fi
fi
if [ -z "$PYTHON" ]; then
	echo "Python not found. Set PYTHON=/path/to/python.exe" >&2
	exit 1
fi
if [ "$PYTHON" != "py -3" ] && ! command -v "$PYTHON" >/dev/null 2>&1 && [ ! -x "$PYTHON" ]; then
	echo "Python not found: $PYTHON" >&2
	exit 1
fi

if [ ! -d assets/Xray-docs-next-main/docs/ru/config ]; then
	echo "Missing assets/Xray-docs-next-main. Run: make -f Makefile.windows assets/Xray-docs-next-main" >&2
	exit 1
fi

OUT="${1:-xray.schema.json}"
rm -f "$OUT"

grep -rI '' assets/Xray-docs-next-main/docs/ru/config/ \
	| cut -d: -f2- \
	| PYTHONUNBUFFERED=1 \
	$PYTHON scrape-docs.py -o "$OUT"

$PYTHON -c "import json, pathlib; p=pathlib.Path('$OUT'); json.load(p.open(encoding='utf-8')); print(f'OK: {p.name} ({p.stat().st_size} bytes)')"
