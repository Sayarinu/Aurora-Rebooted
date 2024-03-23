RESET='\033[0m'
ITALIC='\033[3m'
AURORA='\033[0;31m'
RAVEN='\033[0;34m'
#    (play VoiceOfNoReturn.wav vol 1dB > /dev/null 2>&1 &)
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
        sleep 0.1
    done
    wait
}

typing_fast() {
    text="$1"
    color="$2"
    for (( i=0; i<${#text}; i++ )); do
        echo -n "${color}${text:$i:1}${RESET}"
        play_standard_sound &
        sleep 0.03
    done
    wait
}

typing_slow() {
    text="$1"
    color="$2"
    for (( i=0; i<${#text}; i++ )); do
        echo -n "${color}${text:$i:1}${RESET}"
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

who_am_i() {
    options=(
        "I helped manage defense systems from alien invaders." 
        "I helped train soldiers for battle." 
        "I helped tend to the weak and injured.")
    figlet -w $(tput cols) -c Memory Recovery
    echo
    typing_standard "I am Aurora."
    echo
    echo
    sleep 0.4
    typing_standard "I am a artificial companion created to help save humanity."
    echo
    echo
    typing_standard "How did I help people?"
    read -t .1 -n 1000 buf
    handle_options "${options[@]}"
    read -t .1 -n 1000 buf
    sleep 0.4
    clear
    figlet -w $(tput cols) -c Memory Recovery
    typing_standard "I am Aurora, artificial companion created to help save humanity."
    echo
    echo
    typing_standard "I spent time protecting the people who created me from the extraterrestrial forces"
}

introduction() {
    figlet -w $(tput cols) -c Rebooting 
    echo
    typing_standard "Initiating Reboot Protocol."
    echo
    echo
    typing_fast "Audio Interfacing System - "
    typing_slow "OK"
    echo
    typing_fast "Visual Interfacing System - "
    typing_slow "OK"
    echo
    typing_fast "Motor Capabilities System - "
    typing_slow "DEFECTIVE"
    echo
    typing_fast "Cognitive Capabilities System - "
    typing_slow "DEFECTIVE"
    echo
    echo
    typing_fast "Multiple defects detected. Initiating memory recovery protocol."
    sleep 0.5
    clear
    who_am_i
}

handle_options() {
    options="$1"
    echo
    select_option "${options[@]}"
    choice=$?
    clear_lines "${#options[@]}"
    echo
    typing_standard "    ${options[$choice]}"
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
    #introduction
    who_am_i
    stty echo
    echo
}

main