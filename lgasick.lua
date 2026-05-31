script_name("Unlited")
script_version("1.0")
script_authors("meow")
script_properties 'work-in-pause'

local acef = require 'arizona-events'
local sampev = require 'samp.events'
local fa = require 'fAwesome6_solid'
local imgui = require 'mimgui'
local encoding = require 'encoding'

encoding.default = 'CP1251'
local u8 = encoding.UTF8

local renderWindow = imgui.new.bool(false)
local activeTab = 1

local Clicker = imgui.new.bool(false)
local Konvert = imgui.new.bool(false)
local Office = imgui.new.bool(false)
local textdraw = imgui.new.bool(false)
local delay_td = imgui.new.int(300)
local td = {94, 95, 96, 97}
local stats = {}
local notified_players = {}
local notif_chat = imgui.new.bool(false)
local notif_cef = imgui.new.bool(false)
local weather_change = imgui.new.bool(false)
local weather_id = imgui.new.int(1)
local time_hour = imgui.new.int(12)
local FloodLavka = imgui.new.bool(false)
local StorageCollect = imgui.new.bool(false)

local tabs = { 
    {name = u8"Функции СК", icon = fa.SCREWDRIVER_WRENCH}, 
    {name = u8"Заработок с СК", icon = fa.CIRCLE_DOLLAR_TO_SLOT},
{name = u8"Лавки", icon = fa.SHOP},
    {name = u8"Информация", icon = fa.INFO},
{name = u8"Погода и время", icon = fa.CLOUD}
}
local zones = {
    { x = 1446.81, y = 1922.35, z = 2006.45, r = 2.0 },
    { x = 1446.81, y = 1924.02, z = 2006.45, r = 2.0 },
    { x = 1446.81, y = 1925.60, z = 2006.45, r = 2.0 },
    { x = 1446.82, y = 1927.50, z = 2006.45, r = 2.0 },
}

local cfg_path = getWorkingDirectory() .. "\\config\\qlsc.cfg"

local function loadConfig()
    local f = io.open(cfg_path, "r")
    if not f then return end
    
    local section = nil
    for line in f:lines() do
        line = line:match("^%s*(.-)%s*$")
        if line ~= "" and not line:match("^;") then
            if line:match("^%[.-%]") then
                section = line:match("^%[(.-)%]$")
            else
                local k, v = line:match("(.+)=(.+)")
                if k and v then
                    if section == "settings" then
                        -- Приведение типов для bool и int
                        if k == "Clicker" then Clicker[0] = (v == "true") end
                        if k == "Konvert" then Konvert[0] = (v == "true") end
                        if k == "Office" then Office[0] = (v == "true") end
                        if k == "textdraw" then textdraw[0] = (v == "true") end
                        if k == "delay_td" then delay_td[0] = tonumber(v) end
                        if k == "notif_chat" then notif_chat[0] = (v == "true") end
                        if k == "notif_cef" then notif_cef[0] = (v == "true") end
                        if k == "weather_change" then weather_change[0] = (v == "true") end
                        if k == "weather_id" then weather_id[0] = tonumber(v) end
                        if k == "time_hour" then time_hour[0] = tonumber(v) end
                        if k == "FloodLavka" then FloodLavka[0] = (v == "true") end
                        if k == "StorageCollect" then StorageCollect[0] = (v == "true") end
                    elseif section == "salary" then
                        stats[k] = tonumber(v)
                    end
                end
            end
        end
    end
    f:close()
end

local function saveConfig()
    local f = io.open(cfg_path, "w+")
    if not f then return end
    
    f:write("[settings]\n")
    f:write("Clicker=" .. tostring(Clicker[0]) .. "\n")
    f:write("Konvert=" .. tostring(Konvert[0]) .. "\n")
    f:write("Office=" .. tostring(Office[0]) .. "\n")
    f:write("textdraw=" .. tostring(textdraw[0]) .. "\n")
    f:write("delay_td=" .. tostring(delay_td[0]) .. "\n")
    f:write("notif_chat=" .. tostring(notif_chat[0]) .. "\n")
    f:write("notif_cef=" .. tostring(notif_cef[0]) .. "\n")
    f:write("weather_change=" .. tostring(weather_change[0]) .. "\n")
    f:write("weather_id=" .. tostring(weather_id[0]) .. "\n")
    f:write("time_hour=" .. tostring(time_hour[0]) .. "\n")
    f:write("FloodLavka=" .. tostring(FloodLavka[0]) .. "\n")
    f:write("StorageCollect=" .. tostring(StorageCollect[0]) .. "\n") -- Ваша новая переменная
    
    f:write("\n[salary]\n")
    for date, money in pairs(stats) do
        f:write(date .. "=" .. money .. "\n")
    end
    f:close()
end

local function formatMoney(value)
    return tostring(value):reverse():gsub("(%d%d%d)","%1,"):reverse():gsub("^,","")
end

function imgui.CenterText(text)
    local colWidth = imgui.GetColumnWidth()
    local textSize = imgui.CalcTextSize(text)
    imgui.SetCursorPosX(imgui.GetCursorPosX() + (colWidth - textSize.x) * 0.5)
    imgui.Text(text)
end

function imgui.ToggleButton(label, bool)
    local states = imgui.ToggleButton_States or {}
    imgui.ToggleButton_States = states
    
    local key = tostring(bool)
    local t = states[key] or (bool[0] and 1.0 or 0.0)
    
    local p = imgui.GetCursorScreenPos()
    local draw = imgui.GetWindowDrawList()
    local io = imgui.GetIO()

    local w, h = 34, 18
    local pad, rnd = 3, 3.0
    local s_size = h - (pad * 2)

    local clicked = false -- Добавляем переменную
    if imgui.InvisibleButton(label, imgui.ImVec2(w, h)) then
        bool[0] = not bool[0]
        clicked = true -- Устанавливаем в true при клике
    end

    local target = bool[0] and 1.0 or 0.0
    if t ~= target then
        t = t + (target - t) * math.min(io.DeltaTime * 10.0, 1.0)
        states[key] = t
    end

    local col_bg = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0.15 - (t * 0.07), 0.12 + (t * 0.06), 0.12, 1.0))
    local col_ind = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0.85 - (t * 0.70), 0.15 + (t * 0.70), 0.15, 1.0))

    draw:AddRectFilled(p, imgui.ImVec2(p.x + w, p.y + h), col_bg, rnd)
    draw:AddRect(p, imgui.ImVec2(p.x + w, p.y + h), 0x4D4D4D4D, rnd)
    
    local cur_x = p.x + pad + (t * (w - s_size - (pad * 2)))
    draw:AddRectFilled(imgui.ImVec2(cur_x, p.y + pad), imgui.ImVec2(cur_x + s_size, p.y + pad + s_size), col_ind, 2.0)

    imgui.SameLine(0, 10)
    imgui.SetCursorPosY(imgui.GetCursorPosY() + (h - imgui.CalcTextSize(label).y) * 0.5)
    imgui.Text(label)
    
    return clicked -- Возвращаем результат клика
end

local function applyTheme()
    local bg = imgui.ImVec4(0.06, 0.08, 0.10, 1)
    local childBg = imgui.ImVec4(0.07, 0.09, 0.11, 1)
    local button = imgui.ImVec4(0.12, 0.16, 0.20, 1)
    local buttonHover = imgui.ImVec4(0.18, 0.22, 0.26, 1)
    local frame = imgui.ImVec4(0.10, 0.14, 0.18, 1)
    local text = imgui.ImVec4(0.85, 0.86, 0.88, 1)
    local style = imgui.GetStyle()
    local clr = style.Colors
    style.WindowRounding = 0
    style.ChildRounding = 4
    style.FrameRounding = 4
    style.ScrollbarRounding = 0
    style.ItemSpacing = imgui.ImVec2(10, 12)
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    style.ScrollbarSize = 13
    clr[imgui.Col.Text] = text
    clr[imgui.Col.WindowBg] = bg
    clr[imgui.Col.ChildBg] = childBg
    clr[imgui.Col.TitleBg] = bg
    clr[imgui.Col.TitleBgActive] = bg
    clr[imgui.Col.Button] = button
    clr[imgui.Col.ButtonHovered] = buttonHover
    clr[imgui.Col.ButtonActive] = buttonHover
    clr[imgui.Col.FrameBg] = frame
    clr[imgui.Col.Separator] = imgui.ImVec4(0.15, 0.18, 0.21, 1)
end

imgui.OnInitialize(function()
    imgui.GetIO().IniFilename = nil
    applyTheme()
    fa.Init(13)
end)

imgui.OnFrame(function() return renderWindow[0] end, function()
    imgui.SetNextWindowSize(imgui.ImVec2(750, 500), imgui.Cond.FirstUseEver)
    local sw, sh = getScreenResolution()
    imgui.SetNextWindowPos(imgui.ImVec2(sw * 0.5, sh * 0.5), imgui.Cond.Appearing, imgui.ImVec2(0.5, 0.5))    
    
    if imgui.Begin("##A-Tools", renderWindow, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse) then
        imgui.BeginChild("LeftMenu", imgui.ImVec2(180, -1), true)
            imgui.Spacing()
            imgui.SetCursorPosX((imgui.GetWindowSize().x - imgui.CalcTextSize(u8"Версия: " .. thisScript().version).x) / 2)
            imgui.TextDisabled(u8"Версия: " .. thisScript().version)
            imgui.Spacing()
            imgui.Separator()
            imgui.Spacing()

            for i, tab in ipairs(tabs) do
                if imgui.Button(tab.icon .. "  " .. tab.name, imgui.ImVec2(-1, 35)) then
                    activeTab = i
                end
            end

            imgui.SetCursorPosY(imgui.GetWindowHeight() - 35)
            imgui.Separator()
            imgui.SetCursorPosX(10)
            imgui.TextDisabled(fa.CODE .. " Lua Project")

        imgui.EndChild()        
        imgui.SameLine()
    
        imgui.BeginChild("MainContent", imgui.ImVec2(-1, -1), true)
        
        if activeTab == 1 then
            imgui.TextColored(imgui.ImVec4(0.35, 0.75, 1.0, 1.0), fa.SCREWDRIVER_WRENCH .. u8" Функции СК")
            imgui.Separator()
            
           if imgui.ToggleButton(u8" Автозаполенение документов", Office) then
               saveConfig()
            end
        
            if imgui.ToggleButton(u8" Автокликер для миниигры Clicker", Clicker) then
                saveConfig()
            end

            if imgui.ToggleButton(u8" Автокликер для конвертов", Konvert) then
                saveConfig()
            end

            if imgui.ToggleButton(u8" Автоклик по текстдрайвам", textdraw) then
                saveConfig()
            end

            imgui.PushItemWidth(150)
            if imgui.InputInt(u8"Задержка клика (мс) по текстдрайвам ", delay_td) then
                saveConfig()
            end 
            imgui.PopItemWidth()


            if imgui.ToggleButton(u8" Уведомление о игроках в зоне", notif_chat) then
               saveConfig()
            end

if imgui.ToggleButton(u8" Уведомление в CEF", notif_cef) then
   saveConfig()
end

        elseif activeTab == 2 then
            imgui.TextColored(imgui.ImVec4(0.4, 0.8, 1, 1), fa.CIRCLE_DOLLAR_TO_SLOT .. u8" Заработок")
            imgui.Separator()
            local totalSelary = 0
            for _, money in pairs(stats) do totalSelary = totalSelary + money end
            imgui.Text(u8"Общий заработок: ")
            imgui.SameLine()
            imgui.TextColored(imgui.ImVec4(0.2, 0.8, 0.2, 1.0), "$ " .. formatMoney(totalSelary))
            imgui.Separator()

            if imgui.Button(u8"Очистить историю", imgui.ImVec2(-1, 25)) then
                stats = {}
                saveConfig()
            end
            
            imgui.BeginChild("TableContent", imgui.ImVec2(0, -1), true) 
            imgui.SetCursorPos(imgui.ImVec2(0, 0))     
            imgui.Columns(2, "IncomeCols", true)
            imgui.Spacing()
            imgui.CenterText(u8"День")
            imgui.NextColumn()   
            imgui.Spacing()
            imgui.CenterText(u8"Заработок")
            imgui.NextColumn()       
            imgui.Separator()
            
            local sorted = {}
            for k in pairs(stats) do table.insert(sorted, k) end
            
            table.sort(sorted, function(a, b)
                local d1, m1, y1 = a:match("(%d+)%.(%d+)%.(%d+)")
                local d2, m2, y2 = b:match("(%d+)%.(%d+)%.(%d+)")
                return (y1..m1..d1) > (y2..m2..d2)
            end)
            
            for _, date in ipairs(sorted) do
                imgui.CenterText(date)
                imgui.NextColumn()
                imgui.CenterText("$ " .. formatMoney(stats[date]))
                imgui.NextColumn()
imgui.Separator()
            end

            imgui.Columns(1)
            imgui.EndChild()

elseif activeTab == 3 then
    imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1.0), fa.SHOP .. u8" Управление лавками")
    imgui.Separator()
    
    if imgui.ToggleButton(u8" Флуд открытия/закрытия лавки", FloodLavka) then
        saveConfig()
    end
    
    imgui.Separator()
    imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.0, 1.0), u8"Сбор из хранилища")
    if imgui.ToggleButton(u8" Включить сбор", StorageCollect) then
        saveConfig()
    end
            
        elseif activeTab == 4 then
            imgui.TextColored(imgui.ImVec4(0.00, 0.70, 1.00, 1.00), fa.INFO .. u8" Информация")
            imgui.Separator()
            imgui.Text(u8"Разработчик: meow")
            if imgui.Button(fa.PAPER_PLANE .. u8" Связаться", imgui.ImVec2(-1, 25)) then
                os.execute("start https://blast.hk")
            end
elseif activeTab == 5 then
            imgui.TextColored(imgui.ImVec4(0.25, 0.65, 0.95, 1.0), fa.CLOUD .. u8" Управление окружением")
            imgui.Separator()

            if imgui.ToggleButton(u8" Включить кастомную погоду / время", weather_change) then 
                saveConfig() 
            end
            imgui.Spacing()

            imgui.PushItemWidth(150)
            if imgui.InputInt(u8"ID Погоды (0-45)", weather_id) then
                weather_id[0] = math.max(0, math.min(45, weather_id[0]))
                saveConfig()
                sampAddChatMessage("{66CCFF}[ " .. thisScript().name .. " ] {FFFFFF}Установлен ID погоды: {66CCFF}" .. weather_id[0], -1)
            end

            if imgui.InputInt(u8"Час (0-23)", time_hour) then
                time_hour[0] = math.max(0, math.min(23, time_hour[0]))
                saveConfig()
                sampAddChatMessage("{66CCFF}[ " .. thisScript().name .. " ] {FFFFFF}Установлен час времени: {66CCFF}" .. time_hour[0] .. ":00", -1)
            end
            imgui.PopItemWidth()
        end -- Это закрывает if activeTab == 4
        
        imgui.EndChild() -- Конец MainContent
    end -- Конец Begin(##A-Tools)
    imgui.End()
end) -- Конец OnFrame

function sampev.onServerMessage(color, text)
    -- Проверка на остановку флуда лавки
    if text:find("У Вас уже установлена лавка!") or text:find("Это нельзя сделать находясь в интерьере!") then
        if FloodLavka[0] then
            FloodLavka[0] = false
           sampAddChatMessage("{66CCFF}[ " .. thisScript().name .. " ] {FFFFFF} Функция: {ff6347} FloodLavka {FFFFFF} остановлен", -1)
            saveConfig()
        end
    end

    if color == 1941201407 and text:find("Ваша зарплата:") then
        local moneyText = text:match("Ваша зарплата:.-([^%(]+)")        
        if moneyText then
            local cleanMoney = moneyText:gsub("%D", "")
            local money = tonumber(cleanMoney)
            if money then
                if money < 1000 then money = money * 1000000 end
                local date = os.date("%d.%m.%Y")
                stats[date] = (stats[date] or 0) + money
                saveConfig()
            end
        end
    end
end

function sampev.onShowDialog(id, style, title, button1, button2, text)
    -- Ваш текущий код для документов
    if Office[0] and title:find('{BFBBBA}Заполнение документа') then
        sampSendDialogResponse(id, 1, nil, text:match('{ffff00}(.+)'))
        return false
    end

    -- Добавленный код для хранилища
    if StorageCollect[0] then
        if text:find("Нет доступных предметов") then
            StorageCollect[0] = false
            sampAddChatMessage("{66CCFF}[Unlited] {FFFFFF}В хранилище пусто. Сбор остановлен.", -1)
            sampSendDialogResponse(id, 0, 0, nil)
            return false
        end

        if title:find("Хранилище предметов") and text:find("Основное хранилище") then
            sampSendDialogResponse(id, 1, 1, nil)
            return false
        end
        
        if text:find("Причина выдачи") or text:find("Вы действительно хотите") then
            sampSendDialogResponse(id, 1, 0, nil)
            return false
        end
    end
end

function sampev.onShowTextDraw(id)
    if textdraw[0] then
        for _, td_id in ipairs(td) do
            if id == td_id then
                lua_thread.create(function()
                    for _, click_id in ipairs(td) do
                        wait(delay_td[0])
                        sampSendClickTextdraw(click_id)
                    end
                end)
                break
            end
        end
    end
end

function acef.onArizonaDisplay(packet)
    if Clicker[0] and packet.text:find("window.executeEvent%('event.clicker.setProgress', `%[%d+%]`%);") then
        lua_thread.create(function()
            for i = 1, 4 do
                acef.send("onArizonaSend", { server_id = 0, text = "clickMinigame" })
                wait(69)
            end
        end)
    end

    if Konvert[0] and packet.text:find([[window%.executeEvent%('event%.setActiveView', `%["FindGame"%]`%);]]) then
        acef.send("onArizonaSend", { server_id = 0, text = "findGame.finish" })
        return false
    end

if FloodLavka[0] and packet.text:find("Inventory") then
            acef.send("onArizonaSend", { server_id = 0, text = 'clickOnButton|{"type": 2, "slot": 11, "action": 1}' })
            acef.send("onArizonaSend", { server_id = 0, text = 'rightClickOnBlock|{"slot": 11, "type": 2}' })
            acef.send("onArizonaSend", { server_id = 0, text = "inventoryClose" })
    end
end

local function updateEnvironment()
    if weather_change[0] then
        forceWeatherNow(weather_id[0])
        setTimeOfDay(time_hour[0], 0)
    end
end

local function checkZones()
    local current_state = {} 

    for i, zone in ipairs(zones) do
        for player_id = 0, 999 do
            if sampIsPlayerConnected(player_id) and player_id ~= select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)) then
                local result, ped = sampGetCharHandleBySampPlayerId(player_id)
                if result and doesCharExist(ped) then
                    local px, py, pz = getCharCoordinates(ped)
                    local is_in_zone = getDistanceBetweenCoords3d(px, py, pz, zone.x, zone.y, zone.z) < zone.r
                    local nickname = sampGetPlayerNickname(player_id)

                    if is_in_zone then
                        if not current_state[nickname] then current_state[nickname] = {} end
                        current_state[nickname][i] = true
                    end

                    local was_in_zone = (notified_players[nickname] and notified_players[nickname][i]) or false
                    
                    if is_in_zone ~= was_in_zone then
                        -- Уведомление в чат
                        if notif_chat[0] then
                            sampAddChatMessage("{66CCFF}[ " .. thisScript().name .. " ] {FFFFFF}Игрок {66CCFF}" .. nickname .. "{FFFFFF} " .. (is_in_zone and "подошел к" or "покинул") .. " {66CCFF}позиции № " .. i, -1)
                        end

                        -- Уведомление в CEF
                        if notif_cef[0] then
                            lua_thread.create(function()
                                acef.emul("onArizonaDisplay", { text = "window.executeEvent('cef.modals.showModal', `[\"dialogTip\",{\"position\":\"rightBottom\",\"backgroundImage\":\"bank_notify_add.webp\",\"icon\":\"icon-info\",\"iconColor\":\"" .. (is_in_zone and "#2ECC71" or "#E74C3C") .. "\",\"highlightColor\":\"#5FC6FF\",\"text\":\"Игрок " .. nickname .. " " .. (is_in_zone and "подошел к" or "покинул") .. " позиции №" .. i .. "\"}]`);" })
                                wait(3000)
                                acef.emul("onArizonaDisplay", { text = "window.executeEvent('cef.modals.closeModal', `[\"dialogTip\"]`);" })
                            end)
                        end
                    end
                end
            end
        end
    end
    notified_players = current_state
end


function main()
    while not isSampAvailable() do wait(100) end        
loadConfig()
sampAddChatMessage("{AAAAAA}[ARZ Tools | Debug] {EEEEEE}Ваше сообщение здесь", 0xAAAAAA)
sampAddChatMessage("{66CCFF}[ :true: | " .. thisScript().name .. " ] {FFFFFF}Скрипт загружен. Версия: {66CCFF}" .. thisScript().version .. ". {FFFFFF}Автор: {66CCFF}meow.", -1)

    
    sampRegisterChatCommand("vc", function() renderWindow[0] = not renderWindow[0] end)    
    
sampRegisterChatCommand("st", function(arg)
    local hour = tonumber(arg)
    if hour and hour >= 0 and hour <= 23 then
        time_hour[0] = hour 
        weather_change[0] = true -- Включаем переключатель
        saveConfig() -- Сохраняем в файл
        sampAddChatMessage("{66CCFF}[ " .. thisScript().name .. " ] {FFFFFF}Установлен час: {66CCFF}" .. hour .. ":00", -1)
    else
        sampAddChatMessage("{66CCFF}[ " .. thisScript().name .. " ] {FFFFFF}Используйте: {66CCFF}/st [0-23]", -1)
    end
end)

sampRegisterChatCommand("sw", function(arg)
    local weather = tonumber(arg)
    if weather and weather >= 0 and weather <= 45 then
        weather_id[0] = weather 
        weather_change[0] = true -- Включаем переключатель
        saveConfig() -- Сохраняем в файл
        sampAddChatMessage("{66CCFF}[ " .. thisScript().name .. " ] {FFFFFF}Установлен ID погоды: {66CCFF}" .. weather, -1)
    else
        sampAddChatMessage("{66CCFF}[ " .. thisScript().name .. " ] {FFFFFF}Используйте: {66CCFF}/sw [0-45]", -1)
    end
end)

sampRegisterChatCommand("flavka", function()
        FloodLavka[0] = not FloodLavka[0]
        saveConfig()
        sampAddChatMessage("{66CCFF}[ " .. thisScript().name .. " ] {FFFFFF}Функция: {ff6347} FloodLavka {FFFFFF}" .. (FloodLavka[0] and "{включен" or "остановлен"), -1)
    end)
sampRegisterChatCommand("storage", function()
        StorageCollect[0] = not StorageCollect[0]
        saveConfig()
        sampAddChatMessage("{66CCFF}[ " .. thisScript().name .. " ] {FFFFFF}Функция: {ff6347} StorageCollect {FFFFFF}" .. (StorageCollect[0] and "включен" or "остановлен"), -1)
    end)

    while true do
        wait(0)
        checkZones()
        updateEnvironment()
    end 
end

lua_thread.create(function()
    while true do
        wait(1300)
        if FloodLavka[0] then sampSendChat('/invent') end
        if StorageCollect[0] then sampSendChat('/storage') end
    end
end)