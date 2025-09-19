#! /usr/bin/bash


export LC_COLLATE=C     #Terminal Case Sensitive
shopt -s extglob

#define color variables
red_color='\e[31m' #red
yellow_color='\e[33m' #yellow
white_color='\e[37m' #white
green_color='\e[32m' #green
blue_color='\e[34m' #blue

bold_red='\e[1;31m' #bold_red
bold_yellow='\e[1;33m' #bold_yellow
bold_white='\e[1;37m' #bold_white
bold_green='\e[1;32m' #bold_green
bold_blue='\e[1;34m' #bold_blue

reset_color='\e[0m'  #reset

#DELETE ALL ROWS (TRUNCATE-LIKE)
delete_all_from_table() {
    tables=($(ls -1 *.txt 2>/dev/null | grep -v '^\.' ))
    if [[ ${#tables[@]} = 0 ]]; then
        echo -e "${red_color}No tables found :(${reset_color}"
        return
    fi

    echo "Choose a table to DELETE ALL rows from:"
    select table_file in "${tables[@]}" "Cancel"; do
        if [[ "$table_file" == "Cancel" ]]; then
            echo "Canceled"
            return
        fi

        if [[ -n "$table_file" ]]; then
            table_name="${table_file%.txt}"

            echo "Are you sure you want to delete ALL rows from $table_name?"
            PS3="#? "
            select ans in "Yes" "No"; do
                if [[ "$ans" == "Yes" ]]; then
                    : > "$table_file"
                    echo "All rows deleted from '$table_name'"
                    break
                fi
                if [[ "$ans" == "No" ]]; then
                    echo "Operation canceled"
                    break
                fi
                echo "Invalid choice! Try again"
            done
            break
        else
            echo "Invalid choice! Try again"
        fi
    done
}


delete_all_from_table
