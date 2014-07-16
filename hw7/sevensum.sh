#!/bin/bash

# Ian Nelson
# CMIS325
# Homework 7
# Makes a sum of seven numbers and assess value.

## Assign the sum to zero.
sum=0

## Number of arguments greater than 250
twoFifty=0

## Create a pattern to match integers (+/-)
regex='^-?[0-9]+([.][0-9]+)?$'

## If the number of arguments is zero, print help.
if [[ $# == 0 ]] ; then
    echo "usage: 'sevensum.sh # # # # # # #'"
    echo "usage: Can pass up to 7 integers (positive or negative)."
    echo "usage: Script will die with a bad exit code of -1 if a non-integer is passed."
    exit;
fi

## For each command line argument (1-7 only)
for var in ${@:1:7}; do
    ## Did the variable match the pattern?
    if ! [[ $var =~ $regex ]] ; then
        ## Print an error and die.
        echo "argument '$var' is not a number." >&2; exit -1
    ## Yes it did.
    else
        let "sum = sum + $var"

        ## Was the argument greater than 250?
        if [[ $var -gt 250 ]]; then
            ## If so, increment the sum found.
            let "twoFifty = twoFifty + 1"
        fi
    fi
## Done with the loop.
done

## Print the sum.
echo $sum $twoFifty