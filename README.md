Linux User Creation Bash Script – DevOps Assessment
Overview

This project is a Bash automation script that helps a SysOps engineer easily create multiple users and groups in a Linux environment. The script reads details from a text file containing usernames and their assigned groups, then performs user creation, password setup, permission configuration, and logging automatically.

Objective

The goal of this script is to:

Automate user and group creation for new employees.

Assign each user to the correct groups as mentioned in the input file.

Generate secure random passwords for every user.

Maintain proper ownership and permissions for user home directories.

Keep a detailed log of all activities and errors.

Store all generated passwords securely in a restricted file.


How It Works

Input File Processing
The script reads a text file that contains usernames and their group names.
Each line follows the format:
username; group1,group2,group3
The script automatically ignores spaces.

Personal Group Creation
Every user gets a personal group that matches their username, even if it’s not mentioned in the input file.

Additional Group Assignment
If extra groups are mentioned, the user is added to those as secondary groups.

User Creation and Home Setup
The script creates each user account, sets up their home directory, and ensures it has proper ownership and permissions.

Password Generation and Storage
A strong random password is generated for each user.
These passwords are securely stored in /var/secure/user_passwords.txt, where only the root user has read access.

Logging of Activities
Every step — including user creation, group creation, and errors — is recorded in /var/log/user_management.log.
This helps in tracking what operations were performed and if any failed.

Error Handling
The script checks if a user or group already exists and handles such cases gracefully without interrupting execution.

Conclusion

This project demonstrates practical DevOps automation using Bash scripting.
It simplifies the task of user onboarding by eliminating manual steps, improving consistency, and ensuring that all user management actions are properly logged and secured.
