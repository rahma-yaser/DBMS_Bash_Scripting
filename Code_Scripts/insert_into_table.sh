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

insert_into_table() {
    echo "Choose a table to insert into:"

    #list non-hidden table files
    tables=($(ls *.txt 2>/dev/null | grep -v '^\.' ))
    if [[ ${#tables[@]} -eq 0 ]]; then
        echo -e "${bold_red}No tables found :(${reset_color}"
        return
    fi

    #select menu
    select table_file in "${tables[@]}" "Cancel"; do
        if [[ "$table_file" == "Cancel" ]]; then
            echo -e "${yellow_color}Operation canceled${reset_color}"
            return
        elif [[ -n "$table_file" ]]; then
            table_name="${table_file%.txt}"
            meta_file=".${table_name}_meta.txt"

            if [[ ! -f "$meta_file" ]]; then
                echo -e "${red_color}Metadata file for $table_name not found${reset_color}"
                return
            fi

            # ---- read 3-line CSV meta: names, types, keys ----
            IFS=, read -r -a COLS  < <(sed -n '1p' "$meta_file")
            IFS=, read -r -a TYPES < <(sed -n '2p' "$meta_file")
            IFS=, read -r -a KEYS  < <(sed -n '3p' "$meta_file")

            new_row=""
            valid=true

            #prompt for each column based on its type
            for i in "${!COLS[@]}"; do
                col_name="${COLS[i]}"
                col_type="${TYPES[i]}"   #int/string/bool (lowercased)
                col_key="${KEYS[i]}"

                while true; do
                    case "$col_type" in
                        int)
                            read -p "Enter value for $col_name (int): " value
                            if [[ ! "$value" =~ ^-?[0-9]+$ ]]; then
                                echo -e "${red_color}Invalid integer! Try again${reset_color}"
                                continue
                            fi                            
                            ;;
                        bool)
                            echo "Choose value for $col_name (bool):"
                            select choice in "Yes" "No"; do
                                case $choice in
                                    Yes) value=true; break ;;
                                    No)  value=false; break ;;
                                    *) echo -e "${red_color}Invalid choice! Please try again${reset_color}" ;;
                                esac
                            done
                            ;;
                        string)
                            read -p "Enter value for $col_name (string): " value
                            if [[ -z "$value" ]]; then
                                echo -e "${red_color}String cannot be empty${reset_color}"
                                continue
                            fi
                            ;;
                        *)
                            echo "Invalid type '$col_type' for '$col_name'"
                            valid=false
                            break 2
                            ;;
                    esac

                    #primary key check (for whichever column has 'PK')
                    if [[ "$col_key" == "PK" ]]; then
                        colnum=$((i+1))
                        if [[ -f $table_file ]] && cut -d'|' -f$colnum $table_file | grep -Fxq $value; then
                            echo -e "${red_color}Duplicate primary key value for $col_name${reset_color}"
                            continue
                        fi
                    fi

                    break
                done

                #build the new row
                if [[ -z "$new_row" ]]; then
                    new_row="$value"
                else
                    new_row="$new_row|$value"
                fi
            done

            # Insert row if valid
            if [[ "$valid" == true ]]; then
                echo "$new_row" >> "$table_file"
                echo -e "${bold_green}Row inserted successfully into $table_name${reset_color}"
            fi
            break
        else
            echo -e "${red_color}Invalid choice! Try again${reset_color}"
        fi
    done
}

insert_into_table

