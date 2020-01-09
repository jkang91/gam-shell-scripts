#!/usr/bin/env bash

echo 'Onboarding shell script initiated' | cowsay

#Create a bash alias for GAM
gam='/Users/$USER/bin/gam/gam'
domain='@domain.com'

# Onboarding-Option Method
onboarding_option(){
    echo 'Enter the full username:'; read username;
    echo 'Verify the full username:'; read verification_username;
    echo 'Enter the employee'"'"'s first name:'; read first_name;
    echo 'Enter the employee'"'"'s last name:'; read last_name;
    echo 'Enter the employee office location (nyc, sfo, den, sea):'; read location;
}

# Onboarding-Yes Method
onboarding_yes(){
    #Start the onboarding process
    echo "Onboarding $first_name $last_name..."

    #Add new user email
    echo 'Adding a new user...'
    eval $gam create user $username@domain firstname $first_name lastname $last_name password 'P@ssw0rd!' suspended off gal on 
    wait

    #Add the new user to the appropriate user groups
    echo 'Adding the new user to all group...'
    eval $gam update group all@domain add member $username
    wait

    echo 'Adding the new user to the appropriate office group...'
    eval $gam update group $location@domain add member $username
    wait

    #Add the new user to the office calendars
    #echo 'Adding the new user to calendars...'
    #eval $gam user $username@domain add calendar 'ENTER_CALENDAR' selected true
    #wait

    # Verify if the account was succesfully created on G-Suite
    echo 'Verifying new employee'"'"'s G-Suite account status...'
    if eval $gam whatis $username@domain | grep -q "userNotFound"; then
        echo 'Onboarding not completed! Please check G-Suite for partially created resources!'
        else
        echo 'Onboarding completed!'
    fi
    exit
}

# Verification Failed Method
verification_failed(){    
    echo 'Onboarding script terminated! Please verify the new employee email address!'
    exit
}

# Verification Method
verification_check(){
    if [[ $username == $verification_username ]]; then
        onboarding_yes
    else
        verification_failed
    fi
}

#Onboarding-No Method
onboarding_no(){
    echo 'Onboarding aborted'
    exit
}

#Main Method
while true; do
    read -p "Do you wish to create a new user email using GAM? [yn]: " yn
    case $yn in
    #Yes => Proceed, #No => Terminate process, #* => Return back to menu
        [Yy]* )
            onboarding_option;
            verification_check;
            ;;
        [Nn]* )
            onboarding_no;
            ;;
        * )
            echo 'Please select options y or n.';
            ;;
    esac
done
