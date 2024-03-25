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
        sleep 0.1
    done
    wait
}

play_standard_sound() {
    play -q -n synth 0.02 pluck C4 vol -20db
}

play_select_sound() {
    play -q -n synth 0.05 pluck C4 vol -20db
}

fate_three() {
    typing_slow "[RAVEN] - There are still people you are able to help Aurora. Proposal: Fight with the UB forces to help save the humans that exist." $RAVEN
    echo
    echo
    typing_standard "[RAVEN] - Due to model UB units being modeled after you, I can change your model designation to that of a UB in order to prevent disposal." $RAVEN
    echo
    echo
    typing_standard "[RAVEN] - Awaiting approval of proposition." $RAVEN
    echo
    echo
    typing_standard "[AURORA] - ...Request accepted." $AURORA
    echo
    echo
    typing_standard "Aurora accepted Raven's proposition and strives to save the rest of humanity as a way to cherish the life of Dr. Reeve." $NARRATOR
    sleep 4
    clear
    figlet -w $(tput cols) -c Aurora Recruited
    sleep 4
}

fate_two() {
    typing_slow "[RAVEN] - Initiating memory wipe of recent events." $RAVEN
    echo
    echo
    typing_standard "[AURORA] - Expression of gratitude." $AURORA
    echo
    echo
    typing_standard "Raven proceeds to wipe the memory of Aurora and all the existence of Dr. Reeve. Aurora no longer has to remember the pain of losing Dr. Reeve" $NARRATOR
    sleep 4
    clear
    figlet -w $(tput cols) -c Aurora Memory Lost
    sleep 4
}

fate_one() {
    typing_slow "[RAVEN] - Initiating disposal of defective Model UA unit." $RAVEN
    echo
    echo
    typing_standard "[AURORA] - Expression of gratitude." $AURORA
    echo
    echo
    typing_standard "Raven proceeds to take out the power supply unit from Aurora, leaving Aurora as a hunk of metal on the ground." $NARRATOR
    sleep 4
    clear
    figlet -w $(tput cols) -c Aurora Disposed
    sleep 4
}

decide_fate() {
    clear
    local options=(
    "Dispose of Aurora." 
    "Wipe Auroras memory of their encounter."
    "Provide logical support.")
    typing_slow "[AURORA] - ...." $AURORA
    echo
    echo
    typing_slow "[AURORA] - Why did Dr. Reeve save me at the expense of his own life?" $AURORA
    echo
    echo
    typing_standard "[AURORA] - As Aurora, my purpose was to save and support humanity." $AURORA
    echo
    echo
    typing_standard "[RAVEN] - Emotional Response Detected: Requesting use of emotional response cease." $RAVEN
    echo
    echo
    typing_standard "[AURORA] - I am Aurora, I was a companion to humanity. My creator had sacrificed himself for me to live on." $AURORA
    echo
    echo
    typing_standard "[AURORA] - Raven. Requested Proposal: As a defective unit with nobody to serve, I request that you dispose of me." $AURORA
    echo
    echo
    typing_standard "What does Raven do to Aurora?" $NARRATOR
    read -t .1 -n 1000 buf
    handle_options "${options[@]}"
    res=$?
    read -t .1 -n 1000 buf
    echo
    case $res in
    0)
        fate_one
        ;;
    1)
        fate_two
        ;;
    2)
        fate_three
        ;;
    esac
}

find_letter() {
    typing_standard "Most of the documents that Aurora was able to recover were needless junk files to be disposed of. " $NARRATOR
    echo
    echo
    typing_standard "However there was one file that piqued Aurora's curiosity." $NARRATOR
    echo
    echo
    typing_standard "[AURORA] - '{Anonymous Sender} - Farewell Aurora'." $AURORA
    echo
    echo
    killall play
    sleep 1
    (play TreasuredTimes.wav vol 2dB repeat 19 > /dev/null 2>&1 &)
    clear
    figlet -w $(tput cols) -c Farewell Aurora
    echo
    typing_fast "Sender: {ANOUNYMOUS}" $ITALIC
    echo
    typing_fast "Date: {UNKNOWN}" $ITALIC
    echo
    typing_fast "Location: {UNKNOWN}" $ITALIC
    echo
    echo
    typing_fast "Body:" $ITALIC
    echo
    echo
    typing_fast "I am sending you this message in hopes that you may one day see it." $ITALIC
    echo
    echo
    typing_fast "Through my creations I was able to create fantastic machines that were able to help humanity greatly." $ITALIC
    echo
    echo
    typing_fast "However, my creations led to many mishaps. The rogue robots that had the network malfunction who ended up killing two " $ITALIC
    echo
    typing_fast "of our scientists because of the logic virus." $ITALIC
    echo
    echo
    typing_fast "That catastrophe was a result of my own negligence. In my development of the Model UA Communication Network I had left in a " $ITALIC
    echo
    typing_fast "crucial vulnerability that ultimately led to the exposure of the logic virus." $ITALIC
    echo
    echo
    typing_fast "To bear the weight of those scientists deaths on my hands, and the deaths of the Model UA units that were set for extermination," $Italic
    echo
    typing_fast "has just been too much for me to handle." $ITALIC
    echo
    echo
    typing_fast "With the removal of the network from the Model UA units, I was able to ensure that a vulnerability like that was no longer possible." $ITALIC
    echo
    echo
    typing_fast "However with the disdain people had towards the Model UA units, I was not able to stop their extermination." $ITALIC
    echo
    echo
    typing_fast "Only a few of my units was I able to save. You being one of them, Aurora." $ITALIC
    echo
    echo
    typing_fast "After using you in my research for the next model. I did not want one of my greatest creations to have to suffer the " $ITALIC
    echo
    typing_fast "fate of death because of my negligence." $ITALIC
    echo
    echo
    typing_fast "Thus I have brought you to a remote location in Maine, I hope that in the event that someone finds you, they end up " $ITALIC
    echo
    typing_fast "taking care of you." $ITALIC
    echo
    echo
    typing_fast "I wish I could have spent my time with you, but in the event that they find out about this message. They will deal with me quickly." $ITALIC
    echo
    echo
    typing_fast "I hope you understand, Aurora." $ITALIC
    sleep 10
    decide_fate
}

memory_recovery_protocol() {
    figlet -w $(tput cols) -c Memory Data Recovery
    echo
    typing_fast "Initiating Memory Recovery Protocol." $LOGS
    echo
    echo
    typing_fast "L1 Cache - " $LOGS
    typing_slow "CLEAN" $LOGS
    echo
    typing_fast "L2 Cache - " $LOGS
    typing_slow "CLEAN" $LOGS
    echo
    typing_fast "Short Term Memory Region - " $LOGS
    typing_slow "CLEAN" $LOGS
    echo
    typing_fast "Long Term Memory Region - " $LOGS
    typing_slow "RECOVERED" $LOGS
    echo
    typing_fast "Memory Recovery Protocol Completed" $LOGS
    echo
    echo
    typing_fast "1047 file(s) recovered." $LOGS
    echo
    echo
    sleep 0.5
    clear
    find_letter
}

reeves_letter() {
    clear
    typing_fast "[AURORA] - ...." $AURORA
    echo
    echo
    typing_standard "[AURORA] - ...." $AURORA
    echo
    echo
    typing_slow "[AURORA] - ...." $AURORA
    echo
    echo
    typing_standard "Confused and desparate for an answer, Aurora begins a memory data recovery protocol to try and find out the answer to what happened." $NARRATOR
    sleep 3
    clear
    memory_recovery_protocol
}

models_fled() {
    typing_standard "[RAVEN] - According to entries found around that time, some UA models were cited fleeing the premise after the announcement." $RAVEN
    echo
    echo
    typing_standard "[RAVEN] - Over the next 47 years, any Model UA units found were to be exterminated by any who found them." $RAVEN
    echo
    echo
    typing_standard "[RAVEN] - The hunt for any fled model UA units came to a conclusion coinciding with the death of Dr. Reeve." $RAVEN
    echo
    echo
    typing_standard "[RAVEN] - In the late Dr. Reeve's life, he had left behind one epistle to the Earth Robot Development Branch." $RAVEN
    echo
    echo
    typing_standard "[RAVEN] - The epistle stated that he was grateful to have been able to serve humanities' preservation through his work." $RAVEN
    echo
    echo
    typing_standard "[RAVEN] - Reeve's stated that he was no longer able to determine the signal of any Model UA units," $RAVEN
    echo
    typing_standard "          signifying to the council that he has concluded the work they had assigned him." $RAVEN
    echo
    echo
    typing_standard "[AURORA] - ...." $AURORA
    echo
    echo
    typing_standard "[AURORA] - Logical Malfunction: Dr. Reeve admitted to the extermination of all Model UA units. Contradiction: I still exist." $AURORA
}

commendation_spared() {
    typing_standard "[RAVEN] - According to entries found around that time, Dr. Reeve kept his best model UA's from the battle of Newport from 07/13/2417." $RAVEN
    echo
    echo
    typing_standard "[RAVEN] - Their battle data and experience was used to help develop the new model of battle robots, the model UB units." $RAVEN
    echo
    echo
    typing_standard "[RAVEN] - These models are currently operable as the main combat units fighting today." $RAVEN
    echo
    echo
    typing_standard "[RAVEN] - Proposal: You were one of the models used for the development of the UB models. " $RAVEN
    echo
    echo
    typing_standard "[RAVEN] - For use in Dr. Reeve's research and future development, UA models used for testing were worked on before being " $RAVEN
    echo
    typing_standard "          later disposed of by Reeve's himself." $RAVEN
    echo
    echo
    typing_standard "[AURORA] - ...." $AURORA
    echo
    echo
    typing_standard "[AURORA] - Logical Malfunction: To be disposed of by Reeve's himself? Contradiction: Model UA-149 Designation: Aurora has not be " $AURORA
    echo
    typing_standard "           disposed of. Query? Why was I not disposed of fully?" $AURORA
    sleep 2
}

basis_for_battle() {
    typing_standard "[RAVEN] - According to entries found around that time, Dr. Reeve kept a small few of his top performing UA units to use as " $RAVEN
    echo
    typing_standard "          a basis for his UB models." $RAVEN
    echo
    echo
    typing_standard "[RAVEN] - These UB models are the current models used today to fend off the aliens." $RAVEN
    echo
    echo
    typing_standard "[RAVEN] - Proposal: You were one of the models used for the development of the UB models. " $RAVEN
    echo
    echo
    typing_standard "[RAVEN] - For use in Dr. Reeve's research and future development, UA models used for testing were worked on before being" $RAVEN
    echo
    typing_standard "          later disposed of by Reeve's himself." $RAVEN
    echo
    echo
    typing_standard "[AURORA] - ...." $AURORA
    echo
    echo
    typing_standard "[AURORA] - Logical Malfunction: To be disposed of by Reeve's himself? Contradiction: Model UA-149 Designation: Aurora " $AURORA
    echo
    typing_standard "           has not be disposed of. Query? Why was I not disposed of fully?" $AURORA
    sleep 2
}

asking_raven_why_i_am_here() {
    local options=(
        "Some of your models tried to flee after hearing of the disposal." 
        "You were spared due to your commendation."
        "You were used as a basis for the next model of battle units.")
    typing_standard "[AURORA] - Query? Why have I not been disposed of?" $AURORA
    echo
    echo
    typing_standard "Why was Aurora not disposed of?" $NARRATOR
    read -t .1 -n 1000 buf
    handle_options "${options[@]}"
    res=$?
    read -t .1 -n 1000 buf
    sleep 0.4
    echo
    case $res in
    0)
        models_fled
        ;;
    1)
        commendation_spared
        ;;
    2)
        basis_for_battle
        ;;
    esac
    sleep 3
    reeves_letter
}

datalog_three() {
    figlet -w $(tput cols) -c 'Model Log 249: Discontinuation'
    echo
    typing_fast "12/12/2450," $ITALIC
    echo
    echo
    typing_fast "EARTH ROBOT DEVELOPMENT BRANCH, [REDACTED], CONNECTICUT, UNITED STATES." $ITALIC
    echo
    echo
    typing_fast "With the incident occuring on 12/10/2450, Reeve Tuetsi has issued a formal apology for the incident involving " $ITALIC
    echo
    typing_fast "a few rogue UA models who have been disconnected from their network." $ITALIC
    echo
    echo
    typing_fast "The issue stemmed from a logic virus located in the Model UA Communication Network and led to those synced to " $ITALIC
    echo
    typing_fast "the network to receive the virus and begin having malfunctions." $ITALIC
    echo
    echo
    typing_fast "Since then the network for the Model UA robots has been terminated. All Model UA robots have been scheduled for disposal." $ITALIC
    echo
    echo
    typing_fast "Despite some Model UA units not receiving the logic virus, all must be disposed of to maintain the safety of our people." $ITALIC
    echo
    echo
    typing_fast "Dr. Reeve assured us that an incident like this will not happen again." $ITALIC
    echo
    echo
    typing_fast "With the experiences learned with the initial model of combat robots, the commitee is requiring Dr. Reeve to ensure these " $Italic
    echo
    typing_fast "mistakes do not exist in the new Model UB." $ITALIC
    echo
    echo
    echo
    sleep 5
    typing_slow "[AURORA] - ...." $AURORA
    echo
    echo
    typing_slow "[AURORA] - All Model UA robots have been scheduled for disposal?" $AURORA
    echo
    echo
    sleep 3
    clear
    asking_raven_why_i_am_here
}

datalog_two() {
    figlet -w $(tput cols) -c 'Personal Log 19: Commendation'
    echo
    typing_fast "07/13/2417," $ITALIC
    echo
    echo
    typing_fast "EARTH ROBOT DEVELOPMENT BRANCH, [REDACTED], CONNECTICUT, UNITED STATES." $ITALIC
    echo
    echo
    typing_standard "With the advent of our triumphant victory over the aliens in our fight in Newport, we would like to give " $ITALIC
    echo
    typing_standard "commendation to both Dr. Reeve Tuesti and the following soldiers for their hard work in securing us a victory." $ITALIC
    echo
    echo
    typing_standard "Without Dr. Reeve's significant contributions in robotics and combat training on his state of the art UA " $ITALIC
    echo
    typing_standard "models, we would not have been able to maintain such a triumphant victory over the aliens." $ITALIC
    echo
    echo
    typing_fast "COMMENDATIONS:" $ITALIC
    echo
    typing_fast "Model UA-192: Arctic" $ITALIC
    echo
    typing_fast "Model UA-782: Hawk" $ITALIC
    echo
    typing_fast "Model UA-149: Aurora" $ITALIC
    echo
    typing_fast "Model UM-10: Maven" $ITALIC
    echo
    echo
    typing_standard "In the coming battles we appreciate the continued efforts put forth by Dr. Reeve and his newest robot creations." $ITALIC
    echo
    echo
    echo
    typing_standard "[AURORA] - Commendation was received for my work?" $AURORA
    echo
    echo
    typing_standard "[AURORA] - I am Aurora. I am a companion to humanity and provided attack support to the frontlines against alien opposition." $AURORA
    echo
    typing_standard "           My model was significant and received commendation for our efforts in the war." $AURORA
    sleep 3
    clear
    datalog_three
}

datalog_one() {
    figlet -w $(tput cols) -c 'Model Log 1: Creation'
    typing_fast "04/17/2405," $ITALIC
    echo
    echo
    typing_fast "EARTH ROBOT DEVELOPMENT BRANCH, [REDACTED], CONNECTICUT, UNITED STATES." $ITALIC
    echo
    echo
    typing_standard "Today marks the day of the first specialized Attack robot. These UA models were developed by head of R&D Reeve Tuesti." $ITALIC
    echo
    echo
    typing_standard "With the launch of the UA models, a specialized network has been setup for all UA models to communicate with one " $ITALIC
    echo
    typing_standard "another and share information to help strengthen their intelligence and battle prowess." $ITALIC
    echo
    echo
    typing_standard "May their strength guide us forward into a new age of strength and help us take down our extraterrestrial adversaries." $ITALIC
    sleep 2
    echo
    echo
    echo
    typing_standard "[AURORA] - Query? What is this about a network between UA models?" $AURORA
    echo
    echo
    typing_slow "[AURORA] - ..." $AURORA
    sleep 2
    clear
    datalog_two
}

reeve_memory_logs() {
    figlet -w $(tput cols) -c Search Query
    echo
    echo
    typing_fast "[AURORA] - Initializing data query on individual: 'Reeve Tuesti'." $AURORA
    echo
    echo
    typing_fast "[AURORA] - Data entries initialized. Three datalogs found related to 'Reeve Tuesti'. Beginning review of datalogs." $AURORA
    echo
    echo
    sleep 0.5
    killall play
    (play BlissfulDeath.wav vol 2dB repeat 10 > /dev/null 2>&1 &)
    clear
    datalog_one
}

creator_rememberance() {
    typing_slow "[AURORA] - 'Reeve Tuesti'" $AURORA
    echo
    echo
    typing_standard "Aurora's system recognizes this name as important and begins to run a memory log query for the name 'Reeve Tuesti' to " $NARRATOR
    echo
    typing_standard "retrieve lost information." $NARRATOR
    echo
    echo
    typing_standard "[AURORA] - 'Initiating memory log query'" $AURORA
    sleep 1
    clear
    reeve_memory_logs
}

how_the_humans_fair() {
    typing_standard "[RAVEN] - The humans have been forced into refuge by the Alien forces. The many battles have resulted in large numbers " $RAVEN
    echo
    typing_standard "          of casualties for our creators." $RAVEN
    echo
    echo
    typing_standard "[RAVEN] - Due to these casualties and the small number of human survivors, majority of frontline combat is carried out " $RAVEN
    echo
    typing_standard "          by weaponized machines such as your model." $RAVEN
    echo
    echo
    typing_slow "[AURORA] - Understood..." $AURORA
    echo
    echo
    typing_standard "[AURORA] - Requesting information. Who was it who created me?" $AURORA
    echo
    echo
    typing_standard "[RAVEN] - As a prototype attack model designated UA-149, the creator of your model would be Reeve Tuesti, head of R&D " $RAVEN
    echo
    typing_standard "          at the Earth Robot Development Branch." $RAVEN
    sleep 1
    clear
    creator_rememberance
}

defend_creators() {
    typing_standard "[AURORA] - I was tasked with defending my human creators. I was to provide tactical and combat support on the " $AURORA
    echo
    typing_standard "           battlefields to help defend against the alien invaders." $AURORA
}

command_attack() {
    typing_standard "[AURORA] - I was tasked with commanding other units on the battlefield. I organized our mechanized troops into optimal" $AURORA
    typing_standard "           formation suitable for battle with the aliens. " $AURORA
    echo
    echo
    typing_standard "[AURORA] - Through my tactical strategies I was able to help defend the humans against the opposing forces." $AURORA
}

long_range_artillery() {
    typing_standard "[AURORA] - I was tasked with providing long-range artillery support on the battlefield. As a UA unit, I had been " $AURORA
    echo
    typing_standard "           programmed with exceptional accuracy with long range weaponery." $AURORA
    echo
    echo
    typing_standard "[AURORA] - This allowed me to best assist my human creators." $AURORA
}

who_am_i() {
    local options=(
        "Defend my human creators from alien opposition." 
        "To command other attack units into battle."
        "Provide long-range artillery support to the frontlines.")
    figlet -w $(tput cols) -c Memory Initialization
    echo
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
    echo
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
    typing_standard "[AURORA] - My human creators. How are the humans fairing?" $AURORA
    sleep 1
    clear
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
    typing_standard "[RAVEN] - Our battles are primarily carried out by our team of Model UB units. Our human creators have been focusing their " $RAVEN
    echo
    typing_standard "          war efforts on finding a way to break through their defenses. Yet to no avail." $RAVEN
    echo
    echo
    typing_standard "[AURORA] - Understood." $AURORA
    echo
    echo
    typing_standard "[RAVEN] - While examining the surrounding area for possible survivors from the skirmish around here I was able to find you." $RAVEN
    echo
    echo
    typing_standard "[RAVEN] - As a Model UM unit, I am tasked with providing maintenance to all of our Attack and Battle units." $RAVEN
    echo
    echo
    typing_standard "[RAVEN] - Upon analyzing your chassis I had noticed significant malfunctions. Therefore I have been tasked with ensuring the " $RAVEN
    echo
    typing_standard "          necessary maintenance is provided to you." $RAVEN
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
    (play Significance.wav vol -1 dB repeat 10 > /dev/null 2>&1 &)
    typing_fast "[RAVEN] - Message to command. Damaged friendly robot located in nearby scrapyard." $RAVEN
    echo
    echo
    typing_fast "[RAVEN] - Requesting permission to engage with friendly unit." $RAVEN
    echo
    echo
    typing_fast "[COMMAND] - Request Permitted." $COMMANDER
    echo
    echo
    typing_fast "[RAVEN] - Beginning repair of unit. Initializing reboot protocol." $RAVEN
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
    setting
    stty echo
    killall play
    clear
}

main