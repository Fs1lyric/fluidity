// Power actions shared by the sidebar and the dashboard.
.pragma library
var commands = {
    power: ["systemctl", "poweroff"], reboot: ["systemctl", "reboot"], suspend: ["systemctl", "suspend"],
    logout: ["bash", "-c", "command -v uwsm >/dev/null && uwsm stop || hyprctl dispatch exit"],
    lock: ["bash", "-c", "pidof hyprlock || hyprlock"]
};
