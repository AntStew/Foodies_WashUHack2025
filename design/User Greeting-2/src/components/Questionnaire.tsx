import { useState } from "react";
import { Button } from "./ui/button";
import { Card } from "./ui/card";
import { ChevronLeft, ChevronRight, Check } from "lucide-react";
import { Progress } from "./ui/progress";

type Answer = {
  skillLevel?: string;
  dietaryPreferences: string[];
  cookingTime?: string;
  allergies: string[];
};

const questions = [
  {
    id: 1,
    title: "What's your cooking skill level?",
    subtitle: "Help us match recipes to your experience",
    backgroundImage: "https://images.unsplash.com/photo-1518291344630-4857135fb581?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxraXRjaGVuJTIwY29va2luZyUyMHRvb2xzfGVufDF8fHx8MTc2MTQxODI0OHww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral",
    type: "single" as const,
    options: [
      { id: "beginner", emoji: "🌱", title: "Beginner", description: "I'm just starting my cooking journey" },
      { id: "intermediate", emoji: "👨‍🍳", title: "Intermediate", description: "I'm comfortable with basic techniques" },
      { id: "advanced", emoji: "⭐", title: "Advanced", description: "I love experimenting with complex recipes" },
      { id: "professional", emoji: "🎓", title: "Professional", description: "I have culinary training or work in food" },
    ],
  },
  {
    id: 2,
    title: "Any dietary preferences?",
    subtitle: "We'll personalize your recipe suggestions",
    backgroundImage: "https://images.unsplash.com/photo-1552166539-7f3691985d0b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjb2xvcmZ1bCUyMHZlZ2V0YWJsZXMlMjBmbGF0JTIwbGF5fGVufDF8fHx8MTc2MTQxODI0OHww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral",
    type: "multiple" as const,
    options: [
      { id: "no-restrictions", emoji: "🍽️", title: "No Restrictions", description: "I eat everything" },
      { id: "vegetarian", emoji: "🥗", title: "Vegetarian", description: "No meat or fish" },
      { id: "vegan", emoji: "🌿", title: "Vegan", description: "No animal products" },
      { id: "gluten-free", emoji: "🌾", title: "Gluten-Free", description: "No wheat or gluten" },
      { id: "keto", emoji: "🥩", title: "Keto/Low-Carb", description: "High protein, low carbs" },
      { id: "custom", emoji: "🥜", title: "Custom", description: "Let me specify my needs" },
    ],
  },
  {
    id: 3,
    title: "How much time do you usually have to cook?",
    subtitle: "We'll match recipes to your schedule",
    backgroundImage: "https://images.unsplash.com/photo-1668822434552-13a5ba2aa3e1?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxraXRjaGVuJTIwdGltZXIlMjBjbG9ja3xlbnwxfHx8fDE3NjE0MTgyNDl8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral",
    type: "single" as const,
    options: [
      { id: "quick", emoji: "⚡", title: "Quick (15-20 min)", description: "Fast weeknight meals" },
      { id: "moderate", emoji: "🕐", title: "Moderate (30-45 min)", description: "Balanced cooking time" },
      { id: "relaxed", emoji: "🍷", title: "Relaxed (1+ hour)", description: "Cooking is my therapy" },
    ],
  },
  {
    id: 4,
    title: "Any ingredients you can't eat?",
    subtitle: "Your safety is our top priority",
    backgroundImage: "https://images.unsplash.com/photo-1705079825720-af4a62abb820?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxvcmdhbml6ZWQlMjBwYW50cnklMjBqYXJzfGVufDF8fHx8MTc2MTQxODI0OXww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral",
    type: "multiple" as const,
    options: [
      { id: "no-allergies", emoji: "✅", title: "No Allergies", description: "I'm all good" },
      { id: "nuts", emoji: "🥜", title: "Tree Nuts/Peanuts", description: "Includes almond, cashew, etc." },
      { id: "dairy", emoji: "🥛", title: "Dairy", description: "Milk, cheese, butter" },
      { id: "shellfish", emoji: "🦐", title: "Shellfish", description: "Shrimp, crab, lobster" },
      { id: "eggs", emoji: "🥚", title: "Eggs", description: "Eggs and egg products" },
      { id: "other", emoji: "🌶️", title: "Other", description: "Let me specify" },
    ],
  },
];

export default function Questionnaire({ onComplete }: { onComplete: (answers: Answer) => void }) {
  const [currentQuestion, setCurrentQuestion] = useState(0);
  const [answers, setAnswers] = useState<Answer>({
    dietaryPreferences: [],
    allergies: [],
  });
  const [showSuccess, setShowSuccess] = useState(false);

  const question = questions[currentQuestion];
  const progress = ((currentQuestion + 1) / questions.length) * 100;

  const handleSelect = (optionId: string) => {
    if (question.type === "single") {
      // Single selection
      if (question.id === 1) {
        setAnswers({ ...answers, skillLevel: optionId });
      } else if (question.id === 3) {
        setAnswers({ ...answers, cookingTime: optionId });
      }
    } else {
      // Multiple selection
      const field = question.id === 2 ? "dietaryPreferences" : "allergies";
      const currentSelections = answers[field];
      
      if (currentSelections.includes(optionId)) {
        // Deselect
        setAnswers({
          ...answers,
          [field]: currentSelections.filter((id) => id !== optionId),
        });
      } else {
        // Select
        setAnswers({
          ...answers,
          [field]: [...currentSelections, optionId],
        });
      }
    }
  };

  const isSelected = (optionId: string): boolean => {
    if (question.type === "single") {
      if (question.id === 1) return answers.skillLevel === optionId;
      if (question.id === 3) return answers.cookingTime === optionId;
    } else {
      const field = question.id === 2 ? "dietaryPreferences" : "allergies";
      return answers[field].includes(optionId);
    }
    return false;
  };

  const canProceed = (): boolean => {
    if (question.type === "single") {
      if (question.id === 1) return !!answers.skillLevel;
      if (question.id === 3) return !!answers.cookingTime;
    } else {
      const field = question.id === 2 ? "dietaryPreferences" : "allergies";
      return answers[field].length > 0;
    }
    return false;
  };

  const handleNext = () => {
    if (currentQuestion < questions.length - 1) {
      setCurrentQuestion(currentQuestion + 1);
    } else {
      // Last question - show success screen
      setShowSuccess(true);
      setTimeout(() => {
        onComplete(answers);
      }, 2000);
    }
  };

  const handleBack = () => {
    if (currentQuestion > 0) {
      setCurrentQuestion(currentQuestion - 1);
    }
  };

  if (showSuccess) {
    return (
      <div className="min-h-screen bg-[#FFF8DC] flex items-center justify-center p-4">
        <div 
          className="absolute inset-0 bg-cover bg-center opacity-20"
          style={{
            backgroundImage: `url('https://images.unsplash.com/photo-1700481935677-26f2336f6f36?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxwbGF0ZWQlMjBmb29kJTIwZGlzaHxlbnwxfHx8fDE3NjE0MTgyNDl8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral')`
          }}
        />
        <div className="relative z-10 text-center space-y-8 max-w-2xl">
          <div className="w-24 h-24 mx-auto rounded-full bg-gradient-to-br from-[#27AE60] to-[#2ECC71] flex items-center justify-center shadow-2xl animate-[bounce_1s_ease-in-out_2]">
            <Check className="w-12 h-12 text-white" />
          </div>
          <div className="space-y-4">
            <h2 className="text-5xl text-[#2C3E50]">All Set!</h2>
            <p className="text-xl text-[#2C3E50]/70">
              We're personalizing your experience...
            </p>
          </div>
          <div className="flex justify-center gap-2">
            {[...Array(3)].map((_, i) => (
              <div
                key={i}
                className="w-3 h-3 rounded-full bg-[#E74C3C] animate-[bounce_1s_ease-in-out_infinite]"
                style={{ animationDelay: `${i * 0.15}s` }}
              />
            ))}
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-[#FFF8DC] relative overflow-hidden">
      {/* Background Image */}
      <div 
        className="absolute inset-0 bg-cover bg-center opacity-10"
        style={{ backgroundImage: `url('${question.backgroundImage}')` }}
      />

      {/* Progress Bar */}
      <div className="fixed top-0 left-0 right-0 z-50 bg-white/95 backdrop-blur-sm shadow-sm">
        <div className="max-w-4xl mx-auto px-4 sm:px-8 py-4">
          <div className="flex items-center justify-between mb-2">
            <span className="text-sm text-[#2C3E50]/70">
              Question {currentQuestion + 1} of {questions.length}
            </span>
            <span className="text-sm text-[#E74C3C]">{Math.round(progress)}% Complete</span>
          </div>
          <Progress value={progress} className="h-2" />
        </div>
      </div>

      {/* Main Content */}
      <div className="relative z-10 min-h-screen pt-28 pb-32 px-4 sm:px-8">
        <div className="max-w-4xl mx-auto">
          {/* Question Header */}
          <div className="text-center mb-12 space-y-3">
            <h1 className="text-4xl sm:text-5xl text-[#2C3E50]">
              {question.title}
            </h1>
            <p className="text-lg sm:text-xl text-[#2C3E50]/70">
              {question.subtitle}
            </p>
          </div>

          {/* Options Grid */}
          <div className={`grid gap-4 mb-8 ${
            question.options.length <= 3 
              ? 'sm:grid-cols-3' 
              : question.options.length === 4 
              ? 'sm:grid-cols-2' 
              : 'sm:grid-cols-2 lg:grid-cols-3'
          }`}>
            {question.options.map((option) => (
              <Card
                key={option.id}
                onClick={() => handleSelect(option.id)}
                className={`
                  cursor-pointer p-6 transition-all duration-300
                  border-2 bg-white
                  ${isSelected(option.id) 
                    ? 'border-[#E67E22] border-4 bg-[#FFF5E6] shadow-lg scale-105' 
                    : 'border-gray-200 hover:border-[#E74C3C]/50 hover:shadow-xl hover:-translate-y-1'
                  }
                `}
              >
                <div className="text-center space-y-3">
                  <div className="text-5xl sm:text-6xl mb-3">{option.emoji}</div>
                  <h3 className="text-xl text-[#2C3E50]">
                    {option.title}
                  </h3>
                  <p className="text-sm text-[#2C3E50]/70">
                    {option.description}
                  </p>
                  {isSelected(option.id) && (
                    <div className="mt-3 flex items-center justify-center gap-2 text-[#E67E22]">
                      <Check className="w-5 h-5" />
                      <span className="text-sm">Selected</span>
                    </div>
                  )}
                </div>
              </Card>
            ))}
          </div>

          {/* Micro-copy feedback */}
          {canProceed() && (
            <div className="text-center mb-6 animate-[fadeIn_0.3s_ease-in]">
              <span className="text-[#27AE60]">Nice choice! 👍</span>
            </div>
          )}

          {/* Skip option */}
          <div className="text-center mb-8">
            <button 
              onClick={handleNext}
              className="text-sm text-[#2C3E50]/50 hover:text-[#2C3E50] transition-colors"
            >
              Skip for now
            </button>
          </div>

          {/* Navigation */}
          <div className="flex items-center justify-between gap-4">
            <Button
              variant="outline"
              size="lg"
              onClick={handleBack}
              disabled={currentQuestion === 0}
              className="border-2 border-[#2C3E50]/20 disabled:opacity-30"
            >
              <ChevronLeft className="w-5 h-5 mr-2" />
              Back
            </Button>

            <Button
              size="lg"
              onClick={handleNext}
              disabled={!canProceed()}
              className={`
                min-w-[200px] transition-all duration-300
                ${canProceed()
                  ? 'bg-gradient-to-r from-[#E74C3C] to-[#E67E22] hover:from-[#E74C3C]/90 hover:to-[#E67E22]/90 shadow-lg hover:shadow-xl animate-[pulse_2s_ease-in-out_infinite]'
                  : 'bg-gray-300 cursor-not-allowed'
                }
              `}
            >
              {currentQuestion === questions.length - 1 ? (
                <>
                  🍳 Start Finding Recipes
                  <ChevronRight className="w-5 h-5 ml-2" />
                </>
              ) : (
                <>
                  Next
                  <ChevronRight className="w-5 h-5 ml-2" />
                </>
              )}
            </Button>
          </div>
        </div>
      </div>

      {/* Custom Animations */}
      <style>{`
        @keyframes fadeIn {
          from { opacity: 0; transform: translateY(-10px); }
          to { opacity: 1; transform: translateY(0); }
        }
        @keyframes bounce {
          0%, 100% { transform: scale(1); }
          50% { transform: scale(1.1); }
        }
      `}</style>
    </div>
  );
}
