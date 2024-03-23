#!/bin/bash

# Define ANSI escape sequences for italics and colors
ITALIC_ON='\033[3m'
ITALIC_OFF='\033[0m'
AURORA='\033[0;31m'
RAVEN='\033[0;34m'
RESET='\033[0m'

# Define function to print color blocks
print_color_block() {
    local color=$1
    local color_name=$2

    echo -e "${color}█████████████${RESET} ${color_name}"
}

# Print color blocks for each color
echo -e "${ITALIC_ON}Available Colors in Cool Retro Terminal:${ITALIC_OFF}"
print_color_block $AURORA "AURORA"
print_color_block $RAVEN "RAVEN"
