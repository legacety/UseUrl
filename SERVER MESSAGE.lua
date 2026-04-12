require 'lib.moonloader'
local sampev = require 'lib.samp.events'

function main()
    while not isSampAvailable() do wait(100) end
    print('Скрипт запущен')
    wait(-1)
end

function sampev.onServerMessage(color, text)
    print('[SERVER MESSAGE] ' .. text)
end
