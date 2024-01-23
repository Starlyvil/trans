#!/bin/bash

#Call using the format scriptName -h IP [telnet | nc]

tool=$3
timeout=7

# Compute default value for tool 
: ${tool:="telnet"}


# Check if needed utilities are installed
which telnet > /dev/null 2> /dev/null
ec1=$?

which nc > /dev/null 2> /dev/null
ec2=$?


if [[ $ec1 -eq 1 && $ec2 -eq 1 ]]; then

    echo -e "\nNo Telnet and Netcat utilities installed, try installing one\n"
    exit

elif [[ $ec1 -eq 0 && $ec2 -eq 1 ]]; then

    if [ $tool == "nc" ]; then
        echo -e "\nNo Netcat utility installed, Telnet utility has been set as default\n"
        tool="telnet"
    fi

elif [[ $ec1 -eq 1 && $ec2 -eq 0 ]]; then

    if [ $tool == "telnet" ]; then
        echo -e "\nNo Telnet utility installed, Netcat utility has been set as default\n"
        tool="nc"
    fi

fi


getopts "h:" ip_addr

total_length=${#OPTARG}

if [ $total_length -eq 0 ]; then
    echo "Please provide the IP address and try again"
    exit 2
fi

readarray -t ports < ports.txt
echo "The ports are being tested with $tool utility"

output="${OPTARG}_Ports_test_result.txt"
echo "PORTS CONNECTIVITY TEST  WITH ($OPTARG) RESULT" > $output
echo -e "\n" >> $output
echo -e "PORTS\t----------\tSTATE" >> $output

for port in ${ports[@]}; do

    # Parse Data
    trimmed_port="${port#"${port%%[![:space:]]*}"}"
    trimmed_port="${trimmed_port%"${trimmed_port##*[![:space:]]}"}"

    echo "Testing connectivity with  $OPTARG on port $trimmed_port"

    if [ $tool == "telnet" ]; then
        timeout --foreground $timeout telnet $OPTARG $trimmed_port > temp_output
        cat temp_output | grep -i connected > /dev/null
        ec=$?
    elif [ $tool == "nc" ]; then
        nc -w $timeout $OPTARG $trimmed_port
        ec=$?
    fi

    if [ $ec -eq 0 ]; then
        echo -e "Exit code: $ec, Connected succesfully\n"
        echo -e "$trimmed_port\t----------\tConnected successfully" >> $output
    elif [ $ec -ne 0 ]; then
        echo -e "Exit code: $ec, Could not connect to the server $OPTARG on port $trimmed_port\n"
        echo -e "$trimmed_port\t----------\tCould not connect" >> $output
    fi
done

echo -e "\nPorts testing completed successfully, you can view the test result in the file $output"