// ===== CONFIGURACIÓN Y DATOS =====
const CraftingSystem = {
    isOpen: false,
    activeStation: null,
    selectedRecipe: null,
    quantity: 1,
    inventory: {},
    isCrafting: false,
    craftingProgress: 0,
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
function renderStationTabs() {
    const stationTabs = document.getElementById('station-tabs');
    stationTabs.innerHTML = '';

    Object.entries(CraftingSystem.stations).forEach(([key, station]) => {
        const tab = document.createElement('button');
        tab.className = `station-tab ${CraftingSystem.activeStation === key ? 'active' : ''}`;
        tab.onclick = () => selectStation(key);
        
        tab.innerHTML = `
            <i class="${station.icon}"></i>
            <span>${station.name}</span>
        `;

        stationTabs.appendChild(tab);
    });
}

function renderRecipes() {
    const recipesGrid = document.getElementById('recipes-grid');
    recipesGrid.innerHTML = '';

    if (!CraftingSystem.activeStation || !CraftingSystem.recipes[CraftingSystem.activeStation]) {
        return;
    }

    const recipes = CraftingSystem.recipes[CraftingSystem.activeStation];

    recipes.forEach(recipe => {
        const canCraft = canCraftRecipe(recipe);
        const recipeItem = document.createElement('div');
        recipeItem.className = `recipe-item ${!canCraft ? 'disabled' : ''}`;
        recipeItem.onclick = () => selectRecipe(recipe);
        
        recipeItem.innerHTML = `
            <img src="${getItemImage(recipe.result.item)}" alt="${recipe.name}" onerror="this.style.display='none'">
            <div class="name">${recipe.name}</div>
        `;

        recipesGrid.appendChild(recipeItem);
    });
}

function renderSelectedRecipe() {
    const selectedRecipeEl = document.getElementById('selected-recipe');
    const ingredientsEl = document.getElementById('ingredients-required');
    const quantityControls = document.getElementById('quantity-controls');
    const resultDisplay = document.getElementById('result-display');
    const craftBtn = document.getElementById('craft-btn');

    if (!CraftingSystem.selectedRecipe) {
        selectedRecipeEl.innerHTML = `
            <div class="recipe-info">
                <div class="recipe-icon">
                    <i class="fas fa-question"></i>
                </div>
                <div class="recipe-details">
                    <div class="recipe-name">Select Recipe</div>
                    <div class="recipe-desc">Choose a recipe to start crafting</div>
                </div>
            </div>
        `;
        ingredientsEl.innerHTML = '';
        quantityControls.style.display = 'none';
        resultDisplay.innerHTML = `
            <div class="result-placeholder">
                <i class="fas fa-box-open"></i>
                <span>Result will appear here</span>
            </div>
        `;
        craftBtn.disabled = true;
        return;
    }

    const recipe = CraftingSystem.selectedRecipe;
    const canCraft = canCraftRecipe(recipe);

    // Mostrar receta seleccionada
    selectedRecipeEl.innerHTML = `
        <div class="recipe-info">
            <div class="recipe-icon">
                <img src="${getItemImage(recipe.result.item)}" alt="${recipe.name}" onerror="this.src='data:image/svg+xml,<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 24 24\"><rect width=\"24\" height=\"24\" fill=\"%23666\"/></svg>'">
            </div>
            <div class="recipe-details">
                <div class="recipe-name">${recipe.name}</div>
                <div class="recipe-desc">${recipe.description}</div>
            </div>
        </div>
    `;

    // Mostrar ingredientes requeridos
    ingredientsEl.innerHTML = '';
    Object.entries(recipe.ingredients).forEach(([ingredient, required]) => {
        const available = CraftingSystem.inventory[ingredient] || 0;
        const hasEnough = available >= (required * CraftingSystem.quantity);
        
        const ingredientEl = document.createElement('div');
        ingredientEl.className = `ingredient-item ${hasEnough ? 'available' : 'unavailable'}`;
        ingredientEl.innerHTML = `
            <img src="${getItemImage(ingredient)}" alt="${getItemDisplayName(ingredient)}" onerror="this.style.display='none'">
            <span>${available}/${required * CraftingSystem.quantity}</span>
        `;
        ingredientsEl.appendChild(ingredientEl);
    });

    // Mostrar controles de cantidad
    quantityControls.style.display = 'flex';
    document.getElementById('quantity-display').textContent = CraftingSystem.quantity;

    // Mostrar resultado
    resultDisplay.innerHTML = `
        <div class="result-item">
            <img src="${getItemImage(recipe.result.item)}" alt="${recipe.name}" onerror="this.src='data:image/svg+xml,<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 24 24\"><rect width=\"24\" height=\"24\" fill=\"%23666\"/></svg>'">
            <div class="name">${getItemDisplayName(recipe.result.item)}</div>
            <div class="quantity">+${recipe.result.quantity * CraftingSystem.quantity}</div>
        </div>
    `;

    // Actualizar botón de craft
    craftBtn.disabled = !canCraft || CraftingSystem.isCrafting;
}

function renderInventory() {
    const inventoryItems = document.getElementById('inventory-items');
    inventoryItems.innerHTML = '';

    Object.entries(CraftingSystem.inventory)
        .filter(([_, quantity]) => quantity > 0)
        .sort(([a], [b]) => getItemDisplayName(a).localeCompare(getItemDisplayName(b)))
        .forEach(([item, quantity]) => {
            const itemDiv = document.createElement('div');
            const rarity = CraftingSystem.itemRarity[item] || 'common';
            itemDiv.className = `inventory-item ${rarity}`;
            itemDiv.title = getItemDisplayName(item);
            
            itemDiv.innerHTML = `
                <img src="${getItemImage(item)}" alt="${getItemDisplayName(item)}" onerror="this.style.display='none'">
                <div class="name">${getItemDisplayName(item)}</div>
                <div class="quantity">${quantity}</div>
            `;

            inventoryItems.appendChild(itemDiv);
        });
}

function updateStationDisplay() {
    if (!CraftingSystem.activeStation || !CraftingSystem.stations[CraftingSystem.activeStation]) {
        document.getElementById('station-name').textContent = 'CRAFTING STATION';
        document.getElementById('station-icon').className = 'station-icon fas fa-tools';
        document.getElementById('station-display-icon').className = 'station-display-icon fas fa-tools';
        return;
    }

    const station = CraftingSystem.stations[CraftingSystem.activeStation];
    document.getElementById('station-name').textContent = station.name.toUpperCase();
    document.getElementById('station-icon').className = `station-icon ${station.icon}`;
    document.getElementById('station-display-icon').className = `station-display-icon ${station.icon}`;
}

// ===== FUNCIONES DE LÓGICA =====
function canCraftRecipe(recipe) {
    if (!recipe.ingredients) return false;
    
    return Object.entries(recipe.ingredients).every(
        ([ingredient, required]) => (CraftingSystem.inventory[ingredient] || 0) >= (required * CraftingSystem.quantity)
    );
}

function selectStation(stationKey) {
    CraftingSystem.activeStation = stationKey;
    CraftingSystem.selectedRecipe = null;
    CraftingSystem.quantity = 1;
    
    updateStationDisplay();
    renderStationTabs();
    renderRecipes();
    renderSelectedRecipe();
}

function selectRecipe(recipe) {
    if (!canCraftRecipe(recipe)) return;
    
    // Highlight selected recipe
    document.querySelectorAll('.recipe-item').forEach(item => {
        item.classList.remove('selected');
    });
    event.currentTarget.classList.add('selected');
    
    CraftingSystem.selectedRecipe = recipe;
    CraftingSystem.quantity = 1;
    renderSelectedRecipe();
}

function changeQuantity(delta) {
    if (!CraftingSystem.selectedRecipe) return;
    
    const newQuantity = Math.max(1, CraftingSystem.quantity + delta);
    const maxQuantity = Math.min(
        99, 
        ...Object.entries(CraftingSystem.selectedRecipe.ingredients).map(([ingredient, required]) => 
            Math.floor((CraftingSystem.inventory[ingredient] || 0) / required)
        )
    );
    
    CraftingSystem.quantity = Math.min(newQuantity, maxQuantity);
    renderSelectedRecipe();
}

function clearSelection() {
    CraftingSystem.selectedRecipe = null;
    CraftingSystem.quantity = 1;
    
    document.querySelectorAll('.recipe-item').forEach(item => {
        item.classList.remove('selected');
    });
    
    renderSelectedRecipe();
}

function startCrafting() {
    if (!CraftingSystem.selectedRecipe || CraftingSystem.isCrafting) return;
    
    const recipe = CraftingSystem.selectedRecipe;
    if (!canCraftRecipe(recipe)) {
        showNotification('No tienes suficientes materiales', 'error');
        return;
    }

    // Enviar al servidor para procesar
    postToNUI('startCrafting', {
        station: CraftingSystem.activeStation,
        recipe: recipe.id,
        quantity: CraftingSystem.quantity,
        ingredients: recipe.ingredients
    });
}

function beginCraftingProcess(recipe) {
    CraftingSystem.isCrafting = true;
    CraftingSystem.craftingProgress = 0;

    // Mostrar UI de progreso
    const progressContainer = document.getElementById('crafting-progress');
    progressContainer.classList.remove('hidden');
    document.querySelector('.station-display').style.display = 'none';
    
    document.getElementById('crafting-item-name').textContent = recipe.name;
    
    // Iniciar progreso
    CraftingSystem.craftingInterval = setInterval(() => {
        CraftingSystem.craftingProgress += (100 / (recipe.time / 100));
        
        if (CraftingSystem.craftingProgress >= 100) {
            completeCrafting(recipe);
            return;
        }
        
        updateCraftingProgress(recipe);
    }, 100);

    renderSelectedRecipe();
}

function updateCraftingProgress(recipe) {
    const progressBar = document.getElementById('progress-bar');
    const timeRemaining = document.getElementById('time-remaining');
    
    progressBar.style.width = `${CraftingSystem.craftingProgress}%`;
    
    const remainingTime = formatTime(recipe.time * (1 - CraftingSystem.craftingProgress / 100));
    timeRemaining.textContent = `${remainingTime}s`;
}

function completeCrafting(recipe) {
    clearInterval(CraftingSystem.craftingInterval);
    CraftingSystem.isCrafting = false;
    CraftingSystem.craftingProgress = 0;

    // Ocultar progreso
    document.getElementById('crafting-progress').classList.add('hidden');
    document.querySelector('.station-display').style.display = 'flex';

    // Notificación
    showNotification(`¡${recipe.name} creado exitosamente!`, 'success');

    // Enviar al servidor que se completó
    postToNUI('completeCrafting', {
        station: CraftingSystem.activeStation,
        recipe: recipe.id,
        quantity: CraftingSystem.quantity,
        result: recipe.result
    });

    renderSelectedRecipe();
}

function cancelCrafting() {
    if (!CraftingSystem.isCrafting) return;

    clearInterval(CraftingSystem.craftingInterval);
    CraftingSystem.isCrafting = false;
    CraftingSystem.craftingProgress = 0;

    document.getElementById('crafting-progress').classList.add('hidden');
    document.querySelector('.station-display').style.display = 'flex';
    
    postToNUI('cancelCrafting', {});
    renderSelectedRecipe();
}

// ===== FUNCIONES DE INVENTARIO (AGREGAR/QUITAR ITEMS) =====
function addItemToInventory(itemName, quantity) {
    CraftingSystem.inventory[itemName] = (CraftingSystem.inventory[itemName] || 0) + quantity;
    renderInventory();
    renderSelectedRecipe(); // Re-render para actualizar disponibilidad
}

function removeItemFromInventory(itemName, quantity) {
    if (CraftingSystem.inventory[itemName]) {
        CraftingSystem.inventory[itemName] = Math.max(0, CraftingSystem.inventory[itemName] - quantity);
        if (CraftingSystem.inventory[itemName] === 0) {
            delete CraftingSystem.inventory[itemName];
        }
    }
    renderInventory();
    renderSelectedRecipe(); // Re-render para actualizar disponibilidad
}

function updateInventoryFromServer(inventory) {
    CraftingSystem.inventory = inventory;
    renderInventory();
    renderSelectedRecipe();
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

    updateStationDisplay();
    renderStationTabs();
    renderRecipes();
    renderSelectedRecipe();
    renderInventory();

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

    // Reset state
    CraftingSystem.selectedRecipe = null;
    CraftingSystem.quantity = 1;

    postToNUI('closeCrafting', {});
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
            updateInventoryFromServer(data.inventory);
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

        case 'addItem':
            addItemToInventory(data.item, data.quantity);
            showNotification(`+${data.quantity} ${getItemDisplayName(data.item)}`, 'success');
            break;

        case 'removeItem':
            removeItemFromInventory(data.item, data.quantity);
            showNotification(`-${data.quantity} ${getItemDisplayName(data.item)}`, 'error');
            break;
    }
});

// ===== FUNCIONES GLOBALES =====
window.startCrafting = startCrafting;
window.selectStation = selectStation;
window.selectRecipe = selectRecipe;
window.changeQuantity = changeQuantity;
window.clearSelection = clearSelection;
window.cancelCrafting = cancelCrafting;
