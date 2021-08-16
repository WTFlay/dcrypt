#!/bin/sh

set -e

usage() {
  printf "usage: %s [-e directory|-d file]\n" "$0"
}

while getopts ed name
do
  case $name in
    e) enc=1 ;;
    d) enc=0 ;;
    ?) usage; exit 1 ;;
  esac
done

if [ -z "$enc" ]; then
  printf "option -e or -d is required\n"
  usage
  exit 2
fi

shift $(($OPTIND - 1))
file="$1"

if [ -z "$file" ]; then
  printf "missing file argument\n"
  usage
  exit 3
fi

cipher=aes-256-cbc
iter=10000

if [ -d "$file" ] && [ "$enc" -eq 1 ]; then
  tar Jcf - "$file" | openssl "$cipher" -e -in - -out "${file%/}.enc" -iter "$iter" \
    && find "$file" -type f -exec shred -f {} \; \
    && rm -rf "$file"
elif [ -f "$file" ] && [ "$enc" -eq 0 ]; then
  openssl "$cipher" -d -in "$file" -iter "$iter" | tar Jxf - \
    && shred -f "$file" \
    && rm -f "$file"
else
  usage
  exit 4
fi
