Config = {}

-- ===== CONFIGURACIÓN GENERAL =====
Config.Debug = false

-- ===== CONFIGURACIÓN DE CRAFTING =====
Config.Crafting = {
    MaxCraftingDistance = 3.0,
    ShowBlips = true,
    BlipSprite = 478,
    BlipColor = 46,
    BlipScale = 0.8,
}

-- ===== NOMBRES DE ITEMS PARA LA UI =====
Config.ItemNames = {
    ['water_dirty'] = 'Agua Sucia',
    ['meat_raw'] = 'Carne Cruda',
    ['vegetables'] = 'Vegetales',
    ['herbs'] = 'Hierbas',
    ['charcoal'] = 'Carbón',
    ['metalscrap'] = 'Chatarra',
    ['water_filter'] = 'Filtro Básico',
    ['thick_fabric'] = 'Tela Gruesa',
    ['solid_metal_piece'] = 'Metal Sólido',
    ['sealed_parts'] = 'Partes Selladas',
    ['meat_cooked'] = 'Carne Cocida',
    ['water_clean'] = 'Agua Limpia',
}

-- ===== RAREZA DE ITEMS PARA LA UI =====
Config.ItemRarity = {
    ['water_dirty'] = 'common',
    ['meat_raw'] = 'common',
    ['vegetables'] = 'common',
    ['charcoal'] = 'common',
    ['thick_fabric'] = 'common',
    ['herbs'] = 'uncommon',
    ['metalscrap'] = 'uncommon',
    ['water_filter'] = 'uncommon',
    ['solid_metal_piece'] = 'uncommon',
    ['meat_cooked'] = 'uncommon',
    ['water_clean'] = 'uncommon',
    ['sealed_parts'] = 'rare',
}

-- ===== CONFIGURACIÓN DE UI =====
Config.UI = {
    ImagePath = "nui://inventory_images/images/",
    ImageFormat = ".webp",
}

-- ===== ESTACIONES DE CRAFTING =====
Config.Stations = {
    ['cocina'] = {
        label = 'Cocina',
        description = 'Preparar comidas y bebidas',
        icon = 'fas fa-fire',
        
        locations = {
            {
                coords = vector3(-1196.82, -890.79, 13.99),
                heading = 0.0,
                radius = 2.0,
            },
            {
                coords = vector3(1689.17, 4839.35, 44.91),
                heading = 0.0,
                radius = 2.0,
            }
        },
        
        settings = {
            showBlip = true,
            blipSprite = 479,
            blipColor = 1,
        }
    }
}

-- ===== RECETAS DE CRAFTING =====
Config.Recipes = {
    ['cocina'] = {
        {
            id = 'sealed_parts',
            name = 'Partes Selladas',
            description = 'Partes bien selladas',
            
            requiredItems = {
                ['thick_fabric'] = 1,
                ['solid_metal_piece'] = 1
            },
            
            result = {
                item = 'sealed_parts',
                quantity = 1,
            },
            
            settings = {
                craftTime = 8000,
                successRate = 0.95,
            }
        },
    }
}

-- ===== CONFIGURACIÓN DE NOTIFICACIONES =====
Config.Notifications = {
    Messages = {
        CraftingComplete = 'Has creado %s exitosamente!',
        NotEnoughItems = 'No tienes suficiente %s (%d/%d)',
        CraftingFailed = 'El crafting falló. Perdiste algunos materiales.',
        TooFarAway = 'Estás muy lejos de la estación',
        CraftingStarted = 'Comenzando a crear %s...',
        CraftingCancelled = 'Crafting cancelado',
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
    UIClick = {
        name = 'SELECT',
        set = 'HUD_FRONTEND_DEFAULT_SOUNDSET'
    },
}
