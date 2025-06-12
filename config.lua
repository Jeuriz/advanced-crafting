-- ================================
-- CONFIGURACIÓN SISTEMA DE CRAFTING MINIMALISTA
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
    EnableDailyLimits = false,          -- Activar límites diarios
    ResetTime = 6,                     -- Hora de reset (6 AM)
    
    -- Límites por item (por día)
    DailyLimits = {
        ['health_potion'] = 5,         -- 5 pociones de salud por día
        ['stimulant'] = 3,             -- 3 estimulantes por día
        ['water_filter_advanced'] = 2, -- 2 filtros avanzados por día
    },
    
    -- Límites por nivel
    LevelRequirements = {
        ['health_potion'] = 10,        -- Requiere nivel 10
        ['stimulant'] = 15,            -- Requiere nivel 15
        ['water_filter_advanced'] = 20, -- Requiere nivel 20
    }
}

-- ===== NOMBRES DE ITEMS PARA LA UI =====
Config.ItemNames = {
    -- Items base comunes
    ['water_dirty'] = 'Agua Sucia',
    ['meat_raw'] = 'Carne Cruda',
    ['vegetables'] = 'Vegetales',
    ['herbs'] = 'Hierbas',
    ['charcoal'] = 'Carbón',
    ['metalscrap'] = 'Chatarra',
    ['water_filter'] = 'Filtro Básico',
    ['thick_fabric'] = 'Tela Gruesa',
    ['solid_metal_piece'] = 'Metal Sólido',
    ['plastic'] = 'Plástico',
    ['electronics'] = 'Electrónicos',
    ['glass'] = 'Vidrio',
    ['wood'] = 'Madera',
    ['stone'] = 'Piedra',
    ['oil'] = 'Aceite',
    
    -- Items crafteados básicos
    ['meat_cooked'] = 'Carne Cocida',
    ['water_clean'] = 'Agua Limpia',
    ['bread'] = 'Pan',
    ['soup'] = 'Sopa',
    ['bandage'] = 'Vendaje',
    ['rope'] = 'Cuerda',
    ['knife'] = 'Cuchillo',
    ['torch'] = 'Antorcha',
    ['rubber_strips'] = 'Tiras de Goma',
    
    -- Items avanzados
    ['water_distilled'] = 'Agua Destilada',
    ['health_potion'] = 'Poción de Salud',
    ['stimulant'] = 'Estimulante',
    ['water_filter_advanced'] = 'Filtro Avanzado',
    ['first_aid_kit'] = 'Kit de Primeros Auxilios',
    ['energy_drink'] = 'Bebida Energética',
    ['weapon_parts'] = 'Partes de Arma',
    ['armor_vest'] = 'Chaleco Antibalas',
    ['night_vision'] = 'Visión Nocturna',
    ['lockpick_advanced'] = 'Ganzúa Avanzada'
}

-- ===== RAREZA DE ITEMS PARA LA UI =====
Config.ItemRarity = {
    -- Items comunes (gris)
    ['water_dirty'] = 'common',
    ['meat_raw'] = 'common',
    ['vegetables'] = 'common',
    ['charcoal'] = 'common',
    ['thick_fabric'] = 'common',
    ['plastic'] = 'common',
    ['wood'] = 'common',
    ['stone'] = 'common',
    ['glass'] = 'common',
    
    -- Items poco comunes (verde)
    ['herbs'] = 'uncommon',
    ['metalscrap'] = 'uncommon',
    ['water_filter'] = 'uncommon',
    ['solid_metal_piece'] = 'uncommon',
    ['electronics'] = 'uncommon',
    ['oil'] = 'uncommon',
    ['meat_cooked'] = 'uncommon',
    ['water_clean'] = 'uncommon',
    ['bread'] = 'uncommon',
    ['bandage'] = 'uncommon',
    ['rope'] = 'uncommon',
    ['knife'] = 'uncommon',
    ['torch'] = 'uncommon',
    
    -- Items raros (azul)
    ['water_distilled'] = 'rare',
    ['soup'] = 'rare',
    ['rubber_strips'] = 'rare',
    ['first_aid_kit'] = 'rare',
    ['energy_drink'] = 'rare',
    ['weapon_parts'] = 'rare',
    ['lockpick_advanced'] = 'rare',
    
    -- Items épicos (morado)
    ['health_potion'] = 'epic',
    ['stimulant'] = 'epic',
    ['water_filter_advanced'] = 'epic',
    ['armor_vest'] = 'epic',
    ['night_vision'] = 'epic'
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
        label = 'Cocina',
        description = 'Preparar comidas y bebidas',
        icon = 'fas fa-fire',
        color = 'linear-gradient(135deg, #f97316 0%, #dc2626 100%)',
        
        locations = {
            {
                coords = vector3(-1196.82, -890.79, 13.99), -- Apartamento de Franklin
                heading = 0.0,
                radius = 2.0,
            },
            {
                coords = vector3(1689.17, 4839.35, 44.91), -- Sandy Shores
                heading = 0.0,
                radius = 2.0,
            }
        },
        
        settings = {
            model = `prop_bbq_5`,
            requiredItem = nil,
            requiredJob = nil,
            requiredGang = nil,
            minLevel = 1,
            showBlip = true,
            blipSprite = 479,
            blipColor = 1,
            
            animation = {
                dict = "amb@prop_human_bbq@male@idle_a",
                anim = "idle_b",
                flag = 1,
            }
        }
    }
}

-- ===== MAPEO DE ITEMS =====
Config.ItemMapping = {
    -- Mapeo estándar QBCore -> Sistema interno
    ['water'] = 'water_dirty',
    ['sandwich'] = 'bread',
    ['tosti'] = 'bread'
}

-- ===== RECETAS DE CRAFTING =====
Config.Recipes = {
    ['cocina'] = {
        {
            id = 'meat_cooked',
            name = 'Carne Cocida',
            description = 'Carne bien preparada',
            
            requiredItems = {
                ['thick_fabric'] = 1,
                ['solid_metal_piece'] = 1
            },
            
            result = {
                item = 'sealed_parts',
                quantity = 1,
                metadata = {}
            },
            
            settings = {
                craftTime = 8000,
                experience = 5,
                difficulty = 1,
                successRate = 0.95,
                extraItemChance = 0.05,
                loseItemsOnFail = false,
                
                effects = {
                    '+50 Hambre',
                    '+10 Salud'
                }
            }
        },
    }
}

-- ===== CONFIGURACIÓN DE NOTIFICACIONES =====
Config.Notifications = {
    Type = 'qb',
    Duration = 4000,
    
    Messages = {
        -- Éxito
        CraftingComplete = 'Has creado %s exitosamente!',
        LevelUp = '¡Has subido al nivel %d de crafting!',
        ExperienceGained = 'Has ganado %d puntos de experiencia',
        BonusItem = '¡Has obtenido un item extra!',
        ImprovedQuality = '¡Has creado una versión mejorada!',
        
        -- Error
        NotEnoughItems = 'No tienes suficiente %s (%d/%d)',
        CraftingFailed = 'El crafting falló. Perdiste algunos materiales.',
        DailyLimitReached = 'Límite diario alcanzado (%d)',
        LevelRequired = 'Necesitas nivel %d para crear esto',
        JobRequired = 'Necesitas el trabajo %s',
        ItemRequired = 'Necesitas %s',
        TooFarAway = 'Estás muy lejos de la estación',
        AlreadyCrafting = 'Ya estás crafteando algo',
        
        -- Info
        CraftingStarted = 'Comenzando a crear %s...',
        CraftingCancelled = 'Crafting cancelado',
        CraftingInProgress = 'Crafting... %d%% completado',
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
