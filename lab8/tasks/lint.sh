#!/bin/bash
set -uo pipefail
set +e

FAILURE=false

echo "safety (failure is tolerated)"
FILE=requirements/prod.txt
if [ -f "$FILE" ]; then
    # We're in the main repo
    python -m safety check -r requirements/prod.txt -r requirements/dev.txt
else
    # We're in the labs repo
    python -m safety check -r ../requirements/prod.txt -r ../requirements/dev.txt
fi

echo "FAILURE="$FAILURE

echo "pylint"
python -m pylint text_recognizer training || FAILURE=true

echo "FAILURE="$FAILURE

echo "pycodestyle"
python -m pycodestyle text_recognizer training || FAILURE=true

echo "FAILURE="$FAILURE

echo "pydocstyle"
python -m pydocstyle text_recognizer training || FAILURE=true

echo "FAILURE="$FAILURE

echo "mypy"
python -m mypy text_recognizer training || FAILURE=true

echo "FAILURE="$FAILURE

echo "bandit"
python -m bandit -ll -r {text_recognizer,training} || FAILURE=true

echo "FAILURE="$FAILURE

echo "shellcheck"
find . -name "*.sh" -print0 | xargs -0 shellcheck || FAILURE=true

echo "FAILURE="$FAILURE

if [ "$FAILURE" = true ]; then
  echo "Linting failed"
  exit 1
fi
echo "Linting passed"
exit 0
