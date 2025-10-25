import { motion } from 'motion/react';
import { ChefHat, Mail, Lock, User, ArrowLeft } from 'lucide-react';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { Label } from './ui/label';
import { ImageWithFallback } from './figma/ImageWithFallback';
import { useState } from 'react';

interface SignupPageProps {
  onNavigate: (page: string) => void;
}

export function SignupPage({ onNavigate }: SignupPageProps) {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    password: '',
    confirmPassword: ''
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    // Navigate to onboarding after signup
    onNavigate('onboarding');
  };

  return (
    <div className="min-h-screen bg-[#FFF8DC] flex">
      {/* Left Side - Image */}
      <div className="hidden lg:flex lg:w-1/2 relative overflow-hidden">
        <ImageWithFallback
          src="https://images.unsplash.com/photo-1645802733740-50f48729d151?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxicmVha2Zhc3QlMjBlZ2dzJTIwdG9hc3R8ZW58MXx8fHwxNzYxMzA2MDQ2fDA&ixlib=rb-4.1.0&q=80&w=1080"
          alt="Delicious food"
          className="w-full h-full object-cover"
        />
        <div className="absolute inset-0 bg-gradient-to-br from-[#E74C3C]/70 to-[#F39C12]/70 flex items-center justify-center">
          <div className="text-center px-12">
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.8 }}
            >
              <ChefHat size={80} className="text-white mx-auto mb-6" />
              <h2 className="text-white mb-4" style={{ fontFamily: 'Poppins, sans-serif', fontSize: '2.5rem' }}>
                Join the Kitchen Revolution
              </h2>
              <p className="text-white/90" style={{ fontSize: '1.25rem' }}>
                Start transforming your ingredients into amazing meals today.
              </p>
            </motion.div>
          </div>
        </div>
      </div>

      {/* Right Side - Form */}
      <div className="w-full lg:w-1/2 flex items-center justify-center p-8">
        <motion.div
          className="w-full max-w-md"
          initial={{ opacity: 0, x: 20 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ duration: 0.6 }}
        >
          <Button
            onClick={() => onNavigate('landing')}
            variant="ghost"
            className="mb-8 text-[#2C3E50] hover:text-[#E74C3C]"
          >
            <ArrowLeft className="mr-2" size={20} />
            Back to Home
          </Button>

          <h1 className="text-[#2C3E50] mb-2" style={{ fontFamily: 'Poppins, sans-serif', fontSize: '2.5rem' }}>
            Create Account
          </h1>
          <p className="text-[#2C3E50]/70 mb-8">
            Let's get you started with smart cooking!
          </p>

          <form onSubmit={handleSubmit} className="space-y-6">
            <div>
              <Label htmlFor="name" className="text-[#2C3E50]">Full Name</Label>
              <div className="relative mt-2">
                <User className="absolute left-3 top-1/2 -translate-y-1/2 text-[#2C3E50]/50" size={20} />
                <Input
                  id="name"
                  type="text"
                  placeholder="John Doe"
                  value={formData.name}
                  onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                  className="pl-12 py-6 border-2 border-[#2C3E50]/20 focus:border-[#E74C3C]"
                  style={{ borderRadius: '12px' }}
                  required
                />
              </div>
            </div>

            <div>
              <Label htmlFor="email" className="text-[#2C3E50]">Email Address</Label>
              <div className="relative mt-2">
                <Mail className="absolute left-3 top-1/2 -translate-y-1/2 text-[#2C3E50]/50" size={20} />
                <Input
                  id="email"
                  type="email"
                  placeholder="chef@email.com"
                  value={formData.email}
                  onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                  className="pl-12 py-6 border-2 border-[#2C3E50]/20 focus:border-[#E74C3C]"
                  style={{ borderRadius: '12px' }}
                  required
                />
              </div>
            </div>

            <div>
              <Label htmlFor="password" className="text-[#2C3E50]">Password</Label>
              <div className="relative mt-2">
                <Lock className="absolute left-3 top-1/2 -translate-y-1/2 text-[#2C3E50]/50" size={20} />
                <Input
                  id="password"
                  type="password"
                  placeholder="••••••••"
                  value={formData.password}
                  onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                  className="pl-12 py-6 border-2 border-[#2C3E50]/20 focus:border-[#E74C3C]"
                  style={{ borderRadius: '12px' }}
                  required
                />
              </div>
            </div>

            <div>
              <Label htmlFor="confirmPassword" className="text-[#2C3E50]">Confirm Password</Label>
              <div className="relative mt-2">
                <Lock className="absolute left-3 top-1/2 -translate-y-1/2 text-[#2C3E50]/50" size={20} />
                <Input
                  id="confirmPassword"
                  type="password"
                  placeholder="••••••••"
                  value={formData.confirmPassword}
                  onChange={(e) => setFormData({ ...formData, confirmPassword: e.target.value })}
                  className="pl-12 py-6 border-2 border-[#2C3E50]/20 focus:border-[#E74C3C]"
                  style={{ borderRadius: '12px' }}
                  required
                />
              </div>
            </div>

            <Button
              type="submit"
              className="w-full py-6 bg-gradient-to-r from-[#F39C12] to-[#E74C3C] hover:from-[#E67E22] hover:to-[#C0392B] border-0"
              style={{ borderRadius: '12px', fontSize: '1.125rem' }}
            >
              Start Cooking Smart
            </Button>
          </form>

          <div className="mt-6 text-center">
            <p className="text-[#2C3E50]/70">
              Already have an account?{' '}
              <button
                onClick={() => onNavigate('login')}
                className="text-[#E74C3C] hover:underline"
              >
                Log in here
              </button>
            </p>
          </div>

          {/* Decorative Elements */}
          <div className="mt-12 flex justify-center gap-4 opacity-30">
            <div className="w-16 h-16 bg-[#E74C3C] rounded-full blur-xl" />
            <div className="w-16 h-16 bg-[#F39C12] rounded-full blur-xl" />
            <div className="w-16 h-16 bg-[#27AE60] rounded-full blur-xl" />
          </div>
        </motion.div>
      </div>
    </div>
  );
}
