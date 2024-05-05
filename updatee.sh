#!/bin/bash

check() {
    local variable_name=$1
    while [[ ! $variable_name =~ ^[a-zA-Z0-9_]+$ || $variable_name =~ [[:space:]] ]]; do
        read -p "Sorry, you can't write special characters or spaces. Enter again: " variable_name
    done
echo $variable_name
}

checkint() {
    local variable_int=$1
    while [[ ! $variable_int =~ ^[0-9]+$ ]]; do
        read -p "Sorry, you can only write numbers without special characters or spaces . Enter again: " variable_int
    done
echo $variable_int
}

checkstring() {
    local variable_string=$1
    while [[ ! $variable_string =~ ^[a-zA-Z]+$ ]]; do
        read -p "Sorry, you can only write characters without special characters or spaces. Enter again: " variable_string
    done
echo $variable_string
}

# Function to update a specific record in the table
updaterec() {
    local name=$1
    read -p "Enter your id that you want to update record: " idd

    # Check if the id exists in the table
    while ! cut -f1 -d":" "$name" | grep -w "$idd" > /dev/null; do
        read -p "That primary key doesn't exist, please enter another one: " idd
    done

    # Get the number of the row that needs to be updated
    row_number=$(awk -v val="$idd" 'BEGIN{FS=":"} $1 == val {print NR; exit}' "$name")

    read -p "Enter the column that you want to update: " column
     column=$(check "$column")
    # Check if the name of the column exists in the meta file
    while ! cut -f1 -d":" "$name.meta" | grep -w "$column" > /dev/null; do
        read -p "That column doesn't exist, please enter another one: " column
    done
   

    # Get the number of the column that needs to be updated
    col_number=$(awk -v col="$column" 'BEGIN{FS=":"} $1 == col {print NR; exit}' "$name.meta")
     #get the data type of that column
    datatype=$(awk -v col="$column" 'BEGIN{FS=":"} $1 == col {print $2; exit}' "$name.meta")
   
    read -p "Enter the new value: " new_value
    
    # Check if the new value contains special characters
     new_value=$(check $new_value)
     # Check the datatype of the new value
	   if [[ $datatype == "int" ]]; then
	       new_value=$(checkint "$new_value")
	elif [[ $datatype == "string" ]]; then
	       new_value=$(checkstring "$new_value")
	   fi
 
         # Update the value in the specified column  
    awk -v row="$row_number" -v col="$col_number" -v val="$new_value" 'BEGIN{FS=":"; OFS=":"} {
        if (NR == row) {  
            $col = val;   
        }
        print;           # Print the entire line (either modified or unchanged)
    }' "$name" > .temp_file && mv .temp_file "$name"
}
# Function to check if the value exists in the specified column
    value_exists() {
        local old_value="$1"
        local column_number="$2"
        awk -v val="$old_value" -v col="$column_number" 'BEGIN{FS=":"} $col == val {print "true"; exit}' "$name"
    }
updatecol() {
     local name=$1
    read -p "Enter the name of the column that you want to update: " col
      
    # Check if the name of the column exists in the meta file
    while ! cut -f1 -d":" "$name.meta" | grep -w "$col" > /dev/null; do
        read -p "That column doesn't exist, please enter another one: " col
    done

    # Get the number of the column that needs to be updated
    col_number=$(awk -v col="$col" 'BEGIN{FS=":"} $1 == col {print NR; exit}' "$name.meta")
     #get the data type of that column
    datatype=$(awk -v col="$col" 'BEGIN{FS=":"} $1 == col {print $2; exit}' "$name.meta")
    read -p "Enter the old value: " old_val


    # Check if the old value exists in the specified column
    if [[ $(value_exists "$old_val" "$col_number") == "true" ]]; then
        read -p "Enter the new value: " new_val
         # Check if the new value contains special characters
            #new_val=$(check $new_val)
	     # Check the datatype of the new value
		   if [[ $datatype == "int" ]]; then
		       new_val=$(checkint "$new_val")
		elif [[ $datatype == "string" ]]; then
		       new_val=$(checkstring "$new_val")
		   fi

        # Update the values in the specified column
        awk -v col="$col_number" -v old="$old_val" -v new_value="$new_val" 'BEGIN{FS=":"; OFS=":"} {
            if ($col == old) $col = new_value;
            print $0;
        }' "$name" >.newfile && mv .newfile "$name"

        echo "Values in column '$col' updated successfully."
    else
        echo "Error: The old value does not exist in the specified column."
    fi
}


read -p "Enter the name of the table that you want to update: " name

if [[ ! -e $name ]]; then
    echo "This table '$name' doesn't exist " 
else
    echo "1) Update specific record for a specific user"
    echo "2) Update specific record for the whole table"

    read -p "Enter your option: " option

    if [[ $option == 1 ]]; then
        updaterec $name

    elif [[ $option == 2 ]]; then
        updatecol $name
    else
        echo "Invalid option."
    fi
fi

    read -p "Do you want to update another? (yes/no): " option
    if [[ $option == "no" ]]; then
        exit;
    elif [[ $option = "yes" ]]; then
        ~/files/updatee
    else
        echo "invalid input"
        exit;
    fi













