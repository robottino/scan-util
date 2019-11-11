#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "usage: scandoc.sh <pdf-name> <number-of-pages> <email-to-send-pdf>"
fi

PDFNAME=$1
PAGES=$2
EMAIL=$3

scanimage -p --resolution 200 --mode Gray --wait-for-button=yes --batch=page-%02d.pnm --batch-count=$PAGES 

dirname=${PWD##*/}
tmp_img_name="___tmp_image"
tmp_img_ext="jpg"

convert -quality 70% page-*.pnm "${tmp_img_name}-%04d.${tmp_img_ext}"
convert "${tmp_img_name}*${tmp_img_ext}" -page A4 "${PDFNAME}"

#send e-mail
# https://support.plesk.com/hc/en-us/articles/115004947113-How-to-set-up-Postfix-to-send-emails-using-Gmail-Relay-with-authentication-
echo "" | mail -s "emailing: ${PDFNAME}" ${EMAIL} -A ${PDFNAME}

#clean temporary files
rm "${tmp_img_name}"*"${tmp_img_ext}"

