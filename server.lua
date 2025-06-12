-- ================================
-- SISTEMA DE CRAFTING - SERVIDOR
-- Compatible con QBCore + tgiann-inventory
-- ================================

local QBCore = exports['qb-core']:GetCoreObject()
local playerCraftingData = {}

-- ===== FUNCIONES DE UTILIDAD =====
local function debugPrint(message)
    if Config.Debug then
        print("[CRAFTING SERVER DEBUG] " .. message)
    end
end

local function getPlayer(source)
    return QBCore.Functions.GetPlayer(source)
end

-- Función para verificar items del servidor (compatible con tgiann-inventory)
local function hasRequiredItems(source, requiredItems)
    local Player = getPlayer(source)
    if not Player then return false end
    
    for itemName, requiredAmount in pairs(requiredItems) do
        local item = Player.Functions.GetItemByName(itemName)
        local hasAmount = item and item.amount or 0
        
        if hasAmount < requiredAmount then
            return false, itemName, hasAmount, requiredAmount
        end
    end
    return true
end

-- Función para remover items (compatible con tgiann-inventory)
local function removeItems(source, items)
    local Player = getPlayer(source)
    if not Player then return false end
    
    for itemName, amount in pairs(items) do
        local success = Player.Functions.RemoveItem(itemName, amount)
        if not success then
            debugPrint("Error removiendo item: " .. itemName .. " x" .. amount)
            return false
        end
        debugPrint("Removido del inventario: " .. itemName .. " x" .. amount)
    end
    
    -- Actualizar inventario del cliente
    TriggerClientEvent('inventory:client:ItemBox', source, items, "remove")
    return true
end

-- Función para añadir items (compatible con tgiann-inventory)
local function addItem(source, itemName, amount, metadata)
    local Player = getPlayer(source)
    if not Player then return false end
    
    local success = Player.Functions.AddItem(itemName, amount, false, metadata)
    if success then
        debugPrint("Añadido al inventario: " .. itemName .. " x" .. amount)
        TriggerClientEvent('inventory:client:ItemBox', source, {[itemName] = amount}, "add")
        return true
    else
        debugPrint("Error añadiendo item: " .. itemName .. " x" .. amount)
        return false
    end
end

-- Función para obtener/crear datos de experiencia del jugador
local function getPlayerCraftingData(source)
    local Player = getPlayer(source)
    if not Player then return nil end
    
    local citizenid = Player.PlayerData.citizenid
    
    if not playerCraftingData[citizenid] then
        playerCraftingData[citizenid] = {
            level = 1,
            experience = 0,
            dailyCrafts = {},
            lastReset = os.date("%Y-%m-%d")
        }
        
        -- Cargar datos de la base de datos si existe
        if Config.Experience.Enabled then
            MySQL.Async.fetchAll('SELECT * FROM crafting_data WHERE citizenid = ?', {citizenid}, function(result)
                if result[1] then
                    playerCraftingData[citizenid] = json.decode(result[1].data)
                end
            end)
        end
    end
    
    return playerCraftingData[citizenid]
end

-- Función para guardar datos de crafting
local function saveCraftingData(source)
    if not Config.Experience.Enabled then return end
    
    local Player = getPlayer(source)
    if not Player then return end
    
    local citizenid = Player.PlayerData.citizenid
    local data = playerCraftingData[citizenid]
    
    if data then
        MySQL.Async.execute('INSERT INTO crafting_data (citizenid, data) VALUES (?, ?) ON DUPLICATE KEY UPDATE data = VALUES(data)', {
            citizenid,
            json.encode(data)
        })
    end
end

-- Función para verificar límites diarios
local function checkDailyLimits(source, recipeId)
    if not Config.Limits.EnableDailyLimits then return true end
    
    local data = getPlayerCraftingData(source)
    if not data then return false end
    
    local today = os.date("%Y-%m-%d")
    
    -- Reset diario
    if data.lastReset ~= today then
        data.dailyCrafts = {}
        data.lastReset = today
    end
    
    local dailyLimit = Config.Limits.DailyLimits[recipeId]
    if dailyLimit then
        local currentCount = data.dailyCrafts[recipeId] or 0
        if currentCount >= dailyLimit then
            return false, Config.Notifications.Messages.DailyLimitReached:format(dailyLimit)
        end
    end
    
    return true
end

-- Función para verificar nivel requerido
local function checkLevelRequirement(source, recipeId)
    if not Config.Experience.Enabled then return true end
    
    local data = getPlayerCraftingData(source)
    if not data then return false end
    
    local requiredLevel = Config.Limits.LevelRequirements[recipeId]
    if requiredLevel and data.level < requiredLevel then
        return false, Config.Notifications.Messages.LevelRequired:format(requiredLevel)
    end
    
    return true
end

-- Función para calcular experiencia y nivel
local function addExperience(source, amount)
    if not Config.Experience.Enabled then return false end
    
    local data = getPlayerCraftingData(source)
    if not data then return false end
    
    data.experience = data.experience + amount
    local newLevel = math.floor(data.experience / Config.Experience.ExperiencePerLevel) + 1
    
    if newLevel > data.level and newLevel <= Config.Experience.MaxLevel then
        data.level = newLevel
        return true, newLevel -- Level up!
    end
    
    return false, data.level
end

-- ===== EVENTOS DEL SERVIDOR =====

-- Evento para remover items
RegisterNetEvent('crafting:server:removeItem', function(itemName, amount)
    local src = source
    local Player = getPlayer(src)
    
    if Player then
        Player.Functions.RemoveItem(itemName, amount)
        TriggerClientEvent('inventory:client:ItemBox', src, {[itemName] = amount}, "remove")
    end
end)

-- Evento para añadir items
RegisterNetEvent('crafting:server:addItem', function(itemName, amount, metadata)
    local src = source
    local Player = getPlayer(src)
    
    if Player then
        Player.Functions.AddItem(itemName, amount, false, metadata)
        TriggerClientEvent('inventory:client:ItemBox', src, {[itemName] = amount}, "add")
    end
end)

-- Evento para iniciar crafting
RegisterNetEvent('crafting:server:startCrafting', function(data)
    local src = source
    local Player = getPlayer(src)
    
    if not Player then return end
    
    local station = data.station
    local recipeId = data.recipeId
    local recipe = data.recipe
    
    debugPrint("Procesando crafting en servidor: " .. recipeId)
    
    -- Verificaciones del servidor
    local hasItems, missingItem, hasAmount, requiredAmount = hasRequiredItems(src, recipe.requiredItems)
    if not hasItems then
        TriggerClientEvent('crafting:client:craftingError', src, 
            Config.Notifications.Messages.NotEnoughItems:format(missingItem, hasAmount, requiredAmount))
        return
    end
    
    -- Verificar límites diarios
    local canCraft, reason = checkDailyLimits(src, recipeId)
    if not canCraft then
        TriggerClientEvent('crafting:client:craftingError', src, reason)
        return
    end
    
    -- Verificar nivel requerido
    local hasLevel, levelReason = checkLevelRequirement(src, recipeId)
    if not hasLevel then
        TriggerClientEvent('crafting:client:craftingError', src, levelReason)
        return
    end
    
    -- Remover items
    if not removeItems(src, recipe.requiredItems) then
        TriggerClientEvent('crafting:client:craftingError', src, "Error al consumir materiales")
        return
    end
    
    -- Actualizar contador diario
    if Config.Limits.EnableDailyLimits then
        local data = getPlayerCraftingData(src)
        if data then
            data.dailyCrafts[recipeId] = (data.dailyCrafts[recipeId] or 0) + 1
        end
    end
    
    -- Iniciar proceso de crafting en el cliente
    TriggerClientEvent('crafting:client:startCraftingProcess', src, recipe)
end)

-- Evento para completar crafting
RegisterNetEvent('crafting:server:completeCrafting', function()
    local src = source
    local Player = getPlayer(src)
    
    if not Player then return end
    
    -- Aquí normalmente tendrías los datos del crafting actual del jugador
    -- Por simplicidad, asumimos que el cliente envía la información necesaria
    -- En una implementación completa, almacenarías esta información en el servidor
    
    debugPrint("Crafting completado para jugador: " .. src)
end)

-- Evento para cancelar crafting
RegisterNetEvent('crafting:server:cancelCrafting', function()
    local src = source
    debugPrint("Crafting cancelado para jugador: " .. src)
    -- Aquí puedes devolver items si es necesario
end)

-- Evento para procesar completado de crafting con receta específica
RegisterNetEvent('crafting:server:processCraftingComplete', function(recipeId, station)
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
    
    -- Verificar éxito del crafting
    local success = math.random() <= (recipe.settings.successRate or 1.0)
    
    if success then
        -- Añadir item resultante
        local addSuccess = addItem(src, recipe.result.item, recipe.result.quantity, recipe.result.metadata)
        
        if addSuccess then
            -- Calcular bonificaciones
            local bonuses = {
                extraItem = false,
                improvedQuality = false,
                levelUp = false,
                newLevel = 0,
                experienceGained = 0
            }
            
            -- Añadir experiencia
            if Config.Experience.Enabled then
                bonuses.experienceGained = recipe.settings.experience or 0
                local leveledUp, newLevel = addExperience(src, bonuses.experienceGained)
                bonuses.levelUp = leveledUp
                bonuses.newLevel = newLevel
            end
            
            -- Verificar item extra por habilidad
            if recipe.settings.extraItemChance and math.random() <= recipe.settings.extraItemChance then
                bonuses.extraItem = true
                addItem(src, recipe.result.item, 1, recipe.result.metadata)
            end
            
            -- Guardar datos
            saveCraftingData(src)
            
            -- Notificar éxito al cliente
            TriggerClientEvent('crafting:client:craftingSuccess', src, 
                Config.Notifications.Messages.CraftingComplete:format(recipe.name))
            
            -- Enviar bonificaciones si las hay
            if bonuses.levelUp or bonuses.extraItem or bonuses.experienceGained > 0 then
                TriggerClientEvent('crafting:client:craftingBonuses', src, bonuses)
            end
            
        else
            TriggerClientEvent('crafting:client:craftingError', src, "Error al crear item")
        end
        
    else
        -- Crafting falló
        TriggerClientEvent('crafting:client:craftingError', src, Config.Notifications.Messages.CraftingFailed)
        
        -- Posibilidad de devolver algunos items
        if not recipe.settings.loseItemsOnFail then
            for itemName, amount in pairs(recipe.requiredItems) do
                local returnAmount = math.ceil(amount * 0.5) -- Devolver 50%
                if returnAmount > 0 then
                    addItem(src, itemName, returnAmount)
                end
            end
        end
    end
end)

-- Evento para dar items de prueba
RegisterNetEvent('crafting:server:giveTestItems', function()
    if not Config.Debug then return end
    
    local src = source
    local testItems = {
        'water_dirty', 'meat_raw', 'vegetables', 'herbs', 
        'charcoal', 'metalscrap', 'water_filter'
    }
    
    for _, item in pairs(testItems) do
        addItem(src, item, 10)
    end
    
    TriggerClientEvent('QBCore:Notify', src, "Items de crafting añadidos", "success")
end)

-- ===== CALLBACKS =====

-- Callback para verificar si se puede craftear una receta
QBCore.Functions.CreateCallback('crafting:canCraftRecipe', function(source, cb, recipeId, station)
    local canCraft, reason = checkDailyLimits(source, recipeId)
    if not canCraft then
        cb(false, reason)
        return
    end
    
    local hasLevel, levelReason = checkLevelRequirement(source, recipeId)
    if not hasLevel then
        cb(false, levelReason)
        return
    end
    
    cb(true)
end)

-- Callback para obtener tiempo de crafting ajustado
QBCore.Functions.CreateCallback('crafting:getCraftingTime', function(source, cb, baseTime)
    local adjustedTime = baseTime
    
    if Config.Experience.Enabled then
        local data = getPlayerCraftingData(source)
        if data then
            local speedBonus = math.min(data.level * Config.Experience.Bonuses.SpeedPerLevel, Config.Experience.Bonuses.MaxSpeedBonus)
            adjustedTime = math.ceil(baseTime * (1 - speedBonus))
        end
    end
    
    cb(adjustedTime)
end)

-- Callback para obtener nivel del jugador
QBCore.Functions.CreateCallback('crafting:getPlayerLevel', function(source, cb)
    local data = getPlayerCraftingData(source)
    cb(data and data.level or 1)
end)

-- ===== EVENTOS DE QBCore =====

RegisterNetEvent('QBCore:Server:PlayerLoaded', function(Player)
    getPlayerCraftingData(Player.PlayerData.source)
end)

RegisterNetEvent('QBCore:Server:OnPlayerUnload', function(source)
    saveCraftingData(source)
    
    local Player = getPlayer(source)
    if Player then
        local citizenid = Player.PlayerData.citizenid
        playerCraftingData[citizenid] = nil
    end
end)

-- ===== COMANDOS DE ADMIN =====

-- Comando para dar items de crafting
QBCore.Commands.Add('givecraftitems', 'Da items de crafting (Admin)', {{name = 'id', help = 'ID del jugador (opcional)'}}, false, function(source, args)
    local src = source
    local targetId = args[1] and tonumber(args[1]) or src
    
    local Player = getPlayer(targetId)
    if not Player then
        TriggerClientEvent('QBCore:Notify', src, "Jugador no encontrado", "error")
        return
    end
    
    local testItems = {
        ['water_dirty'] = 10,
        ['meat_raw'] = 10,
        ['vegetables'] = 10,
        ['herbs'] = 10,
        ['charcoal'] = 10,
        ['metalscrap'] = 10,
        ['water_filter'] = 5
    }
    
    for item, amount in pairs(testItems) do
        addItem(targetId, item, amount)
    end
    
    TriggerClientEvent('QBCore:Notify', src, "Items de crafting dados a " .. Player.PlayerData.name, "success")
    TriggerClientEvent('QBCore:Notify', targetId, "Has recibido items de crafting", "success")
end, 'admin')

-- Comando para resetear experiencia de crafting
QBCore.Commands.Add('resetcraftingxp', 'Resetea la experiencia de crafting de un jugador (Admin)', {{name = 'id', help = 'ID del jugador'}}, true, function(source, args)
    local src = source
    local targetId = tonumber(args[1])
    
    local Player = getPlayer(targetId)
    if not Player then
        TriggerClientEvent('QBCore:Notify', src, "Jugador no encontrado", "error")
        return
    end
    
    local citizenid = Player.PlayerData.citizenid
    playerCraftingData[citizenid] = {
        level = 1,
        experience = 0,
        dailyCrafts = {},
        lastReset = os.date("%Y-%m-%d")
    }
    
    saveCraftingData(targetId)
    TriggerClientEvent('QBCore:Notify', src, "Experiencia de crafting reseteada para " .. Player.PlayerData.name, "success")
    TriggerClientEvent('QBCore:Notify', targetId, "Tu experiencia de crafting ha sido reseteada", "primary")
end, 'admin')

-- ===== INICIALIZACIÓN =====

-- Crear tabla en la base de datos si no existe
CreateThread(function()
    if Config.Experience.Enabled then
        MySQL.Async.execute([[
            CREATE TABLE IF NOT EXISTS `crafting_data` (
                `citizenid` VARCHAR(50) NOT NULL,
                `data` LONGTEXT NOT NULL,
                PRIMARY KEY (`citizenid`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ]])
    end
end)

-- Thread para guardar datos periódicamente
if Config.Experience.Enabled then
    CreateThread(function()
        while true do
            Wait(Config.Experience.SaveDataInterval)
            
            for citizenid, data in pairs(playerCraftingData) do
                local players = QBCore.Functions.GetPlayers()
                for _, playerId in pairs(players) do
                    local Player = getPlayer(playerId)
                    if Player and Player.PlayerData.citizenid == citizenid then
                        saveCraftingData(playerId)
                        break
                    end
                end
            end
            
            debugPrint("Datos de crafting guardados periódicamente")
        end
    end)
end

-- ===== EXPORTS =====

exports('GetPlayerCraftingLevel', function(source)
    local data = getPlayerCraftingData(source)
    return data and data.level or 1
end)

exports('GetPlayerCraftingExperience', function(source)
    local data = getPlayerCraftingData(source)
    return data and data.experience or 0
end)

exports('AddCraftingExperience', function(source, amount)
    return addExperience(source, amount)
end)

print("^2[CRAFTING SYSTEM]^7 Sistema de crafting cargado correctamente")
