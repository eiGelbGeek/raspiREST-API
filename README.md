# raspiREST-API

## A Little Tool to execute BashScript with a URL Request!

### Installation

#### Setup for Raspberry Pi Zero W
* Install Raspbian Strech Lite on SD-Card
* Add wpa_supplicant.conf to boot Partion (SD-Card)
```
country=DE
 ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
 update_config=1
 network={
      ssid="Name"
      psk="Password"
      key_mgmt=WPA-PSK
 }
```
* Activate SSH `nano path_to_boot_partion/ssh` and write this empty file do disk
* Boot the RaspberryPi
* Configure your RaspberryPi with `sudo raspi-config`
* `sudo apt-get update && sudo apt-get upgrade`
* `sudo apt-get install git`
* `cd /usr/local`
* `sudo git clone https://github.com/eiGelbGeek/raspiREST-API.git`
* `cd /usr/local/raspiREST-API`

#### Now is a good time to make configurations! Set up the following files according to your wishes!
* `sudo nano script/raspbian_stretch_setup.sh`
* `sudo nano lib/raspi-control.sh`
* `sudo nano public/index.html`

#### Finish Setup
* `sudo nano script/raspbian_stretch_setup.sh`
* `sudo sh script/raspbian_stretch_setup.sh`
* `sudo chmod u+x script/bootstrap`
* `sudo chmod u+x script/install`
* `sudo chmod u+x script/uninstall`
* `sudo script/bootstrap`
* `sudo script/install`
