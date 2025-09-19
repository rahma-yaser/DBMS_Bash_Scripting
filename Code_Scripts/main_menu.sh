#! /usr/bin/bash
PATH=$PATH:$(pwd)
echo "PATH=$PATH:$(pwd)" >> ~/.bashrc
export LC_COLLATE=C     #Terminal Case Sensitive
shopt -s extglob #Enable Sub Pattern 
#shopt nocaseglob #note: windows drivers are incase sensitive

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

#!/bin/bash

# Directory where THIS script lives (should be Project/Code_Scripts)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Project root = parent of Code_Scripts
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Be robust to directory name casing (DBMS vs dbms, Code_Scripts vs code_scripts)
if   [[ -d "$PROJECT_DIR/DBMS" ]];     then DBMS_DIR="$PROJECT_DIR/DBMS"
elif [[ -d "$PROJECT_DIR/dbms" ]];     then DBMS_DIR="$PROJECT_DIR/dbms"
else
  echo "ERROR: Could not find DBMS/ (or dbms/) under $PROJECT_DIR"; exit 1
fi

if   [[ -d "$PROJECT_DIR/Code_Scripts" ]]; then CODE_DIR="$PROJECT_DIR/Code_Scripts"
elif [[ -d "$PROJECT_DIR/code_scripts" ]]; then CODE_DIR="$PROJECT_DIR/code_scripts"
else
  echo "ERROR: Could not find Code_Scripts/ (or code_scripts/) under $PROJECT_DIR"; exit 1
fi

export PS3="Rahma DBMS >>"
if [[ -d ../DBMS ]];then 
    echo "Welcome to Rahma DBMS :)"
else 
    echo "Don't Worry - I will Create DBMS Folder "
    mkdir ../DBMS
fi 


select choice in "Create DB" "List DB" "Connect to DB" "Remove DB" "Exit DBMS"
do 
    case $REPLY in 
        1)

            read -p "Enter Name of DB : " name 
            name=$(tr ' ' '_' <<<$name)
            if [[ $name = [0-9]* ]];then 
                echo -e "${bold_red}Error!${reset_color} Can't Start DB Name with Number :("
            else 
                case $name in 
                    +([A-Z_a-z0-9]) )
                        if [[ -e "$DBMS_DIR/$name" ]]; then
                            echo -e "${bold_red}Error!${reset_color} Name Already Exist"
                        else
                            mkdir "$DBMS_DIR/$name"
                        fi
                    ;;
                    *)
                    echo -e "${bold_red}Error!${reset_color} Can't Contain Special Character"
                ;;
                esac 
            fi 
        ;;
        2)
            db_list=($(ls -F "$DBMS_DIR" | grep '/' | tr '/' ' '))

            if [[ ${#db_list[@]} = 0 ]]; then
                echo -e "${bold_red}DBMS is empty right now${reset_color}"
            else
                ls -F "$DBMS_DIR" | grep '/' | tr '/' ' '
            fi
        ;;
        3)

            read -p "Enter Name of DB : " name
            name=$(tr ' ' '_' <<<"$name")   # replace spaces with underscores

            # Reject names starting with numbers
            if [[ $name = [0-9]* ]]; then
                echo -e "${bold_red}Error!${reset_color} Can't start DB name with a number :("
            else
                case $name in
                    +([A-Za-z0-9_]) )   # valid name (letters, numbers, underscore)
                        if [[ -d "$DBMS_DIR/$name" ]]; then
                            cd "$DBMS_DIR/$name" || exit
                            echo -e "${bold_green}Connected to $name Database Successfully :)${reset_color}"
                            DB_menu.sh "$name"
                        else
                            echo -e "${bold_red}Error!${reset_color} Database '$name' not found in DBMS"
                        fi
                    ;;
                    *)
                        echo -e "${bold_red}Error!${reset_color} DB name can't contain special characters"
                    ;;
                esac
            fi
        ;;

        4)
            echo "Choose a database to remove:"
            
            db_lst=($(ls -F "$DBMS_DIR" | grep '/' | tr '/' ' '))
            select name in "${db_lst[@]}"; do
            if [[ -n "$name" && -d "$DBMS_DIR/$name" ]]; then
                    read -p "Are you sure you want to delete $name? (y/n): " confirm
                    if [[ $confirm == [Yy] ]]; then
                    rm -r "$DBMS_DIR/$name"
                    echo -e "${red_color}Database $name deleted successfully${reset_color}"
                else
                    echo -e "${yellow_color}Operation cancelled${reset_color}"
                fi
                    break
            else
                echo -e "${bold_red}Error Invalid DB!${reset_color} Please select a valid database :)"
                break
            fi
            done
        ;;

        5)
            echo -e "${bold_blue}Exiting DBMS. Goodbye!${reset_color}"

            exit
        ;; 
        *) 
            echo -e "${bold_red}Error!${reset_color} Choice Not Found!"
        ;;
    esac 

done 
