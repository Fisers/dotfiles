#! /bin/bash
#################################################################################
#     File Name           :     cycle_audio_output.sh
#     Created By          :     jguer
#     Creation Date       :     [2016-01-16 22:55]
#     Last Modified       :     [2016-01-17 00:42]
#     Description         :      Cycles audio output devices
#################################################################################
VERBOSITY=0
NOTIFICATIONS=0

function swap_sink {
  o_pulseaudio=$(pactl list sinks| grep -e 'node.name' | sed -e 's/.*"\(.*\)".*/\1/')

  # split o_pulseaudio by new line character into an array
  IFS=$'\n' array=($o_pulseaudio)

  # get the current sink
  current_sink_index=$(pactl info | grep "Default Sink" | cut -d: -f2 | sed 's/ //g')

  # get the next sink in list
  next_sink_index=""
  for i in "${!array[@]}"; do
    if [[ "${array[i]}" == "$current_sink_index" ]]; then
      next_sink_index="${array[i+1]}"
      break
    fi
  done

  # if there is no next sink, get the first one
  if [ -z "$next_sink_index" ]; then
    next_sink_index="${array[0]}"
  fi

  # set the new sink
  pactl set-default-sink "$next_sink_index"

  # move all audio threads to new sink
  for i in $(pactl list short sink-inputs | cut -f1); do
    pactl move-sink-input "$i" "$next_sink_index"
  done
}

function send_notification {
  o_pulseaudio=$(pactl list-sinks| grep -e 'index' -e 'device.description')
  device_name=$(echo "$o_pulseaudio" | sed -n '/* index/{n;p;}' | grep -o '".*"' | sed 's/"//g')
  notify-send "Output cycle" "Changed output to ${device_name}" --icon=audio-headphones-symbolic
}

#MAIN
while getopts "vn" opt; do
  case "${opt}" in
    v)
      VERBOSITY=1
      echo VERBOSE
      ;;
    n)
      NOTIFICATIONS=1
      ;;
    *)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done
shift $((OPTIND-1))

swap_sink

if [ $NOTIFICATIONS == 1 ]; then
  send_notification
fi

