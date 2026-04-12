local acef = require("arizona-events")

function main()
    while not isSampAvailable() do wait(0) end
    sampRegisterChatCommand("test", function()
        lua_thread.create(function()
            acef.emul("onArizonaDisplay", {text = "window.executeEvent('cef.modals.showModal', `[\"dialogTip\",{\"position\":\"rightBottom\",\"backgroundImage\":\"bank_notify_add.webp\",\"icon\":\"icon-info\",\"iconColor\":\"#FFFF00\",\"highlightColor\":\"#5FC6FF\",\"text\":\"Вы в здание СК\"}]`);"})
            wait(3000)
            acef.emul("onArizonaDisplay", { text = "window.executeEvent('cef.modals.closeModal', `[\"dialogTip\"]`);" })
        end)
    end)
end

