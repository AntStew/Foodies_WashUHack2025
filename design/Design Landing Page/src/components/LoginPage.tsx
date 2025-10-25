import { motion } from 'motion/react';
import { ChefHat, Mail, Lock, ArrowLeft } from 'lucide-react';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { Label } from './ui/label';
import { ImageWithFallback } from './figma/ImageWithFallback';
import { useState } from 'react';

interface LoginPageProps {
  onNavigate: (page: string) => void;
}

export function LoginPage({ onNavigate }: LoginPageProps) {
  const [formData, setFormData] = useState({
    email: '',
    password: ''
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    // Navigate to recipes after login
    onNavigate('recipes');
  };

  return (
    <div className="min-h-screen bg-[#FFF8DC] flex">
      {/* Left Side - Form */}
      <div className="w-full lg:w-1/2 flex items-center justify-center p-8">
        <motion.div
          className="w-full max-w-md"
          initial={{ opacity: 0, x: -20 }}
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
            Welcome Back!
          </h1>
          <p className="text-[#2C3E50]/70 mb-8">
            Ready to cook something delicious?
          </p>

          <form onSubmit={handleSubmit} className="space-y-6">
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
              <div className="mt-2 text-right">
                <button type="button" className="text-[#E74C3C] hover:underline">
                  Forgot password?
                </button>
              </div>
            </div>

            <Button
              type="submit"
              className="w-full py-6 bg-gradient-to-r from-[#F39C12] to-[#E74C3C] hover:from-[#E67E22] hover:to-[#C0392B] border-0"
              style={{ borderRadius: '12px', fontSize: '1.125rem' }}
            >
              Log In
            </Button>
          </form>

          <div className="mt-8">
            <div className="relative">
              <div className="absolute inset-0 flex items-center">
                <div className="w-full border-t border-[#2C3E50]/20" />
              </div>
              <div className="relative flex justify-center">
                <span className="bg-[#FFF8DC] px-4 text-[#2C3E50]/70">Or continue with</span>
              </div>
            </div>

            <div className="mt-6 grid grid-cols-2 gap-4">
              <Button
                type="button"
                variant="outline"
                className="py-6 border-2 border-[#2C3E50]/20"
                style={{ borderRadius: '12px' }}
              >
                <svg className="w-5 h-5 mr-2" viewBox="0 0 24 24">
                  <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                  <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                  <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
                  <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
                </svg>
                Google
              </Button>
              <Button
                type="button"
                variant="outline"
                className="py-6 border-2 border-[#2C3E50]/20"
                style={{ borderRadius: '12px' }}
              >
                <svg className="w-5 h-5 mr-2" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/>
                </svg>
                Facebook
              </Button>
            </div>
          </div>

          <div className="mt-6 text-center">
            <p className="text-[#2C3E50]/70">
              Don't have an account?{' '}
              <button
                onClick={() => onNavigate('signup')}
                className="text-[#E74C3C] hover:underline"
              >
                Sign up here
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

      {/* Right Side - Image */}
      <div className="hidden lg:flex lg:w-1/2 relative overflow-hidden">
        <ImageWithFallback
          src="https://images.unsplash.com/photo-1599297915779-0dadbd376d49?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxzdGlyJTIwZnJ5JTIwdmVnZXRhYmxlc3xlbnwxfHx8fDE3NjEzOTc5NDV8MA&ixlib=rb-4.1.0&q=80&w=1080"
          alt="Delicious stir fry"
          className="w-full h-full object-cover"
        />
        <div className="absolute inset-0 bg-gradient-to-bl from-[#27AE60]/70 to-[#E74C3C]/70 flex items-center justify-center">
          <div className="text-center px-12">
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.8 }}
            >
              <ChefHat size={80} className="text-white mx-auto mb-6" />
              <h2 className="text-white mb-4" style={{ fontFamily: 'Poppins, sans-serif', fontSize: '2.5rem' }}>
                Your Kitchen Awaits
              </h2>
              <p className="text-white/90" style={{ fontSize: '1.25rem' }}>
                Thousands of recipes are waiting to be discovered from your ingredients.
              </p>
            </motion.div>
          </div>
        </div>
      </div>
    </div>
  );
}
