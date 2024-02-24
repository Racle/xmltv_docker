#!/usr/bin/bash

if [[ -z "$XMLTV_GRABBER" ]]; then
  echo "No 'XMLTV_GRABBER' variable in place. Using default grabber: 'tv_grab_fi'"
  XMLTV_GRABBER="tv_grab_fi"
fi

# if $1 equals to configure, run the grabber configuration
if [[ $1 == "configure" ]]; then
  echo "Running: '${XMLTV_GRABBER} --configure --config-file /config/${XMLTV_GRABBER}.conf'"
  mkdir -p /config
  ${XMLTV_GRABBER} --configure --config-file /config/${XMLTV_GRABBER}.conf
  exit 0
fi

if [[ $1 == "keep" ]]; then
  echo "Keeping only rows containing $2 in /config/*.conf"
  echo "Running: sed -i '/$2/!d' /config/*.conf"
  sed -i "/$2/!d" /config/*.conf
  exit 0
fi

FILE=/config/${XMLTV_GRABBER}.conf
echo 'Grabber configuration file is: '$FILE
if test -f "$FILE"; then
  if [[ -z "$XMLTV_DAYS" ]]; then
    XMLTV_DAYS="7"
  fi
  if [[ -z "$OUTPUT_XML_FILENAME" ]]; then
    OUTPUT_XML_FILENAME=${XMLTV_GRABBER}.xml
  fi
  echo Running: ${XMLTV_GRABBER} --config-file /config/${XMLTV_GRABBER}.conf --output /output/${OUTPUT_XML_FILENAME} --days ${XMLTV_DAYS}
  ${XMLTV_GRABBER} --config-file /config/${XMLTV_GRABBER}.conf --output /output/${OUTPUT_XML_FILENAME} --days ${XMLTV_DAYS}
  echo "grabber finished, exiting..."
else
  echo "$FILE does not exist. Running: '${XMLTV_GRABBER} --configure'"
  ${XMLTV_GRABBER} --configure --config-file /config/${XMLTV_GRABBER}.conf
fi
exit 0
