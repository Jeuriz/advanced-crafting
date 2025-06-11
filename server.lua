-- ================================
-- SISTEMA DE CRAFTING - CLIENTE (CORREGIDO)
-- Compatible con QBCore + tgiann inventory + ox_target
-- ================================

local QBCore = exports['qb-core']:GetCoreObject()
local isNuiOpen = false
local currentCraftingData = {}
local craftingBlips = {}
local craftingObjects = {}

-- ===== FUNCIONES DE UTILIDAD =====
local function debugPrint(message)
    if Config.Debug then
        print("[CRAFTING DEBUG] " .. message)
    end
end

local function playSound(soundConfig)
    if Config.UI.PlaySoundEffects and soundConfig then
        PlaySoundFrontend(-1, soundConfig.name, soundConfig.set, true)
    end
end

-- Función corregida para obtener inventario
local function getPlayerInventory()
    local inventory = {}
    
    if Config.Inventory == 'tgiann' then
        -- Usar la función correcta de tgiann-inventory
        local success, playerItems = pcall(function()
            return exports['tgiann-inventory']:getUserInventory()
        end)
        
        if success and playerItems then
            for _, item in pairs(playerItems) do
                local mappedName = Config.ItemMapping[item.name]
                if mappedName then
                    inventory[mappedName] = (inventory[mappedName] or 0) + item.count
                end
            end
        else
            -- Fallback: intentar con otra función
            local success2, items = pcall(function()
                return exports['tgiann-inventory']:getItems()
            end)
            
            if success2 and items then
                for _, item in pairs(items) do
                    local mappedName = Config.ItemMapping[item.name]
                    if mappedName then
                        inventory[mappedName] = (inventory[mappedName] or 0) + item.count
                    end
                end
            end
        end
    else
        -- Fallback para QBCore inventory estándar
        local PlayerData = QBCore.Functions.GetPlayerData()
        if PlayerData.items then
            for _, item in pairs(PlayerData.items) do
                if item and item.name and item.amount > 0 then
                    local mappedName = Config.ItemMapping[item.name]
                    if mappedName then
                        inventory[mappedName] = (inventory[mappedName] or 0) + item.amount
                    end
                end
            end
        end
    end
    
    debugPrint("Inventario obtenido: " .. json.encode(inventory))
    return inventory
end

-- Función corregida para verificar items
local function hasRequiredItems(requiredItems)
    for itemName, requiredAmount in pairs(requiredItems) do
        local hasAmount = 0
        
        if Config.Inventory == 'tgiann' then
            -- Usar la función correcta de tgiann-inventory
            local success, count = pcall(function()
                return exports['tgiann-inventory']:getItemCount(itemName)
            end)
            
            if success and count then
                hasAmount = count
            else
                -- Fallback: obtener del inventario completo
                local playerInventory = getPlayerInventory()
                local mappedName = Config.ItemMapping[itemName] or itemName
                hasAmount = playerInventory[mappedName] or 0
            end
        else
            local PlayerData = QBCore.Functions.GetPlayerData()
            if PlayerData.items then
                for _, item in pairs(PlayerData.items) do
                    if item and item.name == itemName then
                        hasAmount = hasAmount + item.amount
                    end
                end
            end
        end
        
        if hasAmount < requiredAmount then
            return false, itemName, hasAmount, requiredAmount
        end
    end
    return true
end

-- Función corregida para remover items
local function removeItems(items)
    for itemName, amount in pairs(items) do
        if Config.Inventory == 'tgiann' then
            local success = pcall(function()
                exports['tgiann-inventory']:removeItem(itemName, amount)
            end)
            
            if not success then
                debugPrint("Error removiendo item con tgiann: " .. itemName)
                -- Fallback a QBCore
                QBCore.Functions.TriggerCallback('crafting:removeItem', function() end, itemName, amount)
            end
        else
            QBCore.Functions.TriggerCallback('crafting:removeItem', function() end, itemName, amount)
        end
        debugPrint("Removido: " .. itemName .. " x" .. amount)
    end
end

-- Función corregida para añadir items
local function addItem(itemName, amount, metadata)
    if Config.Inventory == 'tgiann' then
        local success = pcall(function()
            exports['tgiann-inventory']:addItem(itemName, amount, metadata or {})
        end)
        
        if not success then
            debugPrint("Error añadiendo item con tgiann: " .. itemName)
            -- Fallback a QBCore
            QBCore.Functions.TriggerCallback('crafting:addItem', function() end, itemName, amount, metadata or {})
        end
    else
        QBCore.Functions.TriggerCallback('crafting:addItem', function() end, itemName, amount, metadata or {})
    end
    debugPrint("Añadido: " .. itemName .. " x" .. amount)
end

local function playAnimation(animDict, animName, duration, flag)
    if not animDict or not animName then return end
    
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Wait(1)
    end
    
    TaskPlayAnim(PlayerPedId(), animDict, animName, 8.0, -8.0, duration or -1, flag or 1, 0, false, false, false)
end

local function canPlayerUseStation(stationConfig, stationName)
    local PlayerData = QBCore.Functions.GetPlayerData()
    
    -- Verificar trabajo requerido
    if stationConfig.settings.requiredJob then
        local hasJob = false
        for _, job in pairs(stationConfig.settings.requiredJob) do
            if PlayerData.job.name == job then
                hasJob = true
                break
            end
        end
        if not hasJob then
            local jobList = table.concat(stationConfig.settings.requiredJob, ", ")
            QBCore.Functions.Notify(Config.Notifications.Messages.JobRequired:format(jobList), "error")
            return false
        end
    end
    
    -- Verificar gang requerido
    if stationConfig.settings.requiredGang and PlayerData.gang then
        local hasGang = false
        for _, gang in pairs(stationConfig.settings.requiredGang) do
            if PlayerData.gang.name == gang then
                hasGang = true
                break
            end
        end
        if not hasGang then
            local gangList = table.concat(stationConfig.settings.requiredGang, ", ")
            QBCore.Functions.Notify("Necesitas pertenecer a: " .. gangList, "error")
            return false
        end
    end
    
    -- Verificar item requerido
    if stationConfig.settings.requiredItem then
        local hasItem = false
        if Config.Inventory == 'tgiann' then
            local success, count = pcall(function()
                return exports['tgiann-inventory']:getItemCount(stationConfig.settings.requiredItem)
            end)
            hasItem = success and count and count > 0
        else
            for _, item in pairs(PlayerData.items) do
                if item and item.name == stationConfig.settings.requiredItem and item.amount > 0 then
                    hasItem = true
                    break
                end
            end
        end
        
        if not hasItem then
            QBCore.Functions.Notify(Config.Notifications.Messages.ItemRequired:format(stationConfig.settings.requiredItem), "error")
            return false
        end
    end
    
    return true
end

local function createStationBlip(coords, stationConfig)
    if not Config.Crafting.ShowBlips or not stationConfig.settings.showBlip then return end
    
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, stationConfig.settings.blipSprite or Config.Crafting.BlipSprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, Config.Crafting.BlipScale)
    SetBlipColour(blip, stationConfig.settings.blipColor or Config.Crafting.BlipColor)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(stationConfig.label)
    EndTextCommandSetBlipName(blip)
    
    return blip
end

local function createCraftingStations()
    debugPrint("Creando estaciones de crafting...")
    
    for stationName, stationConfig in pairs(Config.Stations) do
        for i, location in pairs(stationConfig.locations) do
            local coords = location.coords
            
            -- Crear blip
            local blip = createStationBlip(coords, stationConfig)
            if blip then
                table.insert(craftingBlips, blip)
            end
            
            -- Crear objeto si está configurado
            if stationConfig.settings.model then
                RequestModel(stationConfig.settings.model)
                while not HasModelLoaded(stationConfig.settings.model) do
                    Wait(1)
                end
                
                local obj = CreateObject(stationConfig.settings.model, coords.x, coords.y, coords.z, false, false, false)
                SetEntityHeading(obj, location.heading or 0.0)
                FreezeEntityPosition(obj, true)
                SetEntityInvincible(obj, true)
                
                table.insert(craftingObjects, obj)
            end
            
            -- Crear zona de ox_target con verificación
            local targetId = "crafting_" .. stationName .. "_" .. i
            
            -- Verificar que ox_target esté disponible
            if GetResourceState('ox_target') == 'started' then
                exports.ox_target:addSphereZone({
                    coords = coords,
                    radius = location.radius or 2.0,
                    debug = Config.Debug,
                    options = {
                        {
                            name = targetId,
                            icon = stationConfig.icon,
                            label = "Usar " .. stationConfig.label,
                            onSelect = function()
                                if canPlayerUseStation(stationConfig, stationName) then
                                    TriggerEvent('crafting:openStation', {station = stationName})
                                end
                            end,
                            canInteract = function()
                                return not isNuiOpen and not currentCraftingData.recipe
                            end,
                            distance = Config.Crafting.MaxCraftingDistance
                        }
                    }
                })
            else
                debugPrint("ox_target no está disponible, usando drawtext alternativo")
                -- Aquí podrías implementar un sistema de drawtext alternativo
            end
            
            debugPrint("Estación creada: " .. stationName .. " en " .. tostring(coords))
        end
    end
end

local function cleanupStations()
    -- Limpiar blips
    for _, blip in pairs(craftingBlips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    craftingBlips = {}
    
    -- Limpiar objetos
    for _, obj in pairs(craftingObjects) do
        if DoesEntityExist(obj) then
            DeleteEntity(obj)
        end
    end
    craftingObjects = {}
    
    -- Limpiar zonas de ox_target
    if GetResourceState('ox_target') == 'started' then
        for stationName, stationConfig in pairs(Config.Stations) do
            for i, _ in pairs(stationConfig.locations) do
                local targetId = "crafting_" .. stationName .. "_" .. i
                pcall(function()
                    exports.ox_target:removeZone(targetId)
                end)
            end
        end
    end
end

-- ===== FUNCIONES DE CRAFTING =====
function startCrafting(recipeId)
    if currentCraftingData.recipe or isNuiOpen then return end
    
    debugPrint("Iniciando crafting: " .. recipeId)
    
    local stationRecipes = Config.Recipes[currentCraftingData.station]
    if not stationRecipes then
        debugPrint("Error: No se encontraron recetas para la estación")
        return
    end
    
    local recipe = nil
    for _, r in pairs(stationRecipes) do
        if r.id == recipeId then
            recipe = r
            break
        end
    end
    
    if not recipe then
        debugPrint("Error: Receta no encontrada")
        return
    end
    
    -- Verificar items
    local hasItems, missingItem, hasAmount, requiredAmount = hasRequiredItems(recipe.requiredItems)
    if not hasItems then
        SendNUIMessage({
            action = "craftingError",
            message = Config.Notifications.Messages.NotEnoughItems:format(missingItem, hasAmount, requiredAmount)
        })
        return
    end
    
    -- Verificar límites diarios y nivel
    QBCore.Functions.TriggerCallback('crafting:canCraftRecipe', function(canCraft, reason)
        if not canCraft then
            SendNUIMessage({
                action = "craftingError",
                message = reason
            })
            return
        end
        
        -- Consumir items
        removeItems(recipe.requiredItems)
        
        -- Guardar datos del crafting actual
        currentCraftingData.recipe = recipe
        currentCraftingData.startTime = GetGameTimer()
        
        -- Calcular tiempo ajustado por bonificaciones
        QBCore.Functions.TriggerCallback('crafting:getCraftingTime', function(adjustedTime)
            currentCraftingData.adjustedTime = adjustedTime
            
            -- Iniciar animación
            local stationConfig = Config.Stations[currentCraftingData.station]
            if stationConfig and stationConfig.settings.animation then
                local anim = stationConfig.settings.animation
                playAnimation(anim.dict, anim.anim, adjustedTime, anim.flag)
            end
            
            -- Reproducir sonido
            playSound(Config.Sounds.CraftingStart)
            
            -- Enviar al NUI para iniciar progreso
            SendNUIMessage({
                action = "startCraftingProcess",
                recipe = {
                    id = recipe.id,
                    name = recipe.name,
                    time = adjustedTime
                }
            })
            
            -- Notificar inicio
            QBCore.Functions.Notify(Config.Notifications.Messages.CraftingStarted:format(recipe.name), "primary")
            
            -- Iniciar timer para completar
            SetTimeout(adjustedTime, function()
                completeCrafting()
            end)
            
        end, recipe.settings.craftTime)
        
    end, recipeId, currentCraftingData.station)
end

function completeCrafting()
    if not currentCraftingData.recipe then return end
    
    local recipe = currentCraftingData.recipe
    debugPrint("Completando crafting: " .. recipe.id)
    
    -- Verificar si el jugador sigue cerca de la estación
    local playerCoords = GetEntityCoords(PlayerPedId())
    local nearStation = false
    
    for _, location in pairs(Config.Stations[currentCraftingData.station].locations) do
        local distance = #(playerCoords - location.coords)
        if distance <= Config.Crafting.MaxCraftingDistance then
            nearStation = true
            break
        end
    end
    
    if not nearStation then
        QBCore.Functions.Notify(Config.Notifications.Messages.TooFarAway, "error")
        cancelCrafting()
        return
    end
    
    -- Verificar éxito del crafting
    local success = math.random() <= (recipe.settings.successRate or 1.0)
    
    if success then
        -- Añadir item resultante
        addItem(recipe.result.item, recipe.result.quantity, recipe.result.metadata)
        
        -- Verificar bonificaciones del servidor
        QBCore.Functions.TriggerCallback('crafting:processCraftingComplete', function(bonuses)
            if bonuses.extraItem then
                addItem(recipe.result.item, 1, recipe.result.metadata)
                QBCore.Functions.Notify(Config.Notifications.Messages.BonusItem, "success")
            end
            
            if bonuses.improvedQuality then
                QBCore.Functions.Notify(Config.Notifications.Messages.ImprovedQuality, "success")
            end
            
            if bonuses.levelUp then
                QBCore.Functions.Notify(Config.Notifications.Messages.LevelUp:format(bonuses.newLevel), "success")
                playSound(Config.Sounds.LevelUp)
            end
            
            if bonuses.experienceGained > 0 then
                QBCore.Functions.Notify(Config.Notifications.Messages.ExperienceGained:format(bonuses.experienceGained), "primary")
            end
        end, recipe.id, currentCraftingData.station)
        
        -- Notificar éxito
        QBCore.Functions.Notify(Config.Notifications.Messages.CraftingComplete:format(recipe.name), "success")
        playSound(Config.Sounds.CraftingComplete)
        
    else
        -- Crafting falló
        QBCore.Functions.Notify(Config.Notifications.Messages.CraftingFailed, "error")
        playSound(Config.Sounds.CraftingFailed)
        
        -- Posibilidad de devolver algunos items
        if not recipe.settings.loseItemsOnFail then
            for itemName, amount in pairs(recipe.requiredItems) do
                local returnAmount = math.ceil(amount * 0.5) -- Devolver 50%
                if returnAmount > 0 then
                    addItem(itemName, returnAmount)
                end
            end
        end
    end
    
    -- Limpiar datos
    currentCraftingData = {station = currentCraftingData.station}
    
    -- Parar animación
    ClearPedTasks(PlayerPedId())
    
    -- Actualizar inventario en UI
    if isNuiOpen then
        SendNUIMessage({
            action = "updateInventory",
            inventory = getPlayerInventory()
        })
    end
end

function cancelCrafting()
    if not currentCraftingData.recipe then return end
    
    debugPrint("Crafting cancelado")
    
    -- Devolver items
    for itemName, amount in pairs(currentCraftingData.recipe.requiredItems) do
        addItem(itemName, amount)
    end
    
    -- Limpiar datos
    currentCraftingData = {station = currentCraftingData.station}
    
    -- Parar animación
    ClearPedTasks(PlayerPedId())
    
    -- Notificar
    QBCore.Functions.Notify(Config.Notifications.Messages.CraftingCancelled, "primary")
    
    if isNuiOpen then
        SendNUIMessage({
            action = "updateInventory",
            inventory = getPlayerInventory()
        })
    end
end

-- ===== FUNCIONES DE UI =====
function openCrafting(data)
    if isNuiOpen then return end
    
    local stationName = data.station
    debugPrint("Abriendo estación: " .. stationName)
    
    if not Config.Stations[stationName] then
        debugPrint("Error: Estación no encontrada")
        return
    end
    
    currentCraftingData.station = stationName
    isNuiOpen = true
    SetNuiFocus(true, true)
    
    -- Enviar datos al NUI
    SendNUIMessage({
        action = "openCrafting",
        station = stationName,
        inventory = getPlayerInventory(),
        config = {
            ui = Config.UI,
            sounds = Config.Sounds
        }
    })
    
    playSound(Config.Sounds.UIClick)
end

function closeCrafting()
    if not isNuiOpen then return end
    
    debugPrint("Cerrando UI de crafting")
    
    isNuiOpen = false
    SetNuiFocus(false, false)
    
    -- Si está crafteando, cancelar
    if currentCraftingData.recipe then
        cancelCrafting()
    end
    
    currentCraftingData = {}
    
    playSound(Config.Sounds.UIClick)
end

-- ===== EVENTOS =====
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Wait(2000) -- Esperar a que todo cargue
    createCraftingStations()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    if isNuiOpen then
        closeCrafting()
    end
    cleanupStations()
end)

RegisterNetEvent('crafting:openStation', function(data)
    openCrafting(data)
end)

RegisterNetEvent('crafting:updateInventory', function()
    if isNuiOpen then
        SendNUIMessage({
            action = "updateInventory",
            inventory = getPlayerInventory()
        })
    end
end)

RegisterNetEvent('crafting:forceClose', function()
    if isNuiOpen then
        closeCrafting()
    end
end)

-- ===== CALLBACKS NUI =====
RegisterNUICallback('startCrafting', function(data, cb)
    startCrafting(data.recipe)
    cb('ok')
end)

RegisterNUICallback('cancelCrafting', function(data, cb)
    cancelCrafting()
    cb('ok')
end)

RegisterNUICallback('closeCrafting', function(data, cb)
    closeCrafting()
    cb('ok')
end)

RegisterNUICallback('playSound', function(data, cb)
    if data.sound and Config.Sounds[data.sound] then
        playSound(Config.Sounds[data.sound])
    end
    cb('ok')
end)

-- ===== THREADS DE MONITOREO =====
CreateThread(function()
    while true do
        Wait(1000)
        
        if currentCraftingData.recipe then
            local playerPed = PlayerPedId()
            
            -- Verificar si el jugador se movió demasiado
            if not Config.Crafting.AllowCraftingWhileMoving then
                local velocity = GetEntityVelocity(playerPed)
                local speed = math.sqrt(velocity.x^2 + velocity.y^2 + velocity.z^2)
                
                if speed > 1.0 then -- Si se está moviendo rápido
                    cancelCrafting()
                    QBCore.Functions.Notify("Crafting cancelado por movimiento", "error")
                end
            end
            
            -- Verificar si recibió daño
            if Config.Crafting.CancelOnDamage and HasEntityBeenDamagedByAnyPed(playerPed) then
                cancelCrafting()
                QBCore.Functions.Notify("Crafting cancelado por daño recibido", "error")
            end
            
            -- Verificar si entró a un vehículo
            if Config.Crafting.CancelOnVehicle and IsPedInAnyVehicle(playerPed, false) then
                cancelCrafting()
                QBCore.Functions.Notify("Crafting cancelado al entrar al vehículo", "error")
            end
        end
    end
end)

-- ===== COMANDOS DE PRUEBA =====
if Config.Debug then
    RegisterCommand('testcrafting', function(source, args)
        local stationName = args[1] or 'cocina'
        TriggerEvent('crafting:openStation', { station = stationName })
    end, false)
    
    RegisterCommand('givecraftitems', function()
        local items = {
            'water_dirty', 'meat_raw', 'vegetables', 'herbs', 
            'charcoal', 'metalscrap', 'water_filter'
        }
        
        for _, item in pairs(items) do
            addItem(item, 10)
        end
        
        QBCore.Functions.Notify("Items de crafting añadidos", "success")
    end, false)
    
    RegisterCommand('clearcrafting', function()
        if currentCraftingData.recipe then
            cancelCrafting()
        end
        if isNuiOpen then
            closeCrafting()
        end
        QBCore.Functions.Notify("Crafting limpiado", "success")
    end, false)
end

-- ===== CLEANUP =====
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if isNuiOpen then
            SetNuiFocus(false, false)
        end
        
        if currentCraftingData.recipe then
            ClearPedTasks(PlayerPedId())
        end
        
        cleanupStations()
    end
end)

-- ===== INICIALIZACIÓN =====
CreateThread(function()
    -- Esperar a que QBCore esté cargado
    while not QBCore do
        Wait(100)
    end
    
    -- Esperar a que el jugador spawned
    while not QBCore.Functions.GetPlayerData().citizenid do
        Wait(100)
    end
    
    -- Verificar que ox_target esté disponible antes de crear estaciones
    if GetResourceState('ox_target') == 'started' then
        createCraftingStations()
        debugPrint("Sistema de crafting inicializado con ox_target")
    else
        debugPrint("ox_target no disponible, esperando...")
        -- Intentar cada 5 segundos hasta que ox_target esté disponible
        CreateThread(function()
            while GetResourceState('ox_target') ~= 'started' do
                Wait(5000)
            end
            createCraftingStations()
            debugPrint("Sistema de crafting inicializado con ox_target (retrasado)")
        end)
    end
end)

-- ===== EXPORTS =====
exports('IsNUIOpen', function()
    return isNuiOpen
end)

exports('IsCrafting', function()
    return currentCraftingData.recipe ~= nil
end)

exports('GetCurrentStation', function()
    return currentCraftingData.station
end)

exports('OpenCraftingStation', function(stationName)
    TriggerEvent('crafting:openStation', {station = stationName})
end)

exports('CloseCrafting', function()
    if isNuiOpen then
        closeCrafting()
    end
end)
