#!/bin/bash

# Function to select all columns from a table
select_all() {
local name=$1
num=$(wc -l < "$name")
  if [[ $num == 1 ]]; then
    echo "The table is empty"
    break
 else
     cat "$name"
  fi
}

# Function to select rows based on column value
select_rows() {
 local name=$1
      read -p "Enter the column name you want to filter by: " column
        # Get the column number from the meta file
      col=$(awk -v col="$column" 'BEGIN{FS=":"} $1 == col {print NR; exit}' "$name.meta")

      if [[ -n $col ]]; then
        read -p "Enter the value of $column that you want to select: " value
        awk -v val="$col" -v value="$value" 'BEGIN{FS=":"} $val == value {print $0}' "$name"
      else
        read -p "Sorry, the column not found. Do you want to try again? (yes/no): " option
        if [[ $option == "no" ]]; then
          exit;
        elif [[ $option == "yes" ]]; then
          #echo "Column not found. Please enter a correct column name."
          select_rows
        
        fi
      fi
   
}
# Function to select a specific row from a table by pk
select_specific_row(){
 local name=$1
    read -p "Please enter the primary key value: " key_value

   # Check if the id exists in the table
    if  cut -f1 -d":" "$name" | grep -w "$key_value" ; then
        
        # Print the entire row for the given primary key
        awk -v key="$key_value" -F ":" '$1 == key {print $0}' "$name"
    else
        read -p "Primary key not found. do you want to try again? (yes/no): " option
        if [[ $option == "no" ]]; then
          exit;
        elif [[ $option == "yes" ]]; then
          
          select_specific_row
        
        fi
         
    fi

}

# Function to select a specific column from a table
select_column() {
local name=$1
      read -p "Enter the name of the column that you want to select: " column
      #get all the name of columns 
      names=($(awk -F ":" '{print $1}' "./$name.meta"))

      if [[ " ${names[@]} " =~ " $column " ]]; then
         # Get the column number from the meta file
        col_number=$(awk -v col="$column" 'BEGIN{FS=":"} $1 == col {print NR; exit}' "$name.meta")

        # Print the selected column
        awk -v col_number="$col_number" 'BEGIN{FS=":"} {print $col_number}' "$name"
      else
      read -p "Sorry, the column not found Do you want to try again? (yes/no): " option
      if [[ $option == "no" ]]; then
        break
      elif [[ $option == "yes" ]]; then
        select_column
      fi
    fi
  
}

# Main script logic

read -p "Please enter the table name that you want to select from: " name

if [[ ! -e $name ]]; then
    echo "This table '$name' doesn't exist " 
else
PS3="Enter your option:"
select choice in select_all select_rows select_specific_row select_column; do
  case $choice in
    select_all )
      select_all "$name"
      ;;
    select_rows )
      select_rows "$name"
      ;;
    select_specific_row )
      select_specific_row "$name"
       ;;   
    select_column )
      select_column "$name"
      ;;
    * )
      echo "Error. Please try again."
      ;;
  esac
break
done
fi



  read -p "Do you want to select another? (yes/no): " option

  if [[ $option == "no" ]]; then
    exit;
  elif [[ $option == "yes" ]]; then
     ~/files/selectt
    else
        echo "invalid input."
        exit;
    fi

