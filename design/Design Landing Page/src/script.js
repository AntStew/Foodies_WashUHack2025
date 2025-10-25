/* ========================================
   WHAT'S FOR DINNER? - JAVASCRIPT
   Interactive functionality for the web app
   ======================================== */

/* ========================================
   GLOBAL STATE & VARIABLES
   ======================================== */

// Current active page
let currentPage = 'landing';

// Onboarding data
let onboardingData = {
    cookingSkill: '',
    dietaryPreferences: [],
    availableTime: '',
    allergies: []
};

// Current onboarding step
let currentStep = 1;

// Onboarding questions configuration
const onboardingQuestions = [
    {
        step: 1,
        icon: '👨‍🍳',
        title: "What's your cooking skill level?",
        subtitle: "Help us match recipes to your experience",
        background: 'https://images.unsplash.com/photo-1518291344630-4857135fb581?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
        type: 'grid',
        field: 'cookingSkill',
        options: [
            { value: 'beginner', emoji: '🌱', title: 'Beginner', desc: "I'm just starting my cooking journey" },
            { value: 'intermediate', emoji: '👨‍🍳', title: 'Intermediate', desc: "I'm comfortable with basic techniques" },
            { value: 'advanced', emoji: '⭐', title: 'Advanced', desc: 'I love experimenting with complex recipes' },
            { value: 'professional', emoji: '🎓', title: 'Professional', desc: 'I have culinary training or work in food' }
        ]
    },
    {
        step: 2,
        icon: '❤️',
        title: "Any dietary preferences?",
        subtitle: "We'll personalize your recipe suggestions",
        background: 'https://images.unsplash.com/photo-1700150618387-3f46b6d2cf8e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
        type: 'list',
        field: 'dietaryPreferences',
        multiple: true,
        options: [
            { value: 'none', emoji: '🍽️', title: 'No Restrictions', desc: 'I eat everything' },
            { value: 'vegetarian', emoji: '🥗', title: 'Vegetarian', desc: 'No meat or fish' },
            { value: 'vegan', emoji: '🌿', title: 'Vegan', desc: 'No animal products' },
            { value: 'gluten-free', emoji: '🌾', title: 'Gluten-Free', desc: 'No wheat or gluten' },
            { value: 'keto', emoji: '🥩', title: 'Keto/Low-Carb', desc: 'High protein, low carbs' },
            { value: 'custom', emoji: '🥜', title: 'Custom', desc: 'Let me specify my needs' }
        ]
    },
    {
        step: 3,
        icon: '⏰',
        title: "How much time do you usually have to cook?",
        subtitle: "We'll match recipes to your schedule",
        background: 'https://images.unsplash.com/photo-1668822434552-13a5ba2aa3e1?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
        type: 'grid',
        field: 'availableTime',
        options: [
            { value: 'quick', emoji: '⚡', title: 'Quick', subtitle: '15-20 min', desc: 'Fast weeknight meals' },
            { value: 'moderate', emoji: '🕐', title: 'Moderate', subtitle: '30-45 min', desc: 'Balanced cooking time' },
            { value: 'relaxed', emoji: '🍷', title: 'Relaxed', subtitle: '1+ hour', desc: 'Cooking is my therapy' }
        ]
    },
    {
        step: 4,
        icon: '⚠️',
        title: "Any ingredients you can't eat?",
        subtitle: "Your safety is our top priority",
        background: 'https://images.unsplash.com/photo-1705079825720-af4a62abb820?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
        type: 'grid',
        field: 'allergies',
        multiple: true,
        options: [
            { value: 'none', emoji: '✅', title: 'No Allergies', desc: "I'm all good" },
            { value: 'nuts', emoji: '🥜', title: 'Tree Nuts/Peanuts', desc: 'Includes almond, cashew, etc.' },
            { value: 'dairy', emoji: '🥛', title: 'Dairy', desc: 'Milk, cheese, butter' },
            { value: 'shellfish', emoji: '🦐', title: 'Shellfish', desc: 'Shrimp, crab, lobster' },
            { value: 'eggs', emoji: '🥚', title: 'Eggs', desc: 'Eggs and egg products' },
            { value: 'other', emoji: '🌶️', title: 'Other', desc: 'Let me specify' }
        ]
    }
];

// Mock recipe data
const mockRecipes = [
    {
        id: 1,
        title: 'Creamy Mushroom Pasta',
        image: 'https://images.unsplash.com/photo-1722938687772-62a0dbfacc25?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
        matchPercentage: 95,
        cookTime: 25,
        servings: 4,
        difficulty: 'Easy',
        ingredients: ['Pasta', 'Mushrooms', 'Cream', 'Garlic', 'Parmesan'],
        missingIngredients: ['Fresh Parsley']
    },
    {
        id: 2,
        title: 'Rainbow Buddha Bowl',
        image: 'https://images.unsplash.com/photo-1643750182373-b4a55a8c2801?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
        matchPercentage: 88,
        cookTime: 20,
        servings: 2,
        difficulty: 'Easy',
        ingredients: ['Quinoa', 'Chickpeas', 'Avocado', 'Cherry Tomatoes', 'Spinach'],
        missingIngredients: ['Tahini']
    },
    {
        id: 3,
        title: 'Vegetable Stir Fry',
        image: 'https://images.unsplash.com/photo-1599297915779-0dadbd376d49?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
        matchPercentage: 92,
        cookTime: 15,
        servings: 3,
        difficulty: 'Easy',
        ingredients: ['Bell Peppers', 'Broccoli', 'Carrots', 'Soy Sauce', 'Ginger'],
        missingIngredients: []
    },
    {
        id: 4,
        title: 'Classic Breakfast Plate',
        image: 'https://images.unsplash.com/photo-1645802733740-50f48729d151?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
        matchPercentage: 100,
        cookTime: 10,
        servings: 1,
        difficulty: 'Beginner',
        ingredients: ['Eggs', 'Bread', 'Butter', 'Salt', 'Pepper'],
        missingIngredients: []
    },
    {
        id: 5,
        title: 'Hearty Vegetable Soup',
        image: 'https://images.unsplash.com/photo-1665088127661-83aeff6104c4?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
        matchPercentage: 85,
        cookTime: 35,
        servings: 6,
        difficulty: 'Medium',
        ingredients: ['Potatoes', 'Carrots', 'Celery', 'Onions', 'Vegetable Stock'],
        missingIngredients: ['Bay Leaves', 'Thyme']
    },
    {
        id: 6,
        title: 'Savory Omelet',
        image: 'https://images.unsplash.com/photo-1640409084317-ada21bc20d14?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
        matchPercentage: 97,
        cookTime: 12,
        servings: 2,
        difficulty: 'Easy',
        ingredients: ['Eggs', 'Bell Peppers', 'Onions', 'Cheese', 'Milk'],
        missingIngredients: []
    }
];

/* ========================================
   PAGE NAVIGATION
   ======================================== */

/**
 * Navigate to a specific page
 * @param {string} pageName - Name of the page to navigate to
 */
function navigateTo(pageName) {
    // Hide all pages
    const pages = document.querySelectorAll('.page');
    pages.forEach(page => page.classList.remove('active'));
    
    // Show the target page
    const targetPage = document.getElementById(`${pageName}-page`);
    if (targetPage) {
        targetPage.classList.add('active');
        currentPage = pageName;
        
        // Initialize page-specific functionality
        if (pageName === 'onboarding') {
            initializeOnboarding();
        } else if (pageName === 'recipes') {
            renderRecipes();
        }
        
        // Scroll to top
        window.scrollTo(0, 0);
    }
}

/* ========================================
   AUTH FORMS (SIGNUP/LOGIN)
   ======================================== */

/**
 * Handle signup form submission
 * @param {Event} event - Form submit event
 */
function handleSignup(event) {
    event.preventDefault();
    
    // Get form values
    const name = document.getElementById('signup-name').value;
    const email = document.getElementById('signup-email').value;
    const password = document.getElementById('signup-password').value;
    const confirmPassword = document.getElementById('signup-confirm').value;
    
    // Validate passwords match
    if (password !== confirmPassword) {
        alert('Passwords do not match!');
        return;
    }
    
    // In a real app, you would send this data to your backend
    console.log('Signup data:', { name, email, password });
    
    // Navigate to onboarding
    navigateTo('onboarding');
}

/**
 * Handle login form submission
 * @param {Event} event - Form submit event
 */
function handleLogin(event) {
    event.preventDefault();
    
    // Get form values
    const email = document.getElementById('login-email').value;
    const password = document.getElementById('login-password').value;
    
    // In a real app, you would validate credentials with your backend
    console.log('Login data:', { email, password });
    
    // Navigate to recipes page
    navigateTo('recipes');
}

/* ========================================
   ONBOARDING QUESTIONNAIRE
   ======================================== */

/**
 * Initialize the onboarding flow
 */
function initializeOnboarding() {
    currentStep = 1;
    onboardingData = {
        cookingSkill: '',
        dietaryPreferences: [],
        availableTime: '',
        allergies: []
    };
    renderQuestion();
}

/**
 * Render the current question
 */
function renderQuestion() {
    const question = onboardingQuestions[currentStep - 1];
    const container = document.getElementById('question-container');
    
    // Update background
    const bg = document.getElementById('onboarding-bg');
    bg.innerHTML = `<img src="${question.background}" alt="Background">`;
    
    // Update progress
    document.getElementById('current-step').textContent = currentStep;
    document.getElementById('progress-percent').textContent = `${(currentStep / 4) * 100}%`;
    
    // Update segment indicators
    const segments = document.querySelectorAll('.segment');
    segments.forEach((segment, index) => {
        if (index < currentStep) {
            segment.classList.add('active');
        } else {
            segment.classList.remove('active');
        }
    });
    
    // Render question content
    let html = `
        <div class="question">
            <div class="question-icon">${question.icon}</div>
            <h2>${question.title}</h2>
            <p>${question.subtitle}</p>
        </div>
    `;
    
    // Render options based on type
    if (question.type === 'grid') {
        html += '<div class="options-grid">';
        question.options.forEach(option => {
            const isSelected = question.multiple 
                ? onboardingData[question.field].includes(option.value)
                : onboardingData[question.field] === option.value;
            
            html += `
                <div class="option-card ${isSelected ? 'selected' : ''}" 
                     onclick="selectOption('${question.field}', '${option.value}', ${question.multiple})">
                    <div class="option-emoji">${option.emoji}</div>
                    <div class="option-title">${option.title}</div>
                    ${option.subtitle ? `<div class="option-time">${option.subtitle}</div>` : ''}
                    <div class="option-desc">${option.desc}</div>
                </div>
            `;
        });
        html += '</div>';
    } else if (question.type === 'list') {
        html += '<div class="options-list">';
        question.options.forEach(option => {
            const isSelected = question.multiple 
                ? onboardingData[question.field].includes(option.value)
                : onboardingData[question.field] === option.value;
            
            html += `
                <div class="option-list-item ${isSelected ? 'selected' : ''}" 
                     onclick="selectOption('${question.field}', '${option.value}', ${question.multiple})">
                    <div class="option-list-emoji">${option.emoji}</div>
                    <div class="option-list-content">
                        <div class="option-title">${option.title}</div>
                        <div class="option-desc">${option.desc}</div>
                    </div>
                </div>
            `;
            
            // Add custom input for "Other" option
            if (option.value === 'other' && isSelected) {
                html += `
                    <input type="text" 
                           class="custom-input" 
                           placeholder="Please specify your allergies..."
                           onclick="event.stopPropagation()">
                `;
            }
        });
        html += '</div>';
    }
    
    container.innerHTML = html;
    
    // Update navigation buttons
    updateNavigation();
}

/**
 * Select an option in the questionnaire
 * @param {string} field - The data field to update
 * @param {string} value - The selected value
 * @param {boolean} multiple - Whether multiple selections are allowed
 */
function selectOption(field, value, multiple) {
    if (multiple) {
        // Handle multiple selections
        const currentValues = onboardingData[field];
        
        // Special handling for "none" options
        if (value === 'none') {
            onboardingData[field] = ['none'];
            showFeedback('Great! You have lots of options! 🎉');
        } else {
            // Remove "none" if it was selected
            const filtered = currentValues.filter(v => v !== 'none');
            
            // Toggle the selection
            if (filtered.includes(value)) {
                onboardingData[field] = filtered.filter(v => v !== value);
            } else {
                onboardingData[field] = [...filtered, value];
            }
            showFeedback('Nice choice! 👍');
        }
    } else {
        // Single selection
        onboardingData[field] = value;
        showFeedback('Great choice! 🎯');
    }
    
    // Re-render to update selected state
    renderQuestion();
}

/**
 * Show feedback message
 * @param {string} message - Feedback message to display
 */
function showFeedback(message) {
    const feedbackEl = document.getElementById('feedback-message');
    feedbackEl.textContent = message;
    feedbackEl.classList.add('show');
    
    setTimeout(() => {
        feedbackEl.classList.remove('show');
    }, 2000);
}

/**
 * Update navigation button states
 */
function updateNavigation() {
    const backBtn = document.getElementById('back-btn');
    const nextBtn = document.getElementById('next-btn');
    
    // Back button
    backBtn.disabled = currentStep === 1;
    
    // Next button - check if current step has a valid selection
    const question = onboardingQuestions[currentStep - 1];
    const hasSelection = question.multiple 
        ? onboardingData[question.field].length > 0
        : onboardingData[question.field] !== '';
    
    // For optional questions (dietary and allergies), always enable next
    const isOptional = question.field === 'dietaryPreferences' || question.field === 'allergies';
    nextBtn.disabled = !hasSelection && !isOptional;
    
    // Update button text for last step
    if (currentStep === 4) {
        nextBtn.innerHTML = '🍳 Start Finding Recipes';
    } else {
        nextBtn.innerHTML = 'Next →';
    }
}

/**
 * Go to the next step
 */
function nextStep() {
    if (currentStep < 4) {
        currentStep++;
        renderQuestion();
    } else {
        // Show success screen
        showSuccessScreen();
    }
}

/**
 * Go to the previous step
 */
function previousStep() {
    if (currentStep > 1) {
        currentStep--;
        renderQuestion();
    }
}

/**
 * Show success screen and navigate to recipes
 */
function showSuccessScreen() {
    const successScreen = document.getElementById('success-screen');
    successScreen.classList.remove('hidden');
    
    // Navigate to recipes after 2.5 seconds
    setTimeout(() => {
        successScreen.classList.add('hidden');
        navigateTo('recipes');
    }, 2500);
}

/* ========================================
   RECIPES PAGE
   ======================================== */

/**
 * Render recipe cards on the recipes page
 */
function renderRecipes() {
    const grid = document.getElementById('recipes-grid');
    
    let html = '';
    mockRecipes.forEach((recipe, index) => {
        const matchClass = recipe.matchPercentage >= 90 ? 'match-high' : 'match-medium';
        
        html += `
            <div class="recipe-card" style="animation: fadeIn 0.4s ease ${index * 0.1}s forwards; opacity: 0;">
                <div class="recipe-image">
                    <img src="${recipe.image}" alt="${recipe.title}">
                    <div class="match-badge ${matchClass}">
                        <span>📈</span>
                        ${recipe.matchPercentage}% Match
                    </div>
                </div>
                
                <div class="recipe-info">
                    <h3 class="recipe-title">${recipe.title}</h3>
                    
                    <div class="recipe-meta">
                        <span>⏱️ ${recipe.cookTime} min</span>
                        <span>👥 ${recipe.servings} servings</span>
                    </div>
                    
                    <div class="difficulty-badge">${recipe.difficulty}</div>
                    
                    <div class="ingredients-section">
                        <p>You have:</p>
                        <div class="ingredient-tags">
                            ${recipe.ingredients.slice(0, 3).map(ing => 
                                `<span class="ingredient-tag has-ingredient">${ing}</span>`
                            ).join('')}
                            ${recipe.ingredients.length > 3 ? 
                                `<span class="ingredient-tag more-ingredients">+${recipe.ingredients.length - 3} more</span>` 
                                : ''}
                        </div>
                    </div>
                    
                    ${recipe.missingIngredients.length > 0 ? `
                        <div class="ingredients-section">
                            <p>You'll need:</p>
                            <div class="ingredient-tags">
                                ${recipe.missingIngredients.map(ing => 
                                    `<span class="ingredient-tag missing-ingredient">${ing}</span>`
                                ).join('')}
                            </div>
                        </div>
                    ` : `
                        <div class="perfect-match">
                            ✨ Perfect Match - All ingredients available!
                        </div>
                    `}
                    
                    <button class="btn btn-primary btn-full">
                        View Recipe
                    </button>
                </div>
            </div>
        `;
    });
    
    grid.innerHTML = html;
}

/* ========================================
   INITIALIZATION
   ======================================== */

/**
 * Initialize the app when the DOM is ready
 */
document.addEventListener('DOMContentLoaded', function() {
    console.log('What\'s For Dinner? app loaded! 👨‍🍳');
    
    // Set initial page
    navigateTo('landing');
});
