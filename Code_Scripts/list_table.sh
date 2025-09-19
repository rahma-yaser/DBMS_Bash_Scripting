#! /usr/bin/bash


export LC_COLLATE=C     #Terminal Case Sensitive
shopt -s extglob

list_tables() {
    echo "Available Tables:"
    for file in *.txt; do
        if [[ -f "$file" && "$file" != .* && "$file" != .*_meta.txt ]]; then
            table_name="${file%.txt}"  # Remove .txt extension
            echo " - $table_name"
        fi
    done
}
list_tables

