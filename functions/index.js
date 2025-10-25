const {onCall, HttpsError} = require("firebase-functions/v2/https");
const {initializeApp} = require("firebase-admin/app");
const {defineSecret} = require("firebase-functions/params");
const OpenAI = require("openai");

// Define the OpenAI API key as a secret
const openaiApiKey = defineSecret("OPENAI_API_KEY");

// Initialize Firebase Admin
initializeApp();

/**
 * Cloud Function to analyze fridge image using OpenAI Vision API
 *
 * @param {Object} data - Request data
 * @param {string} data.imageUrl - Firebase Storage URL of the fridge image
 * @returns {Array} Array of detected items with name, category, quantity, freshness
 */
exports.analyzeFridgeImage = onCall(
  {secrets: [openaiApiKey]},
  async (request) => {
  // Verify authentication
  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "User must be authenticated to analyze fridge images."
    );
  }

  const {imageUrl} = request.data;

  // Validate input
  if (!imageUrl) {
    throw new HttpsError(
      "invalid-argument",
      "The function must be called with imageUrl."
    );
  }

  try {
    // Initialize OpenAI client with the secret
    const openai = new OpenAI({
      apiKey: openaiApiKey.value(),
    });

    const response = await openai.chat.completions.create({
      model: "gpt-4o",
      messages: [
        {
          role: "user",
          content: [
            {
              type: "text",
              text: `Analyze this fridge image and list all visible food items. For each item provide:
1. Name of the item
2. Category (Dairy, Produce, Meat, Seafood, Frozen, Beverages, Condiments, or Other)
3. Estimated quantity (e.g., "2 bottles", "1 carton", "5 apples")
4. Freshness level (fresh, moderate, or expiring)

Format your response as a JSON array like this:
[{"name": "Milk", "category": "Dairy", "quantity": "1 gallon", "freshness": "fresh"}]

Only return the JSON array, nothing else.`,
            },
            {
              type: "image_url",
              image_url: {
                url: imageUrl,
              },
            },
          ],
        },
      ],
      max_tokens: 1000,
    });

    const content = response.choices[0].message.content;

    // Extract JSON from response
    const jsonMatch = content.match(/\[.*\]/s);
    if (jsonMatch) {
      const items = JSON.parse(jsonMatch[0]);
      return {success: true, items};
    }

    throw new HttpsError(
      "internal",
      "Failed to parse OpenAI response"
    );
  } catch (error) {
    console.error("Error analyzing fridge image:", error);
    throw new HttpsError(
      "internal",
      `OpenAI API error: ${error.message}`
    );
  }
});

/**
 * Cloud Function to generate recipe using OpenAI Chat API
 *
 * @param {Object} data - Request data
 * @param {Array<string>} data.ingredients - List of available ingredients
 * @param {Array<string>} data.dietaryRestrictions - User's dietary restrictions
 * @param {Array<string>} data.cuisinePreferences - User's cuisine preferences
 * @param {number} data.servings - Number of servings
 * @returns {Object} Recipe object with title, description, ingredients, instructions, etc.
 */
exports.generateRecipe = onCall(
  {secrets: [openaiApiKey]},
  async (request) => {
  // Verify authentication
  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "User must be authenticated to generate recipes."
    );
  }

  const {
    ingredients,
    dietaryRestrictions = [],
    cuisinePreferences = [],
    servings = 2,
  } = request.data;

  // Validate input
  if (!ingredients || !Array.isArray(ingredients) || ingredients.length === 0) {
    throw new HttpsError(
      "invalid-argument",
      "The function must be called with a non-empty ingredients array."
    );
  }

  try {
    // Initialize OpenAI client with the secret
    const openai = new OpenAI({
      apiKey: openaiApiKey.value(),
    });

    const dietaryText = dietaryRestrictions.length > 0
      ? `\nDietary restrictions: ${dietaryRestrictions.join(", ")}`
      : "";

    const cuisineText = cuisinePreferences.length > 0
      ? `\nPreferred cuisines: ${cuisinePreferences.join(", ")}`
      : "";

    const response = await openai.chat.completions.create({
      model: "gpt-4o",
      messages: [
        {
          role: "system",
          content: "You are a helpful chef assistant that creates recipes based on available ingredients.",
        },
        {
          role: "user",
          content: `Create a recipe using these ingredients: ${ingredients.join(", ")}${dietaryText}${cuisineText}
Servings: ${servings}

Provide the recipe in this JSON format:
{
  "title": "Recipe Name",
  "description": "Brief description",
  "cuisine": "Cuisine type",
  "prepTime": "15 minutes",
  "cookTime": "30 minutes",
  "servings": ${servings},
  "ingredients": ["ingredient 1", "ingredient 2"],
  "instructions": ["step 1", "step 2"],
  "usedIngredients": ["ingredients from fridge that were used"]
}

Only return the JSON object, nothing else.`,
        },
      ],
      max_tokens: 1500,
    });

    const content = response.choices[0].message.content;

    // Extract JSON from response
    const jsonMatch = content.match(/\{.*\}/s);
    if (jsonMatch) {
      const recipe = JSON.parse(jsonMatch[0]);
      return {success: true, recipe};
    }

    throw new HttpsError(
      "internal",
      "Failed to parse OpenAI response"
    );
  } catch (error) {
    console.error("Error generating recipe:", error);
    throw new HttpsError(
      "internal",
      `OpenAI API error: ${error.message}`
    );
  }
});
