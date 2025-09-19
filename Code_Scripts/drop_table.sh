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


drop_table() {
    echo "Choose a table to drop:"

    #prepare the table list
    tables=($(ls *.txt 2>/dev/null | grep -v '^\.'))
    if [[ ${#tables[@]} = 0 ]]; then
        echo "No tables found :("
        return
    fi

    #show select menu
    select table in "${tables[@]}" "Cancel"; do
        if [[ "$table" == "Cancel" ]]; then
            echo "Operation Canceled"
            break
        elif [[ -n "$table" ]]; then
            echo -ne "${bold_red}Are you sure you want to delete '$table'? (y/n):${reset_color} "
            read confirm
            if [[ "$confirm" == [Yy] ]]; then
                rm -f "$table" ".${table%.txt}_meta.txt"
                echo "Table '${table%.txt}' deleted."
            else
                echo "Deletion canceled."
            fi
            break
        else
            echo "Invalid choice."
        fi
    done
}
drop_table