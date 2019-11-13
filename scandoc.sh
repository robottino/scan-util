#!/bin/bash

if [ "$#" -lt 6 ]; then
    echo "usage: scandoc.sh <[-p|--pdf-file-name] pdf-name> <[-n|--number-of-pages] number-of-pages> <[-e|--destination-email] destination-email>"
    exit 1
fi

#parse arguments
PARAMS=""
while (( "$#" )); do
  case "$1" in
    -e|--destination-email)
      EMAIL=$2
      shift 2
      ;;
    -p|--pdf-file-name)
      PDFNAME=$2
      shift 2
      ;;
    -n|--number-of-pages)
      PAGES=$2
      shift 2
      ;;
    --) # end argument parsing
      shift
      break
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *) # preserve positional arguments
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done
# set positional arguments in their proper place
eval set -- "$PARAMS"

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
rm ${PDFNAME}
rm *.pnm
