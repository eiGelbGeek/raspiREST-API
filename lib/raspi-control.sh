#!/bin/sh
###################################
openhab_url="0.0.0.0"
openhab_port="8080"
tv_ipadresse="0.0.0.0"
rpi_ipadresse="0.0.0.0"
av_receiver_ipadress="0.0.0.0"
vu_plus_ipadress="0.0.0.0"
###################################

case $1 in
  ######## jointSPACE API ########
  key)
    #Key => Standby , VolumeUp , VolumeDown , Mute , Back , Find , RedColour , GreenColour , YellowColour , BlueColour ,
    #       Home , Options , Dot , Digit0-9 , Info , CursorUp , CursorDown , CursorLeft , CursorRight , Confirm , Next ,
    #       Previous , Adjust , WatchTV , Viewmode , Teletext , Subtitle , ChannelStepUp , ChannelStepDown , Source ,
    #       PlayPause , Pause , FastForward , Stop , Rewind , Record , Online
    curl -H "Content-Type: application/json" -X POST -d '{"key": "'$2'"}' http://$tv_ipadresse:1925/1/input/key
    ;;
  set_source)
    #Sources => tv , sat , hdmi1 , hdmi2 , hdmi3 , hdmiside , ext1 , ypbpr , vga
    curl -H "Content-Type: application/json" -X POST -d '{"id": "'$2'"}' http://$tv_ipadresse:1925/1/sources/current
    ;;
  get_source)
    current_scource="$(curl -H "Content-Type: application/json" -s GET  http://$tv_ipadresse:1925/1/sources/current | jq -r '.id')"
    curl -X PUT --header "Content-Type: text/plain" --header "Accept: application/json" -d "$current_scource" "http://$openhab_url:$openhab_port/rest/items/$2"
    ;;
  get_volume)
    tv_max_volume="$(curl -H "Content-Type: application/json" -s GET  http://$tv_ipadresse:1925/1/audio/volume | jq -r '.max')"
    volume_state="$(curl -H "Content-Type: application/json" -s GET  http://$tv_ipadresse:1925/1/audio/volume | jq -r '.current')"
    transform=`echo "scale=2; $tv_max_volume / 100 * $volume_state" | bc | awk '{print int($1+0.5)}'`
    curl -X PUT --header "Content-Type: text/plain" --header "Accept: application/json" -d "$transform" "http://$openhab_url:$openhab_port/rest/items/$2"
    ;;
  set_volume)
    tv_max_volume="$(curl -H "Content-Type: application/json" -s GET  http://$tv_ipadresse:1925/1/audio/volume | jq -r '.max')"
    transform=`echo "scale=2; $tv_max_volume / 100 * $2" | bc | awk '{print int($1+0.5)}'`
    curl -H "Content-Type: application/json" -s POST -d '{"current": '$transform} http://$tv_ipadresse:1925/1/audio/volume
    ;;
  get_mute)
    mute_state="$(curl -H "Content-Type: application/json" -s GET  http://$tv_ipadresse:1925/1/audio/volume | jq -r '.muted')"
    if [[ $mute_state == false ]]; then
      curl -X PUT --header "Content-Type: text/plain" --header "Accept: application/json" -d "OFF" "http://$openhab_url:$openhab_port/rest/items/$2"
    elif [[ $mute_state == true ]]; then
      curl -X PUT --header "Content-Type: text/plain" --header "Accept: application/json" -d "ON" "http://$openhab_url:$openhab_port/rest/items/$2"
    fi
    ;;
  set_mute)
    #true/fasle
    curl -H "Content-Type: application/json" -X POST -d '{"muted": "'$2'"}' http://$tv_ipadresse:1925/1/audio/volume
    ;;
  ######## Rasbberry Pi Commands ########
  shutdownPI)
    sudo shutdown -h now
    ;;
  ######## HDMI CEC Commands ########
  cec_tv_on)
    echo "on 0" | sudo cec-client -s -d 1
    ;;
  #
  cec_tv_standby)
    echo "standby 0" | sudo cec-client -s -d 1
    ;;
  cec_sound_to_av)
    echo "tx 1f:72:01" | sudo cec-client -s -d 1
    ;;
  ######## AV Receiver Commands ########
  set_av_off)
    echo -ne \\r|nc -w1 $av_receiver_ipadress 23
    sleep 0.5
    echo -ne PF\\r|nc -w1 $av_receiver_ipadress 23
    ;;
  set_av_direkt)
    echo -ne \\r|nc -w1 $av_receiver_ipadress 23
    sleep 0.5
    echo -ne PO\\r|nc -w1 $av_receiver_ipadress 23
    sleep 0.5
    echo -ne 091VL\\r|nc -w1 $av_receiver_ipadress 23
    sleep 0.5
    echo -ne 05FN\\r|nc -w1 $av_receiver_ipadress 23
    sleep 0.5
    echo -ne 0007SR\\r|nc -w1 $av_receiver_ipadress 23
    ;;
  set_av_extended_stereo)
    echo -ne \\r|nc -w1 $av_receiver_ipadress 23
    sleep 0.5
    echo -ne PO\\r|nc -w1 $av_receiver_ipadress 23
    sleep 0.5
    echo -ne 121VL\\r|nc -w1 $av_receiver_ipadress 23
    sleep 0.5
    echo -ne 05FN\\r|nc -w1 $av_receiver_ipadress 23
    sleep 0.5
    echo -ne 0112SR\\r|nc -w1 $av_receiver_ipadress 23
    ;;
  set_av_mute)
    if [[ $2 == "ON" ]]; then
      echo -ne \\r|nc -w1 $av_receiver_ipadress 23
      sleep 0.5
      echo -ne MO\\r|nc -w1 $av_receiver_ipadress 23
    elif [[ $2 == "OFF" ]]; then
      echo -ne \\r|nc -w1 $av_receiver_ipadress 23
      sleep 0.5
      echo -ne MF\\r|nc -w1 $av_receiver_ipadress 23
    fi
    ;;
  ######## VUplus Commands ########
  set_vuplus_mute)
    MuteState=$(curl "http://$vu_plus_ipadress/web/vol?set=state" | grep -oP '(?<=<e2ismuted>).*?(?=</e2ismuted>)')
    if [[ $2 == "ON" ]]; then
      if [ $MuteState = "False" ]; then
      curl "http://$vu_plus_ipadress/web/vol?set=mute"
      fi
    elif [[ $2 == "OFF" ]]; then
      if [ $MuteState = "True" ]; then
      curl "http://$vu_plus_ipadress/web/vol?set=mute"
      fi
    fi
    ;;
  #
  ######## irsend Commands ########
  irsend)
    #$2 = Name of Remote (eg. AppleTV)
    #$3 = Key => KEY_MENU , KEY_OK , KEY_PLAYPAUSE , KEY_DOWN , KEY_UP , KEY_LEFT , KEY_RIGHT
    irsend SEND_ONCE $2 $3
    ;;
esac
