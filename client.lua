-- ================================
-- SISTEMA DE CRAFTING - CLIENTE (UI MINIMALISTA)
-- Compatible con QBCore + tgiann-inventory + ox_target
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

-- Función para obtener inventario con tgiann-inventory
local function getPlayerInventory()
    local inventory = {}
    
    local PlayerData = QBCore.Functions.GetPlayerData()
    if PlayerData.items then
        for _, item in pairs(PlayerData.items) do
            if item and item.name and item.amount > 0 then
                local mappedName = Config.ItemMapping[item.name] or item.name
                inventory[mappedName] = (inventory[mappedName] or 0) + item.amount
            end
        end
    end
    
    debugPrint("Inventario obtenido: " .. json.encode(inventory))
    return inventory
end

-- Función para verificar items requeridos
local function hasRequiredItems(requiredItems, quantity)
    quantity = quantity or 1
    
    for itemName, requiredAmount in pairs(requiredItems) do
        local hasAmount = 0
        
        local PlayerData = QBCore.Functions.GetPlayerData()
        if PlayerData.items then
            for _, item in pairs(PlayerData.items) do
                if item and item.name == itemName and item.amount > 0 then
                    hasAmount = hasAmount + item.amount
                end
            end
        end
        
        if hasAmount < (requiredAmount * quantity) then
            return false, itemName, hasAmount, requiredAmount * quantity
        end
    end
    return true
end

-- Función para crear blips de estaciones
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

-- Función para convertir recetas del config al formato UI
local function convertRecipesToUIFormat()
    local uiRecipes = {}
    
    for stationName, recipes in pairs(Config.Recipes) do
        uiRecipes[stationName] = {}
        
        for _, recipe in pairs(recipes) do
            table.insert(uiRecipes[stationName], {
                id = recipe.id,
                name = recipe.name,
                description = recipe.description,
                result = recipe.result,
                ingredients = recipe.requiredItems,
                time = recipe.settings.craftTime,
                difficulty = recipe.settings.difficulty,
                effects = recipe.settings.effects or {}
            })
        end
    end
    
    return uiRecipes
end

-- Función para convertir estaciones del config al formato UI
local function convertStationsToUIFormat()
    local uiStations = {}
    
    for stationName, stationConfig in pairs(Config.Stations) do
        uiStations[stationName] = {
            name = stationConfig.label,
            icon = stationConfig.icon,
            color = stationConfig.color,
            description = stationConfig.description
        }
    end
    
    return uiStations
end

-- Función para verificar permisos de estación
local function canPlayerUseStation(stationConfig, stationName)
    local PlayerData = QBCore.Functions.GetPlayerData()
    
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
    
    if stationConfig.settings.requiredItem then
        local hasItem = false
        for _, item in pairs(PlayerData.items) do
            if item and item.name == stationConfig.settings.requiredItem and item.amount > 0 then
                hasItem = true
                break
            end
        end
        
        if not hasItem then
            QBCore.Functions.Notify(Config.Notifications.Messages.ItemRequired:format(stationConfig.settings.requiredItem), "error")
            return false
        end
    end
    
    return true
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
            
            -- Crear zona de ox_target
            local targetId = "crafting_" .. stationName .. "_" .. i
            
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
                debugPrint("ox_target no está disponible")
            end
            
            debugPrint("Estación creada: " .. stationName .. " en " .. tostring(coords))
        end
    end
end

local function cleanupStations()
    for _, blip in pairs(craftingBlips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    craftingBlips = {}
    
    for _, obj in pairs(craftingObjects) do
        if DoesEntityExist(obj) then
            DeleteEntity(obj)
        end
    end
    craftingObjects = {}
    
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
function startCrafting(data)
    if currentCraftingData.recipe then return end
    
    local recipeId = data.recipe
    local quantity = data.quantity or 1
    
    debugPrint("Iniciando crafting: " .. recipeId .. " x" .. quantity)
    
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
    
    -- Verificar items en el cliente
    local hasItems, missingItem, hasAmount, requiredAmount = hasRequiredItems(recipe.requiredItems, quantity)
    if not hasItems then
        SendNUIMessage({
            action = "craftingError",
            message = Config.Notifications.Messages.NotEnoughItems:format(missingItem, hasAmount, requiredAmount)
        })
        return
    end
    
    -- Enviar al servidor para procesar
    TriggerServerEvent('crafting:server:startCrafting', {
        station = currentCraftingData.station,
        recipeId = recipeId,
        recipe = recipe,
        quantity = quantity
    })
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
    
    TriggerServerEvent('crafting:server:completeCrafting')
end

function cancelCrafting()
    if not currentCraftingData.recipe then return end
    
    debugPrint("Crafting cancelado")
    
    TriggerServerEvent('crafting:server:cancelCrafting')
    
    currentCraftingData = {station = currentCraftingData.station}
    
    ClearPedTasks(PlayerPedId())
    
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
    
    -- Enviar todos los datos del config al NUI
    SendNUIMessage({
        action = "openCrafting",
        activeStation = stationName,
        inventory = getPlayerInventory(),
        stations = convertStationsToUIFormat(),
        recipes = convertRecipesToUIFormat(),
        itemNames = Config.ItemNames,
        itemRarity = Config.ItemRarity,
        config = {
            imagePath = Config.UI.ImagePath,
            imageFormat = Config.UI.ImageFormat,
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
    
    if currentCraftingData.recipe then
        cancelCrafting()
    end
    
    currentCraftingData = {}
    playSound(Config.Sounds.UIClick)
end

-- ===== FUNCIONES PARA AGREGAR/QUITAR ITEMS =====
function addItemToPlayer(itemName, quantity)
    SendNUIMessage({
        action = "addItem",
        item = itemName,
        quantity = quantity
    })
end

function removeItemFromPlayer(itemName, quantity)
    SendNUIMessage({
        action = "removeItem",
        item = itemName,
        quantity = quantity
    })
end

-- ===== EVENTOS =====
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Wait(2000)
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

RegisterNetEvent('crafting:client:updateInventory', function()
    if isNuiOpen then
        SendNUIMessage({
            action = "updateInventory",
            inventory = getPlayerInventory()
        })
    end
end)

RegisterNetEvent('crafting:client:startCraftingProcess', function(recipe)
    currentCraftingData.recipe = recipe
    currentCraftingData.startTime = GetGameTimer()
    
    -- Iniciar animación si está configurada
    local stationConfig = Config.Stations[currentCraftingData.station]
    if stationConfig and stationConfig.settings.animation then
        local anim = stationConfig.settings.animation
        RequestAnimDict(anim.dict)
        while not HasAnimDictLoaded(anim.dict) do
            Wait(1)
        end
        TaskPlayAnim(PlayerPedId(), anim.dict, anim.anim, 8.0, -8.0, recipe.settings.craftTime, anim.flag, 0, false, false, false)
    end
    
    playSound(Config.Sounds.CraftingStart)
    
    SendNUIMessage({
        action = "startCraftingProcess",
        recipe = {
            id = recipe.id,
            name = recipe.name,
            time = recipe.settings.craftTime
        }
    })
    
    QBCore.Functions.Notify(Config.Notifications.Messages.CraftingStarted:format(recipe.name), "primary")
    
    -- Timer automático para completar
    SetTimeout(recipe.settings.craftTime, function()
        completeCrafting()
    end)
end)

RegisterNetEvent('crafting:client:craftingSuccess', function(message)
    currentCraftingData = {station = currentCraftingData.station}
    
    ClearPedTasks(PlayerPedId())
    
    QBCore.Functions.Notify(message, "success")
    playSound(Config.Sounds.CraftingComplete)
    
    if isNuiOpen then
        SendNUIMessage({
            action = "updateInventory",
            inventory = getPlayerInventory()
        })
    end
end)

RegisterNetEvent('crafting:client:craftingError', function(message)
    currentCraftingData = {station = currentCraftingData.station}
    
    ClearPedTasks(PlayerPedId())
    
    QBCore.Functions.Notify(message, "error")
    playSound(Config.Sounds.CraftingFailed)
    
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

-- Eventos para añadir/quitar items
RegisterNetEvent('crafting:client:addItem', function(itemName, quantity)
    addItemToPlayer(itemName, quantity)
end)

RegisterNetEvent('crafting:client:removeItem', function(itemName, quantity)
    removeItemFromPlayer(itemName, quantity)
end)

-- ===== CALLBACKS NUI =====
RegisterNUICallback('startCrafting', function(data, cb)
    startCrafting(data)
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

RegisterNUICallback('completeCrafting', function(data, cb)
    -- Procesar completado de crafting con cantidad
    TriggerServerEvent('crafting:server:processCraftingComplete', data.recipe, data.station, data.quantity or 1)
    cb('ok')
end)

-- ===== THREADS DE MONITOREO =====
CreateThread(function()
    while true do
        Wait(1000)
        
        if currentCraftingData.recipe then
            local playerPed = PlayerPedId()
            
            if not Config.Crafting.AllowCraftingWhileMoving then
                local velocity = GetEntityVelocity(playerPed)
                local speed = math.sqrt(velocity.x^2 + velocity.y^2 + velocity.z^2)
                
                if speed > 1.0 then
                    cancelCrafting()
                    QBCore.Functions.Notify("Crafting cancelado por movimiento", "error")
                end
            end
            
            if Config.Crafting.CancelOnDamage and HasEntityBeenDamagedByAnyPed(playerPed) then
                cancelCrafting()
                QBCore.Functions.Notify("Crafting cancelado por daño recibido", "error")
            end
            
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
        TriggerServerEvent('crafting:server:giveTestItems')
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
    while not QBCore do
        Wait(100)
    end
    
    while not QBCore.Functions.GetPlayerData().citizenid do
        Wait(100)
    end
    
    if GetResourceState('ox_target') == 'started' then
        createCraftingStations()
        debugPrint("Sistema de crafting inicializado con ox_target")
    else
        debugPrint("ox_target no disponible, esperando...")
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

exports('AddItem', function(itemName, quantity)
    addItemToPlayer(itemName, quantity)
end)

exports('RemoveItem', function(itemName, quantity)
    removeItemFromPlayer(itemName, quantity)
end)
