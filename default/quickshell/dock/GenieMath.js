// Hyprland reports logical desktop coordinates, while the overlay is screen-local.
function windowRect(client, screen, titlebarHeight) {
    if (!client.at || !client.size || client.size[0] <= 0 || client.size[1] <= 0)
        return null;
    const bar = client.fullscreen === 2 ? 0 : (titlebarHeight || 0);
    return { x: client.at[0] - (screen.x || 0), y: client.at[1] - (screen.y || 0) - bar,
             width: client.size[0], height: client.size[1] + bar };
}
