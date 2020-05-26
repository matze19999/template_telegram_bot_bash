#!/bin/bash

# set variables
token=''
sleeptime='0.7'
username=''
userid=''

# Test if all required packages are installed
which curl apt jq wget sed > /dev/null
if [[ $? == "1" ]];then
    apt install curl apt jq wget sed -y
fi

# disables Case Matching
shopt -s nocasematch

# Get the latest telegram message sent to the bot
function getlatestmessage {

    API=`wget --no-cache --no-cookies "https://api.telegram.org/bot$token/getUpdates" --no-check-certificate -q -O -`
    LATESTMESSAGE=`echo "$API" | jq -r ".result[-1].message.text"`
    LATESTUSERNAME=`echo "$API" | jq -r ".result[-1].message.chat.username"`
    CHATID_LASTMESSAGE=`echo "$API" | jq -r ".result[-1].message.chat.id"`

}


# Send message
function sendmessage {

    curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" -d "parse_mode=HTML" -d "chat_id=$userid" -d text="$1" > /dev/null

}

# runs function
getlatestmessage


# Checkt auf neue Nachrichten
while true;
do
    OLDMESSAGEDATE=`echo "$API" | jq -r ".result[-1].message.date"`
    getlatestmessage
    MESSAGEDATE=`echo "$API" | jq -r ".result[-1].message.date"`

    if [[ "$OLDMESSAGEDATE" != "$MESSAGEDATE" ]] && [[ "$LATESTUSERNAME" == "$username" ]];then
        echo "Letzte Nachricht: $LATESTMESSAGE von $LATESTUSERNAME mit der ID $CHATID_LASTMESSAGE"

        if [[ "$LATESTMESSAGE" == "/reboot" ]];then
                sendmessage "Rechner wird neu gestartet...!"
                #reboot

        elif [[ "$LATESTMESSAGE" == "/exit" ]];then
                sendmessage "Script wird geschlossen!"
                exit 0

        # Wenn ente enthalten ist, wie in "Wissensakquisitionskomponente"
        elif [[ "$LATESTMESSAGE" == *"ente"* ]];then
                sendmessage "Quack!"

        # Wenn keine passende Nachricht erkannt wurde
        else
                sendmessage "Ich verstehe kein Wort... 🤷🏼‍♂️"
        fi
    fi


sleep $sleeptime
done

exit 0
