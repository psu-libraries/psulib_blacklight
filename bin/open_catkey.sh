#!/bin/bash

# This script is distributed with psulib_blacklight, 
# but will be easier to use if you add an alias for it (.zshrc file), 
# that way you can execute it from any directory on your machine.

# Sample alias
# alias catkey='bash ~/Developer/psulib_blacklight/bin/open_catkey.sh'

# Supports macOS and Linux systems

catalog_url="https://catalog.libraries.psu.edu/catalog/"

help() {
  echo ""
  echo "open-catkey.sh CATKEY# OPTION"
  echo ""
  echo "Options:"
  echo "  <leave blank> - go to library catalog website."
  echo "  json - navigate to raw.json page."
  echo "  djson - download the json to the user's current directory."
  echo "  marc - download marc file to the user's current directory."
  echo "  view - open marc view on library catalog website."
  echo "  help - view this text."
  echo "  options - view this text."
  echo ""
  echo "The \`help\` and \`options\` strings can be used instead of \`CATKEY#\` as well"
  echo ""

  exit 0
}

if [ -z $1 ]; then
  echo "Missing key!"; help; exit 1;
elif [[ $1 == "help" || $1 == "options" ]]; then
  help
else
  key=$1
fi

end_substring=""

case $2 in
  # Open the json view in the user's browser
  "json")
    end_substring="/raw.json"
    ;;

  # Download the JSON file to the user's current directory
  "djson")
    wget -O $key.json $catalog_url$key/raw.json; exit 0;
    ;;

  # Download the marc file to the user's current directory
  "marc")
    wget -O $key.mrc $catalog_url$key.marc; exit 0;
    ;;

  # Open the MARC viewer in the user's browser
  "view")
    end_substring="/marc_view"
    ;;
  
  # Show the help menu
  "help"|"options")
    help
    ;;
esac

main() {
  system=$(uname)
  final_url=$catalog_url$key$end_substring
  
  if [[ $system == "Darwin" ]]; then
    open $final_url
  elif [[ $system == "Linux" ]]; then
    xdg-open $final_url
  fi
}

main
