import { useState } from 'react';
import { LandingPage } from './components/LandingPage';
import { SignupPage } from './components/SignupPage';
import { LoginPage } from './components/LoginPage';
import { OnboardingPage } from './components/OnboardingPage';
import { RecipesPage } from './components/RecipesPage';

type Page = 'landing' | 'signup' | 'login' | 'onboarding' | 'recipes';

export default function App() {
  const [currentPage, setCurrentPage] = useState<Page>('landing');

  const handleNavigate = (page: string) => {
    setCurrentPage(page as Page);
  };

  return (
    <div className="min-h-screen">
      {currentPage === 'landing' && <LandingPage onNavigate={handleNavigate} />}
      {currentPage === 'signup' && <SignupPage onNavigate={handleNavigate} />}
      {currentPage === 'login' && <LoginPage onNavigate={handleNavigate} />}
      {currentPage === 'onboarding' && <OnboardingPage onNavigate={handleNavigate} />}
      {currentPage === 'recipes' && <RecipesPage onNavigate={handleNavigate} />}
    </div>
  );
}
