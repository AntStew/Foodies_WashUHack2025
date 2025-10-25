import { useState } from "react";
import { Button } from "./components/ui/button";
import { Card, CardContent } from "./components/ui/card";
import { Camera, Sparkles, Recycle, ChefHat } from "lucide-react";
import Questionnaire from "./components/Questionnaire";

type View = "landing" | "questionnaire" | "dashboard";

export default function App() {
  const [currentView, setCurrentView] = useState<View>("landing");
  const [userAnswers, setUserAnswers] = useState(null);

  const handleQuestionnaireComplete = (answers: any) => {
    setUserAnswers(answers);
    setCurrentView("dashboard");
  };

  // Show questionnaire view
  if (currentView === "questionnaire") {
    return <Questionnaire onComplete={handleQuestionnaireComplete} />;
  }

  // Show dashboard/success view
  if (currentView === "dashboard") {
    return (
      <div className="min-h-screen bg-[#FFF8DC] flex items-center justify-center p-8">
        <div className="max-w-2xl text-center space-y-6">
          <div className="w-20 h-20 mx-auto rounded-full bg-gradient-to-br from-[#E74C3C] to-[#E67E22] flex items-center justify-center shadow-lg">
            <ChefHat className="w-10 h-10 text-white" />
          </div>
          <h1 className="text-5xl text-[#2C3E50]">Welcome to Your Kitchen!</h1>
          <p className="text-xl text-[#2C3E50]/70">
            Your personalized cooking experience is ready. Let's start creating amazing meals!
          </p>
          <Button
            size="lg"
            className="h-16 px-12 bg-gradient-to-r from-[#E74C3C] to-[#E67E22] hover:from-[#E74C3C]/90 hover:to-[#E67E22]/90 text-white shadow-lg"
            onClick={() => setCurrentView("landing")}
          >
            <span className="text-xl">📸 Scan My Fridge</span>
          </Button>
        </div>
      </div>
    );
  }

  // Landing page view
  return (
    <div className="min-h-screen bg-[#FFF8DC]">
      {/* Hero Section */}
      <section className="relative min-h-[900px] overflow-hidden">
        {/* Background Image with Overlay */}
        <div 
          className="absolute inset-0 bg-cover bg-center"
          style={{
            backgroundImage: `url('https://images.unsplash.com/photo-1614260025937-b4ecb6eb9165?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjb2xvcmZ1bCUyMGZyZXNoJTIwaW5ncmVkaWVudHMlMjB2ZWdldGFibGVzJTIwY29va2luZ3xlbnwxfHx8fDE3NjE0MDY5MDd8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral')`
          }}
        >
          <div className="absolute inset-0 bg-gradient-to-r from-black/60 via-black/40 to-black/20" />
        </div>

        {/* Floating Ingredients - Decorative */}
        <div className="absolute top-20 right-10 opacity-80 animate-[float_6s_ease-in-out_infinite]">
          <div className="w-24 h-24 rounded-full bg-[#E74C3C]/20 blur-2xl" />
        </div>
        <div className="absolute bottom-40 left-20 opacity-60 animate-[float_8s_ease-in-out_infinite]">
          <div className="w-32 h-32 rounded-full bg-[#F39C12]/20 blur-2xl" />
        </div>
        <div className="absolute top-1/3 right-1/4 opacity-70 animate-[float_7s_ease-in-out_infinite_0.5s]">
          <div className="w-20 h-20 rounded-full bg-[#27AE60]/20 blur-2xl" />
        </div>

        {/* Content Container */}
        <div className="relative z-10 max-w-7xl mx-auto px-8 pt-20 pb-32">
          <div className="grid lg:grid-cols-2 gap-16 items-center min-h-[800px]">
            {/* Left Content */}
            <div className="space-y-8">
              {/* Logo/Brand */}
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 rounded-full bg-gradient-to-br from-[#E74C3C] to-[#E67E22] flex items-center justify-center shadow-lg">
                  <ChefHat className="w-6 h-6 text-white" />
                </div>
                <span className="text-white/90 tracking-wider">WHAT'S FOR DINNER?</span>
              </div>

              {/* Main Content Card */}
              <div className="backdrop-blur-md bg-white/95 rounded-3xl p-12 shadow-2xl border border-white/20">
                <div className="space-y-6">
                  <h1 className="text-[#2C3E50]">
                    <span className="block text-6xl mb-2">What's For</span>
                    <span className="block text-6xl bg-gradient-to-r from-[#E74C3C] to-[#E67E22] bg-clip-text text-transparent">
                      Dinner?
                    </span>
                  </h1>
                  
                  <h2 className="text-[#2C3E50] text-2xl">
                    Turn your fridge chaos into delicious meals
                  </h2>
                  
                  <p className="text-[#2C3E50]/70">
                    No more food waste. No more 6pm panic. Just good food.
                  </p>

                  {/* CTA Buttons */}
                  <div className="space-y-4 pt-4">
                    <Button 
                      size="lg"
                      onClick={() => setCurrentView("questionnaire")}
                      className="w-full h-16 bg-gradient-to-r from-[#E74C3C] to-[#E67E22] hover:from-[#E74C3C]/90 hover:to-[#E67E22]/90 text-white shadow-lg hover:shadow-xl transition-all duration-300 hover:scale-105"
                    >
                      <span className="text-xl">🍳 Start Cooking Smart</span>
                    </Button>
                    
                    <Button 
                      variant="outline"
                      size="lg"
                      className="w-full h-16 border-2 border-[#2C3E50] text-[#2C3E50] hover:bg-[#2C3E50] hover:text-white transition-all duration-300"
                    >
                      <span className="text-xl">Already a Chef? Log In</span>
                    </Button>
                  </div>
                </div>
              </div>

              {/* Quick Stats */}
              <div className="grid grid-cols-3 gap-4">
                <div className="backdrop-blur-sm bg-white/80 rounded-xl p-4 text-center shadow-lg">
                  <div className="text-2xl text-[#E74C3C]">12K+</div>
                  <div className="text-xs text-[#2C3E50]/70">Active Users</div>
                </div>
                <div className="backdrop-blur-sm bg-white/80 rounded-xl p-4 text-center shadow-lg">
                  <div className="text-2xl text-[#E67E22]">50K+</div>
                  <div className="text-xs text-[#2C3E50]/70">Recipes</div>
                </div>
                <div className="backdrop-blur-sm bg-white/80 rounded-xl p-4 text-center shadow-lg">
                  <div className="text-2xl text-[#27AE60]">$1.5K</div>
                  <div className="text-xs text-[#2C3E50]/70">Avg. Saved</div>
                </div>
              </div>
            </div>

            {/* Right Side - Hero Image */}
            <div className="relative hidden lg:block">
              <div className="relative rounded-3xl overflow-hidden shadow-2xl transform hover:scale-105 transition-transform duration-500">
                <img 
                  src="https://images.unsplash.com/photo-1736390718073-76ea3393258d?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmcmlkZ2UlMjBkb29yJTIwb3BlbiUyMGZvb2R8ZW58MXx8fHwxNzYxNDA2OTA5fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral"
                  alt="Fresh ingredients"
                  className="w-full h-[600px] object-cover"
                />
                
                {/* Floating UI Element */}
                <div className="absolute top-8 right-8 backdrop-blur-md bg-white/90 rounded-2xl p-4 shadow-xl animate-[float_4s_ease-in-out_infinite]">
                  <div className="flex items-center gap-3">
                    <Sparkles className="w-5 h-5 text-[#F39C12]" />
                    <div>
                      <div className="text-xs text-[#2C3E50]/60">AI Analyzing...</div>
                      <div className="text-[#2C3E50]">23 ingredients found</div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-24 px-8 bg-[#FFF8DC] relative">
        {/* Decorative Sauce Splash Divider */}
        <div className="absolute top-0 left-0 right-0 h-16 overflow-hidden">
          <svg className="w-full h-full" viewBox="0 0 1440 100" preserveAspectRatio="none">
            <path 
              d="M0,0 Q360,50 720,30 T1440,0 L1440,100 L0,100 Z" 
              fill="#FFF8DC"
              opacity="0.5"
            />
          </svg>
        </div>

        <div className="max-w-7xl mx-auto">
          <div className="text-center mb-16">
            <h2 className="text-5xl text-[#2C3E50] mb-4">
              How It Works
            </h2>
            <p className="text-xl text-[#2C3E50]/70">
              Three simple steps to culinary brilliance
            </p>
          </div>

          <div className="grid md:grid-cols-3 gap-8">
            {/* Card 1: Snap Your Fridge */}
            <Card className="group overflow-hidden border-2 border-[#E74C3C]/20 hover:border-[#E74C3C] transition-all duration-300 hover:shadow-2xl hover:scale-105 bg-white">
              <div className="relative h-64 overflow-hidden">
                <img 
                  src="https://images.unsplash.com/photo-1547442693-f6b36564d858?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxwaG9uZSUyMGNhbWVyYSUyMGZvb2QlMjBwaG90b2dyYXBoeXxlbnwxfHx8fDE3NjE0MDY5MDh8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral"
                  alt="Snap your fridge"
                  className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500"
                />
                <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent" />
                <div className="absolute bottom-4 left-4 right-4">
                  <div className="w-12 h-12 rounded-full bg-[#E74C3C] flex items-center justify-center mb-3 shadow-lg">
                    <Camera className="w-6 h-6 text-white" />
                  </div>
                </div>
              </div>
              <CardContent className="p-6">
                <h3 className="text-2xl text-[#2C3E50] mb-3">
                  📸 Snap Your Fridge
                </h3>
                <p className="text-[#2C3E50]/70">
                  Just take a photo. Our AI does the rest. No typing, no lists, no hassle.
                </p>
              </CardContent>
            </Card>

            {/* Card 2: Instant Recipe Magic */}
            <Card className="group overflow-hidden border-2 border-[#F39C12]/20 hover:border-[#F39C12] transition-all duration-300 hover:shadow-2xl hover:scale-105 bg-white">
              <div className="relative h-64 overflow-hidden">
                <img 
                  src="https://images.unsplash.com/photo-1707268912404-0111b9090031?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxyZWNpcGUlMjBjYXJkcyUyMGtpdGNoZW58ZW58MXx8fHwxNzYxNDA2OTA4fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral"
                  alt="Recipe magic"
                  className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500"
                />
                <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent" />
                <div className="absolute bottom-4 left-4 right-4">
                  <div className="w-12 h-12 rounded-full bg-[#F39C12] flex items-center justify-center mb-3 shadow-lg">
                    <Sparkles className="w-6 h-6 text-white" />
                  </div>
                </div>
              </div>
              <CardContent className="p-6">
                <h3 className="text-2xl text-[#2C3E50] mb-3">
                  🤖 Instant Recipe Magic
                </h3>
                <p className="text-[#2C3E50]/70">
                  Get personalized recipes in seconds, not hours. AI-powered culinary genius.
                </p>
              </CardContent>
            </Card>

            {/* Card 3: Save Food, Save Money */}
            <Card className="group overflow-hidden border-2 border-[#27AE60]/20 hover:border-[#27AE60] transition-all duration-300 hover:shadow-2xl hover:scale-105 bg-white">
              <div className="relative h-64 overflow-hidden">
                <img 
                  src="https://images.unsplash.com/photo-1590531711560-43d7a9bc4e6c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmcmVzaCUyMHZlZ2V0YWJsZXMlMjBoZXJic3xlbnwxfHx8fDE3NjE0MDY5MDh8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral"
                  alt="Save food and money"
                  className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500"
                />
                <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent" />
                <div className="absolute bottom-4 left-4 right-4">
                  <div className="w-12 h-12 rounded-full bg-[#27AE60] flex items-center justify-center mb-3 shadow-lg">
                    <Recycle className="w-6 h-6 text-white" />
                  </div>
                </div>
              </div>
              <CardContent className="p-6">
                <h3 className="text-2xl text-[#2C3E50] mb-3">
                  ♻️ Save Food, Save Money
                </h3>
                <p className="text-[#2C3E50]/70">
                  Americans waste $1,500/year on food. Not anymore. Cook smarter, waste less.
                </p>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      {/* Social Proof Section */}
      <section className="py-24 px-8 bg-gradient-to-br from-[#E74C3C]/10 via-[#F39C12]/10 to-[#27AE60]/10">
        <div className="max-w-5xl mx-auto text-center">
          <div className="backdrop-blur-sm bg-white/80 rounded-3xl p-12 shadow-xl">
            <div className="mb-8">
              <div className="inline-flex items-center gap-2 text-[#F39C12] mb-4">
                {[...Array(5)].map((_, i) => (
                  <svg key={i} className="w-8 h-8 fill-current" viewBox="0 0 20 20">
                    <path d="M10 15l-5.878 3.09 1.123-6.545L.489 6.91l6.572-.955L10 0l2.939 5.955 6.572.955-4.756 4.635 1.123 6.545z" />
                  </svg>
                ))}
              </div>
            </div>
            <blockquote className="text-2xl text-[#2C3E50] mb-6 italic">
              "This app literally changed how I cook. I used to throw out so much food. Now? Nothing goes to waste, and I'm eating better than ever!"
            </blockquote>
            <div className="text-[#2C3E50]/70">
              <p>— Sarah K., Home Chef</p>
              <p className="text-sm">Saved $480 in 3 months</p>
            </div>
          </div>
        </div>
      </section>

      {/* Final CTA Section */}
      <section className="py-24 px-8 bg-gradient-to-r from-[#E74C3C] to-[#E67E22] relative overflow-hidden">
        {/* Animated Background Elements */}
        <div className="absolute inset-0 opacity-10">
          <div className="absolute top-10 left-10 w-32 h-32 rounded-full bg-white animate-[float_8s_ease-in-out_infinite]" />
          <div className="absolute bottom-10 right-10 w-40 h-40 rounded-full bg-white animate-[float_6s_ease-in-out_infinite]" />
          <div className="absolute top-1/2 left-1/3 w-24 h-24 rounded-full bg-white animate-[float_7s_ease-in-out_infinite_1s]" />
        </div>

        <div className="max-w-4xl mx-auto text-center relative z-10">
          <h2 className="text-5xl text-white mb-6">
            Ready to Transform Your Kitchen?
          </h2>
          <p className="text-xl text-white/90 mb-10">
            Join thousands of home chefs cooking smarter, not harder
          </p>
          <Button 
            size="lg"
            onClick={() => setCurrentView("questionnaire")}
            className="h-16 px-12 bg-white text-[#E74C3C] hover:bg-[#FFF8DC] shadow-2xl hover:shadow-xl transition-all duration-300 hover:scale-105"
          >
            <span className="text-2xl">🚀 Get Started Free</span>
          </Button>
          <p className="text-white/70 mt-4 text-sm">No credit card required • 100% free to start</p>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-[#2C3E50] text-white py-12 px-8">
        <div className="max-w-7xl mx-auto">
          <div className="grid md:grid-cols-4 gap-8">
            <div>
              <div className="flex items-center gap-2 mb-4">
                <ChefHat className="w-6 h-6" />
                <span>What's For Dinner?</span>
              </div>
              <p className="text-white/60 text-sm">
                Making home cooking easy, sustainable, and delicious.
              </p>
            </div>
            <div>
              <h4 className="mb-4">Product</h4>
              <ul className="space-y-2 text-sm text-white/60">
                <li><a href="#" className="hover:text-white">Features</a></li>
                <li><a href="#" className="hover:text-white">How It Works</a></li>
                <li><a href="#" className="hover:text-white">Pricing</a></li>
              </ul>
            </div>
            <div>
              <h4 className="mb-4">Company</h4>
              <ul className="space-y-2 text-sm text-white/60">
                <li><a href="#" className="hover:text-white">About</a></li>
                <li><a href="#" className="hover:text-white">Blog</a></li>
                <li><a href="#" className="hover:text-white">Contact</a></li>
              </ul>
            </div>
            <div>
              <h4 className="mb-4">Legal</h4>
              <ul className="space-y-2 text-sm text-white/60">
                <li><a href="#" className="hover:text-white">Privacy</a></li>
                <li><a href="#" className="hover:text-white">Terms</a></li>
                <li><a href="#" className="hover:text-white">Cookies</a></li>
              </ul>
            </div>
          </div>
          <div className="border-t border-white/10 mt-8 pt-8 text-center text-sm text-white/40">
            © 2025 What's For Dinner? • Made with 🍳 and ❤️
          </div>
        </div>
      </footer>

      {/* Custom Animations */}
      <style>{`
        @keyframes float {
          0%, 100% { transform: translateY(0px); }
          50% { transform: translateY(-20px); }
        }
      `}</style>
    </div>
  );
}
