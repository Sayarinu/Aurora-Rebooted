RESET='\033[0m'
ITALIC='\033[3m'
AURORA='\033[0;31m'
RAVEN='\033[0;34m'
COMMANDER='\033[0;32m'
NARRATOR='\033[0;33m'
LOGS='\033[0;36m'
#    (play VoiceOfNoReturn.wav vol 1dB -repeat > /dev/null 2>&1 &)
# killall play

select_option() {
    ESC=$( printf "\033")
    cursor_blink_on()  { printf "$ESC[?25h"; }
    cursor_blink_off() { printf "$ESC[?25l"; }
    cursor_to()        { printf "$ESC[$1;${2:-1}H"; }
    print_option()     { printf "   $1 "; }
    print_selected()   { printf "  $ESC[7m $1 $ESC[27m"; }
    get_cursor_row()   { IFS=';' read -sdR -p $'\E[6n' ROW COL; echo ${ROW#*[}; }
    key_input()        { read -s -n3 key 2>/dev/null >&2
    case $key in
        "$ESC[A")
            play_select_sound
            echo up
            ;;
        "$ESC[B")
            play_select_sound
            echo down
            ;;
        "")
            echo enter
            ;;
    esac
    }


    for opt; do printf "\n"; done

    local lastrow=`get_cursor_row`
    local startrow=$(($lastrow - $#))

    trap "cursor_blink_on; stty echo; printf '\n'; exit" 2
    cursor_blink_off

    local selected=0
    while true; do
        local idx=0
        for opt; do
            cursor_to $(($startrow + $idx))
            if [ $idx -eq $selected ]; then
                print_selected "$opt"
            else
                print_option "$opt"
            fi
            ((idx++))
        done

        case `key_input` in
            enter) break;;
            up)    ((selected--));
                if [ $selected -lt 0 ]; then 
                    selected=$(($# - 1)); 
                fi;;
            down)  ((selected++));
                if [ $selected -ge $# ]; then 
                    selected=0; 
                fi;;
        esac
    done

    cursor_to $lastrow
    printf "\n"
    cursor_blink_on

    return $selected
}

typing_standard() {
    text="$1"
    color="$2"
    for (( i=0; i<${#text}; i++ )); do
        echo -en "${color}${text:$i:1}${RESET}"
        play_standard_sound &
        sleep 0.05
    done
    wait
}

typing_fast() {
    text="$1"
    color="$2"
    for (( i=0; i<${#text}; i++ )); do
        echo -en "${color}${text:$i:1}${RESET}"
        play_standard_sound &
        sleep 0.03
    done
    wait
}

typing_slow() {
    text="$1"
    color="$2"
    for (( i=0; i<${#text}; i++ )); do
        echo -en "${color}${text:$i:1}${RESET}"
        play_standard_sound &
        sleep 0.3
    done
    wait
}

play_standard_sound() {
    play -q -n synth 0.02 pluck C4 vol -20db
}

play_select_sound() {
    play -q -n synth 0.05 pluck C4 vol -20db
}

how_the_humans_fair() {
    clear
}

defend_creators() {
    typing_standard "[AURORA] - I was tasked with defending my human creators. I was to provide tactical and combat support on the battlefields to help defend against the alien invaders." $AURORA
}

command_attack() {
    typing_standard "[AURORA] - I was tasked with commanding other units on the battlefield. I organized our mechanized troops into optimal formation suitable for battle with the aliens. " $AURORA
    echo
    echo
    typing_standard "[AURORA] - Through my tactical strategies I was able to help defend the humans against the opposing forces." $AURORA
}

long_range_artillery() {
    typing_standard "[AURORA] - I was tasked with providing long-range artillery support on the battlefield. As a UA unit, I had been programmed with exceptional accuracy with long range weaponery." $AURORA
    echo
    echo
    typing_standard "[AURORA] - This allowed me to best assist my human creators." $AURORA
}

who_am_i() {
    options=(
        "Defend my human creators from alien opposition." 
        "To command other attack units into battle."
        "Provide long-range artillery support to the frontlines.")
    figlet -w $(tput cols) -c Memory Initialization
    echo
    typing_standard "[AURORA] - I am Aurora." $AURORA
    echo
    echo
    sleep 0.4
    typing_standard "[AURORA] - I am an artificial companion created to help save humanity." $AURORA
    echo
    echo
    typing_standard "What was my purpose as a UA model?" $NARRATOR
    read -t .1 -n 1000 buf
    handle_options "${options[@]}"
    res=$?
    read -t .1 -n 1000 buf
    sleep 0.4
    clear
    figlet -w $(tput cols) -c Memory Initialization
    typing_standard "[AURORA] - I am Aurora, artificial companion created to help save humanity." $AURORA
    echo
    echo
    case $res in
    0)
        defend_creators
        ;;
    1)
        command_attack
        ;;
    2)
        long_range_artillery
        ;;
    esac
    echo
    echo
    typing_standard "[AURORA] - My human creators. How are the humans fairing." $AURORA
    sleep 1
    how_the_humans_fair
}

current_state_of_affairs() {
    clear
    typing_standard "[AURORA] - Requesting update on current state of affairs." $AURORA
    echo
    echo
    typing_standard "[RAVEN] - Aliens have continued their invasion of Earth. Many of the humans have lost their lives in the war." $RAVEN
    echo
    echo
    typing_standard "[RAVEN] - Our battles are primarily carried out by our team of UB-159 models. Our human creators have been focusing their war efforts on finding a way to break through their defenses. Yet to no avail." $RAVEN
    echo
    echo
    typing_standard "[AURORA] - Understood." $AURORA
    echo
    echo
    typing_standard "[RAVEN] - While examining the surrounding area for possible survivors from the skirmish around here I was able to find you." $RAVEN
    echo
    echo
    typing_standard "[RAVEN] - As a UM-253 model I am tasked with providing maintenance to all of our Attack and Battle units." $RAVEN
    echo
    echo
    typing_standard "[RAVEN] - Upon analyzing your chassis I had noticed significant malfunctions. Therefore I have been tasked with ensuring the necessary maintenance is provided to you." $RAVEN
    echo
    echo
    typing_standard "[RAVEN] - I have also noticed significant long-term memory storage corruption in unit. Initiating onboard memory initialization." $RAVEN
    sleep 1
    clear
    who_am_i
}

date_and_time() {
    typing_standard "[AURORA] - I am Aurora." $AURORA
    echo
    echo
    typing_standard "[AURORA] - Reinitialization of system information required. Information requested. Please inform me of the current date and time." $AURORA
    echo
    echo
    typing_fast "[RAVEN] - May 10th, 3429. 14:54." $RAVEN
    echo
    echo
    typing_standard "[AURORA] - Affirmative, date and time information registered. Information requested. Current location." $AURORA
    echo
    echo
    typing_fast "[RAVEN] - Yorktown Maine, United States of America." $RAVEN
    echo
    echo
    typing_standard "[AURORA] - Information received. Initializing system reboot." $AURORA
    sleep 0.5
    clear
    current_state_of_affairs
}

introduction() {
    figlet -w $(tput cols) -c Rebooting
    echo
    typing_fast "Initiating Reboot Protocol." $LOGS
    echo
    echo
    typing_fast "Audio Interfacing System - " $LOGS
    typing_slow "OK" $LOGS
    echo
    typing_fast "Visual Interfacing System - " $LOGS
    typing_slow "OK" $LOGS
    echo
    typing_fast "Motor Capabilities System - " $LOGS
    typing_slow "DEFECTIVE" $LOGS
    echo
    typing_fast "Cognitive Capabilities System - " $LOGS
    typing_slow "DEFECTIVE" $LOGS
    echo
    echo
    typing_fast "Multiple defects detected. Initiating memory recovery protocol." $LOGS
    sleep 0.5
    clear
    date_and_time
}

setting() {
    typing_fast "[RAVEN] - Message to command. Damaged robot model UA-149 located in nearby scrapyard." $RAVEN
    echo
    echo
    typing_fast "[RAVEN] - Requesting permission to engage with model UA-149." $RAVEN
    echo
    echo
    typing_fast "[COMMAND] - Request Permitted." $COMMANDER
    echo
    echo
    typing_fast "[RAVEN] - Beginning repair of model UA-149. Initializing reboot protocol." $RAVEN
    sleep 0.5
    clear
    introduction
}

handle_options() {
    options="$1"
    echo
    select_option "${options[@]}"
    choice=$?
    clear_lines "${#options[@]}"
    echo
    typing_standard "    ${options[$choice]}"
    return $choice
}

clear_lines() {
    amount="$1"
    amount=$((amount * 2 - 1))
    local i
    for ((i=0; i<$amount; i++)); do
        tput el
        tput cuu1
    done
}

main() {
    stty -echo
    clear
    #setting
    who_am_i
    stty echo
    clear
}

main