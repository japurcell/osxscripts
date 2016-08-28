#!/bin/bash

command=unload
disabled=true

# disable spotlight activity on all volumes
mdArgs="-a -d"

if [ "$1" = false ]; then
  command=load
  disabled=false

  # enable spotlight activity on all volumes
  mdArgs="-a -i on"
fi

baseDirectory=/System/Library/
domainPrefix=com.apple.
fileExtension=plist

# spotlight indexing and searching
sudo mdutil $mdArgs

agentDirectory=${baseDirectory}LaunchAgents/
agentNames=(
CalendarAgent
cloudd
cloudphotosd
cloudfamilyrestrictionsd-mac
cloudpaird
cloudphotosd
icloud.findmydeviced.findmydevice-user-agent
icloud.fmfd
gamed
photolibraryd
reversetemplated
Safari.SafeBrowsing.Service
SafariCloudHistoryPushAgent
SafariNotificationAgent
SafariPlugInUpdateNotifier
sharingd
speechsynthesisd
)

for agentName in ${agentNames[@]}
do
  agent=${agentDirectory}${domainPrefix}${agentName}

  launchctl $command -w $agent.${fileExtension}
  defaults write $agentName Disabled -bool $disabled 

  if [ $disabled = true ]; then
    sudo killall $agentName
  fi
done

appNames=(
  "Google Photos Backup" 
  "Google Drive"
  "Flux"
)

if [ $disabled = true ]; then
  sudo killall Spotlight 

  for((i=0; i<${#appNames[@]}; i++))
  do
    kill $(pgrep "${appNames[$i]}") 
  done
fi

if [ $disabled = false ]; then
  for((i=0; i<${#appNames[@]}; i++))
  do
    nohup open "/Applications/${appNames[$i]}.app" > /dev/null &
  done
fi
