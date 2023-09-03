#!/bin/sh

output="/root/multiple_port_scan_result.log"
recipient="support@grinbux.com"
sender_name="Grin Archive Node Chicago"
sender_email="support@grinbux.com"
# Get current date and time in UTC
current_datetime=$(date -u +"%Y-%m-%d %H:%M:%S UTC")

# Create a custom subject with the current date and time
subject="Grin nodes results $current_datetime"
# Clear the output file or create a new one
> "$output"
for server in $(cat server-list.txt);
do
	for port in $(cat port-list.txt);
	do
		#echo $server
		nc -zvw3 "$server" "$port" 2>&1 | tee -a "$output"
		echo "" >> "$output"
done
done 
# Read the content of the output file into the email body
email_body=$(cat "$output")

# Send the email using the mail command with sender's name, email, subject, and body
(
echo "Subject: $subject"
echo "To: $recipient"
echo "From: $sender_name <$sender_email>"
echo
echo "$email_body"
) | /usr/sbin/sendmail -t -oi
