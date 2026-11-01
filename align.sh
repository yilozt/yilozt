#!/usr/bin/env bash

IFS=$'\n'

function split_readme() {
  local title
  local content

  IFS=$'\n'
  for l in $(cat -E readme.md); do
    local line=$(echo "$l" | sed 's/\$$//')

    if echo "$line" | grep '^[a-zA-Z]' >/dev/null; then
      content="$content$line\n"
    elif [[ "$content" != "" ]]; then
      local aligned=$(echo -e "$content" | column -s= -o' = ' -L -t | sed 's/^ .*//')
      echo -e "$aligned"
      content=''
      echo "$line"
    else
      echo "$line"
    fi
  done
}

sed -ri 's/\s*=\s/=/' readme.md
split_readme >a
mv a readme.md
# mv a readme.md
