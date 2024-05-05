#!/bin/bash

# Function to delete the table file and its meta file
delete_table() {
  name=$1
  rm "$name"
  rm "$name.meta"
}
# Function to delete all data from the table file
delete_all_data() {
  name=$1
num=$(wc -l < "$name")
if [[ $num == 1 ]]; then
echo "The table is already empty"
break
else
 #delete all data exclude first row (columns name)
awk 'BEGIN{FS=":"} NR == 1 {print $0; next} {print "" > FILENAME; exit}' "$name" > .newfile && mv .newfile "$name"

  echo "All data was deleted successfully from the table '$name'."
fi
}
# Function to delete a specific row based on the primary key
delete_specific_row() {
  
    read -p "Please enter the primary key value of the row you want to delete: " key_value

    # Check if the id exists in the table
    if cut -f1 -d":" "$name" | grep -w "$key_value"; then
   # Exclude the row with the specified primary key
      awk -v key="$key_value" 'BEGIN{FS=":"; OFS=":"} {if ($1 != key) print $0}' "$name" > .newfile
      mv .newfile "$name"
      echo "The row with primary key was deleted successfully from the table '$name'."
      break
    else
      read -p "This primary key does not exist. Do you want to try again? (yes/no): " option
      if [[ $option == "no" ]]; then
        exit;
      elif [[ $option == "yes" ]]; then
         delete_specific_row
       else 
        echo "Invalid input"
        exit
      fi
    fi
  
}
# Function to delete rows based on a specified column value
delete_rows_by_value() {
  
    read -p "Enter the column name to filter by: " column

    # Check if the entered column name exists in the meta file
    if grep -qw "$column" "./$name.meta"; then
	      read -p "Enter the value of $column to delete rows: " value
		# Get the number of the column that needs to be updated
	    col_number=$(awk -v col="$column" 'BEGIN{FS=":"} $1 == col {print NR; exit}' "$name.meta")
	       # Check if the value exists in the specified column
        if awk -v col="$col_number" -v val="$value" -F ":" '$col == val' "$name" | grep -q "$value"; then
	    # Exclude rows where the specified column has the specified value
	      grep -v -E ":[^:]*$value" "$name" > .newfile && mv .newfile "$name"

	      echo "Rows were deleted successfully from the table '$name'."
	       break
             else 
                read -p "value not found in the table. Do you want to try again? (yes/no): " option
	      
		      if [[ $option == "no" ]]; then
			break
		      elif [[ $option == "yes" ]]; then
			delete_rows_by_value
		      else 
			echo "Invalid input"
			break
		      fi
                    break
		fi          
   
    else
      read -p "Column not found in the meta file. Do you want to try again? (yes/no): " option
      
      if [[ $option == "no" ]]; then
        break
      elif [[ $option == "yes" ]]; then
        delete_rows_by_value
      else 
        echo "Invalid input"
        break
      fi
    break
    fi
  
}


  read -p "Please enter the table name that you want to delete from: " name
  if [[ ! -e ./$name ]]; then
    echo "This table '$name' doesn't exist "
  else
    PS3="Enter the option :"
    select choice in delete_all_data delete_table delete_row delete_value; do
      case $choice in
        delete_all_data)
          delete_all_data "$name"
          break
          ;;
        delete_table)
          delete_table "$name"
          break
          ;;
        delete_row)
          delete_specific_row
          ;;
        delete_value)
          delete_rows_by_value
          ;;
        *)
          echo "Error. Please try again."
          ;;
      esac
    break
    done
  fi
   
      read -p "Do you want to delete another? (yes/no): " option

      if [[ $option == "no" ]]; then
        exit
      elif [[ $option == "yes" ]]; then
        ~/files/delete
      else
        echo "invalid input."
        exit
      fi
    
 




