#!/bin/bash

if [ "$#" -ne 3 ];
then
    echo "Usage:   ./savantconf.sh <left bind> <middle bind> <right bind>"
    echo "Example: ./savantconf.sh capslock leftshift leftctrl"
    exit 1
fi

#
# Keys from args.
#
LEFT=$1
MIDDLE=$2
RIGHT=$3

#
# Scancodes.
#
CODE_COMMON_1="700E0"
CODE_COMMON_2="700E2"
CODE_LEFT="70021"
CODE_MIDDLE="70022"
CODE_RIGHT="70023"

#
# Vendor ID.
#
VENDOR="05F3"

#
# Product ID.
#
PRODUCT="030C"

#
# Check that the evdev match is correct.
#
CHECK=$(lsusb | grep -i "$VENDOR:$PRODUCT" | wc -l;)
if [ "$CHECK" -ne "1" ];
then
    echo "Configured vendor and product ids do not match a usb device."
    exit 1
fi

#
# Write the hwdb file for the pedals.
#
sudo tee "/etc/udev/hwdb.d/kinesis-savant.hwdb" > /dev/null <<EOF
evdev:input:b0003v${VENDOR}p${PRODUCT}*
 KEYBOARD_KEY_${CODE_COMMON_1}=unknown
 KEYBOARD_KEY_${CODE_COMMON_2}=unknown
 KEYBOARD_KEY_${CODE_LEFT}=${LEFT}
 KEYBOARD_KEY_${CODE_MIDDLE}=${MIDDLE}
 KEYBOARD_KEY_${CODE_RIGHT}=${RIGHT}
EOF

#
# Update and reload the hwdb.
#
sudo udevadm hwdb --update
sudo udevadm trigger

#
# Rerun xmodmap.
#
if [ -s ~/.Xmodmap ]; then
    xmodmap ~/.Xmodmap
fi
