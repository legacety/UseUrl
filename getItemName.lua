local sampev = require 'lib.samp.events'
local active = true

local function getItemName(cleanText)
    local name = cleanText:match("Предмет:%s*([^\r\n]+)") or cleanText:match("([^\r\n]+)")
    return name and name:gsub("^%[%d+%]%s*", ""):gsub("^Купить предмет%s*", ""):gsub("^Продать предмет%s*", ""):gsub("^[^%(:]+:%s*", ""):gsub("%s*%(Улучшение%)", ""):match("^%s*(.-)%s*$") or "Неизвестный предмет"
end

function main()
    while not isSampAvailable() do wait(100) end    
    sampRegisterChatCommand("shopscan", function()
        active = not active
        sampAddChatMessage("{FFFF00}[ShopScanner] {FFFFFF}Сканер: " .. (active and "{00FF00}Включен" or "{FF0000}Выключен"), -1)
    end)
    
    wait(-1)
end

function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
    if active then
        if title:find("Информация о предмете") or title:find("Покупка предмета") or title:find("Продажа предмета") then
            local cleanText = text:gsub("{%x%x%x%x%x%x}", "")
            local itemName = getItemName(cleanText)
            sampAddChatMessage("{FFFF00}[ShopScanner] {FFFFFF}Распознан предмет: {00FF00}" .. itemName, -1)
        end
    end
end