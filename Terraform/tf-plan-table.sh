#!/bin/bash

# Define table header
header="Resource\tAction\tDetails"

# Print the header
echo -e "$header"
echo -e "-------\t-------\t-------"

# Loop through each line containing resource actions
while IFS= read -r line; do
  # Check if line starts with "#" (comment) or is empty
  if [[ $line =~ ^# ]] || [[ -z "$line" ]]; then
    continue
  fi

  # Extract resource name and action
  resource=$(echo "$line" | awk '{print $2}')
  action=$(echo "$line" | cut -d ' ' -f1 | cut -c 2-)

  # Extract details (handle different action symbols)
  if [[ $action == "~" ]]; then
    details=$(echo "$line" | grep -Eo "\([^)]+\)" | head -n 1)
  elif [[ $action == "-/+" ]]; then
    details="destroy -> create"
  else
    details=$(echo "$line" | grep -Eo "\([^)]+\)" | grep -v "^id")
  fi

  # Print table row with formatted details
  details=$(echo "$details" | sed 's/^\t//')  # Remove leading tab
  printf "%s\t%s\t%s\n" "$resource" "$action" "$details"
done < <(grep 'resource' <<< "$1")  # Pass input string as argument

# Example usage:
# ./resource_actions.sh "$(terraform plan)"
