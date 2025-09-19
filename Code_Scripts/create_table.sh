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


create_table_schema() {
    export LC_COLLATE=C     #Terminal Case Sensitive
    shopt -s extglob
    
    declare -a table_name
    declare -a col_names
    declare -a col_types
    declare -a col_constraints


    
    # check table_name validation
    while true; do
        read -p "Enter the table name first >> " table_name

        table_name=$(tr ' ' '_' <<<$table_name)
        if [[ $table_name = [0-9]* ]];then 
            echo -e "${bold_red}Error!${reset_color} Can't Start DB Table Name with Number :("
        else 
        
            case $table_name in 
                +([A-Za-z0-9]))
                        if [[ -e "$table_name.txt" || -e ".${table_name}_meta.txt" ]]; then
                            echo -e "${bold_red}Error!${reset_color} Table Name Already Exist"
                            
                        else
                            # Create empty data file
                            : > $table_name.txt
                            echo "Table $table_name created"
                            break
                            
                        fi
                ;;
                *)
                    echo -e "${bold_red}Error!${reset_color} Can't Contain Special Character"
                ;;
            esac 
        fi
    done


    read -p "Enter number of columns: " col_count


    for ((i=1; i<=col_count; i++)); do
        # col_name validation
        read -p "Enter name for column $i: " col_name
        col_name=$(tr ' ' '_' <<<$col_name)

        #check col_name validation
        for existing in "${col_names[@]}"; do
            if [[ "$existing" == "$col_name" ]]; then
                echo -e "${bold_red}Error!${reset_color} Column '$col_name' already used, choose another."
                ((i--))   # retry same column
                continue 2  # skip to next iteration of the outer loop
            fi
        done

        if [[ $col_name = [0-9]* ]];then 
            echo -e "${bold_red}Error!${reset_color} Can't Start DB Column Name with Number :("
        else 
            case $col_name in 
                +([A-Z_a-z0-9]) )
                        
                            col_names+=("$col_name")
                        
                ;;
                *)
                    echo -e "${bold_red}Error!${reset_color} Can't Contain Special Character"
                ;;
            esac 
        fi

        # col_type validation
        echo "Choose type for column $col_name:"
        select col_type in "int" "string" "bool"; do
            case $col_type in
                int|string|bool)   
                    col_types+=("$col_type")
                    break
                    ;;
                *)
                    echo "Invalid choice! Please select again :)"
                    ;;
            esac
        done
    done

    echo "Enter choice (1 or 2) to select your PK:"
    select pk_choice in "Choose one of the columns as PRIMARY KEY" "Auto-create a primary key column 'id' starting from 1"
    do
        pk_col=""
        case $REPLY in
        1)
            echo "Choose primary key column:"
            for ((i=1; i<=col_count; i++)); do
                echo "$i) ${col_names[$((i-1))]}"
            done
            read -p "Enter number of PK column: " pk_index
            pk_col="${col_names[$((pk_index-1))]}"
        ;;
        2)
            col_names=("id" "${col_names[@]}")
            col_types=("int(auto_increment)" "${col_types[@]}")
            pk_col="id"
            ((col_count++))
        ;;
        *)
            echo "Your Choice is out of Scope! Please enter a valid number :)"
        ;;
        esac
        break
    done
    
    # Build constraints row
    for ((i=0; i<col_count; i++)); do
        if [[ "${col_names[$i]}" == "$pk_col" ]]; then
            col_constraints+=("PK")
        else
            col_constraints+=("NULL")
        fi
    done

    # Save schema to metadata file
    {
        IFS=','; echo "${col_names[*]}"
        echo "${col_types[*]}"
        echo "${col_constraints[*]}"
    } > .${table_name}_meta.txt

    

    echo "Table Schema Created and saved:"
    echo "Metadata → .${table_name}_meta.txt"
    echo "Data file → ${table_name}.txt"
}


create_table_schema