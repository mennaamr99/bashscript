#!/bin/bash
check() {
    local variable_name=$1
    while [[ ! $variable_name =~ ^[a-zA-Z0-9_]+$ || $variable_name =~ [[:space:]] ]]; do
        read -p "Sorry, you can't write special characters or spaces. Enter again: " variable_name
    done
echo $variable_name
}

# to Ensure the column name is unique 
checkColumnName() {
    local new_column_name=$1
     local columns=$2
    while [[ " $columns " =~ " $new_column_name " ]]; do
    
        read -p "Column already exists. Please enter a different name: " new_column_name
    done
    
echo $new_column_name
}

    read -p "Please enter the name of the table: " name
    name=$(check $name)
     #to make sure the name of the table didn't exist
    if [[ -e $name ]]; then
        echo "Sorry, the table '$name' was already created."
    else
        touch $name
        read -p "Can you enter the number of fields: " num
         #to make sure the user will enter numbers only
         while [[ ! $num =~ ^[0-9]+$ ]]; do
        read -p "Sorry, you can only write numbers. Enter again: " num
         done
        read -p "Enter the name of the primary key column: " primarykey
        primarykey=$(check $primarykey) 
        
        #new for concate the name columns and the data type
        new=""
        #column to store the name of columns in it before the concatenation       
        columns=""
         echo "Enter the data type of the primary key :"
        PS3="Enter your option: "
        select option in "integer" "string"; do
            case $option in
                "integer")
                    new+="$primarykey:intpk"$'\n'
                    break
                    ;;
                "string")
                    new+="$primarykey:stringpk"$'\n'
                    break
                    ;;
                *)
                    echo "Not valid."
                    ;;
            esac
        done

        i=0
        while [[ $i -lt $num-1 ]]; do
            read -p "Enter the name of the next column : " column
            #check the name of columns has no special chars
            column=$(check $column)
             # Ensure the column name is unique
            column=$(checkColumnName "$column" "${columns[@]}")
            columns+="$column "
            #chech the name of the columns not the same name of primary key
            while [[ "$column" == "$primarykey" ]]; do
                echo "Column name cannot be the same as the primary key"
                read -p "Enter the name of the name again: " column
                 column=$(check $column)
             done  
               
                echo "What is the data type? "
                PS3="Enter your option: "
                select option in "integer" "string"; do
                    case $option in
                        "integer")
                            new+="$column:int"$'\n'
                            break
                            ;;
                        "string")
                            new+="$column:string"$'\n'
                            break
                            ;;
                        *)
                            echo "Not valid."
                            ;;
                    esac
                    break
                done

                ((i++))
           
        done
        echo "$primarykey:${columns[*]}" | tr ' ' ':' >> "$name"
        echo -e "$new" >> "./$name.meta"
        
        echo "The table '$name' was created successfully."
    fi
    read -p "Do you want to create another? (yes/no): " option
    if [[ $option == "no" ]]; then
        exit;
    elif [[ $option = "yes" ]]; then
        ~/files/createtable
    else
        echo "invalid input"
        exit;
    fi


