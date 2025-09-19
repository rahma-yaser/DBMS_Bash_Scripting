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


db_name="$1"

export PS3="$db_name DB >> "
select choice in "Create Table" "List Tables" "Drop Table" "Insert into Table" "Select from Table" "Delete from Table" "Update Table" "Back to Main Menu"
do 
    case $REPLY in
            1)
                echo "[$db_name] -> Creating table..."
                create_table.sh
                ;;
            2)
                echo "[$db_name] -> Listing tables..."
                list_table.sh
                ;;
            3)
                echo "[$db_name] -> Dropping table..."
                drop_table.sh
                ;;
            4)
                echo "[$db_name] -> Inserting into table..."
                insert_into_table.sh
                ;;
            5)
                echo "[$db_name] -> Selecting from table..."
                select_table.sh
                ;;
            6)
                echo "[$db_name] -> Deleting from table..."
                delete_from_table.sh
                ;;
            7)
                echo "[$db_name] -> Updating table..."
                update_table.sh
                ;;
            8)
                echo -e "${yellow_color}Returning to Main Menu...${reset_color}"
                break
                ;;
                
            *)
                echo -e "${bold_red}Invalid choice. Please select a valid option${reset_color}"
                ;;
        esac
    done 