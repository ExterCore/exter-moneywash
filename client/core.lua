Core = nil
CoreName = nil
CoreReady = false
Citizen.CreateThread(function()
    for k, v in pairs(Cores) do
        if GetResourceState(v.ResourceName) == "starting" or GetResourceState(v.ResourceName) == "started" then
            CoreName = v.ResourceName
            Core = v.GetFramework()
            CoreReady = true
        end
    end
end)

function TriggerCallback(name, cb, ...)
    Config.ServerCallbacks[name] = cb
    TriggerServerEvent('exter-moneywash:server:triggerCallback', name, ...)
end


RegisterCommand("props", function()
    SetNuiFocus(1, 1)
    SendNUIMessage({
        action = "openProps",
        data = Config.PropsAll,
    })
end)

RegisterNetEvent('exter-moneywash:client:triggerCallback', function(name, ...)
    if Config.ServerCallbacks[name] then
        Config.ServerCallbacks[name](...)
        Config.ServerCallbacks[name] = nil
    end
end)

function Notify(text, length, type)
    if CoreName == "qb-core" then
        Core.Functions.Notify(text, type, length)
    elseif CoreName == "es_extended" then
        Core.ShowNotification(text)
    end
end

function GetPlayerData()
    if CoreName == "qb-core" then
        local player = Core.Functions.GetPlayerData()
        return player
    elseif CoreName == "es_extended" then
        local player = Core.GetPlayerData()
        return player
    end
end


function OpenStash(stashId)
    local hasOx = GetResourceState('ox_inventory') == 'started'
    local hasQb = GetResourceState('qb_inventory') == 'started'

    if hasOx then 
        exports.ox_inventory:openInventory("stash", tostring(stashId))
    elseif hasQb then 
        TriggerServerEvent('inventory:server:OpenInventory', 'stash', 'launder_' .. menuId , {
             maxweight = 4000000,
             slots = 1,
        })
        TriggerEvent('inventory:client:SetCurrentStash', 'launder_' .. menuId)
            
    else
        -- CUSTOM INVENTORY
    end
end