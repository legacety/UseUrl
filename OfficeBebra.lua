local sampev = require 'lib.samp.events'
local inicfg = require 'inicfg'

local direct = "AutoDoc.ini"
local main_ini = inicfg.load({
    settings = {
        active = false
    }
}, direct)

Office = main_ini.settings.active

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end
    sampAddChatMessage("{00FFFF}[AutoDoc] {FFFFFF}Ñêðèïò óñïåøíî {33FF33}çàãðóæåí{FFFFFF}. Àâòîð: {00FFFF}legacy.", -1)
    sampRegisterChatCommand("act", function()
        Office = not Office
        main_ini.settings.active = Office
        inicfg.save(main_ini, direct)
        sampAddChatMessage("{00FFFF}[AutoDoc] {FFFFFF}Àâòîçàïîëíåíèå äîêóìåíòîâ: " .. (Office and "{33FF33}Àêòèâèðîâàí" or "{FF4C4C}Äåàêòèâèðîâàí"), -1)
    end)
    wait(-1)
end

function sampev.onShowDialog(id, style, title, button1, button2, text)
    if Office then
        if title:find('{BFBBBA}Çàïîëíåíèå äîêóìåíòà') then
            sampSendDialogResponse(id, 1, nil, text:match('{ffff00}(.+)'))
            return false
        end
    end
end
