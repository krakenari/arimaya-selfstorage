local QBCore = exports['qb-core']:GetCoreObject()
if Config.inventory == "ox_inventory" then
    ox_inventory = exports.ox_inventory
end

QBCore.Functions.CreateCallback('arimaya-selfstorage:server:getStorageData', function(source, cb)
    local data = MySQL.Sync.fetchAll('SELECT * FROM arimaya_selfstorage', {})
    cb(data)
end)

RegisterNetEvent('arimaya-selfstorage:server:openStash', function(stashid, stashname)
    local src = source
    local stashLabel = 'Stash ' .. tostring(stashname)
    

    if Config.inventory == "ox_inventory" then
        ox_inventory:RegisterStash(
            stashid,
            stashLabel,
            Config.slot,
            Config.weight
        )
    
        TriggerClientEvent('ox_inventory:openInventory', src, 'stash', stashid)
    elseif Config.inventory == "qb-inventory" then
    local data = { label = stashLabel, maxweight = Config.weight, slots = Config.slot }
    exports['qb-inventory']:OpenInventory(src, stashLabel, data)
    end
    TriggerClientEvent('arimaya-selfstorage:client:closeUi', src)
end)


RegisterNetEvent('arimaya-selfstorage:server:checkPassword', function(data)
    local src = source
    local result = MySQL.Sync.fetchAll('SELECT * FROM arimaya_selfstorage WHERE id = ?', { data.data.id })
    
    if result[1] and data.password == result[1].password then
        TriggerClientEvent('arimaya-selfstorage:client:passwordCorrect', src, result[1].num, data.data.name)
    else
        TriggerClientEvent('arimaya-selfstorage:client:passwordIncorrect', src)
    end
end)

QBCore.Functions.CreateCallback('arimaya-selfstorage:server:buyStorage', function(source, cb, data, identifier)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player then
        local money = Player.PlayerData.money.bank
        
        if money >= Config.price then
            local num = tostring(math.random(1000, 9999))
            
            MySQL.Async.insert(
                'INSERT INTO arimaya_selfstorage (name, password, num, identifier) VALUES (?, ?, ?, ?)',
                { data.name, data.password, num, identifier },
                function(insertId)
                    if insertId then
                        Player.Functions.RemoveMoney('bank', 50000, 'Buy Storage')
                        TriggerClientEvent('arimaya-selfstorage:client:refresh', src)
                        cb(true)
                    else
                        cb(false)
                    end
                end
            )
        else
            cb(false)
        end
    else
        cb(false)
    end
end)