local KGCore = exports['kg-core']:GetCoreObject()

CreateThread(function()
    while true do
        Wait(1000)
        GenerateVehicleList()
        Wait((1000 * 60) * 60)
    end
end)

RegisterNetEvent('kg-scrapyard:server:LoadVehicleList', function()
    local src = source
    TriggerClientEvent('kg-scapyard:client:setNewVehicles', src, Config.CurrentVehicles)
end)


KGCore.Functions.CreateCallback('kg-scrapyard:checkOwnerVehicle', function(_, cb, plate)
    local result = MySQL.scalar.await('SELECT `plate` FROM `player_vehicles` WHERE `plate` = ?', { plate })
    if result then
        cb(false)
    else
        cb(true)
    end
end)


RegisterNetEvent('kg-scrapyard:server:ScrapVehicle', function(listKey)
    local src = source
    local Player = KGCore.Functions.GetPlayer(src)
    if Config.CurrentVehicles[listKey] ~= nil then
        for _ = 1, math.random(2, 4), 1 do
            local item = Config.Items[math.random(1, #Config.Items)]
            exports['kg-inventory']:AddItem(src, item, math.random(25, 45), false, false, 'kg-scrapyard:server:ScrapVehicle')
            TriggerClientEvent('kg-inventory:client:ItemBox', src, KGCore.Shared.Items[item], 'add')
            Wait(500)
        end
        local Luck = math.random(1, 8)
        local Odd = math.random(1, 8)
        if Luck == Odd then
            local random = math.random(10, 20)
            exports['kg-inventory']:AddItem(src, 'rubber', random, false, false, 'kg-scrapyard:server:ScrapVehicle')
            TriggerClientEvent('kg-inventory:client:ItemBox', src, KGCore.Shared.Items['rubber'], 'add')
        end
        Config.CurrentVehicles[listKey] = nil
        TriggerClientEvent('kg-scapyard:client:setNewVehicles', -1, Config.CurrentVehicles)
    end
end)

function GenerateVehicleList()
    Config.CurrentVehicles = {}
    for i = 1, Config.VehicleCount, 1 do
        local randVehicle = Config.Vehicles[math.random(1, #Config.Vehicles)]
        if not IsInList(randVehicle) then
            Config.CurrentVehicles[i] = randVehicle
        end
    end
    TriggerClientEvent('kg-scapyard:client:setNewVehicles', -1, Config.CurrentVehicles)
end

function IsInList(name)
    local retval = false
    if Config.CurrentVehicles ~= nil and next(Config.CurrentVehicles) ~= nil then
        for k in pairs(Config.CurrentVehicles) do
            if Config.CurrentVehicles[k] == name then
                retval = true
            end
        end
    end
    return retval
end
