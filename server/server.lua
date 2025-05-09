cacheData = {}
objId = {}
obj = nil
lastCreateId = 0

-- ⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛
--                                                        EVENT                                                        
-- ⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛

RegisterNetEvent('exter-moneywash:getData')
AddEventHandler('exter-moneywash:getData', function()
    MySQL.Async.fetchAll('SELECT * FROM exter_moneywash', {}, function(result)
        local temp = {}

        for k, v in pairs(result) do
            table.insert(temp, {
                id = v.id,
                identifier = v.identifier,
                props = v.props and json.decode(v.props) or {},
                miner = v.miner and json.decode(v.miner) or {},
                machine_data = v.machine_data and json.decode(v.machine_data) or {},
                canvas = v.canvas and json.decode(v.canvas) or {},
            })
        end

        cacheData = temp
    end)
end)


RegisterNetEvent('exter-moneywash:dataPostClient')
AddEventHandler('exter-moneywash:dataPostClient',function()
    TriggerClientEvent('exter-moneywash:setClient',source,cacheData)
end)

RegisterNetEvent('exter-moneywash:createUser')
AddEventHandler('exter-moneywash:createUser', function(xPlayer,identifier)
    if not cacheData then
        cacheData = {}
    end

    for _, v in ipairs(cacheData) do
        if v.identifier == identifier then
            return  
        end
    end

    machine = {
        money = 0,
        cooling = 350,  
        heating = 0,
        performance = 350,
        time = 0
    }

    MySQL.Async.execute('INSERT INTO exter_moneywash (`identifier`, `props` , `miner` , `canvas` , `machine_data` ) VALUES (@identifier,@props,@miner,@canvas,@machine_data)',
    {
        ['@identifier'] = identifier, 
        ['@props'] = json.encode({}), 
        ['@miner'] = json.encode({}), 
        ['@canvas'] = json.encode({}), 
        ['@machine_data'] = json.encode(machine)
    })

    Wait(2000)

    MySQL.Async.fetchAll('SELECT * FROM exter_moneywash WHERE identifier = @identifier', {['@identifier'] = identifier}, function(result)
        for k, v in pairs(result) do
            data = {
                id = v.id,
                identifier = v.identifier,
                props = v.props and json.decode(v.props) or {},
                miner = v.miner and json.decode(v.miner) or {},
                machine_data = v.machine_data and json.decode(v.machine_data) or {},
                canvas = v.canvas and json.decode(v.canvas) or {},
            }
            lastCreateId = v.id
            table.insert(cacheData, data)
        end
    end)

    TriggerClientEvent('exter-moneywash:setClient', -1, cacheData)
    
end)

RegisterNetEvent('exter-moneywash:createProp')
AddEventHandler('exter-moneywash:createProp',function(prop,id)
    local src = source
    local xPlayer = GetPlayer(src)
    local identifier = GetPlayerCid(src)
    local propData = {} 
    local flag = false

    --eğer hiç data yoksa data oluştur ve itemin bilgisayar olup olmadığını kontrol et
    if cacheData == nil or #cacheData < 1 then
        if prop.itemType ~= "desk" then
            Notify(src,Config.Notify["firstItemControl"]["text"],Config.Notify["firstItemControl"]["msgType"],Config.Notify["firstItemControl"]["length"])
            TriggerClientEvent('exter-moneywash:deleteLastProp',src)
            return
        end
            
            TriggerEvent('exter-moneywash:createUser', xPlayer,identifier)
    
            Wait(5000)

            local stashId = "launder_" .. lastCreateId
            RegisterStash(tostring(stashId), 1, 4000000) 


            table.insert(propData, prop)
            updateCacheDataForIdentifier(identifier, "props", propData)
            MySQL.Async.execute('UPDATE exter_moneywash SET `props` = @props WHERE identifier = @identifier', 
            {
                ['@props'] = json.encode(propData), 
                ['@identifier'] = identifier
            })
            TriggerClientEvent('exter-moneywash:setClient', -1, cacheData)
            return
    end


    for k,v in pairs(cacheData) do 
        if v.identifier == identifier then
            flag = true
            propData = type(v.props) == 'string' and json.decode(v.props) or v.props or {}
        end
    end

    --eğer data varsa identifieri kontrol et , aynı identity varsa ve miner gelirse ekle desk gelirse uyar ve ekleme
    --2.blok eğer data varsa fakat identifier eşleşmiyorsa yeni bir data oluştur ve ilk itemin desk olmasını kontrol et
    for k , v in pairs(cacheData) do 
        if flag then 
            if prop.itemType == "desk" then
                Notify(src,Config.Notify["alreadyPc"]["text"],Config.Notify["alreadyPc"]["msgType"],Config.Notify["alreadyPc"]["length"])
                TriggerClientEvent('exter-moneywash:deleteLastProp',src)
                return
            end

            for x , y in pairs(v.props) do
                if y.itemType == "desk" then
                    local coords1 = y.position
                    local coords2 = prop.position
                    local distance = CalculateDistance(coords1, coords2)
                    if distance < Config.MinerDistance then
                        Notify(src,Config.Notify["minerSuccess"]["text"],Config.Notify["minerSuccess"]["msgType"],Config.Notify["minerSuccess"]["length"])
                        table.insert(propData, prop)
                        updateCacheDataForIdentifier(identifier, "props", propData)
                        MySQL.Async.execute('UPDATE exter_moneywash SET `props` = @props WHERE identifier = @identifier', 
                        {
                            ['@props'] = json.encode(propData), 
                            ['@identifier'] = identifier
                        })
                        TriggerClientEvent('exter-moneywash:setClient', -1, cacheData)
                        return
                    else 
                        Notify(src,Config.Notify["minerControl"]["text"],Config.Notify["minerControl"]["msgType"],Config.Notify["minerControl"]["length"])
                        TriggerClientEvent('exter-moneywash:deleteLastProp',src)
                        return
                    end 
                end
            end
        else
                
            if prop.itemType ~= "desk" then
                Notify(src,Config.Notify["firstItemControl"]["text"],Config.Notify["firstItemControl"]["msgType"],Config.Notify["firstItemControl"]["length"])
                TriggerClientEvent('exter-moneywash:deleteLastProp',src)
                return
            end
        
            TriggerEvent('exter-moneywash:createUser', xPlayer,identifier)
    
            Wait(5000)
    
            table.insert(propData, prop)
            updateCacheDataForIdentifier(identifier, "props", propData)
            MySQL.Async.execute('UPDATE exter_moneywash SET `props` = @props WHERE identifier = @identifier', 
            {
                ['@props'] = json.encode(propData), 
                ['@identifier'] = identifier
            })
            TriggerClientEvent('exter-moneywash:setClient', -1, cacheData)
            return
        end
    end
end)

RegisterNetEvent('exter-money:addLastProp')
AddEventHandler('exter-money:addLastProp', function(item)
    local xPlayer =  GetPlayer(source)
    if item == nil then return end
    AddItem(source, item, 1, {})
end)

function NotifyClient(src, message, data)
    TriggerClientEvent(message, src, data)
end


AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then 
        return
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then 
        TriggerEvent('exter-moneywash:getData')
        return
    end
end)

function CalculateDistance(coords1, coords2)
    local x1, y1, z1 = coords1.x, coords1.y, coords1.z
    local x2, y2, z2 = coords2.x, coords2.y, coords2.z

    local dx = x1 - x2
    local dy = y1 - y2
    local dz = z1 - z2

    return math.sqrt(dx * dx + dy * dy + dz * dz)
end


function updateCacheData(id, property, value)
    for k, v in pairs(cacheData) do
        if v.id == id then
            v[property] = value
        end
    end
end

function updateCacheDataForIdentifier(identifier, property, value)
    for k, v in pairs(cacheData) do
        if v.identifier == identifier then
            v[property] = value
        end
    end
end



-- ⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛
--                                                        CALLBACK                                                    
-- ⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛


CreateCallback('exter-money:objUpdate', function(source, cb, obj,id)
    local src = source
    local xPlayer =  GetPlayer(src)
    local obj = obj
    for k, v in pairs(cacheData) do
        if v.id == id then
            v.props = type(v.props) == 'string' and json.decode(v.props) or v.props or {}
            
            for i, j in pairs(v.props) do
                if j.itemType == "miner" and tonumber(j.objId) == tonumber(obj.id) then
                    v.props[i].linked = true
                    updateCacheData(v.id, "props", v.props)
                    MySQL.Async.execute('UPDATE exter_moneywash SET `props` = @props WHERE id = @id', 
                    {
                        ['@props'] = json.encode(v.props), 
                        ['@id'] = id
                    })
                    
                    TriggerClientEvent('exter-money:setClient', -1, cacheData)
                    return cb(cacheData)
                end
            end
        end
    end

    cb(false)
end)


CreateCallback('exter-moneywash:setCanvas', function(source, cb, canvas, id)
    local src = source
    local xPlayer = GetPlayer(src)
    local canvasData = canvas
    
    for k, v in pairs(cacheData) do
        if v.id == id then
            v.canvas = type(v.canvas) == 'string' and json.decode(v.canvas) or v.canvas or {}
            
            local updated = false
            
            for i, existingCanvas in ipairs(v.canvas) do
                if existingCanvas.objId == canvasData.objId then
                    v.canvas[i] = canvasData
                    updated = true
                    break
                end
            end

            if not updated then
                table.insert(v.canvas, canvasData)
            end

            updateCacheData(v.id, "canvas", v.canvas)
            MySQL.Async.execute('UPDATE exter_moneywash SET `canvas` = @canvas WHERE id = @id', 
            {
                ['@canvas'] = json.encode(v.canvas), 
                ['@id'] = id
            })

            TriggerClientEvent('exter-moneywash:setClient', -1, cacheData)
            return cb(cacheData)
        end
    end

    cb(false)
end)

CreateCallback('exter-moneywash:getInventory', function(source,cb,searchItem)
    local xPlayer =  GetPlayer(source)
    local items = GetInventory(source)
    local itemArr = {}
    for k, v in pairs(items) do
        for x , y in pairs(searchItem) do 
        if v.name == y.itemName  then
                table.insert(itemArr, v)
            end 
        end
    end
    cb(itemArr)
end)


CreateCallback('exter-moneywash:propItemControl', function(source,cb,data)
    local xPlayer =  GetPlayer(source)
    local item = GetItem(source, data.itemName)
    if item ~= nil then 
        if ItemCountControl(source, data.itemName,1) then
            RemoveItem(source, data.itemName, 1, {})
            cb(true)
        else
            cb(false)
        end
    else
        cb(false)
    end

end)

CreateCallback('exter-moneywash:withdrawMoney', function(source,cb,data)
    local identifier =  GetPlayerCid(source)

    for k, v in pairs(cacheData) do
        if v.identifier == identifier  then
                machine = v.machine_data
                money = machine.money
                updateCacheData(v.id, "machine_data", {money = 0, cooling = machine.cooling, heating = machine.heating, performance = machine.performance, time = machine.time})
                TriggerClientEvent('exter-moneywash:setClient', -1, cacheData)
                AddMoney(source, 'cash', money , 'withdraw')
                cb(true)
        else
            cb(false)
        end
    end

end)

function calculateIncreaseValue(machineCount)
    return machineCount * 5
end

function coolingCalculation(machineCount, fanCount)
    local coolingValue
    if fanCount < machineCount then
        coolingValue = (fanCount - machineCount) * Config.MachineCoolingDown
    elseif fanCount == machineCount then
        coolingValue = 1
    else
        coolingValue = (fanCount - machineCount) * Config.MachineCoolingUp
    end
    return coolingValue
end

function heatingCalculation(machineCount, fanCount)
    local heatingValue
    if fanCount < machineCount then
        heatingValue = (machineCount - fanCount) * Config.MachineHeatingUp
    elseif fanCount == machineCount then
        heatingValue = -1
    else
        heatingValue = (fanCount - machineCount) * Config.MachineHeatingDown
    end
    return heatingValue
end

function moneyCalculation(machineCount,fanCount)
    local moneyValue
    if fanCount < machineCount then
        moneyValue = (fanCount - machineCount ) * machineCount
    elseif fanCount == machineCount then
        moneyValue = Config.MachineMoneyCount * machineCount
    else
        moneyValue = Config.MachineMoneyCount * machineCount
    end

    return moneyValue
end

function getFanLength(props)
    local fanCount = 0
    for _, prop in pairs(props) do
        if prop.itemType == "fan" then
            fanCount = fanCount + 1
        end
    end
    return fanCount
end

function getMachineLength(props)
    local machineCount = 0
    for _, prop in pairs(props) do
        if prop.itemType == "miner" then
            if prop.linked then
                machineCount = machineCount + 1
            end
        end
    end
    return machineCount
end

function calculateHourlyMoney(machineCount)
    local increaseValuePerCycle = calculateIncreaseValue(machineCount)
    local cyclesPerHour = 6 -- 10 minutes per cycle
    local hourlyMoney = increaseValuePerCycle * cyclesPerHour
    return hourlyMoney
end

function updateLaunderData(stashItems, itemKey, isOxInventory)
    local launderData = MySQL.Sync.fetchAll('SELECT * FROM exter_moneywash')

    for _, stash in pairs(stashItems) do
        local items = json.decode(isOxInventory and stash.data or stash.items)
        local itemsUpdated = false

            for _, item in pairs(items) do
                
                if not Config.UseMarkedBills then 
                    
                    if item.name == Config.BlackMoneyItem and item[itemKey] then
                        local newValue = item[itemKey] - tonumber(Config.BlackMoneyDecrease)
                        if newValue >= 0 then
                            item[itemKey] = newValue
                            itemsUpdated = true
                        end
                    end
                else
                    if item.name == Config.MarkedBillsItem and item[itemKey] then
                        local newValue = item['info']['worth']- tonumber(Config.BlackMoneyDecrease)
                        if newValue >= 0 then
                            item['info']['worth'] = newValue
                            itemsUpdated = true
                        end
                    end
                end
            end

        if itemsUpdated then
            local updatedItemsJson = json.encode(items)
            if isOxInventory then
                MySQL.Sync.execute('UPDATE ox_inventory SET data = @data WHERE name = @name', {
                    ['@data'] = updatedItemsJson,
                    ['@name'] = stash.name
                })
            else
                MySQL.Sync.execute('UPDATE stashitems SET items = @items WHERE stash = @stash', {
                    ['@items'] = updatedItemsJson,
                    ['@stash'] = stash.stash
                })
            end

            for _, launder in pairs(launderData) do
                local machine = json.decode(launder.machine_data)
                local machineProps = launder.props and json.decode(launder.props) or {}
                local machineCount = getMachineLength(machineProps)
                local fanCount = getFanLength(machineProps)

                if not machine or next(machine) == nil then
                    machine = {
                        money = 0,
                        cooling = 350,
                        heating = 0,
                        performance = 350,
                        time = 0
                    }
                else
                    local increaseValue = calculateIncreaseValue(machineCount)
                    local coolingValue = coolingCalculation(machineCount, fanCount)
                    local heatingValue = heatingCalculation(machineCount, fanCount)
                    local moneyValue = moneyCalculation(machineCount, fanCount)
                    local dailyMoney, hourlyMoney = calculateHourlyMoney(machineCount)

                    machine.money = (machine.money or 0) + moneyValue
                    machine.cooling = math.min(math.max((machine.cooling or 0) + coolingValue, 0), 350)
                    machine.heating = math.min(math.max((machine.heating or 0) + heatingValue, 0), 350)
                    machine.time = dailyMoney

                    if fanCount < machineCount then
                        machine.performance = math.max((machine.performance or 0) - increaseValue, 0)
                    else
                        machine.performance = math.min((machine.performance or 0) + increaseValue, 350)
                    end
                end

                local updatedMachineJson = json.encode(machine)
                MySQL.Sync.execute('UPDATE exter_moneywash SET machine_data = @machine_data WHERE id = @id', {
                    ['@machine_data'] = updatedMachineJson,
                    ['@id'] = launder.id
                })

                updateCacheData(launder.id, "machine_data", machine)
                TriggerClientEvent('exter-moneywash:setClient', -1, cacheData)
            end
        end
    end
end

Citizen.CreateThread(function()
    while true do
        Wait(Config.ControlTime) 
        local hasOx = GetResourceState('ox_inventory') == 'started'

        if hasOx then
            local stashItems = MySQL.Sync.fetchAll("SELECT * FROM ox_inventory WHERE name LIKE '%launder%'")
            updateLaunderData(stashItems, "count", true)
        else
            local stashItems = MySQL.Sync.fetchAll("SELECT * FROM stashitems WHERE stash LIKE '%launder%'")
            updateLaunderData(stashItems, "amount", false)
        end
    end
end)



-- ⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛
--                                                        THREAD                                                    
-- ⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛


