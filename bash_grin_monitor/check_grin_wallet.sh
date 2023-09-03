#!/bin/bash

# Set the recipient's email address
recipient_email="support@grinbux.com"

# Set the sender's name and email address
sender_name="Grin-wallet checker"
sender_email="support@grinbux.com"

# Get the current UTC date and time
current_datetime=$(date -u +"%Y-%m-%d %H:%M:%S UTC")

# Define the subject of the email
email_subject="Grin Wallets Check - $current_datetime"

# Read the list of Grin wallet addresses and corresponding IP addresses from an external file
addresses_file="grin_wallet_addresses_with_ips.txt"
wallet_addresses=()
ip_addresses=()

while read -r line; do
    wallet_address=$(echo "$line" | cut -d ' ' -f 1)
    ip_address=$(echo "$line" | cut -d ' ' -f 2)
    wallet_addresses+=("$wallet_address")
    ip_addresses+=("$ip_address")
done < "$addresses_file"

# Initialize variables to store email content and terminal output
email_content=""
terminal_output=""

# Loop through each wallet address and its corresponding IP address
for ((i = 0; i < ${#wallet_addresses[@]}; i++)); do
    grin_address="${wallet_addresses[i]}"
    ip_address="${ip_addresses[i]}"

    response=$(curl -s "https://grinnode.live:8080/walletcheck/$grin_address")
    is_wallet_valid=$(echo "$response" | jq -r '.isWalletValid')

    if [ "$is_wallet_valid" == "true" ]; then
        result="Grin address $grin_address is online. (IP: $ip_address)"
    elif [ "$is_wallet_valid" == "false" ]; then
        result="Grin address $grin_address is not online. (IP: $ip_address)"
    else
        result="Unable to determine status for Grin address $grin_address. (IP: $ip_address)"
    fi

    email_content+="\n$result"
    terminal_output+="\n$result"
done

# Display the results in the terminal
echo -e "Grin Wallets Check Results:$terminal_output"

# Send the email with the results
echo -e "$email_content" | mail -s "$email_subject" -a "From: $sender_name <$sender_email>" "$recipient_email"
