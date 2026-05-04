local acef = require("arizona-events")
local banner = true

function acef.onArizonaDisplay(packet)
    if banner and packet.text:find('RewardBanner') and packet.text:find('event.setActiveView') then
        acef.send("onArizonaSend", { server_id = 0, text = "rewardBanner.close" })
        return false
    end
end

function main()
    while not isSampAvailable() do wait(0) end
    sampAddChatMessage('{FF4141}AutoCloseBanner загружен', -1)
    sampRegisterChatCommand('banners', function()
        banner = not banner
        sampAddChatMessage('{FF4141}[Freym-tech] {ffffff}Автозакрытие баннеров: ' .. (banner and '{00ff00}Активировано' or '{ff0000}Деактивировано'), -1)
    end)
    
    wait(-1)
end
