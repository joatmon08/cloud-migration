#!/bin/bash

input="pid_file"
while IFS= read -r line
do
    kill -9 "$line" || true
done < "$input"

rm -f pid_file