#!/bin/bash


#Part 1

#1.Automatically identify the LAN network range + 2.Automatically scan the current LAN + #3.Enumerate each live host
echo "Scanning for LAN network range, current LAN & Enumerate each live host"
	
sudo nmap 192.168.152.0/24 -sV -p- -O --exclude 192.168.152.1,192.168.152.2,192.168.152.254 -oN enuresult.txt  #this syntax is to scan for LAN range using CIDR, then identify current host IP address & enumerate current & live host in this LAN to discover any open port & services
echo "Result saved as enuresult.txt"

#4.Find potential vulnerabilities for each device
echo "Input discovered live host IP to search for potential vulnerabilities"
read ipadd

sudo nmap --script vulners -sV $ipadd > vulresult.txt #this syntax will use vulners script to identify all potential vulnerabilities for discovered services of live host.
echo "Result saved into vulresult.txt"



#Part 2

#1.Allow the user to specify a user list
function suserlist() #this function can let user have the option to choose one of the 4 potential username list to use for bruteforce later when needed.
{

	echo "Please specify the userlist"
	echo "
A.cirt-default-usernames.txt 
B.mssql-usernames-nansh0u-guardicore.txt 
C.sap-default-usernames.txt 
D.xato-net-10-million-usernames.txt"
	
	read option #any selected userlist will be copied into current directories to avoid the hassle of locate the copied file again.
		case $option in 
		A|a)
			echo "You have selected A"
			A=$(cp /usr/share/seclists/Usernames/cirt-default-usernames.txt .)
			echo "File copied to your current directory"
		;;	
		b|b)
			echo "You have selected B"
			B=$(cp /usr/share/seclists/Usernames/mssql-usernames-nansh0u-guardicore.txt .)
			echo "File copied to your current directory"
		;;
		C|c)
			echo "You have selected C"
			B=$(cp /usr/share/seclists/Usernames/sap-default-usernames.txt .)
			echo "File copied to your current directory"
		;;
		D|d)
			echo "You have selected D"
			B=$(cp /usr/share/seclists/Usernames/xato-net-10-million-usernames.txt .)
			echo "File copied to your current directory"
	
		esac
		
}
suserlist


#2.Allow the user to specify a password list
function spasslist() #this function can let user have the option to choose one of the 4 potential password list to use for bruteforce later when needed.
{

	echo "Please specify the password list."
	echo "
A.2020-200_most_used_passwords.txt
B.500-worst-passwords.txt 
C.darkweb2017-top1000.txt 
D.xato-net-10-million-passwords-1000.txt"
	
	read option #any selected passwordlist will be copied into current directories to avoid the hassle of locate the copied file again.
		case $option in 
		A|a)
			echo "You have selected A"
			A=$(cp /usr/share/seclists/Passwords/2020-200_most_used_passwords.txt .)
			echo "File copied to your current directory"
		;;	
		b|b)
			echo "You have selected B"
			B=$(cp /usr/share/seclists/Passwords/500-worst-passwords.txt .)
			echo "File copied to your current directory"
		;;
		C|c)
			echo "You have selected C"
			B=$(cp /usr/share/seclists/Passwords/darkweb2017-top1000.txt .)
			echo "File copied to your current directory"
		;;
		D|d)
			echo "You have selected D"
			B=$(cp /usr/share/seclists/Passwords/xato-net-10-million-passwords-1000.txt .)
			echo "File copied to your current directory"
	
		esac
		
}
spasslist

#3.Allow the user to create a password list
function cpasslist() #in case the above selected passwordlist doesn't have a match for bruteforce, user is allow generate their own list of password 
{
	echo "Create own password"

	echo "Input minimum length for password"
	read inputminl
	
	echo "Input maximum length for password"
	read inputmaxl
	
	echo "Input pattern to use for password"
	read inputpattern
	
	echo "Input any other specific password" #last resort if user own generated password list doesn't match or take too long to bruteforce.
	read spassword
		
}
cpasslist
crunch $inputminl $inputmaxl $inputpattern > cpass.txt
echo $spassword >> cpass.txt
echo "Saved into cpass.txt"

#4.If a login service is available, Brute Force with the password list + #5.If more than one login service is available, choose the first service
function bforce() #to bruteforce targeted device/host, can use either Hydra or Medusa 
{
	echo "Please input details for Brute Forcing"
	echo "Input Login Username"
	read username
	
	echo "Select Passwordlist"
	ls | grep -i -E 'pass|top' 
	read pwlist
	
	echo "Input Target IP Address"
	read ipad
	
	echo "Select Available Login Service from the NMAP result"
	read service
	
}
bforce
hydra -l $username -P $pwlist $ipad $service > bforceresult.txt
echo "Result saved into bforceresult.txt"
#medusa -h $ipad -u $username -P $pwlist -M $service > bforceresult.txt



#Part 3 #key in target IP will show you all result from all the process above.
echo "Input target IP to display the overall result."
read ipador
echo "Enumeration result for $ipador"
cat enuresult.txt | grep $ipador -A 50
echo "Potential vulnerabilities for $ipador"
cat vulresult.txt | grep $ipador -A 500
echo "Bruteforce result for $ipador"
cat bforceresult.txt | grep $ipador -C 10
