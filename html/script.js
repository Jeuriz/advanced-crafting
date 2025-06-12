// ===== CONFIGURACIÓN Y DATOS =====
const CraftingSystem = {
    isOpen: false,
    activeStation: null,
    inventory: {},
    isCrafting: false,
    craftingProgress: 0,
    craftingRecipe: null,
    craftingInterval: null,
    
    // Datos que vienen del servidor
    stations: {},
    recipes: {},
    itemNames: {},
    itemRarity: {},
    config: {}
};

// ===== FUNCIONES DE UTILIDAD =====
function getItemImage(itemName) {
    const imagePath = CraftingSystem.config.imagePath || "nui://inventory_images/images/";
    const imageFormat = CraftingSystem.config.imageFormat || ".webp";
    return `${imagePath}${itemName}${imageFormat}`;
}

function getItemDisplayName(itemName) {
    return CraftingSystem.itemNames[itemName] || itemName;
}

function canCraft(recipe) {
    if (!recipe.ingredients) return false;
    
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
            const rarity = CraftingSystem.itemRarity[item] || 'common';
            itemDiv.className = `inventory-item ${rarity}`;
            
            itemDiv.innerHTML = `
                <div class="item-info">
                    <img class="item-image" src="${getItemImage(item)}" alt="${getItemDisplayName(item)}" onerror="this.style.display='none'">
                    <span class="item-name">${getItemDisplayName(item)}</span>
                </div>
                <span class="item-quantity">${quantity}</span>
            `;

            inventoryGrid.appendChild(itemDiv);
        });
}

function renderRecipes() {
    const recipesContainer = document.getElementById('recipes-container');
    recipesContainer.innerHTML = '';

    if (!CraftingSystem.activeStation || !CraftingSystem.recipes[CraftingSystem.activeStation]) {
        return;
    }

    const recipes = CraftingSystem.recipes[CraftingSystem.activeStation];

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
                        <img class="ingredient-image" src="${getItemImage(ingredient)}" alt="${getItemDisplayName(ingredient)}" onerror="this.style.display='none'">
                        <span class="ingredient-name">${getItemDisplayName(ingredient)}</span>
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
                            <span>+${recipe.result.quantity} ${getItemDisplayName(recipe.result.item)}</span>
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
    if (!CraftingSystem.activeStation || !CraftingSystem.stations[CraftingSystem.activeStation]) {
        document.getElementById('station-name').textContent = 'Selecciona una Estación';
        document.getElementById('station-description').textContent = 'Elige una estación para comenzar';
        return;
    }

    const station = CraftingSystem.stations[CraftingSystem.activeStation];
    
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

    if (!CraftingSystem.activeStation || !CraftingSystem.recipes[CraftingSystem.activeStation]) {
        showNotification('Error: Estación no válida', 'error');
        return;
    }

    const recipe = CraftingSystem.recipes[CraftingSystem.activeStation].find(r => r.id === recipeId);
    if (!recipe || !canCraft(recipe)) {
        showNotification('No tienes los materiales necesarios', 'error');
        return;
    }

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
    // Cargar todos los datos del servidor
    CraftingSystem.stations = data.stations || {};
    CraftingSystem.recipes = data.recipes || {};
    CraftingSystem.itemNames = data.itemNames || {};
    CraftingSystem.itemRarity = data.itemRarity || {};
    CraftingSystem.config = data.config || {};
    CraftingSystem.inventory = data.inventory || {};
    
    // Establecer estación por defecto
    const firstStation = Object.keys(CraftingSystem.stations)[0];
    CraftingSystem.activeStation = data.activeStation || firstStation || null;
    
    CraftingSystem.isOpen = true;
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
