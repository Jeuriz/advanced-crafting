-- ================================
-- SISTEMA DE CRAFTING - SERVIDOR
-- Compatible con QBCore + tgiann-inventory
-- ================================

local QBCore = exports['qb-core']:GetCoreObject()

-- ===== FUNCIONES DE UTILIDAD =====
local function debugPrint(message)
    if Config.Debug then
        print("[CRAFTING SERVER DEBUG] " .. message)
    end
end

local function getPlayer(source)
    return QBCore.Functions.GetPlayer(source)
end

-- Función para verificar items del servidor
local function hasRequiredItems(source, requiredItems, quantity)
    quantity = quantity or 1
    local Player = getPlayer(source)
    if not Player then return false end
    
    for itemName, requiredAmount in pairs(requiredItems) do
        local item = Player.Functions.GetItemByName(itemName)
        local hasAmount = item and item.amount or 0
        local totalRequired = requiredAmount * quantity
        
        if hasAmount < totalRequired then
            return false, itemName, hasAmount, totalRequired
        end
    end
    return true
end

-- Función para remover items
local function removeItems(source, items, quantity)
    quantity = quantity or 1
    local Player = getPlayer(source)
    if not Player then return false end
    
    for itemName, amount in pairs(items) do
        local totalAmount = amount * quantity
        local success = Player.Functions.RemoveItem(itemName, totalAmount)
        if not success then
            debugPrint("Error removiendo item: " .. itemName .. " x" .. totalAmount)
            return false
        end
        debugPrint("Removido del inventario: " .. itemName .. " x" .. totalAmount)
    end
    
    TriggerClientEvent('inventory:client:ItemBox', source, items, "remove")
    TriggerClientEvent('crafting:client:updateInventory', source)
    return true
end

-- Función para añadir items
local function addItem(source, itemName, amount)
    local Player = getPlayer(source)
    if not Player then return false end
    
    local success = Player.Functions.AddItem(itemName, amount)
    if success then
        debugPrint("Añadido al inventario: " .. itemName .. " x" .. amount)
        TriggerClientEvent('inventory:client:ItemBox', source, {[itemName] = amount}, "add")
        TriggerClientEvent('crafting:client:updateInventory', source)
        return true
    else
        debugPrint("Error añadiendo item: " .. itemName .. " x" .. amount)
        return false
    end
end

-- ===== EVENTOS DEL SERVIDOR =====

-- Evento para iniciar crafting
RegisterNetEvent('crafting:server:startCrafting', function(data)
    local src = source
    local Player = getPlayer(src)
    
    if not Player then return end
    
    local station = data.station
    local recipeId = data.recipeId
    local recipe = data.recipe
    local quantity = data.quantity or 1
    
    debugPrint("Procesando crafting en servidor: " .. recipeId .. " x" .. quantity)
    
    -- Verificaciones del servidor
    local hasItems, missingItem, hasAmount, requiredAmount = hasRequiredItems(src, recipe.requiredItems, quantity)
    if not hasItems then
        TriggerClientEvent('crafting:client:craftingError', src, 
            Config.Notifications.Messages.NotEnoughItems:format(missingItem, hasAmount, requiredAmount))
        return
    end
    
    -- Remover items
    if not removeItems(src, recipe.requiredItems, quantity) then
        TriggerClientEvent('crafting:client:craftingError', src, "Error al consumir materiales")
        return
    end
    
    -- Iniciar proceso de crafting en el cliente
    TriggerClientEvent('crafting:client:startCraftingProcess', src, recipe)
end)

-- Evento para completar crafting
RegisterNetEvent('crafting:server:completeCrafting', function()
    local src = source
    local Player = getPlayer(src)
    
    if not Player then return end
    
    -- Para simplificar, siempre tendrá éxito
    TriggerClientEvent('crafting:client:craftingSuccess', src, "Crafting completado exitosamente")
end)

-- Evento para procesar completado con datos específicos
RegisterNetEvent('crafting:server:processCraftingComplete', function(recipeId, station, quantity)
    local src = source
    local Player = getPlayer(src)
    
    if not Player then return end
    
    -- Buscar la receta
    local recipe = nil
    if Config.Recipes[station] then
        for _, r in pairs(Config.Recipes[station]) do
            if r.id == recipeId then
                recipe = r
                break
            end
        end
    end
    
    if not recipe then
        TriggerClientEvent('crafting:client:craftingError', src, "Receta no encontrada")
        return
    end
    
    quantity = quantity or 1
    
    -- Verificar éxito del crafting
    local success = math.random() <= (recipe.settings.successRate or 1.0)
    
    if success then
        -- Añadir item resultante
        local totalResult = recipe.result.quantity * quantity
        local addSuccess = addItem(src, recipe.result.item, totalResult)
        
        if addSuccess then
            TriggerClientEvent('crafting:client:craftingSuccess', src, 
                Config.Notifications.Messages.CraftingComplete:format(recipe.name))
        else
            TriggerClientEvent('crafting:client:craftingError', src, "Error al crear item")
        end
    else
        TriggerClientEvent('crafting:client:craftingError', src, Config.Notifications.Messages.CraftingFailed)
    end
end)

-- Evento para cancelar crafting
RegisterNetEvent('crafting:server:cancelCrafting', function()
    local src = source
    debugPrint("Crafting cancelado para jugador: " .. src)
end)

-- Evento para dar items de prueba (solo si debug está activado)
RegisterNetEvent('crafting:server:giveTestItems', function()
    if not Config.Debug then return end
    
    local src = source
    local testItems = {
        ['thick_fabric'] = 10,
        ['solid_metal_piece'] = 10,
        ['water_dirty'] = 10,
        ['meat_raw'] = 10,
        ['vegetables'] = 10,
        ['herbs'] = 10,
        ['charcoal'] = 10,
        ['metalscrap'] = 10,
        ['water_filter'] = 5
    }
    
    for item, amount in pairs(testItems) do
        addItem(src, item, amount)
    end
    
    TriggerClientEvent('QBCore:Notify', src, "Items de crafting añadidos", "success")
end)

-- ===== COMANDOS DE ADMIN =====
if Config.Debug then
    QBCore.Commands.Add('givecraftitems', 'Da items de crafting (Debug)', {}, false, function(source, args)
        TriggerEvent('crafting:server:giveTestItems', source)
    end, 'admin')
end

print("^2[CRAFTING SYSTEM]^7 Sistema de crafting cargado correctamente")
