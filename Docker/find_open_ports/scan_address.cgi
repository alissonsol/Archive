#!/bin/bash

ADDRESS="`echo $QUERY_STRING | sed 's/address\=\([^&]\+\).*/\1/'`";

echo "Content-type: text/html"
echo ""
echo "<html>"
echo "<head>"
echo "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">"
echo "<title>NMap scanning $ADDRESS</title>"
echo "</head>"
echo "<body>"
echo "<pre>"
nmap -Pn $ADDRESS
echo "</pre>"
echo "</body>"
echo "</html>"

exit 0
