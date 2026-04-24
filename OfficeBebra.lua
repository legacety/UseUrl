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
    sampAddChatMessage("{00FFFF}[AutoDoc] {FFFFFF}Скрипт успешно {33FF33}загружен{FFFFFF}. Автор: {00FFFF}legacy.", -1)
    sampRegisterChatCommand("act", function()
        Office = not Office
        main_ini.settings.active = Office
        inicfg.save(main_ini, direct)
        sampAddChatMessage("{00FFFF}[AutoDoc] {FFFFFF}Автозаполнение документов: " .. (Office and "{33FF33}Активирован" or "{FF4C4C}Деактивирован"), -1)
    end)
    wait(-1)
end

function sampev.onShowDialog(id, style, title, button1, button2, text)
    if Office[0] then
        if title:find('{BFBBBA}Заполнение документа') then
            sampSendDialogResponse(id, 1, nil, text:match('{ffff00}(.+)'))
            return false
        end
    end
end