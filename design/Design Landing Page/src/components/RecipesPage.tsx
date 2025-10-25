import { motion } from 'motion/react';
import { Camera, ChefHat, Clock, Users, TrendingUp, Sparkles, LogOut } from 'lucide-react';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { ImageWithFallback } from './figma/ImageWithFallback';

interface RecipesPageProps {
  onNavigate: (page: string) => void;
}

const mockRecipes = [
  {
    id: 1,
    title: 'Creamy Mushroom Pasta',
    image: 'https://images.unsplash.com/photo-1722938687772-62a0dbfacc25?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxwYXN0YSUyMGRpc2glMjBmb29kfGVufDF8fHx8MTc2MTQwNjMxNXww&ixlib=rb-4.1.0&q=80&w=1080',
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
    image: 'https://images.unsplash.com/photo-1643750182373-b4a55a8c2801?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxoZWFsdGh5JTIwc2FsYWQlMjBib3dsfGVufDF8fHx8MTc2MTM3MzM2N3ww&ixlib=rb-4.1.0&q=80&w=1080',
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
    image: 'https://images.unsplash.com/photo-1599297915779-0dadbd376d49?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxzdGlyJTIwZnJ5JTIwdmVnZXRhYmxlc3xlbnwxfHx8fDE3NjEzOTc5NDV8MA&ixlib=rb-4.1.0&q=80&w=1080',
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
    image: 'https://images.unsplash.com/photo-1645802733740-50f48729d151?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxicmVha2Zhc3QlMjBlZ2dzJTIwdG9hc3R8ZW58MXx8fHwxNzYxMzA2MDQ2fDA&ixlib=rb-4.1.0&q=80&w=1080',
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
    image: 'https://images.unsplash.com/photo-1665088127661-83aeff6104c4?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmcmVzaCUyMHZlZ2V0YWJsZXMlMjBpbmdyZWRpZW50c3xlbnwxfHx8fDE3NjEzOTg3OTV8MA&ixlib=rb-4.1.0&q=80&w=1080',
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
    image: 'https://images.unsplash.com/photo-1640409084317-ada21bc20d14?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjb29raW5nJTIwb21lbGV0JTIwdmVnZXRhYmxlc3xlbnwxfHx8fDE3NjE0MTk4MzJ8MA&ixlib=rb-4.1.0&q=80&w=1080',
    matchPercentage: 97,
    cookTime: 12,
    servings: 2,
    difficulty: 'Easy',
    ingredients: ['Eggs', 'Bell Peppers', 'Onions', 'Cheese', 'Milk'],
    missingIngredients: []
  }
];

export function RecipesPage({ onNavigate }: RecipesPageProps) {
  return (
    <div className="min-h-screen bg-[#FFF8DC]">
      {/* Header */}
      <header className="bg-white shadow-sm sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-8 py-4 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <ChefHat size={32} className="text-[#E74C3C]" />
            <h1 className="text-[#2C3E50]" style={{ fontFamily: 'Poppins, sans-serif', fontSize: '1.5rem' }}>
              What's For Dinner?
            </h1>
          </div>
          <div className="flex items-center gap-4">
            <Button
              variant="outline"
              className="border-2 border-[#E74C3C] text-[#E74C3C] hover:bg-[#E74C3C] hover:text-white"
              style={{ borderRadius: '20px' }}
            >
              <Camera className="mr-2" size={20} />
              Scan Fridge
            </Button>
            <Button
              onClick={() => onNavigate('landing')}
              variant="ghost"
              className="text-[#2C3E50] hover:text-[#E74C3C]"
            >
              <LogOut size={20} />
            </Button>
          </div>
        </div>
      </header>

      {/* Hero Banner */}
      <section className="bg-gradient-to-r from-[#E74C3C] to-[#F39C12] text-white py-12 px-8">
        <div className="max-w-7xl mx-auto">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6 }}
          >
            <div className="flex items-center gap-2 mb-4">
              <Sparkles size={24} />
              <span style={{ fontSize: '1.125rem' }}>AI-Powered Recommendations</span>
            </div>
            <h2 className="mb-4" style={{ fontFamily: 'Poppins, sans-serif', fontSize: '2.5rem' }}>
              Your Personalized Recipes
            </h2>
            <p className="max-w-2xl" style={{ fontSize: '1.125rem' }}>
              Based on your ingredients and preferences, we found <span style={{ fontFamily: 'Poppins, sans-serif' }}>6 delicious recipes</span> you can make right now!
            </p>
          </motion.div>
        </div>
      </section>

      {/* Recipes Grid */}
      <section className="max-w-7xl mx-auto px-8 py-12">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {mockRecipes.map((recipe, index) => (
            <motion.div
              key={recipe.id}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.4, delay: index * 0.1 }}
              whileHover={{ y: -8, transition: { duration: 0.2 } }}
              className="bg-white rounded-2xl shadow-lg overflow-hidden cursor-pointer"
            >
              {/* Recipe Image */}
              <div className="relative h-56 overflow-hidden">
                <ImageWithFallback
                  src={recipe.image}
                  alt={recipe.title}
                  className="w-full h-full object-cover"
                />
                {/* Match Badge */}
                <div className="absolute top-4 right-4">
                  <Badge
                    className="px-3 py-1 text-white border-0"
                    style={{
                      background: recipe.matchPercentage >= 90
                        ? 'linear-gradient(135deg, #27AE60, #2ECC71)'
                        : 'linear-gradient(135deg, #F39C12, #E67E22)',
                      fontSize: '0.875rem'
                    }}
                  >
                    <TrendingUp size={14} className="mr-1" />
                    {recipe.matchPercentage}% Match
                  </Badge>
                </div>
              </div>

              {/* Recipe Info */}
              <div className="p-6">
                <h3 className="text-[#2C3E50] mb-3" style={{ fontFamily: 'Poppins, sans-serif', fontSize: '1.25rem' }}>
                  {recipe.title}
                </h3>

                {/* Meta Info */}
                <div className="flex gap-4 mb-4 text-[#2C3E50]/70">
                  <div className="flex items-center gap-1">
                    <Clock size={16} />
                    <span>{recipe.cookTime} min</span>
                  </div>
                  <div className="flex items-center gap-1">
                    <Users size={16} />
                    <span>{recipe.servings} servings</span>
                  </div>
                </div>

                {/* Difficulty Badge */}
                <div className="mb-4">
                  <Badge variant="outline" className="border-[#27AE60] text-[#27AE60]">
                    {recipe.difficulty}
                  </Badge>
                </div>

                {/* Ingredients */}
                <div className="mb-4">
                  <p className="text-[#2C3E50]/70 mb-2">You have:</p>
                  <div className="flex flex-wrap gap-2">
                    {recipe.ingredients.slice(0, 3).map((ingredient, i) => (
                      <span
                        key={i}
                        className="px-2 py-1 bg-[#27AE60]/10 text-[#27AE60] rounded-lg"
                        style={{ fontSize: '0.875rem' }}
                      >
                        {ingredient}
                      </span>
                    ))}
                    {recipe.ingredients.length > 3 && (
                      <span
                        className="px-2 py-1 bg-[#2C3E50]/10 text-[#2C3E50]/70 rounded-lg"
                        style={{ fontSize: '0.875rem' }}
                      >
                        +{recipe.ingredients.length - 3} more
                      </span>
                    )}
                  </div>
                </div>

                {/* Missing Ingredients */}
                {recipe.missingIngredients.length > 0 ? (
                  <div className="mb-4">
                    <p className="text-[#2C3E50]/70 mb-2">You'll need:</p>
                    <div className="flex flex-wrap gap-2">
                      {recipe.missingIngredients.map((ingredient, i) => (
                        <span
                          key={i}
                          className="px-2 py-1 bg-[#E74C3C]/10 text-[#E74C3C] rounded-lg"
                          style={{ fontSize: '0.875rem' }}
                        >
                          {ingredient}
                        </span>
                      ))}
                    </div>
                  </div>
                ) : (
                  <div className="mb-4">
                    <Badge className="bg-[#27AE60] text-white border-0">
                      ✨ Perfect Match - All ingredients available!
                    </Badge>
                  </div>
                )}

                {/* Action Button */}
                <Button
                  className="w-full py-5 bg-gradient-to-r from-[#F39C12] to-[#E74C3C] hover:from-[#E67E22] hover:to-[#C0392B] border-0"
                  style={{ borderRadius: '12px' }}
                >
                  View Recipe
                </Button>
              </div>
            </motion.div>
          ))}
        </div>
      </section>

      {/* CTA Section */}
      <section className="bg-white py-16 px-8 mt-12">
        <div className="max-w-4xl mx-auto text-center">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6 }}
            viewport={{ once: true }}
          >
            <Camera size={60} className="text-[#E74C3C] mx-auto mb-6" />
            <h2 className="text-[#2C3E50] mb-4" style={{ fontFamily: 'Poppins, sans-serif', fontSize: '2rem' }}>
              Got More Ingredients?
            </h2>
            <p className="text-[#2C3E50]/70 mb-8" style={{ fontSize: '1.125rem' }}>
              Scan your fridge again to discover even more recipe possibilities!
            </p>
            <Button
              className="px-8 py-6 bg-gradient-to-r from-[#F39C12] to-[#E74C3C] hover:from-[#E67E22] hover:to-[#C0392B] border-0"
              style={{ borderRadius: '40px', fontSize: '1.125rem' }}
            >
              <Camera className="mr-2" size={24} />
              Scan Again
            </Button>
          </motion.div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-gradient-to-r from-[#2C3E50] to-[#34495E] text-white py-8 px-8 mt-12">
        <div className="max-w-7xl mx-auto text-center">
          <p className="text-white/80">
            © 2025 What's For Dinner? | Made with ❤️ at WashU Hackathon.
          </p>
        </div>
      </footer>
    </div>
  );
}
