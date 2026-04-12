local sampev = require 'lib.samp.events'

local active = false
local putActive = false
local currentShelf = 0 -- Индекс полки (0 = первая, 1 = вторая и т.д.)

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end

    -- Команда для твоего старого функционала (улучшение)
    sampRegisterChatCommand("vup", function()
        active = not active
        sampAddChatMessage(active and "{00FF00}[VC] Улучшение: ON" or "{FF0000}[VC] Улучшение: OFF", -1)
    end)

    -- Команда для автоматической расстановки на полки
    sampRegisterChatCommand("vput", function()
        putActive = not putActive
        currentShelf = 0 -- Сбрасываем цикл на первую полку при включении
        sampAddChatMessage(putActive and "{00FF00}[VC] Авто-установка: ON" or "{FF0000}[VC] Авто-установка: OFF", -1)
    end)

    wait(-1)
end

function sampev.onShowDialog(id, style, title, b1, b2, text)
    -- Логика улучшения (твой прошлый запрос)
    if active then
        if title:find("Выберите вид улучшения для видеокарты") then
            sampSendDialogResponse(id, 1, 1, nil)
            return false
        end
        if title:find("Улучшение видеокарты") then
            sampSendDialogResponse(id, 1, 0, nil)
            return false
        end
    end

    -- Логика расстановки видеокарт по полкам (1-4)
    if putActive and title:find("Выберите полку") then
        -- Отправляем ответ с текущим индексом полки
        sampSendDialogResponse(id, 1, currentShelf, nil)
        
        -- Увеличиваем индекс для следующего раза (0 -> 1 -> 2 -> 3 -> 0)
        currentShelf = currentShelf + 1
        if currentShelf > 3 then 
            currentShelf = 0 
        end
        
        return false
    end
end