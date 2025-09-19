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


# UPDATE one column (chosen by user) WHERE PK = value
# Assumes:
#   .<table>_meta.txt:
#     line1: id,name,age
#     line2: int,string,string
#     line3: PK,NULL,NULL
#   data rows are | separated in <table>.txt

# Helper: prompt for a value with type validation (int/string/bool)
prompt_value() {
    type="$1"
    label="$2"
    if [[ "$type" == "int" ]]; then
        while true; do
            read -r -p "$label (int): " v
            if [[ "$v" =~ ^-?[0-9]+$ ]]; then
                echo "$v"
                return
            fi
            echo "Invalid integer. Try again."
        done
    elif [[ "$type" == "bool" ]]; then
        echo "$label (bool):"
        PS3="#? "
        select b in "Yes" "No"; do
            if [[ "$b" == "Yes" ]]; then
                echo "true"
                return
            fi
            if [[ "$b" == "No" ]]; then
                echo "false"
                return
            fi
            echo "Invalid choice. Try again."
        done
    else
        while true; do
            read -r -p "$label (string): " v
            if [[ -n "$v" ]]; then
                echo "$v"
                return
            fi
            echo "String cannot be empty. Try again."
        done
    fi
}

# UPDATE one column WHERE PK = value
update_column_by_pk() {
    # 1) pick table
    tables=($(ls -1 *.txt 2>/dev/null | grep -v '^\.' ))
    if [[ ${#tables[@]} -eq 0 ]]; then
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

            # 2) read meta (3 lines)
            IFS=, read -r -a COLS  < <(sed -n '1p' "$meta_file")
            IFS=, read -r -a TYPES < <(sed -n '2p' "$meta_file")
            IFS=, read -r -a KEYS  < <(sed -n '3p' "$meta_file")

            if [[ ${#COLS[@]} -eq 0 ]]; then
                echo "Invalid metadata"
                return
            fi
            if [[ ${#COLS[@]} -ne ${#TYPES[@]} ]]; then
                echo "Metadata lines have different lengths"
                return
            fi
            if [[ ${#COLS[@]} -ne ${#KEYS[@]} ]]; then
                echo "Metadata lines have different lengths"
                return
            fi

            # clean names
            CLEAN_COLS=()
            for c in "${COLS[@]}"; do
                CLEAN_COLS+=("${c//[[:space:]]/}")
            done

            # 3) find PK column
            pk_index=-1
            pk_name=""
            pk_type=""
            for i in "${!KEYS[@]}"; do
                if [[ "${KEYS[i]}" == "PK" ]]; then
                    pk_index=$((i+1))          # 1-based
                    pk_name="${CLEAN_COLS[i]}"
                    pk_type="${TYPES[i],,}"    # int/string/bool
                    break
                fi
            done
            if [[ $pk_index -eq -1 ]]; then
                echo "No primary key defined"
                return
            fi

            # 4) update loop (repeat until user cancels)
            while true; do
                if [[ ! -s "$table_file" ]]; then
                    echo "Table is empty."
                    break
                fi

                echo "Pick a column to UPDATE (or 'Cancel' to stop):"
                select target_col in "${CLEAN_COLS[@]}" "Cancel"; do
                    if [[ "$target_col" == "Cancel" ]]; then
                        echo "Stopped updating."
                        return
                    fi
                    if [[ -n "$target_col" ]]; then
                        update_col_idx="$REPLY"    # 1-based
                        update_type="${TYPES[$((update_col_idx-1))]}"
                        break
                    else
                        echo "Invalid choice. Try again."
                    fi
                done

                # 5) enter PK value (typed-checked)
                pk_value="$(prompt_value "$pk_type" "Enter PK ($pk_name) value")"

                # confirm row exists
                matches=$(awk -F'|' -v i="$pk_index" -v v="$pk_value" '$i==v{c++} END{print c+0}' "$table_file")
                if [[ "$matches" -eq 0 ]]; then
                    echo "No row found where $pk_name = $pk_value"
                    read -r -p "Try another update? (y/n): " again
                    if [[ "$again" == "y" || "$again" == "Y" ]]; then
                        continue
                    else
                        break
                    fi
                fi

                # 6) enter NEW value for chosen column (typed-checked)
                col_label="New value for ${CLEAN_COLS[$((update_col_idx-1))]}"
                new_value="$(prompt_value "$update_type" "$col_label")"

                # 7) if updating PK, enforce uniqueness
                if [[ $update_col_idx -eq $pk_index ]]; then
                    if [[ -f "$table_file" ]]; then
                        if cut -d'|' -f"$pk_index" "$table_file" | grep -Fxq -- "$new_value"; then
                            echo "Duplicate primary key value. Update aborted."
                            read -r -p "Do another update? (y/n): " again
                            if [[ "$again" == "y" || "$again" == "Y" ]]; then
                                continue
                            else
                                break
                            fi
                        fi
                    fi
                fi

                # 8) perform the update
                tmpfile=$(mktemp)
                awk -F'|' -v OFS='|' \
                    -v i_pk="$pk_index" -v v_pk="$pk_value" \
                    -v i_upd="$update_col_idx" -v v_new="$new_value" '
                    { if ($i_pk==v_pk) { $i_upd=v_new; c++ } print }
                    END { if (c+0 == 0) { exit 2 } }
                ' "$table_file" > "$tmpfile"

                if [[ $? -eq 0 ]]; then
                    mv "$tmpfile" "$table_file"
                    echo "Updated $matches row(s) in '$table_name'."
                else
                    rm -f "$tmpfile"
                    echo "Update failed."
                fi

                # 9) ask to continue
                read -r -p "Do you want to make another update on this table? (y/n): " again
                if [[ "$again" == "y" || "$again" == "Y" ]]; then
                    continue
                else
                    break
                fi
            done

            break
        else
            echo "Invalid choice. Try again."
        fi
    done
}

update_column_by_pk