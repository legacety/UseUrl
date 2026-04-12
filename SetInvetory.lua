local acef = require("arizona-events")

function main()
    while not isSampAvailable() do wait(100) end
    sampAddChatMessage("{00FFFF}[CEF] Ñêğèïò çàãğóæåí. Êîìàíäà: /inv 1-3", -1)
    sampRegisterChatCommand("inv", function(param)
        local page = tonumber(param)
        if page and page >= 1 and page <= 3 then
            sampSendChat("/invent")
      acef.send("onArizonaSend", { server_id = 0, text = "inventory.setAccessoryPage|" .. page })
            sampAddChatMessage("{00FF00}[CEF] Îòïğàâëåíî: inventory.setAccessoryPage|" .. page,-1)
        else
            sampAddChatMessage("{FF0000}[CEF] Îøèáêà: /inv 1-3",-1)
        end
    end)
    wait(-1)
end
