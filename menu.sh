#!/bin/bash

# Function to check if a string contains no special characters or spaces
check() {
    while [[ ! $name =~ ^[a-zA-Z0-9_]+$ || $name =~ [[:space:]] ]]; do
        read -p "Sorry, you can't use special characters or spaces. Enter again: " name
    done
}

# Function to create a database
createdb() {
   
        read -p "Please enter the name of the database: " name
        check 

        if [[ -e $name ]]; then
            echo "Sorry, the database already exists."
        else
            mkdir $name
            echo "The database was created successfully."
        fi

        read -p "Do you want to create another? (yes/no): " option
        if [[ $option == "yes" ]]; then
            createdb
        elif [[ $option == "no" ]]; then
            ~/files/menu
        else
            echo "invalid input"
           break
        fi
    
}

# Function to connect to a database
connecttodb() {
    
        read -p "Enter the name of the database you want to connect to: " name
        check

        if [[ -e $name ]]; then
            echo "You are now in the database."
            cd $name
            tablemenu
            
        else
            read -p "Sorry, this database does not exist. Do you want to try again? (yes/no): " option
            if [[ $option == "yes" ]]; then
                connecttodb
            elif [[ $option == "no" ]]; then
                ~/files/menu
            else
                echo "invalid input"
                 break
            fi
        fi

}

# Function to drop a database
Dropdb() {
        read -p "Please enter the name of the database you want to delete: " name
        check

        if [[ -e $name ]]; then
            rm -r $name
            echo "The database was deleted successfully."
            
        else
            read -p "Sorry, no database with this name. Do you want to try again? (yes/no): " option
            if [[ $option == "no" ]]; then
                ~/files/menu
            elif [[ $option == "yes" ]]; then
                Dropdb
            fi
        fi
   
}

# Function to display the table menu
tablemenu() {
    echo "         Table Menu       "
    PS3="Enter your option: "
    select option in "CreateTable" "ListTables" "InsertToTable" "SelectFromTable" "DeleteFromTable" "UpdateTable" "Exit"; do
        case $option in
            "CreateTable")
                ~/files/createtable
                tablemenu
                ;;
            "ListTables") 
                echo "Tables:"
                ls -F | grep -vE '(\.meta$|^\.)'
                tablemenu
                ;;
            "InsertToTable")
                ~/files/insertin
                tablemenu
                ;;
            "SelectFromTable")
                ~/files/selectt
                tablemenu
                ;;
            "DeleteFromTable")
                ~/files/delete
                tablemenu
                ;;
            "UpdateTable")
                ~/files/updatee
                tablemenu
                ;;
            "Exit")
                ~/files/menu
                ;;
            *)
                echo "Sorry, this is not an option."
                tablemenu
                ;;
        esac
    break
    done
}

# Main menu
echo "         Main Menu       "
PS3="Enter your option: "
select option in "CreateDB" "ListDB" "ConnectToDB" "DropDB" "Exit"; do
    case $option in
        "CreateDB")
            createdb
            ;;
        "ListDB")
            echo "The Databases:"
            ls -F | grep / | sed 's/\/$//'
            ~/files/menu
            ;;
        "ConnectToDB")
            connecttodb 
             
            ;;
        "DropDB")
            Dropdb
            ~/files/menu
            ;;
        "Exit")
            exit 0
            ;;
        *)
            echo "Sorry, this is not an option."
            ~/files/menu
            ;;
    esac
break
done

