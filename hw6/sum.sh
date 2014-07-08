#!/bin/bash

# Ian Nelson
# CMIS325
# Homework 6
# Summation shell script

## Assign the sum to zero.
sum=0

## Assign the threshold to zero.
threshold=0

## Create a pattern to match integers (+/-)
regex='^-?[0-9]+([.][0-9]+)?$'

## If the number of arguments is zero, print help.
if [[ $# == 0 ]] ; then
    echo "usage: 'sum.sh (-t) # # #'"
    echo "usage: Can pass any number of integers (positive or negative)."
    echo "usage: Script will die with a bad exit code of -1 if a non-integer is passed."
    echo "usage: -t : Threshold to add only when argument is greater than 10."
    exit;
fi

## For each command line argument ('...unspecified number of command
## line arguments' from assignment)
for var in "$@"; do
    ## Did user supply the threshold flag?
    if [[ $var == "-t" ]]; then
        threshold=1
    ## Nope.
    else
        ## Did the variable match the pattern?
        if ! [[ $var =~ $regex ]] ; then
            ## Print an error and die.
            echo "argument '$var' is not a number." >&2; exit -1
        ## Yes it did.
        else
            ## Are we dealing with the >10 threshold?
            if [[ $threshold == 1 ]]; then
                ## Is the argument greater than 10?
                if [[ $var -ge 10 ]]; then
                    let "sum = sum + $var"
                fi
            ## Nope. Just add.
            else
                let "sum = sum + $var"
            fi
        fi
    fi
## Done with the loop.
done

## Print the sum.
echo $sum