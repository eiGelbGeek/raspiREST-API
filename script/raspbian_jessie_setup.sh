#!/bin/bash

#Update / Install
apt-get -y update
apt-get -y upgrade
apt-get -y install  lirc autoconf build-essential git cmake libudev-dev libxrandr-dev

#NodeJS!
wget https://nodejs.org/dist/latest-v8.x/node-v8.9.3-linux-armv6l.tar.gz
tar -xvf node-v8.9.3-linux-armv6l.tar.gz
cd node-v8.9.3-linux-armv6l
cp -R * /usr/local/

npm install -g forever

#HDMI Config
echo "hdmi_ignore_cec_init=1" >> /boot/config.txt
echo "hdmi_group=1" >> /boot/config.txt
echo "hdmi_mode=31" >> /boot/config.txt

#Keyboard Config
>/etc/default/keyboard
cat <<EOF > /etc/default/keyboard
# KEYBOARD CONFIGURATION FILE

# Consult the keyboard(5) manual page.

XKBMODEL="pc105"
XKBLAYOUT="de"
XKBVARIANT=""
XKBOPTIONS=""

BACKSPACE="guess"
EOF

#Install CEC Client
git clone https://github.com/Pulse-Eight/platform.git
mkdir platform/build
cd platform/build
cmake ..
make
make install
cd
git clone https://github.com/Pulse-Eight/libcec.git
mkdir libcec/build
cd libcec/build
cmake -DRPI_INCLUDE_DIR=/opt/vc/include -DRPI_LIB_DIR=/opt/vc/lib ..
make -j4
make install
ldconfig

#Lirc Config
echo "lirc_dev" >> /etc/modules
echo "lirc_rpi gpio_out_pin=17 gpio_in_pin=18" >> /etc/modules
echo "dtoverlay=lirc-rpi,gpio_out_pin=17,gpio_in_pin=18" >> /boot/config.txt

>/etc/lirc/hardware.conf
cat <<EOF > /etc/lirc/hardware.conf
# /etc/lirc/hardware.conf
#
# Arguments which will be used when launching lircd
#LIRCD_ARGS=""

#LIRCD_ARGS="--uinput"
LIRCD_ARGS=""

#Don't start lircmd even if there seems to be a good config file
#START_LIRCMD=false

#Don't start irexec, even if a good config file seems to exist.
#START_IREXEC=false

#Try to load appropriate kernel modules
LOAD_MODULES=true

# Run "lircd --driver=help" for a list of supported drivers.
DRIVER="default"
# usually /dev/lirc0 is the correct setting for systems using udev
DEVICE="/dev/lirc0"
MODULES="lirc_rpi"

# Default configuration files for your hardware if any
LIRCD_CONF=""
LIRCMD_CONF=""
EOF

#Add Remotes
>/etc/lirc/lircd.conf
cat <<EOF > /etc/lirc/lircd.conf
# Please make this file available to others
# by sending it to <lirc@bartelmus.de>
#
# this config file was automatically generated
# using lirc-0.9.0-pre1(default) on Sun Mar 27 17:17:52 2016
#
# contributed by
#
# brand:                       AppleTV
# model no. of remote control:
# devices being controlled by this remote:
#

begin remote

  name  AppleTV
  bits            8
  flags SPACE_ENC|CONST_LENGTH
  eps            30
  aeps          100

  header       9083  4430
  one           604  1620
  zero          604   519
  ptrail        604
  repeat       9084  2195
  pre_data_bits   16
  pre_data       0x77E1
  post_data_bits  8
  post_data      0x9A
  gap          108064
  toggle_bit_mask 0x0

      begin codes
          KEY_DOWN                 0xB0
          KEY_UP                   0xD0
          KEY_LEFT                 0x10
          KEY_RIGHT                0xE0
          KEY_OK                   0xBA 0x20
          KEY_MENU                 0x40
          KEY_PLAYPAUSE            0x7A 0x20
      end codes

end remote
EOF

echo "System reboots in 10 Seconds!"
sleep 10
reboot
