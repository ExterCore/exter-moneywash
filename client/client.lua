playerData = {}
cacheData = {}
buildCacheData = {}
allObject = {}
sell = false
randomCoords = nil
torbaci = nil
currentObject = nil
objectHash = nil
lastPropItem = nil
itemSell = nil
coinSell = 0
local modelsToLoad = {"w_am_case","ch_prop_casino_drone_02a"}
menuId = 0



function openMenu()
    local stashId = "launder_" .. menuId 
    
    TriggerEvent('inventory:client:SetCurrentStash', 'launder-' .. menuId)
    TriggerServerEvent('inventory:server:OpenInventory', 'stash', 'launder-' .. menuId , {
         maxweight = 4000000,
    slots = 1})

end

function openGeneralData(id) 
    menuId = id

    SetNuiFocus(1, 1)
    SendNUIMessage({
        action = "open",
        data = cacheData,
        config = AC
    })
end

function openBuildPage(id)
    menuId = id
    SetNuiFocus(1, 1)

    local sendData = nil
    local canvasData = nil
    for _, v in pairs(cacheData) do
        if tonumber(id) == tonumber(v.id) then
            sendData = v["props"]
            canvasData = v["canvas"]
            break
        end
    end    

    SendNUIMessage({
                action = "openControl",
                data = {
                    sendData = sendData,   
                    canvasData = canvasData                 
                }
            })
 end

function openMiner(id)
    TriggerServerEvent('inventory:server:OpenInventory', 'stash', id)
    TriggerEvent('inventory:client:SetCurrentStash', id)
end

function loadModels(models)
    for _, model in ipairs(models) do
        RequestModel(model)
    end
    while not AreModelsLoaded(models) do
        Wait(500)
    end
end

function AreModelsLoaded(models)
    for _, model in ipairs(models) do
        if not HasModelLoaded(model) then
            return false
        end
    end
    return true
end

RegisterNUICallback('connected', function(data, cb)
    TriggerCallback('exter-money:objUpdate', function(bool)
        cb(bool)
     end, data,menuId)
end)

RegisterNUICallback('setCanvas', function(data, cb)
    TriggerCallback('exter-moneywash:setCanvas', function(serverCb) 
        cb(serverCb)
    end, data.canvasData,menuId)
end)

RegisterNUICallback("close", function()
    SetNuiFocus(0, 0)
end)

RegisterNUICallback('withdrawMoney', function(data, cb)
    TriggerCallback('exter-moneywash:withdrawMoney', function(serverCb) 
        cb(serverCb)
    end, data,menuId)
end)


RegisterNUICallback('saveBuild', function(data,cb)

    for k , v in pairs(Config.PropsAll) do
        if v.hash == tostring(objectHash) then
            data = {
                rotation = GetEntityRotation(currentObject),
                position = GetEntityCoords(currentObject),
                heading = GetEntityHeading(currentObject),
                name = v.name,
                hash = v.hash,
                propname = v.propname,
                itemType = v.itemType,
                objId = math.random(1, 1000000),
                linked = false
            }
            TriggerServerEvent('exter-moneywash:createProp', data, menuId)

            if v.itemType == "miner" then
                SendNUIMessage({
                    action = "newMiner",
                    data = {
                        data = data,
                    }
                })
            end

        end
    end

end)


RegisterNUICallback('openNui', function(data,cb)
    SetNuiFocus(1, 1)
end)

-- exter-moneywash client.lua

RegisterNUICallback("openProps", function(data, cb)
    flag = false
    TriggerCallback('exter-moneywash:propItemControl', function(serverCb) 
        if serverCb then
            lastPropItem = data.itemName
            objectName = data.propName
            objectHash = data.hash
            local playerPed = PlayerPedId()
            local offset = GetOffsetFromEntityInWorldCoords(playerPed, 0, 1.0, 0)
            local model = joaat(objectName)

            currentObject = CreateObject(model, offset.x, offset.y, offset.z, true, false, false)

            Citizen.CreateThread(function()
                while flag do 
                    Wait(100)
                    SendNUIMessage({
                        action = "setPropsData",
                        data = {
                            rotation = GetEntityRotation(currentObject),
                            position = GetEntityCoords(currentObject),
                        }
                    })
                end
            end)

            local objectPositionData = exports.object_gizmo:useGizmo(currentObject) 

            FreezeEntityPosition(currentObject, true)

        else
            cb(false)
        end
    end, data)
end)

RegisterNUICallback('deleteProp',function()
    DeleteEntity(currentObject)
    DeleteObject(currentObject)
    currentObject = nil
    TriggerServerEvent('exter-money:addLastProp', lastPropItem)
    lastPropItem = nil
end)

RegisterNUICallback("close", function()
    SetNuiFocus(0, 0)
end)

RegisterNetEvent('exter-moneywash:setClient')
AddEventHandler('exter-moneywash:setClient',function(data)
    cacheData = data

    if cacheData then
        for k, v in pairs(cacheData) do
                id = v.id
                identifier = v.identifier
                props = v.props
                miner = v.miner
                canvas = v.canvas
        end
    end

end)

RegisterNetEvent('exter-moneywash:notify')
AddEventHandler('exter-moneywash:notify',function(data)
    Notify(data)
end)

RegisterNetEvent('exter-moneywash:spawnProp')
AddEventHandler('exter-moneywash:spawnProp',function(data,obj)

    SetEntityAsMissionEntity(NetworkGetNetworkIdFromEntity(obj), true, true)
    SetEntityHeading(NetworkGetNetworkIdFromEntity(obj), data.heading)
    FreezeEntityPosition(NetworkGetNetworkIdFromEntity(obj), true)
    SetModelAsNoLongerNeeded(data.hash)
end)

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    playerData = GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded', function()
    playerData = GetPlayerData()
end)


Citizen.CreateThread(function()
    while true do
         Citizen.Wait(500)
         if NetworkIsPlayerActive(PlayerId()) then 
            playerData = GetPlayerData()
            TriggerServerEvent('exter-moneywash:dataPostClient')
            Wait(5000)
            TriggerEvent('exter-moneywash:createObject', cacheData)
            break
        end 
    end
end)



RegisterNetEvent('exter-moneywash:createObject')
AddEventHandler('exter-moneywash:createObject', function(cacheData)
    
    for _, v1 in pairs(cacheData) do
        if CoreName == "es_extended" then
            if playerData.identifier == v1.identifier then
                for _, v2 in pairs(v1.props) do
                    if v2.itemType == "desk" then 
                        zvalue = v2.position.z-0.45
                    else
                        zvalue = v2.position.z
                    end

                    obj = CreateObject(tonumber(v2.hash), v2.position.x, v2.position.y, zvalue, true, true, true)
                    SetEntityAsMissionEntity(obj, true, true)
                    SetEntityHeading(obj, v2.heading)
                    FreezeEntityPosition(obj, true)
                    SetModelAsNoLongerNeeded(model)
                    table.insert(allObject, obj)
                end
            end
        else
            if tonumber(playerData.citizenid) == tonumber(v1.identifier) then
                for _, v2 in pairs(v1.props) do
                    
                    if v2.itemType == "desk" then 
                        zvalue = v2.position.z-0.45
                    else
                        zvalue = v2.position.z
                    end
                    obj = CreateObject(tonumber(v2.hash), v2.position.x, v2.position.y, zvalue, true, true, true)
                    SetEntityAsMissionEntity(obj, true, true)
                    SetEntityHeading(obj, v2.heading)
                    FreezeEntityPosition(obj, true)
                    SetModelAsNoLongerNeeded(model)
                    table.insert(allObject, obj)
                end
            end
        end
    end
end)


RegisterNetEvent('exter-moneywash:deleteProp')
AddEventHandler('exter-moneywash:deleteProp',function()
    DeleteEntity(currentObject)
    DeleteObject(currentObject)
    for k, v in pairs(allObject) do
        DeleteEntity(v)
        DeleteObject(v)
    end
    allObject = {}
    currentObject = nil
end)

function GetClosestProp(coords)
    local pump = nil
    local pumpCoords
    for i = 1, #Config.Props, 1 do
        local currentPumpModel = Config.Props[i]
        pump = GetClosestObjectOfType(coords.x, coords.y, coords.z, 3.0, currentPumpModel, true, true, true)
        pumpCoords = GetEntityCoords(pump)
        if pump ~= 0 then break end
    end
    return pumpCoords, pump
end



function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    SetTextScale(0.32, 0.32)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
    local factor = (string.len(text)) / 500
    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 68)
end


function loadAnimDict(dict)  
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Citizen.Wait(500)
    end
end 



local deskInteractions = {}

Citizen.CreateThread(function()
    while true do 
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        for k, v in pairs(cacheData) do
            for x, y in pairs(v.props) do
                if y.itemType == "desk" then 
                    local id = 'launder_' .. v.id

                    if not deskInteractions[id] then
                        exports.interact:AddInteraction({
                            coords = vector3(y.position.x, y.position.y, y.position.z),
                            distance = 2.0,
                            interactDst = 1.6,
                            id = id,
                            name = "Money Launder",
                            options = {
                                {
                                    label = Config.HackText or "Hack Machine",
                                    action = function(entity, coords, args)
                                        TriggerEvent("exter-moneywash:openMenu", v.id)
                                    end
                                },
                                {
                                    label = Config.BuildText or "Open Desk",
                                    action = function(entity, coords, args)
                                        TriggerEvent("exter-moneywash:openDesk", v.id)
                                    end
                                },
                                {
                                    label = Config.GeneralDataText or "View Data",
                                    action = function(entity, coords, args)
                                        TriggerEvent("exter-moneywash:openData", v.id)
                                    end
                                },
                            }
                        })

                        deskInteractions[id] = true
                    end
                end
            end
        end

        Wait(5000) -- cek setiap 5 detik saja, tidak perlu setiap frame
    end 
end)


RegisterNetEvent('exter-moneywash:openMiner')
AddEventHandler('exter-moneywash:openMiner',function(id)
    openMiner(id)
end)

RegisterNetEvent('exter-moneywash:openMenu')
AddEventHandler('exter-moneywash:openMenu', function(id)
    openMenu(id)
end)

RegisterNetEvent('exter-moneywash:openDesk')
AddEventHandler('exter-moneywash:openDesk', function(id)
    openBuildPage(id)
end)

RegisterNetEvent('exter-moneywash:openData')
AddEventHandler('exter-moneywash:openData', function(id)
    openGeneralData(id)
end)

RegisterNetEvent('exter-moneywash:deleteLastProp')
AddEventHandler('exter-moneywash:deleteLastProp', function()
    DeleteEntity(currentObject)
    DeleteObject(currentObject)
    currentObject = nil
end)




AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end
    for k, v in pairs(allObject) do
        DeleteEntity(v)
        DeleteObject(v)
        end
        DeleteEntity(currentObject)
        DeleteObject(currentObject)
        currentObject = nil
        allObject = {}
end)
