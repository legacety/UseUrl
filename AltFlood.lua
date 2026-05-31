local sampev = require 'lib.samp.events'

local active = false

function main()
    while not isSampAvailable() do wait(0) end
        sampRegisterChatCommand("alt", function() 
        active = not active 
        sampAddChatMessage(active and "{FFFFFF}[Alt-Flood] {00FF00}активирован" or "{FFFFFF}[Alt-Flood] {FF0000}деактивирован", -1)
    end)

    while true do
        wait(0)
        if active and not sampIsCursorActive() then
            SendAlt()
            wait(1)
        end
    end
end

function sampev.onShowDialog(id, style, title, button1, button2, text)
    if active and text:find("Стоимость аренды лавки") then
        sampSendDialogResponse(id, 1, 0, nil)
        active = false
        sampAddChatMessage("{00FF00}[Alt] Флуд остановлен.", -1)
        -- return false -- блокировка показа диалога 
    end
end

function SendAlt()
    local _, myId = sampGetPlayerIdByCharHandle(PLAYER_PED)
    local data = allocateMemory(68)
    sampStorePlayerOnfootData(myId, data)
    setStructElement(data, 4, 2, 1024)
    sampSendOnfootData(data)
    freeMemory(data)
end
