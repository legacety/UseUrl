local font = renderCreateFont("Comic Sans MS", 12.5, 12)
local posX, posY = 600, 730 
local isDragging = false

function SetPosTime()
    if isDragging then
        posX, posY = getCursorPos()
        
        if isKeyJustPressed(1) then
            isDragging = false
            sampAddChatMessage("Режим перетаскивания выключен", -1)
        end
    end
end

function main()
    while not isSampAvailable() do wait(100) end  
    sampRegisterChatCommand("drag", function()
        isDragging = not isDragging
        sampAddChatMessage(isDragging and "Режим перетаскивания: ВКЛ" or "Режим перетаскивания: ВЫКЛ", -1)
    end)

    while true do
        wait(0)
        SetPosTime()
        local text = "Время: " .. os.date("%H:%M:%S")
        renderFontDrawText(font, text, posX, posY, 0xFFFFFFFF)
    end
end