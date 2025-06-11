
// ===== CONFIGURACIÓN Y DATOS =====
const CraftingSystem = {
    isOpen: false,
    activeStation: 'cocina',
    inventory: {},
    isCrafting: false,
    craftingProgress: 0,
    craftingRecipe: null,
    craftingInterval: null,

    // Configuración de estaciones
    stations: {
        cocina: {
            name: 'Cocina de Supervivencia',
            icon: 'fas fa-fire',
            color: 'linear-gradient(135deg, #f97316 0%, #dc2626 100%)',
            description: 'Prepara alimentos nutritivos',
            recipes: [
                {
                    id: 'carne_cocida',
                    name: 'Carne Cocida',
                    description: 'Carne bien cocinada que restaura energía',
                    result: { item: 'carne_cocida', quantity: 1 },
                    ingredients: { 'carne_cruda': 1, 'carbon': 1 },
                    time: 10000,
                    difficulty: 1,
                    effects: ['+50 Hambre', '+10 Salud', '+5 Energía']
                },
                {
                    id: 'estofado',
                    name: 'Estofado Nutritivo',
                    description: 'Comida completa que satisface completamente',
                    result: { item: 'estofado', quantity: 1 },
                    ingredients: { 'carne_cruda': 2, 'vegetales': 2, 'hierbas': 1 },
                    time: 15000,
                    difficulty: 2,
                    effects: ['+80 Hambre', '+20 Salud', '+15 Energía', '+5 Hidratación']
                },
                {
                    id: 'sopa_hierbas',
                    name: 'Sopa de Hierbas',
                    description: 'Sopa medicinal con propiedades curativas',
                    result: { item: 'sopa_hierbas', quantity: 1 },
                    ingredients: { 'hierbas': 3, 'vegetales': 1, 'agua_limpia': 1 },
                    time: 12000,
                    difficulty: 2,
                    effects: ['+30 Hambre', '+25 Salud', 'Regeneración 60s']
                }
            ]
        },
        purificacion: {
            name: 'Purificador de Agua',
            icon: 'fas fa-tint',
            color: 'linear-gradient(135deg, #3b82f6 0%, #06b6d4 100%)',
            description: 'Convierte agua contaminada en potable',
            recipes: [
                {
                    id: 'agua_limpia',
                    name: 'Agua Purificada',
                    description: 'Agua segura para consumo humano',
                    result: { item: 'agua_limpia', quantity: 2 },
                    ingredients: { 'agua_sucia': 3, 'filtro_improvised': 1 },
                    time: 8000,
                    difficulty: 1,
                    effects: ['+40 Hidratación', 'Elimina toxinas']
                },
                {
                    id: 'agua_destilada',
                    name: 'Agua Destilada',
                    description: 'Agua ultra pura para uso médico',
                    result: { item: 'agua_destilada', quantity: 1 },
                    ingredients: { 'agua_limpia': 2, 'carbon': 1 },
                    time: 12000,
                    difficulty: 2,
                    effects: ['+30 Hidratación', '+10 Salud', 'Pureza 100%']
                }
            ]
        },
        alquimia: {
            name: 'Mesa de Alquimia',
            icon: 'fas fa-flask',
            color: 'linear-gradient(135deg, #8b5cf6 0%, #ec4899 100%)',
            description: 'Crea pociones y estimulantes',
            recipes: [
                {
                    id: 'pocion_salud',
                    name: 'Poción de Salud',
                    description: 'Restaura salud instantáneamente',
                    result: { item: 'pocion_salud', quantity: 1 },
                    ingredients: { 'hierbas': 3, 'agua_destilada': 1 },
                    time: 18000,
                    difficulty: 3,
                    effects: ['+100 Salud', 'Regeneración 30s', 'Cura envenenamiento']
                },
                {
                    id: 'estimulante',
                    name: 'Estimulante de Combate',
                    description: 'Aumenta capacidades físicas temporalmente',
                    result: { item: 'estimulante', quantity: 1 },
                    ingredients: { 'hierbas': 2, 'carne_cocida': 1, 'agua_limpia': 1 },
                    time: 14000,
                    difficulty: 2,
                    effects: ['+50 Energía', '+25% Velocidad 5min', '+15% Fuerza 5min']
                }
            ]
        },
        herramientas: {
            name: 'Banco de Trabajo',
            icon: 'fas fa-hammer',
            color: 'linear-gradient(135deg, #6b7280 0%, #4b5563 100%)',
            description: 'Fabrica herramientas y equipos',
            recipes: [
                {
                    id: 'filtro_mejorado',
                    name: 'Filtro Avanzado',
                    description: 'Filtro de alta eficiencia para purificación',
                    result: { item: 'filtro_mejorado', quantity: 1 },
                    ingredients: { 'metal_chatarra': 2, 'filtro_improvised': 1, 'carbon': 1 },
                    time: 20000,
                    difficulty: 3,
                    effects: ['Purifica 5x agua', 'Durabilidad +200%', 'Eficiencia +50%']
                }
            ]
        }
    },

    // Nombres de items
    itemNames: {
        'agua_sucia': 'Agua Contaminada',
        'carne_cruda': 'Carne Cruda',
        'vegetales': 'Vegetales Frescos',
        'hierbas': 'Hierbas Medicinales',
        'carbon': 'Carbón Vegetal',
        'metal_chatarra': 'Chatarra Metálica',
        'filtro_improvised': 'Filtro Improvisado',
        'carne_cocida': 'Carne Cocida',
        'agua_limpia': 'Agua Purificada',
        'agua_destilada': 'Agua Destilada',
        'estofado': 'Estofado Nutritivo',
        'sopa_hierbas': 'Sopa de Hierbas',
        'pocion_salud': 'Poción de Salud',
        'estimulante': 'Estimulante de Combate',
        'filtro_mejorado': 'Filtro Avanzado'
    },

    // Rareza de items
    itemRarity: {
        'agua_sucia': 'common',
        'carne_cruda': 'common',
        'vegetales': 'common',
        'hierbas': 'uncommon',
        'carbon': 'common',
        'metal_chatarra': 'uncommon',
        'filtro_improvised': 'uncommon',
        'carne_cocida': 'uncommon',
        'agua_limpia': 'uncommon',
        'agua_destilada': 'rare',
        'estofado': 'rare',
        'sopa_hierbas': 'rare',
        'pocion_salud': 'epic',
        'estimulante': 'rare',
        'filtro_mejorado': 'epic'
    }
};

// ===== FUNCIONES DE UTILIDAD =====
function getItemImage(itemName) {
    return `nui://inventory_images/images/${itemName}.webp`;
}

function canCraft(recipe) {
    return Object.entries(recipe.ingredients).every(
        ([ingredient, required]) => (CraftingSystem.inventory[ingredient] || 0) >= required
    );
}

function showNotification(message, type = 'success') {
    const notification = document.getElementById('notification');
    const icon = notification.querySelector('.notification-icon');
    const text = notification.querySelector('.notification-text');

    notification.className = `notification ${type}`;
    icon.className = `notification-icon fas ${type === 'success' ? 'fa-check-circle' : 'fa-exclamation-circle'}`;
    text.textContent = message;

    notification.classList.remove('hidden');
    
    setTimeout(() => {
        notification.classList.add('hidden');
    }, 3000);
}

function formatTime(milliseconds) {
    return Math.ceil(milliseconds / 1000);
}

function postToNUI(action, data = {}) {
    fetch(`https://${GetParentResourceName()}/${action}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify(data)
    });
}

// ===== FUNCIONES DE RENDERIZADO =====
function renderStations() {
    const stationsList = document.getElementById('stations-list');
    stationsList.innerHTML = '';

    Object.entries(CraftingSystem.stations).forEach(([key, station]) => {
        const stationBtn = document.createElement('button');
        stationBtn.className = `station-btn ${CraftingSystem.activeStation === key ? 'active' : ''}`;
        stationBtn.dataset.station = key;
        
        stationBtn.innerHTML = `
            <div class="station-btn-icon">
                <i class="${station.icon}"></i>
            </div>
            <div class="station-btn-info">
                <div class="station-btn-name">${station.name}</div>
                <div class="station-btn-desc">${station.description}</div>
            </div>
        `;

        stationBtn.addEventListener('click', () => selectStation(key));
        stationsList.appendChild(stationBtn);
    });
}

function renderInventory() {
    const inventoryGrid = document.getElementById('inventory-grid');
    inventoryGrid.innerHTML = '';

    Object.entries(CraftingSystem.inventory)
        .filter(([_, quantity]) => quantity > 0)
        .forEach(([item, quantity]) => {
            const itemDiv = document.createElement('div');
            itemDiv.className = `inventory-item ${CraftingSystem.itemRarity[item]}`;
            
            itemDiv.innerHTML = `
                <div class="item-info">
                    <img class="item-image" src="${getItemImage(item)}" alt="${CraftingSystem.itemNames[item]}" onerror="this.style.display='none'">
                    <span class="item-name">${CraftingSystem.itemNames[item]}</span>
                </div>
                <span class="item-quantity">${quantity}</span>
            `;

            inventoryGrid.appendChild(itemDiv);
        });
}

function renderRecipes() {
    const recipesContainer = document.getElementById('recipes-container');
    recipesContainer.innerHTML = '';

    if (!CraftingSystem.stations[CraftingSystem.activeStation]) return;

    const recipes = CraftingSystem.stations[CraftingSystem.activeStation].recipes;

    recipes.forEach(recipe => {
        const canCraftRecipe = canCraft(recipe);
        const recipeCard = document.createElement('div');
        recipeCard.className = `recipe-card ${canCraftRecipe && !CraftingSystem.isCrafting ? 'can-craft' : 'cannot-craft'}`;

        // Generar estrellas de dificultad
        const difficultyStars = Array.from({ length: 3 }, (_, i) => 
            `<i class="difficulty-star fas fa-star ${i < recipe.difficulty ? 'filled' : 'empty'}"></i>`
        ).join('');

        // Generar ingredientes
        const ingredientsList = Object.entries(recipe.ingredients).map(([ingredient, required]) => {
            const available = CraftingSystem.inventory[ingredient] || 0;
            const hasEnough = available >= required;
            
            return `
                <div class="ingredient-item ${hasEnough ? 'available' : 'unavailable'}">
                    <div class="ingredient-info">
                        <img class="ingredient-image" src="${getItemImage(ingredient)}" alt="${CraftingSystem.itemNames[ingredient]}" onerror="this.style.display='none'">
                        <span class="ingredient-name">${CraftingSystem.itemNames[ingredient]}</span>
                    </div>
                    <span class="ingredient-count">${available} / ${required}</span>
                </div>
            `;
        }).join('');

        // Generar efectos
        const effectsList = recipe.effects.map(effect => `
            <div class="effect-item">
                <i class="effect-icon fas fa-bolt"></i>
                <span>${effect}</span>
            </div>
        `).join('');

        recipeCard.innerHTML = `
            <div class="recipe-header">
                <div class="recipe-info">
                    <div class="recipe-title-row">
                        <h3 class="recipe-name">${recipe.name}</h3>
                        <div class="difficulty-stars">${difficultyStars}</div>
                    </div>
                    <p class="recipe-description">${recipe.description}</p>
                    <div class="recipe-meta">
                        <div class="recipe-time">
                            <i class="fas fa-clock"></i>
                            <span>${formatTime(recipe.time)}s</span>
                        </div>
                        <i class="fas fa-chevron-right"></i>
                        <div class="recipe-result">
                            <span>+${recipe.result.quantity} ${CraftingSystem.itemNames[recipe.result.item]}</span>
                        </div>
                    </div>
                </div>
                <button class="craft-btn ${canCraftRecipe && !CraftingSystem.isCrafting ? 'can-craft' : 'cannot-craft'}" 
                        ${!canCraftRecipe || CraftingSystem.isCrafting ? 'disabled' : ''} 
                        onclick="startCrafting('${recipe.id}')">
                    ${CraftingSystem.isCrafting ? 'Fabricando...' : 'Crear'}
                </button>
            </div>
            <div class="recipe-details">
                <div class="ingredients-section">
                    <h4>Ingredientes</h4>
                    <div class="ingredients-list">${ingredientsList}</div>
                </div>
                <div class="effects-section">
                    <h4>Efectos</h4>
                    <div class="effects-list">${effectsList}</div>
                </div>
            </div>
        `;

        recipesContainer.appendChild(recipeCard);
    });
}

function updateStationHeader() {
    const station = CraftingSystem.stations[CraftingSystem.activeStation];
    if (!station) return;

    document.getElementById('station-icon').className = `station-icon ${station.icon}`;
    document.getElementById('station-name').textContent = station.name;
    document.getElementById('station-description').textContent = station.description;
    
    const iconContainer = document.querySelector('.station-icon-container');
    iconContainer.style.background = station.color;
}

// ===== FUNCIONES DE CRAFTING =====
function selectStation(stationKey) {
    CraftingSystem.activeStation = stationKey;
    renderStations();
    updateStationHeader();
    renderRecipes();
}

function startCrafting(recipeId) {
    if (CraftingSystem.isCrafting) return;

    const recipe = CraftingSystem.stations[CraftingSystem.activeStation].recipes.find(r => r.id === recipeId);
    if (!recipe || !canCraft(recipe)) return;

    // Enviar al servidor para validar y consumir items
    postToNUI('startCrafting', {
        station: CraftingSystem.activeStation,
        recipe: recipeId,
        ingredients: recipe.ingredients
    });
}

function beginCraftingProcess(recipe) {
    CraftingSystem.isCrafting = true;
    CraftingSystem.craftingProgress = 0;
    CraftingSystem.craftingRecipe = recipe;

    // Mostrar UI de progreso
    const progressContainer = document.getElementById('crafting-progress');
    progressContainer.classList.remove('hidden');
    
    document.getElementById('crafting-item-name').textContent = recipe.name;
    
    // Iniciar progreso
    CraftingSystem.craftingInterval = setInterval(() => {
        CraftingSystem.craftingProgress += (100 / (recipe.time / 100));
        
        if (CraftingSystem.craftingProgress >= 100) {
            completeCrafting(recipe);
            return;
        }
        
        updateCraftingProgress();
    }, 100);

    renderRecipes(); // Re-render para deshabilitar botones
}

function updateCraftingProgress() {
    const progressBar = document.getElementById('progress-bar');
    const progressPercentage = document.getElementById('progress-percentage');
    const timeRemaining = document.getElementById('time-remaining');
    
    progressBar.style.width = `${CraftingSystem.craftingProgress}%`;
    progressPercentage.textContent = `${Math.round(CraftingSystem.craftingProgress)}%`;
    
    const remainingTime = formatTime(CraftingSystem.craftingRecipe.time * (1 - CraftingSystem.craftingProgress / 100));
    timeRemaining.textContent = remainingTime;
}

function completeCrafting(recipe) {
    clearInterval(CraftingSystem.craftingInterval);
    CraftingSystem.isCrafting = false;
    CraftingSystem.craftingProgress = 0;
    CraftingSystem.craftingRecipe = null;

    // Ocultar progreso
    document.getElementById('crafting-progress').classList.add('hidden');

    // Notificación
    showNotification(`¡${recipe.name} creado exitosamente!`, 'success');

    // Enviar al servidor que se completó
    postToNUI('completeCrafting', {
        station: CraftingSystem.activeStation,
        recipe: recipe.id,
        result: recipe.result
    });

    renderRecipes();
}

function cancelCrafting() {
    if (!CraftingSystem.isCrafting) return;

    clearInterval(CraftingSystem.craftingInterval);
    CraftingSystem.isCrafting = false;
    CraftingSystem.craftingProgress = 0;
    CraftingSystem.craftingRecipe = null;

    document.getElementById('crafting-progress').classList.add('hidden');
    
    postToNUI('cancelCrafting', {});
    renderRecipes();
}

// ===== FUNCIONES DE UI =====
function openCrafting(data = {}) {
    CraftingSystem.isOpen = true;
    CraftingSystem.inventory = data.inventory || {};
    
    document.getElementById('crafting-container').classList.remove('hidden');
    document.body.style.overflow = 'hidden';

    renderStations();
    renderInventory();
    updateStationHeader();
    renderRecipes();

    // Focus en la ventana para capturar teclas
    document.addEventListener('keydown', handleKeyPress);
}

function closeCrafting() {
    if (CraftingSystem.isCrafting) {
        cancelCrafting();
    }

    CraftingSystem.isOpen = false;
    document.getElementById('crafting-container').classList.add('hidden');
    document.body.style.overflow = 'auto';
    document.removeEventListener('keydown', handleKeyPress);

    postToNUI('closeCrafting', {});
}

function updateInventory(inventory) {
    CraftingSystem.inventory = inventory;
    renderInventory();
    renderRecipes(); // Re-render para actualizar disponibilidad
}

function handleKeyPress(event) {
    if (event.key === 'Escape') {
        closeCrafting();
    }
}

// ===== EVENT LISTENERS =====
document.addEventListener('DOMContentLoaded', function() {
    // Botón cerrar
    document.getElementById('close-btn').addEventListener('click', closeCrafting);

    // Manejar clics fuera del modal
    document.getElementById('crafting-container').addEventListener('click', function(e) {
        if (e.target === this) {
            closeCrafting();
        }
    });
});

// ===== COMUNICACIÓN CON NUI =====
window.addEventListener('message', function(event) {
    const data = event.data;

    switch(data.action) {
        case 'openCrafting':
            openCrafting(data);
            break;

        case 'closeCrafting':
            closeCrafting();
            break;

        case 'updateInventory':
            updateInventory(data.inventory);
            break;

        case 'startCraftingProcess':
            beginCraftingProcess(data.recipe);
            break;

        case 'craftingError':
            showNotification(data.message, 'error');
            break;

        case 'craftingSuccess':
            showNotification(data.message, 'success');
            break;
    }
});

// ===== FUNCIONES GLOBALES =====
window.startCrafting = startCrafting;
window.selectStation = selectStation;
