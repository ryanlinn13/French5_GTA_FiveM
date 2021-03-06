RconLog({LOG = 'Please contact the server administrators. -- www.french5.fr --'})

RegisterServerEvent('rlPlayerActivated')

local names = {}

AddEventHandler('rlPlayerActivated', function()
    -- RconLog({ msgType = 'playerActivated', netID = source, name = GetPlayerName(source), guid = GetPlayerIdentifiers(source)[1], ip = GetPlayerEP(source) })
    -- RconLog({F5 = 'IN', ID = source, NAME = GetPlayerName(source), STEAM = GetPlayerIdentifiers(source)[1] })
    TriggerEvent('Slog', '[JOIN] id: '..source..', name: '..GetPlayerName(source)..', '..GetPlayerIdentifiers(source)[1]..', ip: '..GetPlayerEP(source))
    names[source] = { name = GetPlayerName(source), id = source }

    -- TriggerClientEvent('rlUpdateNames', GetHostId())
end)

RegisterServerEvent('rlUpdateNamesResult')

AddEventHandler('rlUpdateNamesResult', function(res)
    if source ~= tonumber(GetHostId()) then
        print('bad guy')
        return
    end

    for id, data in pairs(res) do
        if data then
            if data.name then
                if not names[id] then
                    names[id] = data
                end

                if names[id].name ~= data.name or names[id].id ~= data.id then
                    names[id] = data

                    -- RconLog({ msgType = 'playerRenamed', netID = id, name = data.name })
                end
            end
        else
            names[id] = nil
        end
    end
end)

AddEventHandler('playerDropped', function()
    -- RconLog({ msgType = 'playerDropped', netID = source, name = GetPlayerName(source) })
    -- RconLog({F5 = 'OUT', ID = source})
    TriggerEvent('Slog', '[QUIT] id: '..source)
    names[source] = nil
end)

AddEventHandler('chatMessage', function(netID, name, message)
    -- RconLog({ msgType = 'chatMessage', netID = netID, name = name, message = message, guid = GetPlayerIdentifiers(netID)[1] })
    -- RconLog({F5 = 'MSG', ID = netID, MSG = message })
    TriggerEvent('Slog', '[CHAT] id: '..netID..', name: '..name..', message: '..message)
end)

AddEventHandler('rconCommand', function(commandName, args)
    if commandName == 'status' then
        for netid, data in pairs(names) do
            local guid = GetPlayerIdentifiers(netid)

            if guid and guid[1] and data then
                local ping = GetPlayerPing(netid)

                RconPrint(netid .. ' ' .. guid[1] .. ' ' .. data.name .. ' ' .. GetPlayerEP(netid) .. ' ' .. ping .. "\n")
            end
        end

        CancelEvent()
    elseif commandName:lower() == 'clientkick' then
        local playerId = table.remove(args, 1)
        local msg = table.concat(args, ' ')

        DropPlayer(playerId, msg)

        CancelEvent()
    elseif commandName:lower() == 'tempbanclient' then
        local playerId = table.remove(args, 1)
        local msg = table.concat(args, ' ')

        TempBanPlayer(playerId, msg)

        CancelEvent()
    end
end)
