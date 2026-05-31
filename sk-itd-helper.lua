script_name("igasick")
script_author("legacy.")

local fa = require 'fAwesome6_solid'
local imgui = require 'mimgui'
local encoding = require 'encoding'
local acef = require 'arizona-events'
local sampev = require 'samp.events'
local memory = require "memory"
script_properties 'work-in-pause'
local wm = require('lib.windows.message')
local vkeys = require('vkeys')
local hotkey = require 'mimgui_hotkeys'

encoding.default = 'CP1251'
local u8 = encoding.UTF8

local renderWindow = imgui.new.bool(false)
local activeTab = 1

local Clicker = imgui.new.bool(false)
local Konvert = imgui.new.bool(false)
local Office = imgui.new.bool(false)
local TextDraw = imgui.new.bool(false)
local NotifyChat = imgui.new.bool(false)
local NotifyCef = imgui.new.bool(false)
local Notify = imgui.new.bool(false)
local TimeValue = imgui.new.int(12)
local Alavka = imgui.new.bool(false)
local useKeyLavka = imgui.new.bool(false)
local useKeyStorage = imgui.new.bool(false)
local TimeLock = imgui.new.bool(false)
local WeatherValue = imgui.new.int(1)
local WeatherLock = imgui.new.bool(false)
local StorageCollect = imgui.new.bool(false)
local useKey = imgui.new.bool(false)
local actual = {time = memory.getint8(0xB70153),weather = memory.getint16(0xC81320)}
local td = {94, 95, 96, 97}
local TdClickDelay = imgui.new.int(300)
local Players = {}
local stats = {}
local zones = {
    { x = 1446.81, y = 1922.35, z = 2006.45, r = 2.5 },
    { x = 1446.81, y = 1924.02, z = 2006.45, r = 2.5 },
    { x = 1446.81, y = 1924.02, z = 2006.45, r = 2.5 },
    { x = 1446.82, y = 1927.50, z = 2006.45, r = 2.5 },
    { x = 1446.82, y = 1927.50, z = 2006.45, r = 2.5 }
}
local binding = {
    lavka = { is_editing = false, key = 79 },
    storage = { is_editing = false, key = 69 }
}
local tabs = { 
    {name = u8"Главная", icon = fa.HOUSE}, 
    {name = u8"Функции СК", icon = fa.SCREWDRIVER_WRENCH}, 
    {name = u8"Заработок", icon = fa.CIRCLE_DOLLAR_TO_SLOT},
    {name = u8"Погода", icon = fa.CLOUD_SUN},
    {name = u8"Маркет", icon = fa["STORE"]}
}

local function get_key_name(id)
    local name = vkeys.id_to_name(id)
    return name and name:gsub('VK_', '') or tostring(id)
end

function setWorldTimeLocal(hour)
    local bs = raknetNewBitStream()
    raknetBitStreamWriteInt8(bs, hour)
    raknetEmulRpcReceiveBitStream(94, bs)
    raknetDeleteBitStream(bs)
end

function setWorldWeatherLocal(id)
    local bs = raknetNewBitStream()
    raknetBitStreamWriteInt8(bs, id)
    raknetEmulRpcReceiveBitStream(152, bs)
    raknetDeleteBitStream(bs)
end

function isPlayerInWorld(interior_id)
    local ip, port = sampGetCurrentServerAddress()
    if ip == "80.66.82.147" then return (interior_id == 20) end
    return (interior_id == 0)
end

local cfg_path = getWorkingDirectory() .. "\\config\\igasick.cfg"
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
                        if k == "Clicker" then Clicker[0] = v == "true" end
                        if k == "Konvert" then Konvert[0] = v == "true" end
                        if k == "Office" then Office[0] = v == "true" end
                        if k == "TextDraw" then TextDraw[0] = v == "true" end
                        if k == "TdClickDelay" then TdClickDelay[0] = tonumber(v) or 300 end
                        if k == "Notify" then Notify[0] = v == "true" end
                        if k == "NotifyChat" then NotifyChat[0] = v == "true" end
                        if k == "NotifyCef" then NotifyCef[0] = v == "true" end
                    elseif section == "climate" then
                        if k == "TimeValue" then TimeValue[0] = tonumber(v) or 12 end
                        if k == "TimeLock" then TimeLock[0] = v == "true" end
                        if k == "WeatherValue" then WeatherValue[0] = tonumber(v) or 1 end
                        if k == "WeatherLock" then WeatherLock[0] = v == "true" end
                    elseif section == "market" then
                        if k == "Alavka" then Alavka[0] = v == "true" end
                        if k == "StorageCollect" then StorageCollect[0] = v == "true" end
                        if k == "useKeyLavka" then useKeyLavka[0] = v == "true" end
                        if k == "useKeyStorage" then useKeyStorage[0] = v == "true" end
                        if k == "lavkaKey" then 
                            binding.lavka.key = tonumber(v) or 79 
                        end
                        if k == "storageKey" then 
                            binding.storage.key = tonumber(v) or 69 
                        end
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
    f:write("TextDraw=" .. tostring(TextDraw[0]) .. "\n")
    f:write("TdClickDelay=" .. TdClickDelay[0] .. "\n")
    f:write("Notify=" .. tostring(Notify[0]) .. "\n")
    f:write("NotifyChat=" .. tostring(NotifyChat[0]) .. "\n")
    f:write("NotifyCef=" .. tostring(NotifyCef[0]) .. "\n")

    f:write("\n[climate]\n")
    f:write("TimeValue=" .. TimeValue[0] .. "\n")
    f:write("TimeLock=" .. tostring(TimeLock[0]) .. "\n")
    f:write("WeatherValue=" .. WeatherValue[0] .. "\n")
    f:write("WeatherLock=" .. tostring(WeatherLock[0]) .. "\n")

f:write("\n[market]\n")
    f:write("Alavka=" .. tostring(Alavka[0]) .. "\n")
    f:write("lavkaKey=" .. binding.lavka.key .. "\n")
    f:write("storageKey=" .. binding.storage.key .. "\n")
    f:write("useKeyLavka=" .. tostring(useKeyLavka[0]) .. "\n")
    f:write("useKeyStorage=" .. tostring(useKeyStorage[0]) .. "\n")
    f:write("StorageCollect=" .. tostring(StorageCollect[0]) .. "\n")

    f:write("\n[salary]\n")
    for date, money in pairs(stats) do f:write(date .. "=" .. money .. "\n") end
    f:close()
end

function imgui.CenterText(text)
    local colWidth = imgui.GetColumnWidth()
    local textSize = imgui.CalcTextSize(text)
    imgui.SetCursorPosX(imgui.GetCursorPosX() + (colWidth - textSize.x) * 0.5)
    imgui.Text(text)
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
    imgui.SetNextWindowSize(imgui.ImVec2(550, 450), imgui.Cond.FirstUseEver)
    local sw, sh = getScreenResolution()
    imgui.SetNextWindowPos(imgui.ImVec2(sw * 0.5, sh * 0.5), imgui.Cond.Appearing, imgui.ImVec2(0.5, 0.5))
    if imgui.Begin(u8"SetVc Tools", renderWindow, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse) then
        imgui.BeginChild("LeftMenu", imgui.ImVec2(150, -1), true)
        for i, tab in ipairs(tabs) do
            if imgui.Button(tab.icon .. "  " .. tab.name, imgui.ImVec2(-1, 35)) then
                activeTab = i
            end
        end
        imgui.EndChild()
        imgui.SameLine()
        imgui.BeginChild("MainContent", imgui.ImVec2(-1, -1), true)
        if activeTab == 1 then
            imgui.TextColored(imgui.ImVec4(0.35, 0.75, 1.0, 1.0), fa.HOUSE .. u8" Информация о скрипте")
            imgui.Separator()

            imgui.BeginChild("InfoBlock", imgui.ImVec2(0, 0), true)
            imgui.TextColored(imgui.ImVec4(1, 1, 1, 1), fa["INFO"] .. u8" Общие сведения")
            imgui.Separator()
            imgui.Dummy(imgui.ImVec2(0, 5))
            
            imgui.Text(u8"Название: SetVc Tools")
            imgui.Text(u8"Автор: legacy")
            imgui.Text(u8"Версия: 4.0")
            imgui.Text(u8"Назначение: Автоматизация работы в СК")

            imgui.Dummy(imgui.ImVec2(0, 15))
            imgui.TextColored(imgui.ImVec4(1, 1, 1, 1), fa.CIRCLE_CHECK .. u8" Возможности")
            imgui.Separator()
            imgui.Dummy(imgui.ImVec2(0, 5))

            imgui.BulletText(u8"Автокликер в 1 кабинете")
            imgui.BulletText(u8"Автопрохождение документов во 2 кабинете")
            imgui.BulletText(u8"Автоклик по TextDraw в 3 кабинете")
            imgui.BulletText(u8"Автозаполнение диалогов в 3 кабинете")
            imgui.BulletText(u8"Уведомления о игроках возле зон СК")
            imgui.BulletText(u8"Cтатистика заработка в СК")

            imgui.Dummy(imgui.ImVec2(0, 20))
            imgui.Separator() 
            imgui.CenterText(fa.CIRCLE_CHECK .. u8" Скрипт готов к работе")

        elseif activeTab == 2 then
            imgui.TextColored(imgui.ImVec4(0.4, 0.8, 1, 1), fa.SCREWDRIVER_WRENCH .. u8" Функции")
            imgui.Separator()
            if imgui.Checkbox(u8"Включить кликер", Clicker) then saveConfig() end
            if imgui.Checkbox(u8"Включить конвертер", Konvert) then saveConfig() end
            if imgui.Checkbox(u8"Автозаполнение документов", Office) then saveConfig() end
            if imgui.Checkbox(u8"Клик по текстдрайвам", TextDraw) then saveConfig() end

            if TextDraw[0] then
                imgui.Separator()
                if imgui.SliderInt(u8"Задержка TD (мс)", TdClickDelay, 1, 500) then saveConfig() end
            end

            imgui.Text(u8"Уведомления о игроках:")
            if imgui.Checkbox(u8"Включить уведомления", Notify) then saveConfig() end
            if Notify[0] then
                imgui.Separator()
                if imgui.Checkbox(u8"Уведомления в чат", NotifyChat) then saveConfig() end
                if imgui.Checkbox(u8"Уведомления в CEF", NotifyCef) then saveConfig() end
            end

        elseif activeTab == 3 then
            imgui.TextColored(imgui.ImVec4(0.4, 0.8, 1, 1), fa.CIRCLE_DOLLAR_TO_SLOT .. u8" Заработок")
            imgui.Separator()
            local totalSelary = 0
             for _, money in pairs(stats) do
                totalSelary = totalSelary + money
            end
            imgui.TextColored(imgui.ImVec4(0, 1, 0, 1),u8"Общий заработок: $ " .. tostring(totalSelary):reverse():gsub("(%d%d%d)","%1,"):reverse():gsub("^,",""))
            if imgui.Button(u8"Очистить историю", imgui.ImVec2(-1, 20)) then stats = {} saveConfig() end
            imgui.BeginChild("Table", imgui.ImVec2(0, -1), true)
            imgui.SetCursorPos(imgui.ImVec2(0, 0))
            imgui.Columns(2, "IncomeCols", true)
            imgui.Dummy(imgui.ImVec2(0, 1))
            imgui.CenterText(u8"День")
            imgui.NextColumn()
            imgui.Dummy(imgui.ImVec2(0, 1))
            imgui.CenterText(u8"Заработок")
            imgui.NextColumn()
            imgui.Separator()

            local sorted = {}
            for k in pairs(stats) do table.insert(sorted, k) end
            table.sort(sorted, function(a,b) return a > b end)
            for _, date in ipairs(sorted) do
            imgui.CenterText(date); imgui.NextColumn()
            imgui.CenterText("$ " .. tostring(stats[date]):reverse():gsub("(%d%d%d)","%1,"):reverse():gsub("^,","")); imgui.NextColumn()
            imgui.Separator()
            end
        elseif activeTab == 4 then
            imgui.TextColored(imgui.ImVec4(1, 0.8, 0.4, 1), fa.CLOUD_SUN .. u8" Окружение")
            imgui.Separator()
            
            imgui.Text(u8"Время:")
            if imgui.SliderInt("##time", TimeValue, 0, 23) then
                setWorldTimeLocal(TimeValue[0])
                sampAddChatMessage("{00FFFF}[SetVc] {FFFFFF}Установлено время: " .. TimeValue[0] .. ":00", -1)
                saveConfig()
            end
            if imgui.Checkbox(u8"Зафиксировать время", TimeLock) then saveConfig() end
            
            imgui.Dummy(imgui.ImVec2(0, 10))
            imgui.Text(u8"Погода:")
            if imgui.SliderInt("##weather", WeatherValue, 0, 45) then
                setWorldWeatherLocal(WeatherValue[0])
                sampAddChatMessage("{00FFFF}[SetVc] {FFFFFF}Установлен ID погоды: " .. WeatherValue[0], -1)
                saveConfig()
            end
            if imgui.Checkbox(u8"Зафиксировать погоду", WeatherLock) then saveConfig() end
elseif activeTab == 5 then
    imgui.TextColored(imgui.ImVec4(0.4, 0.8, 1, 1), fa.STORE .. u8" Маркет")
    imgui.Separator()
    imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.0, 1.0), u8"Авто-установка лавки")  
    if imgui.Checkbox(u8"Включить авто-лавку##lavka_main", Alavka) then saveConfig() end
    if imgui.Checkbox(u8"Активация кнопкой##lavka_use_key", useKeyLavka) then saveConfig() end    
    imgui.SameLine()
    local lavka_disabled = not useKeyLavka[0]    
    if lavka_disabled then
        imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, 0.6)
    end
    local lavka_key_name = vkeys.id_to_name(binding.lavka.key) and vkeys.id_to_name(binding.lavka.key):gsub('VK_', '') or tostring(binding.lavka.key)
    if imgui.Button((binding.lavka.is_editing and u8"Нажмите клавишу...##L" or u8(lavka_key_name)) .. "##btn_lavka", imgui.ImVec2(120, 20)) then
        if not lavka_disabled then
            binding.lavka.is_editing = true
        end
    end

    if lavka_disabled then
        imgui.PopStyleVar()
    end

    imgui.Separator()
    imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.0, 1.0), u8"Сбор предметов из хранилища")
    
    if imgui.Checkbox(u8"Включить сбор##storage_main", StorageCollect) then saveConfig() end
    if imgui.Checkbox(u8"Активация кнопкой##storage_use_key", useKeyStorage) then saveConfig() end
    
    imgui.SameLine()
    local storage_disabled = not useKeyStorage[0]

    if storage_disabled then
        imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, 0.6)
    end

    local storage_key_name = vkeys.id_to_name(binding.storage.key) and vkeys.id_to_name(binding.storage.key):gsub('VK_', '') or tostring(binding.storage.key)
    if imgui.Button((binding.storage.is_editing and u8"Нажмите клавишу...##S" or u8(storage_key_name)) .. "##btn_storage", imgui.ImVec2(120, 20)) then
        if not storage_disabled then
            binding.storage.is_editing = true
        end
    end

    if storage_disabled then
        imgui.PopStyleVar()
    end

    if binding.lavka.is_editing or binding.storage.is_editing then
        for vkey = 0, 255 do
            if isKeyDown(vkey) then
                if vkey ~= vkeys.VK_RETURN and vkey ~= vkeys.VK_ESCAPE then
                    if binding.lavka.is_editing then
                        binding.lavka.key = vkey
                        sampAddChatMessage("{00FFFF}[SetVc] {FFFFFF}Установили клавишу для лавки: {00FFFF}" .. (vkeys.id_to_name(vkey) or vkey), -1)
                    elseif binding.storage.is_editing then
                        binding.storage.key = vkey
                        sampAddChatMessage("{00FFFF}[SetVc] {FFFFFF}Установили клавишу для сторейджа: {00FFFF}" .. (vkeys.id_to_name(vkey) or vkey), -1)
                    end
                    saveConfig()
                end
                binding.lavka.is_editing = false
                binding.storage.is_editing = false
                break
            end
        end
    end
        end
        
        imgui.EndChild()
    end
    imgui.End()
end)

addEventHandler('onWindowMessage', function(msg, wparam, lparam)
    if msg == wm.WM_KEYDOWN and not renderWindow[0] and not sampIsChatInputActive() then
        if useKeyLavka[0] and wparam == binding.lavka.key then
            Alavka[0] = not Alavka[0]
            saveConfig()
            sampAddChatMessage("{00FFFF}[SetVc] {FFFFFF}Автоустановка лавки " .. (Alavka[0] and "{00FF00}включена" or "{FF0000}выключена"), -1)
        end        
        if useKeyStorage[0] and wparam == binding.storage.key then
            StorageCollect[0] = not StorageCollect[0] 
            saveConfig()
            sampAddChatMessage("{00FFFF}[SetVc] {FFFFFF}Сбор предметов " .. (StorageCollect[0] and "{33FF33}Активирован" or "{FF4C4C}Деактивирован"), -1)
        end
    end
end)

function sampev.onSetWeather(id)
    actual.weather = id
    if WeatherLock[0] then return false end
end

function sampev.onSetPlayerTime(hour, min)
    actual.time = hour
    if TimeLock[0] then return false end
end

function sampev.onSetWorldTime(hour)
    actual.time = hour
    if TimeLock[0] then return false end
end

function sampev.onSetInterior(id)
    local result = isPlayerInWorld(id)
    if TimeLock[0] then setWorldTimeLocal(result and TimeValue[0] or actual.time) end
    if WeatherLock[0] then setWorldWeatherLocal(result and WeatherValue[0] or actual.weather) end
end

function sampev.onServerMessage(color, text)
    if color == 1941201407 and text:find("Ваша зарплата:") then
        local moneyText = text:match("Ваша зарплата:.-([^%(]+)")        
        if moneyText then
            local cleanMoney = moneyText:gsub("%D", "")
            local money = tonumber(cleanMoney)
            if money then
                if money < 1000 then 
                    money = money * 1000000 
                end
                local date = os.date("%d.%m.%Y")
                stats[date] = (stats[date] or 0) + money
                saveConfig()
            end
        end
    end
end

function sampev.onShowTextDraw(id)
    if not TextDraw[0] then return end
    for _, td_id in ipairs(td) do
        if id == td_id then
            lua_thread.create(function()
                for _, click_id in ipairs(td) do
                    wait(TdClickDelay[0])
                    sampSendClickTextdraw(click_id)
                end
            end)
            break
        end
    end
end
function sampev.onShowDialog(id, style, title, button1, button2, text)
    if Office[0] then
        if title:find('{BFBBBA}Заполнение документа') then
            sampSendDialogResponse(id, 1, nil, text:match('{ffff00}(.+)'))
            return false
        end
    end

    if StorageCollect[0] then
        if text:find("Нет доступных предметов") then
            StorageCollect[0] = false
            saveConfig()
            sampAddChatMessage("{00FFFF}[SetVc] {FFFFFF}В хранилище пусто. {FF4C4C}Сбор завершён.", -1)
            sampSendDialogResponse(id, 0, 0, nil)
            return false
        end

        if title:find("Хранилище предметов") and text:find("Основное хранилище") then
            sampSendDialogResponse(id, 1, 1, nil)
            return false
        end
        
        if text:find("Причина выдачи") and text:find("Дата выдачи") then
            sampSendDialogResponse(id, 1, 0, nil)
            return false
        end

        if text:find("Вы действительно хотите забрать") or text:find("нажмите клавишу 'Далее'") then
            sampSendDialogResponse(id, 1, 0, nil)
            return false
        end
    end
end

function acef.onArizonaDisplay(packet)
    if Clicker[0] and packet.text:find("event.clicker.setProgress") then
        lua_thread.create(function()
            for i = 1, 4 do
                acef.send("onArizonaSend", { server_id = 0, text = "clickMinigame" })
                wait(69)
            end
        end)
    end

    if Konvert[0] and packet.text:find("FindGame") then
        for i = 1, 5 do acef.send("onArizonaSend", { server_id = 0, text = "findGame.Success" }) end
        acef.send("onArizonaSend", { server_id = 0, text = "findGame.finish" })
        return false
    end

if Alavka[0] and packet.text:find("Inventory") then
    acef.send("onArizonaSend", { server_id = 0, text = 'clickOnButton|{"type": 2, "slot": 11, "action": 1}' })
    acef.send("onArizonaSend", { server_id = 0, text = 'rightClickOnBlock|{"slot": 11, "type": 2}' })
    acef.send("onArizonaSend", { server_id = 0, text = "inventoryClose" })
end
end
function main()
    while not isSampAvailable() do wait(0) end
    loadConfig()
    sampAddChatMessage("{00FFFF}[SetVc Tools] {FFFFFF}Загружен. Меню: {00FFFF}/vc", -1)    
    sampRegisterChatCommand("vc", function() renderWindow[0] = not renderWindow[0] end)   
    sampRegisterChatCommand("st", function(arg) 
        local hour = tonumber(arg)
        if hour and hour >= 0 and hour <= 23 then
            TimeValue[0] = hour
            setWorldTimeLocal(hour)
            saveConfig()
          sampAddChatMessage("{00FFFF}[SetVc] {FFFFFF}Установлено время: {00FFFF}" .. hour .. ":00", -1)
         else
            sampAddChatMessage("{00FFFF}[SetVc] {FFFFFF}Используйте: /st [0-23]", -1)
        end
    end)

    sampRegisterChatCommand("sw", function(arg) 
        local id = tonumber(arg)
        if id and id >= 0 and id <= 45 then
            WeatherValue[0] = id
            setWorldWeatherLocal(id)
            saveConfig()
          sampAddChatMessage("{00FFFF}[SetVc] {FFFFFF}Установлен ID погоды: {00FFFF}" .. id, -1)
        else
            sampAddChatMessage("{00FFFF}[SetVc] {FFFFFF}Используйте: /sw [0-45]", -1)
        end
    end)

    sampRegisterChatCommand("bt", function()
        TimeLock[0] = not TimeLock[0]
        saveConfig()
        local state = TimeLock[0] and "{00FF00}включена" or "{FF0000}выключена"
        sampAddChatMessage("{00FFFF}[SetVc] {FFFFFF}Заморозка времени " .. state, -1)
    end)

    sampRegisterChatCommand("bw", function()
        WeatherLock[0] = not WeatherLock[0]
        saveConfig()
        local state = WeatherLock[0] and "{00FF00}включена" or "{FF0000}выключена"
        sampAddChatMessage("{00FFFF}[SetVc] {FFFFFF}Заморозка погоды " .. state, -1)
    end)

sampRegisterChatCommand('sbor', function()
    StorageCollect[0] = not StorageCollect[0]
    saveConfig()
    sampAddChatMessage("{00FFFF}[SetVc] {FFFFFF}Сбор предметов " .. (StorageCollect[0] and "{33FF33}Активирован" or "{FF4C4C}Деактивирован"), -1)
end)

lua_thread.create(function()
        while true do
            wait(1300)
            if Alavka[0] then
                sampProcessChatInput('/invent')
            end
            if StorageCollect[0] then
                sampProcessChatInput('/storage')
            end
        end
    end)

   while true do
        wait(250)
        for playerId = 0, 999 do
            if sampIsPlayerConnected(playerId) then
                local res, ped = sampGetCharHandleBySampPlayerId(playerId)
                if res and doesCharExist(ped) then
                    local px, py, pz = getCharCoordinates(ped)
                    for i, zone in ipairs(zones) do
                        if not Players[i] then Players[i] = {} end
                        local inzone = getDistanceBetweenCoords3d(px, py, pz, zone.x, zone.y, zone.z) <= zone.r
                        if inzone ~= (Players[i][playerId] or false) then
                            Players[i][playerId] = inzone
                            local nick = sampGetPlayerNickname(playerId)
                            if NotifyChat[0] then
                                sampAddChatMessage("{00FFFF}[Зоны] {FFFFFF}Игрок " .. nick .. (inzone and " подошел к " or " покинул ") .. "позиции №" .. i, -1)
                            end
                            if NotifyCef[0] then
                                lua_thread.create(function()
                                    acef.emul("onArizonaDisplay", { text = "window.executeEvent('cef.modals.showModal', `[\"dialogTip\",{\"position\":\"rightBottom\",\"backgroundImage\":\"bank_notify_add.webp\",\"icon\":\"icon-info\",\"iconColor\":\"#2ECC71\",\"highlightColor\":\"#5FC6FF\",\"text\":\"Игрок " .. nick .. " " .. (inzone and "подошел к" or "покинул") .. " позиции №" .. i .. "\"}]`);" })
                                    wait(3000)
                                    acef.emul("onArizonaDisplay", { text = "window.executeEvent('cef.modals.closeModal', `[\"dialogTip\"]`);" })
                                end)
                            end
                        end
                    end
                end
            end
        end
    end
end