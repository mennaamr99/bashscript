#!/bin/bash
checkint() {
    local variable_int=$1
    while [[ ! $variable_int =~ ^[0-9]+$ ]]; do
        read -p "Sorry, you can only write numbers without spaces. Enter again: " variable_int
    done
echo $variable_int
}

checkstring() {
    local variable_string=$1
    while [[ ! $variable_string =~ ^[a-zA-Z]+$ ]]; do
        read -p "Sorry, you can only write characters without spaces or special chars. Enter again: " variable_string
    done
echo $variable_string
}

checkint_unique() {
    local variable_int=$1
    local name=$2

    while [[ ! $variable_int =~ ^[0-9]+$ ||  $(cut -f1 -d":" "$name" | grep -w "$variable_int" | wc -l) -gt 0 ]]; do
        read -p "Sorry, you can only write unique numbers without spaces or special chars. Enter again: " variable_int
    done

    echo $variable_int
}
checkstring_unique() {
    local variable_int=$1
    local name=$2

    while [[ ! $variable_int =~ ^[a-zA-Z]+$ ||  $(cut -f1 -d":" "$name" | grep -w "$variable_int" | wc -l) -gt 0 ]]; do
        read -p "Sorry, you can only write unique numbers without spaces or special chars. Enter again: " variable_int
    done

    echo $variable_int
}


read -p "Enter the name of the table that you want to insert in: " name

if [[ ! -e $name ]]; then
    echo "This table '$name' doesn't exist.  " 

else
   
    new=""
    num=$(wc -l < "$name.meta")
    num2=$(wc -l < "$name")
    data_types=($(awk -F ":" '{print $2}' "$name.meta"))
    names=($(awk -F ":" '{print $1}' "$name.meta"))

    for ((i=0; i<num-1; i++)); do
        read -p "Enter the value of the ${names[$i]} column: " val

        case ${data_types[$i]} in
            "intpk")
		val=$(checkint_unique "$val" "$name")
		 new+="$val:"
                 ;;
            "stringpk")
		 val=$(checkstring_unique "$val" "$name")
		 new+="$val:"
                 ;;
            "string")
                val=$(checkstring "$val")
                 new+="$val:"
                ;;
            "int")
                val=$(checkint "$val")
                new+="$val:"
                ;;
            *)
                echo "Invalid data type."
                ;;
        esac
echo " inserted sucssesfully"
    done

    echo -e "$new" >> "./$name"
fi
read -p "Do you want to insert another? (yes/no): " option
if [[ $option == "no" ]]; then
    exit;
elif [[ $option == "yes" ]]; then
    ~/files/insertin
else
    echo "invalid input"
    exit;
fi

