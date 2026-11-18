#!/usr/bin/env bash
# Runs every tests/*.test.sh and reports a total. Exit code is non-zero if any file failed.
set -u
cd "$(dirname "$0")"
bad=0
for t in ./*.test.sh; do
  echo "${t#./}"
  bash "$t" || bad=$((bad + 1))
done
if ((bad)); then echo "$bad test file(s) failed"; exit 1; fi
echo "all test files passed"
