local sampev = require 'lib.samp.events'

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end
    wait(-1)
end

function sampev.onShowDialog(id, style, title, button1, button2, text)
    if title:find('Меню оружия') then
        sampAddChatMessage('Диалог открыт: ' .. title, 0x00FF00)
    end
end