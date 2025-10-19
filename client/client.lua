local QBCore = exports['qb-core']:GetCoreObject()
local coreLoaded = false

Citizen.CreateThread(function()
    while QBCore == nil do
        Citizen.Wait(30)
    end
    coreLoaded = true

    local blip = AddBlipForCoord(Config.location)
    SetBlipSprite(blip, 473)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.5)
    SetBlipColour(blip, 41)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Self Storage")
    EndTextCommandSetBlipName(blip)
    
    PlayerData = QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent('arimaya-selfstorage:client:refresh', function()
    openStash()
end)

RegisterNetEvent('arimaya-selfstorage:client:closeUi', function()
    SendNUIMessage({ type = "close"})
    SetNuiFocus(false, false)
end)

RegisterNetEvent('arimaya-selfstorage:client:passwordCorrect', function(num, name)
    TriggerServerEvent('arimaya-selfstorage:server:openStash', num, name)
    TriggerEvent("arimaya-selfstorage:client:closeUi")
end)

RegisterNetEvent('arimaya-selfstorage:client:passwordIncorrect', function()
    QBCore.Functions.Notify("Girdiğiniz şifre yanlış", "error", 2000)
end)

function openStash()
    QBCore.Functions.TriggerCallback('arimaya-selfstorage:server:getStorageData', function(data)
        SendNUIMessage({ 
            type = "open", 
            data = data, 
            identifier = PlayerData.citizenid, 
            stashPrice = Config.price 
        })
        SetNuiFocus(true, true)
    end)
end

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        SetNuiFocus(false, false)
    end
end)

RegisterNUICallback('closeBtn', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('createStash', function(data, cb)
    QBCore.Functions.TriggerCallback('arimaya-selfstorage:server:buyStorage', function(success)
        if success then
            QBCore.Functions.Notify("Başarıyla depoyu satın aldın", "success", 4500)
        else
            QBCore.Functions.Notify("Depo satın alınamadı!", "error", 4500)
        end
    end, data, QBCore.Functions.GetPlayerData().citizenid)
    cb('ok')
end)

RegisterNUICallback('createError', function(data, cb)
    QBCore.Functions.Notify("Depo İsminde Türkçe Karakter, Boşluk İçeremez!", "error", 4500)
    cb('ok')
end)

RegisterNUICallback('openError', function(data, cb)
    QBCore.Functions.Notify("Şifre yanlış!", "error", 4500)
    cb('ok')
end)

RegisterNUICallback('openStash', function(data, cb)
    TriggerServerEvent('arimaya-selfstorage:server:checkPassword', data)
    cb('ok')
end)

CreateThread(function()
    local pedModel = GetHashKey("a_m_y_hasjew_01")
    
    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
        Wait(1)
    end
    
    local groundZ = Config.location.z
    local found, z = GetGroundZFor_3dCoord(Config.location.x, Config.location.y, Config.location.z, false)
    
    if found then
        groundZ = z
    end
    
    local npc = CreatePed(1, pedModel, Config.location.x, Config.location.y, groundZ, Config.location.w, false, true)
    SetPedCombatAttributes(npc, 46, true)
    SetPedFleeAttributes(npc, 0, 0)
    SetBlockingOfNonTemporaryEvents(npc, true)
    SetEntityAsMissionEntity(npc, true, true)
    SetEntityInvincible(npc, true)
    FreezeEntityPosition(npc, true)
    
    if Config.target == "qb-target" then
        exports['qb-target']:AddTargetEntity(npc, {
            options = {
                {
                    type = "client",
                    event = "arimaya-selfstorage:client:refresh",
                    icon = "fas fa-box",
                    label = "Depoyu Aç",
                }
            },
            distance = 2.0
        })
    elseif Config.target == "ox_target" then
        exports.ox_target:addLocalEntity(npc, {
            {
                name = 'arimaya-selfstorage_storage_open',
                icon = 'fas fa-box',
                label = 'Depoyu Aç',
                onSelect = function()
                    TriggerEvent('arimaya-selfstorage:client:refresh')
                end,
                distance = 2.0
            }
        })
    end
    
    SetModelAsNoLongerNeeded(pedModel)
end)
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())

    SetTextScale(0.3, 0.3)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 245)

    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
    local factor = (string.len(text)) / 410
    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 133)
end