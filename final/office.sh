#!/bin/bash

## Ian Nelson
## CMIS325
## Final Project
##
## Phonebook script that deals with user input,
## menus, adding, modifying, deleting, and
## validation of credentials.

## Define the trap for SIGINT/SIGTERM signals.
trap trap_terminate SIGINT SIGTERM

## Ask user for file
get_file () {
    ## File is validated until proven guilty ;)
    validated=1

    ## Get the filename from the user.
    echo "What file do you want to open? ";
    read filename;

    ## Validate the file itself.
    validate_file

    ## Check for badness.
    if [[ $validated == 0 ]]
    then
        terminate "Phonebook file is bad or doesn't exist"
    fi

    ## Validate the file structure.
    validate_columns

    ## Check for badness.
    if [[ $validated == 0 ]]
    then
        terminate "Phonebook file is malformed"
    fi
}

## Validate the file structure and existance
validate_file () {
    ## Does the file exist?
    if [ ! -e $filename ]
    then
        validated=0
    fi

    ## Is it a regular file?
    if [ ! -f $filename ]
    then
        validated=0
    fi

    ## Is it zero-byte?
    if [ ! -s $filename ]
    then
        validated=0
    fi
}

## Validate the file contents to determine columns
validate_columns () {
    ## Read each line.
    while read line; do
        ## If line doesn't match regex
        if [[ ! $line =~ $regex ]]
        then
            ## Invalidate.
            validated=0
        fi
    ## Stream in file.
    done < $filename
}

## Add a phonebook entry
add () {
    ## Authenticate against /etc/passwd
    authenticate

    ## Let user know
    if [[ $authenticated == 1 ]]; then
        echo "User $(logname) is authenticated"; echo ""
    else
        echo "Unable to add, not in /etc/passwd"; echo ""
        return -1
    fi

    ## Get user input for entry.
    echo "What is the last name?"
    read new_lastname
    echo "What is the first name?"
    read new_firstname
    echo "What is the phone number? (Format as ###-###-####)"
    read new_phonenumber

    ## Create the new entry.
    newentry="$new_lastname $new_firstname $new_phonenumber"

    ## Make sure entry is formatted correctly
    if [[ ! $newentry =~ $regex ]]
    then
        echo ""
        echo "New entry isn't formatted correctly."
        echo ""
        return
    fi

    ## Make sure new entry doesn't exist.
    entry_count=$(grep "$newentry" $filename | wc -l)
    if [[ $entry_count -ne 0 ]]; then
        echo ""
        echo "Entry already exists"
        echo ""
    fi

    ## Push the entry into the file. Do not add the CRLF
    ## and parse the new lines correctly to ensure that
    ## the file is formatted correctly.
    echo -n -e "\n$newentry" >> $filename
    echo ""
    echo "Entry was added to $filename"
    echo ""
}

## Delete a phonebook entry
delete () {
    ## Spacer.
    echo ""

    ## If the first name exists...
    if [[ -n "$firstname" ]]; then
        ## Define the pattern with it.
        pattern="$lastname $firstname"
        echo "Deleting anything containing '$lastname $firstname'..."
    ## If it doesn't...
    else
        ## Pattern only contains last name.
        pattern="$lastname"
        echo "Deleting anything containing '$lastname'..."
    fi

    ## Spacer.
    echo ""

    ## Iterate through the list of results from the pattern.
    grep -i "$pattern" $filename | while read -r delete_entry ; do
        ## Show user what is getting removed.
        echo "Removing \"$delete_entry\"..."
        ## Get the line number of the matched entry.
        line_number=$(grep -i -nr "$delete_entry" $filename | cut -f1 -d:)
        ## Tell user where this entry is.
        echo "Entry is located on line $line_number"
        ## Remove it in place with sed.
        sed -i ${line_number}d $filename
    done

    ## Spacer.
    echo ""
}

## Modify a phonebook entry
modify () {
    ## If the first name exists...
    if [[ -n "$firstname" ]]; then
        ## Define the pattern with it.
        pattern="$lastname $firstname"
    ## If it doesn't...
    else
        ## Pattern only contains last name.
        pattern="$lastname"
    fi

    ## Get a count of the results.
    results=$(grep -i "$pattern" $filename | wc -l)

    ## Not specific enough.
    if [[ $results -gt 1 ]]; then
        echo ""
        echo "More than one results. Please change your search to modify."
        echo ""
        return
    fi

    ## No results.
    if [[ $results == 0 ]]; then
        echo ""
        echo "No results to change. Refine your search."
        echo ""
        return
    fi

    ## Get the line number.
    line_number=$(grep -i -nr "$pattern" $filename | cut -f1 -d:)

    ## Spacer.
    echo ""

    ## Get the original entry.
    original=$(grep -i "$pattern" $filename)

    ## Notify that a record is getting modified.
    echo "Changing \"$original\"..."; echo ""

    ## Get user input for entry.
    echo "What is the last name?"
    read new_lastname
    echo "What is the first name?"
    read new_firstname
    echo "What is the phone number? (Format as ###-###-####)"
    read new_phonenumber

    ## Create the new entry.
    newentry="$new_lastname $new_firstname $new_phonenumber"

    ## Make sure entry is formatted correctly
    if [[ ! $newentry =~ $regex ]]
    then
        echo ""
        echo "Modified entry isn't formatted correctly."
        echo ""
        return
    fi

    ## Make sure new entry doesn't exist.
    entry_count=$(grep "$newentry" $filename | wc -l)
    if [[ $entry_count -ne 0 ]]; then
        echo ""
        echo "Entry already exists"
        echo ""
        return;
    fi

    ## Spacer.
    echo ""

    ## Replace the entry in-line.
    sed -i "$line_number"s/"$pattern"/"$newentry"/ "$filename"

    ## Spacer.
    echo ""
}

## Display a single phonebook entry
display_one () {
    echo ""
    echo "Searching for '$lastname $firstname'..."
    echo $(grep -i "$lastname $firstname" $filename)
    echo ""
}

## Display all phonebook entries
display_all () {
    ## Spacer.
    echo ""

    ## Pipe in sorted file
    sorted=$(sort $filename)

    ## Print the sorted file.
    echo "$sorted"

    ## Spacer.
    echo ""
}

## Authenticate user against /etc/passwd
authenticate () {
    count=$(grep $(logname) /etc/passwd | wc -l)
    if [[ $count -ne 0 ]]; then
        authenticated=1
    fi
}

## Trap termination signals.
trap_terminate () {
    terminate "CTRL+C detected."
}

## Exit with a code.
terminate () {
    echo "$1"
    exit 0;
}

## Show menu of options to user.
menu () {
    echo "Add an entry        (A)"
    echo "Modify an entry     (M)"
    echo "Delete an entry     (D)"
    echo "Display an entry    (I)"
    echo "Display all entries (P)"
    echo "Exit                (X)"
    echo ""
    echo "What is your choice?"

    ## Read user input
    read choice;

    ## Switch the choice cases.
    case "$choice" in
        ("A") add ;;
        ("M") modify ;;
        ("D") delete ;;
        ("I") display_one ;;
        ("P") display_all ;;
        ("X") terminate "Goodbye." ;;
        (*) echo "Bad selection"; echo "" ;;
    esac
}

## Show usage output to user
usage () {
    ## Display usage information.
    echo "office.sh {last name} {first name}";
    echo "Must provide at least one argument (last name).";
    echo "Cannot provide more than two arguments."
}

## ----- Program ----- ##

## Formatting regex.
regex="[A-Za-z]{1,}\s[A-Za-z]{1,}\s[0-9]{3}-[0-9]{3}-[0-9]{4}"

## By default, not authenticated against /etc/passwd
authenticated=0

## Check for zero-length first argument.
if [ -z "$1" ]; then
    usage
    terminate
fi

## Check for more than 2 arguments.
if [ $# -gt 2 ]; then
    usage
    terminate
fi

## Only one argument supplied
if [[ $# == 1 ]]; then
    ## Print message to user.
    echo "More than one entry might be displayed from the phone book."
    ## Alias the last name.
    lastname=$1
fi

## Two are supplied.
if [[ $# == 2 ]]; then
    ## Alias the first and last name
    lastname=$1
    firstname=$2
fi

## Get the file from the user.
get_file

## Spacer.
echo ""

## Print the menu for the user.
while [[ 1 == 1 ]]; do
    menu
done