local sampev = require 'samp.events'

function sampev.onServerMessage(color, text)
    if text:find("Ваша зарплата:") then
        sampAddChatMessage("Числовой код цвета зарплаты: " .. color, -1)
    end
end