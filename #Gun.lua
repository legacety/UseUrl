require 'lib.moonloader'
local sampev = require 'lib.samp.events'

local weapon_list = {
    [0] = "RPG",
    [1] = "Fist",
    [2] = "Brass Knuckles",
    [3] = "Golf Club",
}

local gun_id, ammo_count

function main()
    while not isSampAvailable() do wait(100) end
    sampRegisterChatCommand("gn", function(params)
        local args = split(params, ' ')
        if #args ~= 2 then
            return sampAddChatMessage("Используй: /gn [ID оружия] [патроны]", 0xFF0000)
        end
        gun_id, ammo_count = tonumber(args[1]), tonumber(args[2])
        if not weapon_list[gun_id] then
            sampAddChatMessage("Оружие с ID " .. gun_id .. " не найдено.", 0xFF0000)
            gun_id, ammo_count = nil, nil
            return
        end
        sampSendChat("/gun")
    end)
end

function sampev.onShowDialog(id, style, title, btn1, btn2, text)
    if gun_id and ammo_count then
        if id == 27820 then
            local weaponName = weapon_list[gun_id]
            for i, line in ipairs(split(text, '\n')) do
                if line:lower():find(weaponName:lower()) then
                    sampSendDialogResponse(id, 1, i - 1, tostring(ammo_count))
                    return false
                end
            end
            gun_id, ammo_count = nil, nil
            return false
        elseif id == 3011 then
            sampSendDialogResponse(id, 1, 0, tostring(ammo_count))
            gun_id, ammo_count = nil, nil
            return false
        end
    end
end

function split(str, sep)
    local result = {}
    for token in string.gmatch(str, "[^" .. (sep or "%s") .. "]+") do
        table.insert(result, token)
    end
    return result
end
