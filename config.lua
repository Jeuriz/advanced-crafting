-- ================================
-- CONFIGURACIÓN SISTEMA DE CRAFTING (CORREGIDO)
-- Compatible con QBCore + tgiann inventory + ox_target
-- ================================

Config = {}

-- ===== CONFIGURACIÓN GENERAL =====
Config.Debug = false                    -- Activar logs de debug
Config.Framework = 'qb-core'           -- Framework (qb-core)
Config.Inventory = 'tgiann'            -- Sistema de inventario (tgiann, qb-inventory)
Config.Target = 'ox_target'            -- Sistema de target (ox_target, qb-target)
Config.UseSound = true                 -- Activar sonidos de crafting
Config.SoundVolume = 0.3               -- Volumen de sonidos (0.0 - 1.0)

-- ===== CONFIGURACIÓN DE CRAFTING =====
Config.Crafting = {
    CraftingCooldown = 1000,           -- Cooldown entre craftings (ms)
    MaxCraftingDistance = 3.0,         -- Distancia máxima para craftear
    ShowBlips = true,                  -- Mostrar blips en el mapa
    BlipSprite = 478,                  -- Sprite del blip
    BlipColor = 46,                    -- Color del blip
    BlipScale = 0.8,                   -- Tamaño del blip
    RequireTools = false,              -- Requerir herramientas para ciertas recetas
    AllowCraftingWhileMoving = false,  -- Permitir craftear mientras se mueve
    CancelOnDamage = true,             -- Cancelar crafting si recibe daño
    CancelOnVehicle = true,            -- Cancelar si entra a un vehículo
}

-- ===== SISTEMA DE EXPERIENCIA =====
Config.Experience = {
    Enabled = true,                    -- Activar sistema de XP
    ExperiencePerLevel = 1000,         -- XP necesaria por nivel
    MaxLevel = 100,                    -- Nivel máximo
    ShowLevelUpNotification = true,    -- Mostrar notificación al subir nivel
    SaveDataInterval = 300000,         -- Guardar datos cada 5 minutos (ms)
    
    -- Bonificaciones por nivel
    Bonuses = {
        SpeedPerLevel = 0.02,          -- 2% más rápido por nivel (máx 50%)
        EfficiencyPerLevel = 0.01,     -- 1% chance item extra por nivel (máx 25%)
        QualityPerLevel = 0.005,       -- 0.5% chance calidad mejorada por nivel (máx 15%)
        MaxSpeedBonus = 0.5,           -- Máximo 50% de velocidad
        MaxEfficiencyBonus = 0.25,     -- Máximo 25% de eficiencia
        MaxQualityBonus = 0.15,        -- Máximo 15% de calidad
    }
}

-- ===== LÍMITES DE CRAFTING =====
Config.Limits = {
    EnableDailyLimits = true,          -- Activar límites diarios
    ResetTime = 6,                     -- Hora de reset (6 AM)
    
    -- Límites por item (por día)
    DailyLimits = {
        ['pocion_salud'] = 5,         -- 5 pociones de salud por día
        ['estimulante'] = 3,             -- 3 estimulantes por día
        ['filtro_mejorado'] = 2, -- 2 filtros avanzados por día
    },
    
    -- Límites por nivel
    LevelRequirements = {
        ['pocion_salud'] = 10,        -- Requiere nivel 10
        ['estimulante'] = 15,            -- Requiere nivel 15
        ['filtro_mejorado'] = 20, -- Requiere nivel 20
    }
}

-- ===== NOMBRES DE ITEMS PARA LA UI =====
Config.ItemNames = {
    -- Items base
    ['agua_sucia'] = 'Agua Contaminada',
    ['water_dirty'] = 'Agua Contaminada',
    ['carne_cruda'] = 'Carne Cruda',
    ['meat_raw'] = 'Carne Cruda',
    ['vegetales'] = 'Vegetales Frescos',
    ['vegetables'] = 'Vegetales Frescos',
    ['hierbas'] = 'Hierbas Medicinales',
    ['herbs'] = 'Hierbas Medicinales',
    ['carbon'] = 'Carbón Vegetal',
    ['charcoal'] = 'Carbón Vegetal',
    ['metal_chatarra'] = 'Chatarra Metálica',
    ['metalscrap'] = 'Chatarra Metálica',
    ['filtro_improvised'] = 'Filtro Improvisado',
    ['water_filter'] = 'Filtro Improvisado',
    ['thick_fabric'] = 'Tela Gruesa',
    ['solid_metal_piece'] = 'Pieza de Metal Sólido',
    
    -- Items crafteados
    ['carne_cocida'] = 'Carne Cocida',
    ['meat_cooked'] = 'Carne Cocida',
    ['agua_limpia'] = 'Agua Purificada',
    ['water_clean'] = 'Agua Purificada',
    ['agua_destilada'] = 'Agua Destilada',
    ['water_distilled'] = 'Agua Destilada',
    ['estofado'] = 'Estofado Nutritivo',
    ['stew'] = 'Estofado Nutritivo',
    ['sopa_hierbas'] = 'Sopa de Hierbas',
    ['herb_soup'] = 'Sopa de Hierbas',
    ['pocion_salud'] = 'Poción de Salud',
    ['health_potion'] = 'Poción de Salud',
    ['estimulante'] = 'Estimulante de Combate',
    ['stimulant'] = 'Estimulante de Combate',
    ['filtro_mejorado'] = 'Filtro Avanzado',
    ['water_filter_advanced'] = 'Filtro Avanzado',
    ['sealed_parts'] = 'Partes Selladas'
}

-- ===== RAREZA DE ITEMS PARA LA UI =====
Config.ItemRarity = {
    -- Items base - Common
    ['agua_sucia'] = 'common',
    ['water_dirty'] = 'common',
    ['carne_cruda'] = 'common',
    ['meat_raw'] = 'common',
    ['vegetales'] = 'common',
    ['vegetables'] = 'common',
    ['carbon'] = 'common',
    ['charcoal'] = 'common',
    ['thick_fabric'] = 'common',
    
    -- Items uncommon
    ['hierbas'] = 'uncommon',
    ['herbs'] = 'uncommon',
    ['metal_chatarra'] = 'uncommon',
    ['metalscrap'] = 'uncommon',
    ['filtro_improvised'] = 'uncommon',
    ['water_filter'] = 'uncommon',
    ['carne_cocida'] = 'uncommon',
    ['meat_cooked'] = 'uncommon',
    ['agua_limpia'] = 'uncommon',
    ['water_clean'] = 'uncommon',
    ['solid_metal_piece'] = 'uncommon',
    
    -- Items rare
    ['agua_destilada'] = 'rare',
    ['water_distilled'] = 'rare',
    ['estofado'] = 'rare',
    ['stew'] = 'rare',
    ['sopa_hierbas'] = 'rare',
    ['herb_soup'] = 'rare',
    ['estimulante'] = 'rare',
    ['stimulant'] = 'rare',
    ['sealed_parts'] = 'rare',
    
    -- Items epic
    ['pocion_salud'] = 'epic',
    ['health_potion'] = 'epic',
    ['filtro_mejorado'] = 'epic',
    ['water_filter_advanced'] = 'epic'
}

-- ===== CONFIGURACIÓN DE LOGS =====
Config.Logging = {
    Enabled = true,                    -- Activar logging
    LogToDatabase = true,              -- Guardar en base de datos
    LogToFile = false,                 -- Guardar en archivo
    LogToDiscord = false,              -- Enviar a Discord
    DiscordWebhook = "",               -- URL del webhook
    LogLevel = "INFO",                 -- Nivel de log (DEBUG, INFO, WARN, ERROR)
    RetentionDays = 30,                -- Días para mantener logs
    
    -- Eventos a loggear
    Events = {
        CraftingStarted = true,
        CraftingCompleted = true,
        CraftingCancelled = true,
        LevelUp = true,
        AdminCommands = true,
    }
}

-- ===== CONFIGURACIÓN DE UI =====
Config.UI = {
    EnableAnimations = true,           -- Activar animaciones
    AnimationSpeed = 0.3,              -- Velocidad de animaciones
    Theme = "dark",                    -- Tema (dark, light)
    ShowItemImages = true,             -- Mostrar imágenes de items
    ImagePath = "nui://inventory_images/images/", -- Ruta de imágenes
    ImageFormat = ".webp",             -- Formato de imágenes
    EnableTooltips = true,             -- Activar tooltips
    AutoCloseOnComplete = false,       -- Cerrar UI al completar crafting
    ShowProgressPercentage = true,     -- Mostrar porcentaje de progreso
    PlaySoundEffects = true,           -- Sonidos de UI
}

-- ===== ESTACIONES DE CRAFTING =====
Config.Stations = {
    ['cocina'] = {
        label = 'Cocina de Supervivencia',
        description = 'Prepara alimentos nutritivos y sabrosos',
        icon = 'fas fa-fire',
        color = 'linear-gradient(135deg, #f97316 0%, #dc2626 100%)',
        
        -- Ubicaciones
        locations = {
            {
                coords = vector3(1689.17, 4839.35, 44.91),
                heading = 0.0,
                radius = 2.0,
            }
        },
        
        -- Configuración
        settings = {
            model = `prop_bbq_5`,
            requiredItem = nil,
            requiredJob = nil,
            requiredGang = nil,
            minLevel = 1,
            showBlip = true,
            blipSprite = 479,
            blipColor = 1,
            
            -- Animación durante crafting
            animation = {
                dict = "amb@prop_human_bbq@male@idle_a",
                anim = "idle_b",
                flag = 1,
            },
            
            -- Efectos de partículas (opcional)
            particles = {
                dict = "core",
                name = "fire_wrecked_plane_cockpit",
                offset = vector3(0.0, 0.0, 0.5),
                scale = 1.0,
            }
        }
    },
}

-- ===== MAPEO DE ITEMS =====
Config.ItemMapping = {
    -- Items base del framework -> Items del sistema de crafting
    ['water_dirty'] = 'agua_sucia',
    ['meat_raw'] = 'carne_cruda',
    ['vegetables'] = 'vegetales',
    ['herbs'] = 'hierbas',
    ['charcoal'] = 'carbon',
    ['metalscrap'] = 'metal_chatarra',
    ['water_filter'] = 'filtro_improvised',
    
    -- Items crafteados
    ['meat_cooked'] = 'carne_cocida',
    ['water_clean'] = 'agua_limpia',
    ['water_distilled'] = 'agua_destilada',
    ['stew'] = 'estofado',
    ['herb_soup'] = 'sopa_hierbas',
    ['health_potion'] = 'pocion_salud',
    ['stimulant'] = 'estimulante',
    ['water_filter_advanced'] = 'filtro_mejorado'
}

-- ===== RECETAS DE CRAFTING =====
Config.Recipes = {
    ['cocina'] = {
        {
            id = 'carne_cocida',
            name = 'Carne Cocida',
            description = 'Carne bien cocinada que restaura energía',
            
            -- Requisitos
            requiredItems = {
                ['sealed_parts'] = 1,
                ['solid_metal_piece'] = 1
            },
            
            -- Resultado
            result = {
                item = 'rubber_strips',
                quantity = 1,
                metadata = {
                    quality = 'good',
                    expiry = 72 -- Horas antes de expirar
                }
            },
            
            -- Configuración
            settings = {
                craftTime = 10000,      -- 10 segundos
                experience = 10,
                difficulty = 1,
                consumeTools = false,
                
                -- Chance de items extra o fallo
                successRate = 0.95,     -- 95% de éxito
                extraItemChance = 0.1,  -- 10% chance de item extra
                loseItemsOnFail = true, -- Perder items si falla
                
                -- Efectos
                effects = {
                    '+50 Hambre',
                    '+10 Salud',
                    '+5 Energía'
                }
            }
        }
        
    
    }
}

-- ===== CONFIGURACIÓN DE NOTIFICACIONES =====
Config.Notifications = {
    Type = 'qb', -- qb, ox, custom
    Duration = 5000, -- Duración en ms
    
    -- Mensajes personalizables
    Messages = {
        -- Éxito
        CraftingComplete = 'Has creado %s exitosamente!',
        LevelUp = '¡Has subido al nivel %d de crafting!',
        ExperienceGained = 'Has ganado %d puntos de experiencia',
        BonusItem = '¡Has obtenido un item extra gracias a tu habilidad!',
        ImprovedQuality = '¡Has creado una versión mejorada del item!',
        
        -- Error
        NotEnoughItems = 'No tienes suficiente %s (%d/%d)',
        CraftingFailed = 'El crafting ha fallado. Has perdido algunos materiales.',
        DailyLimitReached = 'Has alcanzado el límite diario de %d para este item',
        LevelRequired = 'Necesitas nivel %d para crear este item',
        JobRequired = 'Necesitas el trabajo %s para usar esta estación',
        ItemRequired = 'Necesitas %s para usar esta estación',
        TooFarAway = 'Estás muy lejos de la estación de crafting',
        AlreadyCrafting = 'Ya estás crafteando algo',
        
        -- Info
        CraftingStarted = 'Comenzando a crear %s...',
        CraftingCancelled = 'Crafting cancelado',
        CraftingInProgress = 'Crafting en progreso... %d%% completado',
    }
}

-- ===== CONFIGURACIÓN DE SONIDOS =====
Config.Sounds = {
    CraftingStart = {
        name = 'TIMER_STOP',
        set = 'HUD_MINI_GAME_SOUNDSET'
    },
    CraftingComplete = {
        name = 'PICK_UP',
        set = 'HUD_FRONTEND_DEFAULT_SOUNDSET'
    },
    CraftingFailed = {
        name = 'LOOSE_MATCH',
        set = 'HUD_MINI_GAME_SOUNDSET'
    },
    LevelUp = {
        name = 'RANK_UP',
        set = 'HUD_AWARDS'
    },
    UIClick = {
        name = 'SELECT',
        set = 'HUD_FRONTEND_DEFAULT_SOUNDSET'
    },
    UIHover = {
        name = 'NAV_UP_DOWN',
        set = 'HUD_FRONTEND_DEFAULT_SOUNDSET'
    }
}
