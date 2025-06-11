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
                coords = vector3(1973.85, 3815.26, 33.44),
                heading = 0.0,
                radius = 2.0,
            },
            {
                coords = vector3(-1196.45, -893.44, 13.89), -- Vespucci Beach
                heading = 180.0,
                radius = 2.0,
            },
            {
                coords = vector3(1687.99, 4815.89, 42.01), -- Grapeseed
                heading = 90.0,
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
    
    ['purificacion'] = {
        label = 'Purificador de Agua',
        description = 'Convierte agua contaminada en agua potable',
        icon = 'fas fa-tint',
        color = 'linear-gradient(135deg, #3b82f6 0%, #06b6d4 100%)',
        
        locations = {
            {
                coords = vector3(1975.23, 3820.12, 33.44),
                heading = 90.0,
                radius = 2.0,
            },
            {
                coords = vector3(-1198.67, -895.78, 13.89), -- Vespucci Beach
                heading = 180.0,
                radius = 2.0,
            }
        },
        
        settings = {
            model = `prop_watercooler`,
            requiredItem = nil,
            requiredJob = nil,
            requiredGang = nil,
            minLevel = 1,
            showBlip = true,
            blipSprite = 480,
            blipColor = 3,
            
            animation = {
                dict = "mp_common",
                anim = "givetake2_a",
                flag = 1,
            }
        }
    },
    
    ['alquimia'] = {
        label = 'Mesa de Alquimia',
        description = 'Crea pociones y estimulantes avanzados',
        icon = 'fas fa-flask',
        color = 'linear-gradient(135deg, #8b5cf6 0%, #ec4899 100%)',
        
        locations = {
            {
                coords = vector3(1970.44, 3817.88, 33.44),
                heading = 270.0,
                radius = 2.0,
            },
            {
                coords = vector3(-1201.23, -898.45, 13.89), -- Vespucci Beach
                heading = 0.0,
                radius = 2.0,
            }
        },
        
        settings = {
            model = `bkr_prop_meth_table01a`,
            requiredItem = 'chemistry_kit',
            requiredJob = nil,
            requiredGang = nil,
            minLevel = 5,
            showBlip = true,
            blipSprite = 499,
            blipColor = 27,
            
            animation = {
                dict = "mp_suicide",
                anim = "pill_fp",
                flag = 1,
            }
        }
    },
    
    ['herramientas'] = {
        label = 'Banco de Trabajo',
        description = 'Fabrica herramientas y equipos especializados',
        icon = 'fas fa-hammer',
        color = 'linear-gradient(135deg, #6b7280 0%, #4b5563 100%)',
        
        locations = {
            {
                coords = vector3(1968.12, 3812.99, 33.44),
                heading = 45.0,
                radius = 2.0,
            },
            {
                coords = vector3(-1203.89, -901.12, 13.89), -- Vespucci Beach
                heading = 90.0,
                radius = 2.0,
            }
        },
        
        settings = {
            model = `prop_tool_bench02`,
            requiredItem = nil,
            requiredJob = {'mechanic'},
            requiredGang = nil,
            minLevel = 3,
            showBlip = true,
            blipSprite = 446,
            blipColor = 0,
            
            animation = {
                dict = "mp_common",
                anim = "givetake2_a",
                flag = 1,
            }
        }
    }
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
                ['meat_raw'] = 1,
                ['charcoal'] = 1
            },
            
            -- Resultado
            result = {
                item = 'meat_cooked',
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
        },
        
        {
            id = 'estofado',
            name = 'Estofado Nutritivo',
            description = 'Comida completa que satisface completamente',
            
            requiredItems = {
                ['meat_raw'] = 2,
                ['vegetables'] = 2,
                ['herbs'] = 1
            },
            
            result = {
                item = 'stew',
                quantity = 1,
                metadata = {
                    quality = 'excellent',
                    expiry = 48
                }
            },
            
            settings = {
                craftTime = 15000,
                experience = 25,
                difficulty = 2,
                successRate = 0.90,
                extraItemChance = 0.15,
                
                effects = {
                    '+80 Hambre',
                    '+20 Salud',
                    '+15 Energía',
                    '+5 Hidratación'
                }
            }
        },
        
        {
            id = 'sopa_hierbas',
            name = 'Sopa de Hierbas',
            description = 'Sopa medicinal con propiedades curativas',
            
            requiredItems = {
                ['herbs'] = 3,
                ['vegetables'] = 1,
                ['water_clean'] = 1
            },
            
            result = {
                item = 'herb_soup',
                quantity = 1,
                metadata = {
                    quality = 'premium',
                    healing = true,
                    expiry = 24
                }
            },
            
            settings = {
                craftTime = 12000,
                experience = 20,
                difficulty = 2,
                successRate = 0.92,
                extraItemChance = 0.12,
                
                effects = {
                    '+30 Hambre',
                    '+25 Salud',
                    'Regeneración 60s'
                }
            }
        }
    },
    
    ['purificacion'] = {
        {
            id = 'agua_limpia',
            name = 'Agua Purificada',
            description = 'Agua segura para consumo humano',
            
            requiredItems = {
                ['water_dirty'] = 3,
                ['water_filter'] = 1
            },
            
            result = {
                item = 'water_clean',
                quantity = 2,
                metadata = {
                    purity = 'clean',
                    expiry = 168 -- 1 semana
                }
            },
            
            settings = {
                craftTime = 8000,
                experience = 5,
                difficulty = 1,
                successRate = 0.98,
                consumeFilter = false, -- No consume el filtro
                
                effects = {
                    '+40 Hidratación',
                    'Elimina toxinas'
                }
            }
        },
        
        {
            id = 'agua_destilada',
            name = 'Agua Destilada',
            description = 'Agua ultra pura para uso médico',
            
            requiredItems = {
                ['water_clean'] = 2,
                ['charcoal'] = 1
            },
            
            result = {
                item = 'water_distilled',
                quantity = 1,
                metadata = {
                    purity = 'distilled',
                    medical_grade = true,
                    expiry = 336 -- 2 semanas
                }
            },
            
            settings = {
                craftTime = 12000,
                experience = 15,
                difficulty = 2,
                successRate = 0.94,
                
                effects = {
                    '+30 Hidratación',
                    '+10 Salud',
                    'Pureza 100%'
                }
            }
        }
    },
    
    ['alquimia'] = {
        {
            id = 'pocion_salud',
            name = 'Poción de Salud',
            description = 'Restaura salud instantáneamente',
            
            requiredItems = {
                ['herbs'] = 3,
                ['water_distilled'] = 1
            },
            
            result = {
                item = 'health_potion',
                quantity = 1,
                metadata = {
                    potency = 'high',
                    expiry = 720, -- 30 días
                    healing_power = 100
                }
            },
            
            settings = {
                craftTime = 18000,
                experience = 30,
                difficulty = 3,
                successRate = 0.85,
                extraItemChance = 0.05,
                
                effects = {
                    '+100 Salud',
                    'Regeneración 30s',
                    'Cura envenenamiento'
                }
            }
        },
        
        {
            id = 'estimulante',
            name = 'Estimulante de Combate',
            description = 'Aumenta capacidades físicas temporalmente',
            
            requiredItems = {
                ['herbs'] = 2,
                ['meat_cooked'] = 1,
                ['water_clean'] = 1
            },
            
            result = {
                item = 'stimulant',
                quantity = 1,
                metadata = {
                    duration = 300, -- 5 minutos
                    strength_boost = 25,
                    speed_boost = 25
                }
            },
            
            settings = {
                craftTime = 14000,
                experience = 25,
                difficulty = 2,
                successRate = 0.88,
                extraItemChance = 0.08,
                
                effects = {
                    '+50 Energía',
                    '+25% Velocidad 5min',
                    '+15% Fuerza 5min'
                }
            }
        }
    },
    
    ['herramientas'] = {
        {
            id = 'filtro_mejorado',
            name = 'Filtro Avanzado',
            description = 'Filtro de alta eficiencia para purificación',
            
            requiredItems = {
                ['metalscrap'] = 2,
                ['water_filter'] = 1,
                ['charcoal'] = 1
            },
            
            result = {
                item = 'water_filter_advanced',
                quantity = 1,
                metadata = {
                    durability = 100,
                    efficiency = 'high',
                    capacity = 50 -- Usos antes de romperse
                }
            },
            
            settings = {
                craftTime = 20000,
                experience = 50,
                difficulty = 3,
                successRate = 0.80,
                extraItemChance = 0.08,
                
                effects = {
                    'Purifica 5x agua',
                    'Durabilidad +200%',
                    'Eficiencia +50%'
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
