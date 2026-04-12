function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end

    sampRegisterChatCommand("setmark", function()
        local posX, posY, posZ = getCharCoordinates(PLAYER_PED)
        changeBlipColour(addBlipForCoord(posX, posY, posZ), 52)
        createCheckpoint(1, posX, posY, posZ - 1.0, 0, 0, 0, 3.0)               
        sampAddChatMessage("{00FF00}[Marker]{FFFFFF} Новая метка установлена!", -1)
    end)

    wait(-1)
end