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


#SELECT * FROM <table>
select_all_from_table() {
    # List tables
    tables=($(ls -1 *.txt 2>/dev/null | grep -v '^\.' ))
    if [[ ${#tables[@]} = 0 ]]; then
        echo "No tables found :("
        return
    fi

    echo "Choose a table:"
    select table_file in "${tables[@]}" "Cancel"; do
        if [[ "$table_file" == "Cancel" ]]; then
            echo "Canceled"
            return
        fi

        if [[ -n "$table_file" ]]; then
            table_name="${table_file%.txt}"
            meta_file=".${table_name}_meta.txt"

            if [[ ! -f "$meta_file" ]]; then
                echo "Metadata file not found"
                return
            fi

            # Read header (columns)
            IFS=, read -r -a COLS < <(sed -n '1p' "$meta_file")
            # Trim spaces in header
            header=""
            for c in "${COLS[@]}"; do
                col="${c//[[:space:]]/}"
                if [[ -z "$header" ]]; then
                    header="$col"
                else
                    header="$header|$col"
                fi
            done

            echo "$header"
            if [[ -s "$table_file" ]]; then
                cat "$table_file"
            else
                echo "(no rows)"
            fi
            break
        else
            echo "Invalid choice! Try again"
        fi
    done
}

#SELECT chosen columns FROM table
select_columns_from_table() {
    # List tables
    tables=($(ls -1 *.txt 2>/dev/null | grep -v '^\.' ))
    if [[ ${#tables[@]} = 0 ]]; then
        echo "No tables found :("
        return
    fi

    echo "Choose a table:"
    select table_file in "${tables[@]}" "Cancel"; do
        if [[ "$table_file" == "Cancel" ]]; then
            echo "Canceled"
            return
        fi

        if [[ -n "$table_file" ]]; then
            table_name="${table_file%.txt}"
            meta_file=".${table_name}_meta.txt"

            if [[ ! -f "$meta_file" ]]; then
                echo "Metadata file not found"
                return
            fi

            #Read column names
            IFS=, read -r -a COLS < <(sed -n '1p' "$meta_file")

            #Clean names and build a display list
            CLEAN_COLS=()
            for c in "${COLS[@]}"; do
                CLEAN_COLS+=("${c//[[:space:]]/}")
            done

            echo "Select columns to show (choose multiple; pick 'Done' when finished):"
            chosen_idx=()   # store 1-based indices
            while true; do
                # Build menu each time so user sees current selection status
                options=("${CLEAN_COLS[@]}" "Done" "Cancel")
                select col_choice in "${options[@]}"; do
                    if [[ "$col_choice" = "Cancel" ]]; then
                        echo "Canceled"
                        return
                    fi

                    if [[ "$col_choice" == "Done" ]]; then
                        if [[ ${#chosen_idx[@]} = 0 ]]; then
                            echo "You must choose at least one column."
                            break
                        fi

                        # Print header using chosen columns
                        HEADER=""
                        fields=""
                        for idx in "${chosen_idx[@]}"; do
                            name="${CLEAN_COLS[$((idx-1))]}"
                            if [[ -z "$HEADER" ]]; then
                                HEADER="$name"
                            else
                                HEADER="$HEADER|$name"
                            fi
                            if [[ -z "$fields" ]]; then
                                fields="$idx"
                            else
                                fields="$fields,$idx"
                            fi
                        done

                        echo "$HEADER"
                        if [[ -s "$table_file" ]]; then
                            cut -d'|' -f"$fields" "$table_file"
                        else
                            echo "(no rows)"
                        fi
                        return
                    fi

                    if [[ -n "$col_choice" ]]; then
                        # Determine selected index
                        select_idx="$REPLY"
                        # Check duplicates before adding
                        already=false
                        for x in "${chosen_idx[@]}"; do
                            if [[ "$x" -eq "$select_idx" ]]; then
                                already=true
                                break
                            fi
                        done

                        if [[ "$already" == true ]]; then
                            echo "Column '$col_choice' already selected."
                        else
                            chosen_idx+=("$select_idx")
                            echo "Selected: $col_choice"
                        fi
                        break
                    else
                        echo "Invalid choice. Try again."
                    fi
                done
            done
        else
            echo "Invalid choice. Try again."
        fi
    done
}

#small menu to choose which SELECT to run
select_rows_menu() {
    echo "What do you want to do?"
    select action in "Select ALL columns (*)" "Select specific columns" "Cancel"; do
        if [[ "$action" == "Cancel" ]]; then
            echo -e "${yellow_color}Canceled Operation${reset_color}"
            return
        fi

        if [[ "$action" == "Select ALL columns (*)" ]]; then
            select_all_from_table
            break
        elif [[ "$action" == "Select specific columns" ]]; then
            select_columns_from_table
            break
        else
            echo -e "${red_color}Invalid choice! Try again${reset_color}"
        fi
    done
}

select_rows_menu

select_all_from_table

select_columns_from_table
