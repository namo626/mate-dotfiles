xinput --set-prop 'SynPS/2 Synaptics TouchPad' 'libinput Accel Speed' 0.8 &
xinput --set-prop 'SynPS/2 Synaptics TouchPad' 'libinput Natural Scrolling Enabled' 1 &
xinput --set-prop 'SynPS/2 Synaptics TouchPad' 'libinput Tapping Enabled' 1 &
xinput --set-prop 'SynPS/2 Synaptics TouchPad' 'libinput Tapping Drag Enabled' 1 &
# redshift -b 0.8:0.6 &
setxkbmap -option caps:escape
setxkbmap -layout us,th -option grp:lctrl_lshift_toggle
xbindkeys
compton &
udiskie --tray &
#dropbox start &
#~/.dropbox-dist/dropboxd &
#megasync &
#/usr/lib/notification-daemon-1.0/notification-daemon &
#xscreensaver &
#feh --bg-scale ~/Pictures/sky.jpg &
xset b off & #turn off beeping
exec mate-session
