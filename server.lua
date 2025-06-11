-- ================================
-- SISTEMA DE CRAFTING - SERVIDOR
-- Compatible con QBCore + tgiann inventory + ox_target
-- ================================

local QBCore = exports['qb-core']:GetCoreObject()

-- ===== VARIABLES GLOBALES =====
local playerCraftingData = {} -- Datos de crafting por jugador
local lastCraftingTime = {}   -- Último tiempo de crafting por jugador
local dailyCraftingCount = {} -- Contador diario de crafting

-- ===== FUNCIONES DE UTILIDAD =====
local function debugPrint(message)
    if Config.Debug then
        print("[CRAFTING SERVER DEBUG] " .. message)
    end
end

local function getCurrentDay()
    return os.date("%Y-%m-%d")
end

local function initializePlayerData(citizenid)
    if not playerCraftingData[citizenid] then
        playerCraftingData[citizenid] = {
            level = 1,
            experience = 0,
            totalCrafted = 0,
            skillBonuses = {
                speed = 0,      -- Reducción de tiempo de crafting
                efficiency = 0, -- Chance de obtener items extra
                quality = 0     -- Chance de obtener versiones mejoradas
            }
        }
    end
    
    local currentDay = getCurrentDay()
    if not dailyCraftingCount[citizenid] then
        dailyCraftingCount[citizenid] = {}
    end
    if not dailyCraftingCount[citizenid][currentDay] then
        dailyCraftingCount[citizenid][currentDay] = {}
    end
end

local function loadPlayerCraftingData(citizenid)
    local result = MySQL.Sync.fetchAll('SELECT * FROM player_crafting_data WHERE citizenid = ?', {citizenid})
    
    if result and result[1] then
        local data = json.decode(result[1].data)
        playerCraftingData[citizenid] = data
        debugPrint("Datos de crafting cargados para: " .. citizenid)
    else
        initializePlayerData(citizenid)
        savePlayerCraftingData(citizenid)
        debugPrint("Nuevos datos de crafting creados para: " .. citizenid)
    end
end

local function savePlayerCraftingData(citizenid)
    if not playerCraftingData[citizenid] then return end
    
    MySQL.Async.execute('INSERT INTO player_crafting_data (citizenid, data) VALUES (?, ?) ON DUPLICATE KEY UPDATE data = ?', {
        citizenid,
        json.encode(playerCraftingData[citizenid]),
        json.encode(playerCraftingData[citizenid])
    })
    
    debugPrint("Datos de crafting guardados para: " .. citizenid)
end

local function calculateLevel(experience)
    return math.floor(experience / Config.Experience.ExperiencePerLevel) + 1
end

local function addExperience(citizenid, amount)
    if not Config.Experience.Enabled then return 0, false end
    
    initializePlayerData(citizenid)
    
    local oldLevel = playerCraftingData[citizenid].level
    playerCraftingData[citizenid].experience = playerCraftingData[citizenid].experience + amount
    playerCraftingData[citizenid].level = calculateLevel(playerCraftingData[citizenid].experience)
    
    local leveledUp = playerCraftingData[citizenid].level > oldLevel
    
    -- Verificar si subió de nivel
    if leveledUp then
        -- Actualizar bonificaciones
        updateSkillBonuses(citizenid)
        
        -- Log de level up
        logCraftingActivity(citizenid, "level_up", {
            oldLevel = oldLevel,
            newLevel = playerCraftingData[citizenid].level,
            experience = playerCraftingData[citizenid].experience
        })
    end
    
    savePlayerCraftingData(citizenid)
    return amount, leveledUp, playerCraftingData[citizenid].level
end

local function updateSkillBonuses(citizenid)
    local level = playerCraftingData[citizenid].level
    
    -- Calcular bonificaciones basadas en el nivel
    playerCraftingData[citizenid].skillBonuses = {
        speed = math.min(level * Config.Experience.Bonuses.SpeedPerLevel, Config.Experience.Bonuses.MaxSpeedBonus),
        efficiency = math.min(level * Config.Experience.Bonuses.EfficiencyPerLevel, Config.Experience.Bonuses.MaxEfficiencyBonus),
        quality = math.min(level * Config.Experience.Bonuses.QualityPerLevel, Config.Experience.Bonuses.MaxQualityBonus)
    }
end

local function canCraftToday(citizenid, recipeId)
    if not Config.Limits.EnableDailyLimits or not Config.Limits.DailyLimits[recipeId] then return true end
    
    local currentDay = getCurrentDay()
    if not dailyCraftingCount[citizenid] then
        dailyCraftingCount[citizenid] = {}
    end
    if not dailyCraftingCount[citizenid][currentDay] then
        dailyCraftingCount[citizenid][currentDay] = {}
    end
    
    local currentCount = dailyCraftingCount[citizenid][currentDay][recipeId] or 0
    local maxCount = Config.Limits.DailyLimits[recipeId]
    
    return currentCount < maxCount
end

local function incrementDailyCraftingCount(citizenid, recipeId)
    local currentDay = getCurrentDay()
    if not dailyCraftingCount[citizenid][currentDay][recipeId] then
        dailyCraftingCount[citizenid][currentDay][recipeId] = 0
    end
    dailyCraftingCount[citizenid][currentDay][recipeId] = dailyCraftingCount[citizenid][currentDay][recipeId] + 1
end

local function logCraftingActivity(citizenid, action, data)
    if not Config.Logging.Enabled then return end
    
    local logData = {
        citizenid = citizenid,
        action = action,
        data = data,
        timestamp = os.time()
    }
    
    -- Guardar en base de datos
    if Config.Logging.LogToDatabase then
        MySQL.Async.execute('INSERT INTO crafting_logs (citizenid, action, data, timestamp) VALUES (?, ?, ?, ?)', {
            citizenid,
            action,
            json.encode(data),
            os.time()
        })
    end
    
    -- Enviar a Discord webhook si está configurado
    if Config.Logging.LogToDiscord and Config.Logging.DiscordWebhook and Config.Logging.DiscordWebhook ~= "" then
        local Player = QBCore.Functions.GetPlayerByCitizenId(citizenid)
        local playerName = Player and Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname or "Desconocido"
        
        local embed = {
            {
                color = 3447003,
                title = "🔨 Actividad de Crafting",
                fields = {
                    {
                        name = "Jugador",
                        value = playerName .. " (" .. citizenid .. ")",
                        inline = true
                    },
                    {
                        name = "Acción",
                        value = action,
                        inline = true
                    },
                    {
                        name = "Datos",
                        value = "```json\n" .. json.encode(data, {indent = true}) .. "\n```",
                        inline = false
                    }
                },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }
        }
        
        PerformHttpRequest(Config.Logging.DiscordWebhook, function(err, text, headers) end, 'POST', json.encode({
            username = "Crafting System",
            embeds = embed
        }), { ['Content-Type'] = 'application/json' })
    end
    
    debugPrint("Actividad registrada: " .. action .. " para " .. citizenid)
end

-- ===== CALLBACKS =====
QBCore.Functions.CreateCallback('crafting:getPlayerLevel', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then 
        cb(1)
        return 
    end
    
    initializePlayerData(Player.PlayerData.citizenid)
    cb(playerCraftingData[Player.PlayerData.citizenid].level)
end)

QBCore.Functions.CreateCallback('crafting:canCraftRecipe', function(source, cb, recipeId, stationName)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then 
        cb(false, "Jugador no encontrado")
        return 
    end
    
    local citizenid = Player.PlayerData.citizenid
    initializePlayerData(citizenid)
    
    -- Verificar cooldown
    if lastCraftingTime[citizenid] and (GetGameTimer() - lastCraftingTime[citizenid]) < Config.Crafting.CraftingCooldown then
        cb(false, "Espera un momento antes de craftear nuevamente")
        return
    end
    
    -- Buscar la receta
    local recipe = nil
    if Config.Recipes[stationName] then
        for _, r in pairs(Config.Recipes[stationName]) do
            if r.id == recipeId then
                recipe = r
                break
            end
        end
    end
    
    if not recipe then
        cb(false, "Receta no encontrada")
        return
    end
    
    -- Verificar límites diarios
    if not canCraftToday(citizenid, recipeId) then
        local limit = Config.Limits.DailyLimits[recipeId]
        cb(false, Config.Notifications.Messages.DailyLimitReached:format(limit))
        return
    end
    
    -- Verificar nivel requerido
    if Config.Limits.LevelRequirements[recipeId] then
        local requiredLevel = Config.Limits.LevelRequirements[recipeId]
        if playerCraftingData[citizenid].level < requiredLevel then
            cb(false, Config.Notifications.Messages.LevelRequired:format(requiredLevel))
            return
        end
    end
    
    -- Actualizar contadores
    lastCraftingTime[citizenid] = GetGameTimer()
    incrementDailyCraftingCount(citizenid, recipeId)
    
    cb(true, "OK")
end)

QBCore.Functions.CreateCallback('crafting:getCraftingTime', function(source, cb, baseCraftTime)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then 
        cb(baseCraftTime)
        return 
    end
    
    initializePlayerData(Player.PlayerData.citizenid)
    
    -- Aplicar bonificaciones de velocidad
    local speedBonus = playerCraftingData[Player.PlayerData.citizenid].skillBonuses.speed
    local adjustedTime = math.floor(baseCraftTime * (1 - speedBonus))
    
    cb(adjustedTime)
end)

QBCore.Functions.CreateCallback('crafting:processCraftingComplete', function(source, cb, recipeId, stationName)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then 
        cb({})
        return 
    end
    
    local citizenid = Player.PlayerData.citizenid
    initializePlayerData(citizenid)
    
    -- Buscar la receta
    local recipe = nil
    if Config.Recipes[stationName] then
        for _, r in pairs(Config.Recipes[stationName]) do
            if r.id == recipeId then
                recipe = r
                break
            end
        end
    end
    
    if not recipe then
        cb({})
        return
    end
    
    -- Incrementar contador total
    playerCraftingData[citizenid].totalCrafted = playerCraftingData[citizenid].totalCrafted + 1
    
    -- Añadir experiencia
    local expGained, leveledUp, newLevel = addExperience(citizenid, recipe.settings.experience or 0)
    
    -- Verificar bonificación de eficiencia (item extra)
    local efficiencyBonus = playerCraftingData[citizenid].skillBonuses.efficiency
    local bonusItem = math.random() < efficiencyBonus
    
    -- Verificar bonificación de calidad (versión mejorada)
    local qualityBonus = playerCraftingData[citizenid].skillBonuses.quality
    local improvedQuality = math.random() < qualityBonus
    
    -- Registrar actividad
    logCraftingActivity(citizenid, "crafting_completed", {
        recipe = recipeId,
        station = stationName,
        bonusItem = bonusItem,
        improvedQuality = improvedQuality,
        experienceGained = expGained,
        leveledUp = leveledUp,
        newLevel = newLevel,
        totalCrafted = playerCraftingData[citizenid].totalCrafted
    })
    
    savePlayerCraftingData(citizenid)
    
    cb({
        extraItem = bonusItem,
        improvedQuality = improvedQuality,
        experienceGained = expGained,
        levelUp = leveledUp,
        newLevel = newLevel
    })
end)

-- Para inventarios que no sean tgiann
QBCore.Functions.CreateCallback('crafting:removeItem', function(source, cb, itemName, amount)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        Player.Functions.RemoveItem(itemName, amount)
    end
    cb(true)
end)

QBCore.Functions.CreateCallback('crafting:addItem', function(source, cb, itemName, amount, metadata)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        Player.Functions.AddItem(itemName, amount, false, metadata)
    end
    cb(true)
end)

-- ===== EVENTOS =====
RegisterNetEvent('QBCore:Server:PlayerLoaded', function(Player)
    local citizenid = Player.PlayerData.citizenid
    loadPlayerCraftingData(citizenid)
end)

RegisterNetEvent('QBCore:Server:OnPlayerUnload', function(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        savePlayerCraftingData(Player.PlayerData.citizenid)
    end
end)

RegisterNetEvent('crafting:addExperience', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    addExperience(Player.PlayerData.citizenid, amount)
    
    TriggerClientEvent('QBCore:Notify', src, 
        'Has ganado ' .. amount .. ' puntos de experiencia en crafting', 'primary')
end)

RegisterNetEvent('crafting:validateCrafting', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local citizenid = Player.PlayerData.citizenid
    
    -- Verificar cooldown
    if lastCraftingTime[citizenid] and (GetGameTimer() - lastCraftingTime[citizenid]) < Config.CraftingCooldown then
        TriggerClientEvent('QBCore:Notify', src, 'Espera un momento antes de craftear nuevamente', 'error')
        return
    end
    
    -- Verificar límites diarios
    if not canCraftToday(citizenid, data.recipeId) then
        local limit = Config.DailyCraftingLimits[data.recipeId]
        TriggerClientEvent('QBCore:Notify', src, 
            'Has alcanzado el límite diario de ' .. limit .. ' para este item', 'error')
        return
    end
    
    -- Aplicar bonificaciones de velocidad
    initializePlayerData(citizenid)
    local speedBonus = playerCraftingData[citizenid].skillBonuses.speed
    local adjustedTime = math.floor(data.craftTime * (1 - speedBonus))
    
    -- Registrar actividad
    logCraftingActivity(citizenid, "crafting_started", {
        recipe = data.recipeId,
        station = data.station,
        originalTime = data.craftTime,
        adjustedTime = adjustedTime,
        speedBonus = speedBonus
    })
    
    -- Actualizar contadores
    lastCraftingTime[citizenid] = GetGameTimer()
    incrementDailyCraftingCount(citizenid, data.recipeId)
    
    -- Confirmar al cliente
    TriggerClientEvent('crafting:craftingValidated', src, {
        adjustedTime = adjustedTime,
        speedBonus = speedBonus
    })
end)

RegisterNetEvent('crafting:completeCrafting', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local citizenid = Player.PlayerData.citizenid
    initializePlayerData(citizenid)
    
    -- Incrementar contador total
    playerCraftingData[citizenid].totalCrafted = playerCraftingData[citizenid].totalCrafted + 1
    
    -- Verificar bonificación de eficiencia (item extra)
    local efficiencyBonus = playerCraftingData[citizenid].skillBonuses.efficiency
    local bonusItem = math.random() < efficiencyBonus
    
    -- Verificar bonificación de calidad (versión mejorada)
    local qualityBonus = playerCraftingData[citizenid].skillBonuses.quality
    local improvedQuality = math.random() < qualityBonus
    
    -- Registrar actividad
    logCraftingActivity(citizenid, "crafting_completed", {
        recipe = data.recipeId,
        station = data.station,
        bonusItem = bonusItem,
        improvedQuality = improvedQuality,
        totalCrafted = playerCraftingData[citizenid].totalCrafted
    })
    
    -- Notificar bonificaciones al cliente
    if bonusItem then
        TriggerClientEvent('QBCore:Notify', src, 
            '¡Has obtenido un item extra gracias a tu habilidad!', 'success')
    end
    
    if improvedQuality then
        TriggerClientEvent('QBCore:Notify', src, 
            '¡Has creado una versión mejorada del item!', 'success')
    end
    
    savePlayerCraftingData(citizenid)
end)

-- ===== COMANDOS DE ADMINISTRACIÓN =====
QBCore.Commands.Add('craftingstats', 'Ver estadísticas de crafting de un jugador', {
    {name = 'id', help = 'ID del jugador'}
}, true, function(source, args)
    local targetId = tonumber(args[1])
    local TargetPlayer = QBCore.Functions.GetPlayer(targetId)
    
    if not TargetPlayer then
        TriggerClientEvent('QBCore:Notify', source, 'Jugador no encontrado', 'error')
        return
    end
    
    local citizenid = TargetPlayer.PlayerData.citizenid
    initializePlayerData(citizenid)
    
    local data = playerCraftingData[citizenid]
    local message = string.format([[
Estadísticas de Crafting para %s:
- Nivel: %d
- Experiencia: %d
- Total Crafteado: %d
- Bonificaciones:
  * Velocidad: %.1f%%
  * Eficiencia: %.1f%%
  * Calidad: %.1f%%
]], 
        TargetPlayer.PlayerData.charinfo.firstname .. " " .. TargetPlayer.PlayerData.charinfo.lastname,
        data.level,
        data.experience,
        data.totalCrafted,
        data.skillBonuses.speed * 100,
        data.skillBonuses.efficiency * 100,
        data.skillBonuses.quality * 100
    )
    
    TriggerClientEvent('chat:addMessage', source, {
        color = {0, 255, 0},
        multiline = true,
        args = {"[CRAFTING STATS]", message}
    })
end, 'admin')

QBCore.Commands.Add('setcraftinglevel', 'Establecer nivel de crafting', {
    {name = 'id', help = 'ID del jugador'},
    {name = 'level', help = 'Nivel a establecer'}
}, true, function(source, args)
    local targetId = tonumber(args[1])
    local level = tonumber(args[2])
    
    if not level or level < 1 or level > Config.MaxLevel then
        TriggerClientEvent('QBCore:Notify', source, 'Nivel inválido (1-' .. Config.MaxLevel .. ')', 'error')
        return
    end
    
    local TargetPlayer = QBCore.Functions.GetPlayer(targetId)
    if not TargetPlayer then
        TriggerClientEvent('QBCore:Notify', source, 'Jugador no encontrado', 'error')
        return
    end
    
    local citizenid = TargetPlayer.PlayerData.citizenid
    initializePlayerData(citizenid)
    
    playerCraftingData[citizenid].level = level
    playerCraftingData[citizenid].experience = (level - 1) * Config.ExperiencePerLevel
    updateSkillBonuses(citizenid)
    savePlayerCraftingData(citizenid)
    
    TriggerClientEvent('QBCore:Notify', source, 
        'Nivel de crafting de ' .. TargetPlayer.PlayerData.charinfo.firstname .. ' establecido a ' .. level, 'success')
    TriggerClientEvent('QBCore:Notify', TargetPlayer.PlayerData.source, 
        'Tu nivel de crafting ha sido establecido a ' .. level, 'primary')
    
    logCraftingActivity(citizenid, "admin_level_set", {
        admin = QBCore.Functions.GetPlayer(source).PlayerData.citizenid,
        newLevel = level
    })
end, 'admin')

-- ===== INICIALIZACIÓN =====
CreateThread(function()
    -- Crear tablas de base de datos si no existen
    MySQL.ready(function()
        MySQL.Sync.execute([[
            CREATE TABLE IF NOT EXISTS `player_crafting_data` (
                `citizenid` varchar(50) NOT NULL,
                `data` longtext NOT NULL,
                PRIMARY KEY (`citizenid`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ]])
        
        MySQL.Sync.execute([[
            CREATE TABLE IF NOT EXISTS `crafting_logs` (
                `id` int(11) NOT NULL AUTO_INCREMENT,
                `citizenid` varchar(50) NOT NULL,
                `action` varchar(100) NOT NULL,
                `data` longtext NOT NULL,
                `timestamp` int(11) NOT NULL,
                PRIMARY KEY (`id`),
                KEY `citizenid` (`citizenid`),
                KEY `timestamp` (`timestamp`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ]])
        
        debugPrint("Base de datos inicializada correctamente")
    end)
    
    -- Limpiar logs antiguos cada día
    if Config.EnableLogging then
        CreateThread(function()
            while true do
                Wait(86400000) -- 24 horas
                
                -- Eliminar logs más antiguos de 30 días
                MySQL.Async.execute('DELETE FROM crafting_logs WHERE timestamp < ?', {
                    os.time() - (30 * 24 * 60 * 60)
                })
                
                debugPrint("Logs antiguos limpiados")
            end
        end)
    end
end)

-- ===== EXPORTS =====
exports('GetPlayerCraftingLevel', function(citizenid)
    initializePlayerData(citizenid)
    return playerCraftingData[citizenid].level
end)

exports('GetPlayerCraftingData', function(citizenid)
    initializePlayerData(citizenid)
    return playerCraftingData[citizenid]
end)

exports('AddCraftingExperience', function(citizenid, amount)
    addExperience(citizenid, amount)
end)
