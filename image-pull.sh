#!/bin/bash

PFX=img
cp Forum.db Forum.db1
sqlite3 Forum.db1 'select content from posts' | grep -Po '"http[^)"]*"' | grep -iE '(jpg|png|jpeg)' | sed -E 's/\\\//\//g' | tr -d '"' | while read i; do

  fullpath=$PFX/$(echo "$i" | sed -E 's/https?:\/\///g')
  path=$PFX/$(dirname "$i" | sed -E 's/https?:\/\///g')
  [[ -d "$path" ]] || mkdir -p "$path"

  if [[ $(grep -l "$i" success.txt failure.txt) ]]; then
    echo -n '.'
  elif [[ -e "$fullpath" ]] ; then
    echo -n '?'
    echo "$i" >> success.txt
  else
    timeout 8s wget "$i" -O "$fullpath" "$i"
    if [[ -s "$fullpath" ]]; then 
      echo "$i" >> success.txt
    else 
      echo "$i" >> failure.txt
    fi
  fi

done
