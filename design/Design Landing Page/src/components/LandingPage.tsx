import { motion } from 'motion/react';
import { Camera, Bot, Recycle, ChefHat } from 'lucide-react';
import { Button } from './ui/button';
import { ImageWithFallback } from './figma/ImageWithFallback';

interface LandingPageProps {
  onNavigate: (page: string) => void;
}

export function LandingPage({ onNavigate }: LandingPageProps) {
  return (
    <div className="min-h-screen bg-[#FFF8DC]">
      {/* Hero Section */}
      <section className="relative h-screen overflow-hidden">
        {/* Background Image with Overlay */}
        <div className="absolute inset-0">
          <ImageWithFallback
            src="https://images.unsplash.com/photo-1640409084317-ada21bc20d14?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjb29raW5nJTIwb21lbGV0JTIwdmVnZXRhYmxlc3xlbnwxfHx8fDE3NjE0MTk4MzJ8MA&ixlib=rb-4.1.0&q=80&w=1080"
            alt="Cooking background"
            className="w-full h-full object-cover"
          />
          <div className="absolute inset-0 bg-gradient-to-br from-[#E74C3C]/80 via-[#F39C12]/60 to-[#27AE60]/40" />
        </div>

        {/* Hero Content */}
        <div className="relative z-10 h-full flex flex-col items-center justify-center px-8 text-center">
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8 }}
          >
            <h1 className="text-white mb-6" style={{ fontFamily: 'Poppins, sans-serif', fontSize: '5rem', fontWeight: 800, lineHeight: 1.1 }}>
              What's For Dinner?
            </h1>
          </motion.div>

          <motion.p
            className="text-white/95 mb-12 max-w-2xl"
            style={{ fontSize: '1.5rem' }}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.2 }}
          >
            Turn your fridge chaos into delicious meals — powered by AI.
          </motion.p>

          <motion.div
            className="flex gap-6 flex-wrap justify-center"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.4 }}
          >
            <Button
              onClick={() => onNavigate('signup')}
              className="px-8 py-6 bg-gradient-to-r from-[#F39C12] to-[#E74C3C] hover:from-[#E67E22] hover:to-[#C0392B] border-0"
              style={{ borderRadius: '40px', fontSize: '1.25rem' }}
            >
              <ChefHat className="mr-2" size={24} />
              Start Cooking Smart
            </Button>
            <Button
              onClick={() => onNavigate('login')}
              variant="outline"
              className="px-8 py-6 border-2 border-white text-white hover:bg-white hover:text-[#E74C3C]"
              style={{ borderRadius: '40px', fontSize: '1.25rem' }}
            >
              Already a Chef? Log In
            </Button>
          </motion.div>

          {/* Floating Decorative Elements */}
          <motion.div
            className="absolute top-1/4 left-1/4 opacity-60"
            animate={{ y: [0, -20, 0], rotate: [0, 10, 0] }}
            transition={{ duration: 4, repeat: Infinity, ease: "easeInOut" }}
          >
            <div className="w-24 h-24 bg-[#E74C3C] rounded-full blur-2xl" />
          </motion.div>
          <motion.div
            className="absolute bottom-1/3 right-1/4 opacity-60"
            animate={{ y: [0, 20, 0], rotate: [0, -10, 0] }}
            transition={{ duration: 5, repeat: Infinity, ease: "easeInOut", delay: 1 }}
          >
            <div className="w-32 h-32 bg-[#F39C12] rounded-full blur-2xl" />
          </motion.div>
        </div>
      </section>

      {/* Feature Section */}
      <section className="py-20 px-8">
        <div className="max-w-6xl mx-auto">
          <motion.div
            className="grid grid-cols-1 md:grid-cols-3 gap-8"
            initial={{ opacity: 0, y: 40 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6 }}
            viewport={{ once: true }}
          >
            {/* Feature Card 1 */}
            <motion.div
              className="bg-white p-8 rounded-3xl shadow-lg text-center"
              whileHover={{ y: -8, transition: { duration: 0.2 } }}
            >
              <div className="w-20 h-20 mx-auto mb-6 bg-gradient-to-br from-[#E74C3C] to-[#F39C12] rounded-2xl flex items-center justify-center">
                <Camera size={40} className="text-white" />
              </div>
              <h3 className="text-[#2C3E50] mb-4" style={{ fontFamily: 'Poppins, sans-serif' }}>
                📸 Snap Your Fridge
              </h3>
              <p className="text-[#2C3E50]/70">
                Take a photo, let AI do the rest.
              </p>
            </motion.div>

            {/* Feature Card 2 */}
            <motion.div
              className="bg-white p-8 rounded-3xl shadow-lg text-center"
              whileHover={{ y: -8, transition: { duration: 0.2 } }}
            >
              <div className="w-20 h-20 mx-auto mb-6 bg-gradient-to-br from-[#F39C12] to-[#27AE60] rounded-2xl flex items-center justify-center">
                <Bot size={40} className="text-white" />
              </div>
              <h3 className="text-[#2C3E50] mb-4" style={{ fontFamily: 'Poppins, sans-serif' }}>
                🤖 AI-Powered Recipes
              </h3>
              <p className="text-[#2C3E50]/70">
                Instant meal ideas from what's inside.
              </p>
            </motion.div>

            {/* Feature Card 3 */}
            <motion.div
              className="bg-white p-8 rounded-3xl shadow-lg text-center"
              whileHover={{ y: -8, transition: { duration: 0.2 } }}
            >
              <div className="w-20 h-20 mx-auto mb-6 bg-gradient-to-br from-[#27AE60] to-[#E74C3C] rounded-2xl flex items-center justify-center">
                <Recycle size={40} className="text-white" />
              </div>
              <h3 className="text-[#2C3E50] mb-4" style={{ fontFamily: 'Poppins, sans-serif' }}>
                ♻️ Save Food, Save Money
              </h3>
              <p className="text-[#2C3E50]/70">
                Reduce waste and cook smarter.
              </p>
            </motion.div>
          </motion.div>
        </div>
      </section>

      {/* About Section */}
      <section className="py-20 px-8 bg-white">
        <motion.div
          className="max-w-6xl mx-auto grid grid-cols-1 md:grid-cols-2 gap-12 items-center"
          initial={{ opacity: 0 }}
          whileInView={{ opacity: 1 }}
          transition={{ duration: 0.8 }}
          viewport={{ once: true }}
        >
          <div>
            <h2 className="text-[#2C3E50] mb-6" style={{ fontFamily: 'Poppins, sans-serif', fontSize: '2.5rem' }}>
              Built for Real Kitchens, Not Just Recipes.
            </h2>
            <p className="text-[#2C3E50]/80 mb-4" style={{ fontSize: '1.125rem' }}>
              We know the struggle. You open the fridge, stare at random ingredients, and wonder "what can I even make with this?"
            </p>
            <p className="text-[#2C3E50]/80" style={{ fontSize: '1.125rem' }}>
              What's For Dinner? uses advanced AI to analyze your ingredients and suggest personalized recipes that match your cooking skills, dietary needs, and available time. No more food waste, no more dinner stress.
            </p>
          </div>
          <div className="relative h-96 rounded-3xl overflow-hidden shadow-xl">
            <ImageWithFallback
              src="https://images.unsplash.com/photo-1665088127661-83aeff6104c4?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmcmVzaCUyMHZlZ2V0YWJsZXMlMjBpbmdyZWRpZW50c3xlbnwxfHx8fDE3NjEzOTg3OTV8MA&ixlib=rb-4.1.0&q=80&w=1080"
              alt="Fresh ingredients"
              className="w-full h-full object-cover"
            />
          </div>
        </motion.div>
      </section>

      {/* Footer */}
      <footer className="bg-gradient-to-r from-[#2C3E50] to-[#34495E] text-white py-12 px-8">
        <div className="max-w-6xl mx-auto text-center">
          <div className="flex justify-center gap-6 mb-6">
            <a href="https://instagram.com" target="_blank" rel="noopener noreferrer" className="hover:text-[#F39C12] transition-colors">
              <svg className="w-8 h-8" fill="currentColor" viewBox="0 0 24 24">
                <path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zm0-2.163c-3.259 0-3.667.014-4.947.072-4.358.2-6.78 2.618-6.98 6.98-.059 1.281-.073 1.689-.073 4.948 0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98 1.281.058 1.689.072 4.948.072 3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98-1.281-.059-1.69-.073-4.949-.073zm0 5.838c-3.403 0-6.162 2.759-6.162 6.162s2.759 6.163 6.162 6.163 6.162-2.759 6.162-6.163c0-3.403-2.759-6.162-6.162-6.162zm0 10.162c-2.209 0-4-1.79-4-4 0-2.209 1.791-4 4-4s4 1.791 4 4c0 2.21-1.791 4-4 4zm6.406-11.845c-.796 0-1.441.645-1.441 1.44s.645 1.44 1.441 1.44c.795 0 1.439-.645 1.439-1.44s-.644-1.44-1.439-1.44z"/>
              </svg>
            </a>
            <a href="https://github.com" target="_blank" rel="noopener noreferrer" className="hover:text-[#F39C12] transition-colors">
              <svg className="w-8 h-8" fill="currentColor" viewBox="0 0 24 24">
                <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"/>
              </svg>
            </a>
            <a href="https://linkedin.com" target="_blank" rel="noopener noreferrer" className="hover:text-[#F39C12] transition-colors">
              <svg className="w-8 h-8" fill="currentColor" viewBox="0 0 24 24">
                <path d="M19 0h-14c-2.761 0-5 2.239-5 5v14c0 2.761 2.239 5 5 5h14c2.762 0 5-2.239 5-5v-14c0-2.761-2.238-5-5-5zm-11 19h-3v-11h3v11zm-1.5-12.268c-.966 0-1.75-.79-1.75-1.764s.784-1.764 1.75-1.764 1.75.79 1.75 1.764-.783 1.764-1.75 1.764zm13.5 12.268h-3v-5.604c0-3.368-4-3.113-4 0v5.604h-3v-11h3v1.765c1.396-2.586 7-2.777 7 2.476v6.759z"/>
              </svg>
            </a>
          </div>
          <p className="text-white/80">
            © 2025 What's For Dinner? | Made with ❤️ at WashU Hackathon.
          </p>
        </div>
      </footer>
    </div>
  );
}
