#!/usr/bin/env bash 

echo 'Offboarding shell script initiated' | cowsay

# Create a bash alias for GAM
gam='/Users/$USER/bin/gam/gam'
domain='@domain.com'

# Offboarding-Option Method
offboarding_option(){
    echo 'Enter the username:'; read username;
    echo 'Verify the username:'; read verification_username;
    echo 'Enter the manager'"'"'s username:'; read manager_username; 
    echo 'Verify the manager'"'"'s username:'; read verification_manager_username;
    echo 'Enter the employee'"'"'s first name:'; read first_name;
    echo 'Enter the employee'"'"'s last name:'; read last_name;
}

# Offboarding-Yes Method
offboarding_yes(){
    #Start the onboarding process
    echo "Offboarding $first_name $last_name..."

    #Change user password
    echo 'Changing user password...'
    #Generate a new random 8 character password based on time
    #new_password=`date +% | shasum | base64 | head -c 8`
    #echo $new_password
    eval $gam update user $username@domain password TEMPORARYPASSWORD
    wwait

    #Suspend user
    echo 'Suspending user...'
    eval $gam update user $username@domain suspended on 
    wait

    #Remove user from all groups
    echo 'Removing user from all groups...'
    eval $gam user $username@domain delete groups
    wait

    #Transfer user drive contents to the manager's account
    echo 'Transferring Google Drive contents from the user'"'"'s to the manager'"'"'s account...'
    eval $gam create datatransfer $username@domain gdrive $manager_username@domain
    wait

    #Transfer user drive contents to the manager's account
    #echo 'Transferring user drives to the manager...'
    #eval $gam user $autonomicemailaddress transfer gdrive $manager_email_address
    #wait

    #Release and transfer calendar resources to the manager's account
    echo 'Releasing and transferring calendar resources to the manager'"'"'s account...'
    eval $gam create datatransfer $username@domain calendar $manager_username@domain release_resources true
    wait

    #Verify if the termination was succesfully completed on G-Suite
    echo 'Verifying terminated G-Suite account status'
    if eval $gam info user $username@domain| grep -q "Account Suspended: True"; then
        echo 'Offboarding completed!'
        else
        echo 'Offboarding not completed! Please verify information again!'
    fi
    exit
}

# Verification Failed Method
verification_failed(){    
    echo 'Offboarding script terminated! Please verify the terminated employee email address!'
    exit
}

# Verification Method
verification_check(){
    if [[ ($username == $verification_username) && ($manager_username == $verification_manager_username) ]]; then
        offboarding_yes
    else
        verification_failed
    fi
}

# Onboarding-No Method
offboarding_no(){
    echo 'Offboarding aborted'
    exit
}

# Main Method
while true; do
    read -p "Do you wish to proceed with GAM off-boarding process? [yn]: " yn
    case $yn in
    #Yes => Proceed, #No => Terminate process
        [Yy]* )
            offboarding_option;
            verification_check;
            ;;
        [Nn]* )
            offboarding_no;
            ;;
        * )
            echo 'Please select options y or n.';
            ;;
    esac
done
