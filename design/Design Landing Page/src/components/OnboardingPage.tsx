import { motion, AnimatePresence } from 'motion/react';
import { ChefHat, Clock, Heart, Sparkles, ArrowLeft, ArrowRight, AlertCircle, PartyPopper } from 'lucide-react';
import { Button } from './ui/button';
import { Label } from './ui/label';
import { RadioGroup, RadioGroupItem } from './ui/radio-group';
import { Input } from './ui/input';
import { ImageWithFallback } from './figma/ImageWithFallback';
import { useState } from 'react';

interface OnboardingPageProps {
  onNavigate: (page: string) => void;
}

export function OnboardingPage({ onNavigate }: OnboardingPageProps) {
  const [step, setStep] = useState(1);
  const [showSuccess, setShowSuccess] = useState(false);
  const [selectedFeedback, setSelectedFeedback] = useState('');
  const [customAllergy, setCustomAllergy] = useState('');
  const [formData, setFormData] = useState({
    cookingSkill: '',
    dietaryPreferences: [] as string[],
    availableTime: '',
    allergies: [] as string[]
  });

  const handleDietaryToggle = (preference: string) => {
    // If "No Restrictions" is selected, clear all other selections
    if (preference === 'none') {
      setFormData(prev => ({ ...prev, dietaryPreferences: ['none'] }));
      setSelectedFeedback('Great! You have lots of recipe options! 🎉');
    } else {
      setFormData(prev => {
        const current = prev.dietaryPreferences.filter(p => p !== 'none');
        const updated = current.includes(preference)
          ? current.filter(p => p !== preference)
          : [...current, preference];
        return { ...prev, dietaryPreferences: updated };
      });
      setSelectedFeedback('Nice choice! 👍');
    }
    setTimeout(() => setSelectedFeedback(''), 2000);
  };

  const handleAllergyToggle = (allergy: string) => {
    // If "No Allergies" is selected, clear all other selections
    if (allergy === 'none') {
      setFormData(prev => ({ ...prev, allergies: ['none'] }));
      setSelectedFeedback('Perfect! Safety first! ✅');
    } else {
      setFormData(prev => {
        const current = prev.allergies.filter(a => a !== 'none');
        const updated = current.includes(allergy)
          ? current.filter(a => a !== allergy)
          : [...current, allergy];
        return { ...prev, allergies: updated };
      });
      setSelectedFeedback('Got it! We\'ll keep you safe! 🛡️');
    }
    setTimeout(() => setSelectedFeedback(''), 2000);
  };

  const handleNext = () => {
    if (step < 4) {
      setStep(step + 1);
      setSelectedFeedback('');
    } else {
      setShowSuccess(true);
      setTimeout(() => {
        onNavigate('recipes');
      }, 2500);
    }
  };

  const handleBack = () => {
    if (step > 1) {
      setStep(step - 1);
      setSelectedFeedback('');
    }
  };

  const handleSkip = () => {
    onNavigate('recipes');
  };

  const canProceed = () => {
    switch (step) {
      case 1:
        return formData.cookingSkill !== '';
      case 2:
        return true; // Dietary preferences are optional
      case 3:
        return formData.availableTime !== '';
      case 4:
        return true; // Allergies are optional
      default:
        return false;
    }
  };

  // Success screen
  if (showSuccess) {
    return (
      <div className="min-h-screen bg-[#FFF8DC] flex items-center justify-center p-8">
        <motion.div
          className="text-center"
          initial={{ opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ duration: 0.5 }}
        >
          <motion.div
            initial={{ scale: 0 }}
            animate={{ scale: 1 }}
            transition={{ delay: 0.2, type: "spring", stiffness: 200 }}
          >
            <PartyPopper size={100} className="text-[#E74C3C] mx-auto mb-6" />
          </motion.div>
          <h2 className="text-[#2C3E50] mb-4" style={{ fontFamily: 'Poppins, sans-serif', fontSize: '2.5rem' }}>
            All Set!
          </h2>
          <p className="text-[#2C3E50]/70 mb-8" style={{ fontSize: '1.25rem' }}>
            We're personalizing your experience...
          </p>
          <div className="flex justify-center gap-2 mb-8">
            <motion.div
              className="w-3 h-3 bg-[#E74C3C] rounded-full"
              animate={{ scale: [1, 1.5, 1] }}
              transition={{ duration: 0.6, repeat: Infinity, delay: 0 }}
            />
            <motion.div
              className="w-3 h-3 bg-[#F39C12] rounded-full"
              animate={{ scale: [1, 1.5, 1] }}
              transition={{ duration: 0.6, repeat: Infinity, delay: 0.2 }}
            />
            <motion.div
              className="w-3 h-3 bg-[#27AE60] rounded-full"
              animate={{ scale: [1, 1.5, 1] }}
              transition={{ duration: 0.6, repeat: Infinity, delay: 0.4 }}
            />
          </div>
        </motion.div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-[#FFF8DC] relative overflow-hidden">
      {/* Background Images */}
      <div className="absolute inset-0 opacity-10 pointer-events-none">
        {step === 1 && (
          <ImageWithFallback
            src="https://images.unsplash.com/photo-1518291344630-4857135fb581?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxraXRjaGVuJTIwY29va2luZyUyMHRvb2xzfGVufDF8fHx8MTc2MTQxODI0OHww&ixlib=rb-4.1.0&q=80&w=1080"
            alt="Kitchen tools background"
            className="w-full h-full object-cover"
          />
        )}
        {step === 2 && (
          <ImageWithFallback
            src="https://images.unsplash.com/photo-1700150618387-3f46b6d2cf8e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjb2xvcmZ1bCUyMHZlZ2V0YWJsZXMlMjBmbGF0bGF5fGVufDF8fHx8MTc2MTQyMDE2NXww&ixlib=rb-4.1.0&q=80&w=1080"
            alt="Vegetables background"
            className="w-full h-full object-cover"
          />
        )}
        {step === 3 && (
          <ImageWithFallback
            src="https://images.unsplash.com/photo-1668822434552-13a5ba2aa3e1?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxraXRjaGVuJTIwdGltZXIlMjBjbG9ja3xlbnwxfHx8fDE3NjE0MTgyNDl8MA&ixlib=rb-4.1.0&q=80&w=1080"
            alt="Timer background"
            className="w-full h-full object-cover"
          />
        )}
        {step === 4 && (
          <ImageWithFallback
            src="https://images.unsplash.com/photo-1705079825720-af4a62abb820?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxvcmdhbml6ZWQlMjBwYW50cnklMjBqYXJzfGVufDF8fHx8MTc2MTQxODI0OXww&ixlib=rb-4.1.0&q=80&w=1080"
            alt="Pantry background"
            className="w-full h-full object-cover"
          />
        )}
      </div>

      <div className="relative flex items-center justify-center min-h-screen p-8">
        <motion.div
          className="w-full max-w-3xl bg-white rounded-3xl shadow-2xl p-8 md:p-12"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6 }}
        >
          {/* Progress Bar */}
          <div className="mb-10">
            <div className="flex justify-between mb-3">
              <span className="text-[#2C3E50]" style={{ fontFamily: 'Poppins, sans-serif' }}>
                Question {step} of 4
              </span>
              <span className="text-[#2C3E50]/70">{Math.round((step / 4) * 100)}%</span>
            </div>
            <div className="flex gap-2">
              {[1, 2, 3, 4].map((i) => (
                <div
                  key={i}
                  className="flex-1 h-3 rounded-full overflow-hidden"
                  style={{
                    backgroundColor: i <= step ? 'transparent' : '#E5E7EB'
                  }}
                >
                  {i <= step && (
                    <motion.div
                      className="h-full rounded-full"
                      style={{
                        background: i === 1
                          ? 'linear-gradient(90deg, #E74C3C, #E67E22)'
                          : i === 2
                          ? 'linear-gradient(90deg, #F39C12, #E67E22)'
                          : i === 3
                          ? 'linear-gradient(90deg, #E67E22, #27AE60)'
                          : 'linear-gradient(90deg, #27AE60, #2ECC71)'
                      }}
                      initial={{ width: 0 }}
                      animate={{ width: '100%' }}
                      transition={{ duration: 0.5, delay: 0.2 }}
                    />
                  )}
                </div>
              ))}
            </div>
          </div>

          <AnimatePresence mode="wait">
            {/* Step 1: Cooking Skill */}
            {step === 1 && (
              <motion.div
                key="step1"
                initial={{ opacity: 0, x: 20 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -20 }}
                transition={{ duration: 0.3 }}
              >
                <div className="text-center mb-10">
                  <ChefHat size={60} className="text-[#E74C3C] mx-auto mb-4" />
                  <h2 className="text-[#2C3E50] mb-3" style={{ fontFamily: 'Poppins, sans-serif', fontSize: '2.25rem' }}>
                    What's your cooking skill level?
                  </h2>
                  <p className="text-[#2C3E50]/70" style={{ fontSize: '1.125rem' }}>
                    Help us match recipes to your experience
                  </p>
                </div>

                <RadioGroup 
                  value={formData.cookingSkill} 
                  onValueChange={(value) => {
                    setFormData({ ...formData, cookingSkill: value });
                    setSelectedFeedback('Great choice! 🎯');
                    setTimeout(() => setSelectedFeedback(''), 2000);
                  }}
                >
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    {[
                      { value: 'beginner', emoji: '🌱', title: 'Beginner', desc: "I'm just starting my cooking journey" },
                      { value: 'intermediate', emoji: '👨‍🍳', title: 'Intermediate', desc: "I'm comfortable with basic techniques" },
                      { value: 'advanced', emoji: '⭐', title: 'Advanced', desc: 'I love experimenting with complex recipes' },
                      { value: 'professional', emoji: '🎓', title: 'Professional', desc: 'I have culinary training or work in food' }
                    ].map((option) => (
                      <label
                        key={option.value}
                        className={`flex flex-col items-center p-6 rounded-2xl border cursor-pointer transition-all min-h-[150px] ${
                          formData.cookingSkill === option.value
                            ? 'border-[#E67E22] bg-[#FFF5E6] shadow-lg'
                            : 'border-[#E5E7EB] bg-white hover:border-[#E67E22]/50 hover:-translate-y-1 hover:shadow-md'
                        }`}
                        style={{
                          borderWidth: formData.cookingSkill === option.value ? '4px' : '2px'
                        }}
                      >
                        <RadioGroupItem value={option.value} id={option.value} className="sr-only" />
                        <span style={{ fontSize: '3.5rem' }} className="mb-3">{option.emoji}</span>
                        <div className="text-center">
                          <div className="text-[#2C3E50] mb-2" style={{ fontFamily: 'Poppins, sans-serif', fontSize: '1.25rem' }}>
                            {option.title}
                          </div>
                          <div className="text-[#2C3E50]/60">
                            {option.desc}
                          </div>
                        </div>
                      </label>
                    ))}
                  </div>
                </RadioGroup>
              </motion.div>
            )}

            {/* Step 2: Dietary Preferences */}
            {step === 2 && (
              <motion.div
                key="step2"
                initial={{ opacity: 0, x: 20 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -20 }}
                transition={{ duration: 0.3 }}
              >
                <div className="text-center mb-10">
                  <Heart size={60} className="text-[#F39C12] mx-auto mb-4" />
                  <h2 className="text-[#2C3E50] mb-3" style={{ fontFamily: 'Poppins, sans-serif', fontSize: '2.25rem' }}>
                    Any dietary preferences?
                  </h2>
                  <p className="text-[#2C3E50]/70" style={{ fontSize: '1.125rem' }}>
                    We'll personalize your recipe suggestions
                  </p>
                </div>

                <div className="space-y-3">
                  {[
                    { value: 'none', emoji: '🍽️', title: 'No Restrictions', desc: 'I eat everything' },
                    { value: 'vegetarian', emoji: '🥗', title: 'Vegetarian', desc: 'No meat or fish' },
                    { value: 'vegan', emoji: '🌿', title: 'Vegan', desc: 'No animal products' },
                    { value: 'gluten-free', emoji: '🌾', title: 'Gluten-Free', desc: 'No wheat or gluten' },
                    { value: 'keto', emoji: '🥩', title: 'Keto/Low-Carb', desc: 'High protein, low carbs' },
                    { value: 'custom', emoji: '🥜', title: 'Custom', desc: 'Let me specify my needs' }
                  ].map((option) => (
                    <button
                      key={option.value}
                      onClick={() => handleDietaryToggle(option.value)}
                      className={`w-full flex items-center p-5 rounded-2xl border cursor-pointer transition-all ${
                        formData.dietaryPreferences.includes(option.value)
                          ? 'border-[#E67E22] bg-[#FFF5E6] shadow-lg'
                          : 'border-[#E5E7EB] bg-white hover:border-[#E67E22]/50 hover:-translate-y-1 hover:shadow-md'
                      }`}
                      style={{
                        borderWidth: formData.dietaryPreferences.includes(option.value) ? '4px' : '2px'
                      }}
                    >
                      <span style={{ fontSize: '3rem' }} className="mr-5">{option.emoji}</span>
                      <div className="flex-1 text-left">
                        <div className="text-[#2C3E50] mb-1" style={{ fontFamily: 'Poppins, sans-serif', fontSize: '1.25rem' }}>
                          {option.title}
                        </div>
                        <div className="text-[#2C3E50]/60">{option.desc}</div>
                      </div>
                    </button>
                  ))}
                </div>
              </motion.div>
            )}

            {/* Step 3: Available Time */}
            {step === 3 && (
              <motion.div
                key="step3"
                initial={{ opacity: 0, x: 20 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -20 }}
                transition={{ duration: 0.3 }}
              >
                <div className="text-center mb-10">
                  <Clock size={60} className="text-[#E67E22] mx-auto mb-4" />
                  <h2 className="text-[#2C3E50] mb-3" style={{ fontFamily: 'Poppins, sans-serif', fontSize: '2.25rem' }}>
                    How much time do you usually have to cook?
                  </h2>
                  <p className="text-[#2C3E50]/70" style={{ fontSize: '1.125rem' }}>
                    We'll match recipes to your schedule
                  </p>
                </div>

                <RadioGroup 
                  value={formData.availableTime} 
                  onValueChange={(value) => {
                    setFormData({ ...formData, availableTime: value });
                    setSelectedFeedback('Perfect timing! ⏰');
                    setTimeout(() => setSelectedFeedback(''), 2000);
                  }}
                >
                  <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                    {[
                      { value: 'quick', emoji: '⚡', title: 'Quick', subtitle: '15-20 min', desc: 'Fast weeknight meals' },
                      { value: 'moderate', emoji: '🕐', title: 'Moderate', subtitle: '30-45 min', desc: 'Balanced cooking time' },
                      { value: 'relaxed', emoji: '🍷', title: 'Relaxed', subtitle: '1+ hour', desc: 'Cooking is my therapy' }
                    ].map((option) => (
                      <label
                        key={option.value}
                        className={`flex flex-col items-center p-6 rounded-2xl border cursor-pointer transition-all min-h-[180px] ${
                          formData.availableTime === option.value
                            ? 'border-[#E67E22] bg-[#FFF5E6] shadow-lg'
                            : 'border-[#E5E7EB] bg-white hover:border-[#E67E22]/50 hover:-translate-y-1 hover:shadow-md'
                        }`}
                        style={{
                          borderWidth: formData.availableTime === option.value ? '4px' : '2px'
                        }}
                      >
                        <RadioGroupItem value={option.value} id={option.value} className="sr-only" />
                        <span style={{ fontSize: '3.5rem' }} className="mb-3">{option.emoji}</span>
                        <div className="text-center">
                          <div className="text-[#2C3E50] mb-1" style={{ fontFamily: 'Poppins, sans-serif', fontSize: '1.25rem' }}>
                            {option.title}
                          </div>
                          <div className="text-[#E67E22] mb-2" style={{ fontSize: '1.125rem' }}>
                            {option.subtitle}
                          </div>
                          <div className="text-[#2C3E50]/60">
                            {option.desc}
                          </div>
                        </div>
                      </label>
                    ))}
                  </div>
                </RadioGroup>
              </motion.div>
            )}

            {/* Step 4: Allergies */}
            {step === 4 && (
              <motion.div
                key="step4"
                initial={{ opacity: 0, x: 20 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -20 }}
                transition={{ duration: 0.3 }}
              >
                <div className="text-center mb-10">
                  <AlertCircle size={60} className="text-[#27AE60] mx-auto mb-4" />
                  <h2 className="text-[#2C3E50] mb-3" style={{ fontFamily: 'Poppins, sans-serif', fontSize: '2.25rem' }}>
                    Any ingredients you can't eat?
                  </h2>
                  <p className="text-[#2C3E50]/70" style={{ fontSize: '1.125rem' }}>
                    Your safety is our top priority
                  </p>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  {[
                    { value: 'none', emoji: '✅', title: 'No Allergies', desc: "I'm all good" },
                    { value: 'nuts', emoji: '🥜', title: 'Tree Nuts/Peanuts', desc: 'Includes almond, cashew, etc.' },
                    { value: 'dairy', emoji: '🥛', title: 'Dairy', desc: 'Milk, cheese, butter' },
                    { value: 'shellfish', emoji: '🦐', title: 'Shellfish', desc: 'Shrimp, crab, lobster' },
                    { value: 'eggs', emoji: '🥚', title: 'Eggs', desc: 'Eggs and egg products' },
                    { value: 'other', emoji: '🌶️', title: 'Other', desc: 'Let me specify' }
                  ].map((option) => (
                    <div key={option.value}>
                      <button
                        onClick={() => handleAllergyToggle(option.value)}
                        className={`w-full flex items-center p-5 rounded-2xl border cursor-pointer transition-all ${
                          formData.allergies.includes(option.value)
                            ? 'border-[#E67E22] bg-[#FFF5E6] shadow-lg'
                            : 'border-[#E5E7EB] bg-white hover:border-[#E67E22]/50 hover:-translate-y-1 hover:shadow-md'
                        }`}
                        style={{
                          borderWidth: formData.allergies.includes(option.value) ? '4px' : '2px'
                        }}
                      >
                        <span style={{ fontSize: '2.5rem' }} className="mr-4">{option.emoji}</span>
                        <div className="flex-1 text-left">
                          <div className="text-[#2C3E50] mb-1" style={{ fontFamily: 'Poppins, sans-serif', fontSize: '1.125rem' }}>
                            {option.title}
                          </div>
                          <div className="text-[#2C3E50]/60">{option.desc}</div>
                        </div>
                      </button>
                      {option.value === 'other' && formData.allergies.includes('other') && (
                        <motion.div
                          initial={{ opacity: 0, height: 0 }}
                          animate={{ opacity: 1, height: 'auto' }}
                          transition={{ duration: 0.2 }}
                          className="mt-2"
                        >
                          <Input
                            placeholder="Please specify your allergies..."
                            value={customAllergy}
                            onChange={(e) => setCustomAllergy(e.target.value)}
                            className="w-full p-4 border-2 border-[#E5E7EB] rounded-xl"
                          />
                        </motion.div>
                      )}
                    </div>
                  ))}
                </div>
              </motion.div>
            )}
          </AnimatePresence>

          {/* Feedback Message */}
          <AnimatePresence>
            {selectedFeedback && (
              <motion.div
                initial={{ opacity: 0, y: -10 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -10 }}
                className="mt-6 text-center text-[#27AE60]"
                style={{ fontSize: '1.125rem', fontFamily: 'Poppins, sans-serif' }}
              >
                {selectedFeedback}
              </motion.div>
            )}
          </AnimatePresence>

          {/* Navigation Buttons */}
          <div className="mt-12">
            <div className="flex gap-4">
              <Button
                onClick={handleBack}
                variant="outline"
                disabled={step === 1}
                className="py-6 px-8 border-2 border-[#2C3E50]/20 disabled:opacity-50 disabled:cursor-not-allowed"
                style={{ borderRadius: '12px', fontSize: '1.125rem' }}
              >
                <ArrowLeft className="mr-2" size={20} />
                Back
              </Button>
              
              <Button
                onClick={handleNext}
                disabled={!canProceed()}
                className="flex-1 py-6 border-0 disabled:opacity-50 disabled:cursor-not-allowed disabled:from-gray-400 disabled:to-gray-500"
                style={{
                  borderRadius: '12px',
                  fontSize: '1.125rem',
                  background: canProceed()
                    ? 'linear-gradient(90deg, #F39C12, #E74C3C)'
                    : '#9CA3AF'
                }}
              >
                {step === 4 ? (
                  <>
                    🍳 Start Finding Recipes
                  </>
                ) : (
                  <>
                    Next
                    <ArrowRight className="ml-2" size={20} />
                  </>
                )}
              </Button>
            </div>

            {/* Skip Option */}
            <div className="mt-6 text-center">
              <button
                onClick={handleSkip}
                className="text-[#2C3E50]/60 hover:text-[#2C3E50] transition-colors"
              >
                Skip for now
              </button>
            </div>
          </div>
        </motion.div>
      </div>
    </div>
  );
}
