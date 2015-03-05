#!/bin/sh
# Fulfill AFMAN 33-223, section 5.5.2, and UNIX SRG rules GEN000452 and
# GEN000454.
text="`/usr/sbin/loginhistory $LOGNAME`"
[[ "$text" =~ \! ]] && sw=--error || sw=--info
zenity $sw --text="$text"
