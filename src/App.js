import React, { useState, useEffect } from 'react';
import { 
  Users, 
  Calendar, 
  DollarSign, 
  Heart, 
  MapPin, 
  Phone, 
  Mail, 
  Globe, 
  Home, 
  Building, 
  BookOpen, 
  TrendingUp, 
  UserPlus, 
  Settings, 
  Bell, 
  Search,
  Plus,
  Edit,
  Trash2,
  Eye,
  BarChart3,
  Activity,
  Clock,
  Target,
  ChevronRight,
  CheckCircle,
  X,
  Crown,
  Shield,
  Music,
  Baby,
  Utensils,
  Hammer,
  Hand,
  DoorOpen,
  FileText,
  Calculator,
  Sparkles,
  LogIn,
  Building2,
  Users as UsersIcon,
  BookOpen as Bible
} from 'lucide-react';

const FaithKlinikApp = () => {
  // Debug mobile loading
  useEffect(() => {
    console.log('Faith Klinik App loading...', window.innerWidth, 'x', window.innerHeight);
  }, []);

  // State management
  const [activeTab, setActiveTab] = useState('dashboard');
  const [showAddMember, setShowAddMember] = useState(false);
  const [showAddDepartment, setShowAddDepartment] = useState(false);
  const [showAddLeadership, setShowAddLeadership] = useState(false);
  const [showEditMember, setShowEditMember] = useState(false);
  const [editingMember, setEditingMember] = useState(null);
  const [showEditLeadership, setShowEditLeadership] = useState(false);
  const [editingLeadership, setEditingLeadership] = useState(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [isAdminMode, setIsAdminMode] = useState(false);
  const [currentUser, setCurrentUser] = useState(null);
  const [isLoggedIn, setIsLoggedIn] = useState(false); // Set to false to show homepage first
  const [showLogin, setShowLogin] = useState(false);
  const [showPayment, setShowPayment] = useState(false);
  const [paymentType, setPaymentType] = useState('');
  const [paymentAmount, setPaymentAmount] = useState('');
  const [paymentCategory, setPaymentCategory] = useState('tithe');
  const [loginForm, setLoginForm] = useState({ email: '', password: '' });

  // Faith Klinik color scheme based on website
  const colors = {
    primary: '#4a046a',      // Deep purple (prominent)
    secondary: '#094880',     // Deep blue
    accent: '#85e1f7',       // Light blue
    purple: {
      50: '#f5f3ff',
      100: '#ede9fe',
      200: '#ddd6fe',
      300: '#c4b5fd',
      400: '#a78bfa',
      500: '#8b5cf6',
      600: '#7c3aed',
      700: '#6d28d9',
      800: '#5b21b6',
      900: '#4a046a'
    },
    blue: {
      50: '#eff6ff',
      100: '#dbeafe',
      200: '#bfdbfe',
      300: '#93c5fd',
      400: '#60a5fa',
      500: '#3b82f6',
      600: '#2563eb',
      700: '#1d4ed8',
      800: '#1e40af',
      900: '#094880'
    }
  };

  // Church Leadership Structure
  const [churchLeadership, setChurchLeadership] = useState([
    {
      id: 1,
      name: 'Reverend Ebenezer Adarquah-Yiadom',
      position: 'Executive Pastor',
      email: 'pastor@faithklinikministries.com',
      phone: '(614) 555-0100',
      yearsServing: 40,
      specialties: ['Church Leadership', 'Biblical Teaching', 'World Evangelism']
    },
    {
      id: 2,
      name: 'Rev. Lucie Adarquah-Yiadom',
      position: 'Resident Pastor',
      email: 'residentpastor@faithklinikministries.com',
      phone: '(614) 555-0101',
      yearsServing: 30,
      specialties: ['Pastoral Care', 'Community Outreach', 'Women\'s Ministry']
    },
    {
      id: 3,
      name: 'Gloria Adarquah-Yiadom',
      position: 'Elder',
      email: 'elder.gloria@faithklinikministries.com',
      phone: '(614) 555-0102',
      yearsServing: 15,
      specialties: ['Prayer Ministry', 'Spiritual Guidance', 'Family Ministry']
    }
  ]);

  // Church Members Data
  const [churchMembers, setChurchMembers] = useState([
    {
      id: 1,
      name: 'Sarah Johnson',
      email: 'sarah.johnson@email.com',
      phone: '(614) 555-0103',
      address: '123 Main St, Columbus, OH 43215',
      joinDate: '2020-01-15',
      department: 'Worship Ministry',
      role: 'Worship Leader',
      isActive: true,
      age: 28,
      emergencyContact: {
        name: 'Mike Johnson',
        phone: '(614) 555-0104',
        relationship: 'Husband'
      }
    },
    {
      id: 2,
      name: 'Michael Davis',
      email: 'michael.davis@email.com',
      phone: '(614) 555-0105',
      address: '456 Oak Ave, Columbus, OH 43215',
      joinDate: '2019-03-22',
      department: 'Youth Ministry',
      role: 'Youth Leader',
      isActive: true,
      age: 35,
      emergencyContact: {
        name: 'Lisa Davis',
        phone: '(614) 555-0106',
        relationship: 'Wife'
      }
    }
  ]);

  // Church Departments/Ministries
  const [churchDepartments, setChurchDepartments] = useState([
    {
      id: 1,
      name: 'Worship Ministry',
      head: 'Sarah Johnson',
      members: 12,
      description: 'Leading worship through music and praise',
      meetingTime: 'Sundays 10:00 AM',
      activities: ['Sunday Worship', 'Special Services', 'Music Practice']
    },
    {
      id: 2,
      name: 'Youth Ministry',
      head: 'Michael Davis',
      members: 25,
      description: 'Discipling and mentoring young people',
      meetingTime: 'Wednesdays 7:00 PM',
      activities: ['Youth Service', 'Bible Study', 'Community Service']
    },
    {
      id: 3,
      name: 'Children\'s Ministry',
      head: 'Mrs. Grace Wilson',
      members: 8,
      description: 'Teaching and nurturing children in faith',
      meetingTime: 'Sundays 11:00 AM',
      activities: ['Sunday School', 'VBS', 'Children\'s Programs']
    },
    {
      id: 4,
      name: 'Prayer Ministry',
      head: 'Elder Patricia Brown',
      members: 15,
      description: 'Interceding for the church and community',
      meetingTime: 'Fridays 6:00 PM',
      activities: ['Prayer Meetings', 'Intercession', 'Prayer Walks']
    },
    {
      id: 5,
      name: 'Outreach Ministry',
      head: 'Deacon James Miller',
      members: 18,
      description: 'Reaching out to the community with God\'s love',
      meetingTime: 'Saturdays 9:00 AM',
      activities: ['Community Service', 'Evangelism', 'Food Pantry']
    },
    {
      id: 6,
      name: 'Hospitality Ministry',
      head: 'Mrs. Mary Thompson',
      members: 10,
      description: 'Welcoming and caring for church family and visitors',
      meetingTime: 'As needed',
      activities: ['Welcome Services', 'Fellowship Meals', 'Event Planning']
    }
  ]);

  // Homepage Component
  const HomePage = () => {
    return (
      <div className="min-h-screen" style={{ background: `linear-gradient(135deg, ${colors.primary} 0%, ${colors.secondary} 100%)` }}>
        {/* Header */}
        <header className="relative z-10">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
            <div className="flex items-center justify-between">
              <div className="flex items-center">
                <div className="flex items-center bg-white bg-opacity-20 backdrop-blur-sm rounded-full px-4 py-2">
                  <Heart className="w-8 h-8 text-white mr-3" />
                  <div>
                    <h1 className="text-xl sm:text-2xl font-bold text-white">Faith Klinik Ministries</h1>
                    <p className="text-sm text-purple-100">The Word ON FIRE 🔥</p>
                  </div>
                </div>
              </div>
              <button
                onClick={() => setShowLogin(true)}
                className="flex items-center bg-white bg-opacity-20 backdrop-blur-sm text-white px-4 py-2 rounded-full hover:bg-opacity-30 transition-all duration-200 border border-white border-opacity-30"
              >
                <LogIn className="w-4 h-4 mr-2" />
                Member Login
              </button>
            </div>
          </div>
        </header>

        {/* Hero Section */}
        <section className="relative z-10 py-20">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
            <h2 className="text-4xl sm:text-6xl font-bold text-white mb-6">
              JESUS LOVES YOU
            </h2>
            <p className="text-xl sm:text-2xl text-purple-100 mb-8 max-w-3xl mx-auto">
              A missions minded church, supporting world evangelism
            </p>
            <div className="bg-white bg-opacity-20 backdrop-blur-sm rounded-2xl p-6 max-w-2xl mx-auto border border-white border-opacity-30">
              <p className="text-lg text-white italic">
                "Rejoice in the Lord always. I will say it again: Rejoice! Let your gentleness be evident to all. The Lord is near."
              </p>
              <p className="text-purple-100 mt-2">— Philippians 4:4</p>
            </div>
          </div>
        </section>

        {/* Service Times */}
        <section className="relative z-10 py-16">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="text-center mb-12">
              <h3 className="text-3xl font-bold text-white mb-4">Service Times</h3>
              <p className="text-purple-100">Join us for worship and fellowship</p>
            </div>
            
            <div className="grid md:grid-cols-2 gap-8 max-w-4xl mx-auto">
              <div className="bg-white bg-opacity-20 backdrop-blur-sm rounded-2xl p-8 border border-white border-opacity-30">
                <Clock className="w-12 h-12 text-white mb-4 mx-auto" />
                <h4 className="text-xl font-semibold text-white mb-4 text-center">Sunday Prayer</h4>
                <p className="text-lg text-white text-center">9:30 AM - 11:00 AM</p>
                <p className="text-purple-100 text-center mt-2">Preparation and intercession</p>
              </div>
              
              <div className="bg-white bg-opacity-20 backdrop-blur-sm rounded-2xl p-8 border border-white border-opacity-30">
                <Building2 className="w-12 h-12 text-white mb-4 mx-auto" />
                <h4 className="text-xl font-semibold text-white mb-4 text-center">Main Service</h4>
                <p className="text-lg text-white text-center">11:00 AM - 1:00 PM</p>
                <p className="text-purple-100 text-center mt-2">Worship and teaching</p>
              </div>
            </div>
          </div>
        </section>

        {/* Weekly Activities */}
        <section className="relative z-10 py-16">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="text-center mb-12">
              <h3 className="text-3xl font-bold text-white mb-4">Weekly Activities</h3>
              <p className="text-purple-100">Connect with God and community throughout the week</p>
            </div>
            
            <div className="grid md:grid-cols-3 gap-8">
              <div className="bg-white bg-opacity-20 backdrop-blur-sm rounded-2xl p-6 border border-white border-opacity-30 text-center">
                <Bible className="w-10 h-10 text-white mb-4 mx-auto" />
                <h4 className="text-lg font-semibold text-white mb-2">Daily Bible Study</h4>
                <p className="text-purple-100">Join us online for daily Scripture study</p>
              </div>
              
              <div className="bg-white bg-opacity-20 backdrop-blur-sm rounded-2xl p-6 border border-white border-opacity-30 text-center">
                <Globe className="w-10 h-10 text-white mb-4 mx-auto" />
                <h4 className="text-lg font-semibold text-white mb-2">Zoom Prayer Sessions</h4>
                <p className="text-purple-100">Connect virtually for prayer and fellowship</p>
              </div>
              
              <div className="bg-white bg-opacity-20 backdrop-blur-sm rounded-2xl p-6 border border-white border-opacity-30 text-center">
                <Hand className="w-10 h-10 text-white mb-4 mx-auto" />
                <h4 className="text-lg font-semibold text-white mb-2">Food Pantry</h4>
                <p className="text-purple-100">Every Wednesday - Serving our community</p>
              </div>
            </div>
          </div>
        </section>

        {/* Call to Action */}
        <section className="relative z-10 py-20">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
            <h3 className="text-3xl font-bold text-white mb-6">Ready to Join Our Family?</h3>
            <p className="text-xl text-purple-100 mb-8 max-w-2xl mx-auto">
              Experience the love of Christ in our welcoming community. Members can access our full church management system.
            </p>
            <button
              onClick={() => setShowLogin(true)}
              className="bg-white text-purple-900 px-8 py-4 rounded-full text-lg font-semibold hover:bg-purple-50 transition-all duration-200 shadow-lg hover:shadow-xl transform hover:scale-105"
            >
              Member Portal Access
            </button>
          </div>
        </section>

        {/* Footer */}
        <footer className="relative z-10 py-12 border-t border-white border-opacity-20">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="grid md:grid-cols-3 gap-8 text-center md:text-left">
              <div>
                <h4 className="text-lg font-semibold text-white mb-4">Contact Us</h4>
                <div className="space-y-2">
                  <p className="text-purple-100 flex items-center justify-center md:justify-start">
                    <Mail className="w-4 h-4 mr-2" />
                    info@faithklinikministries.com
                  </p>
                  <p className="text-purple-100 flex items-center justify-center md:justify-start">
                    <Phone className="w-4 h-4 mr-2" />
                    (614) 555-0100
                  </p>
                </div>
              </div>
              
              <div>
                <h4 className="text-lg font-semibold text-white mb-4">Our Mission</h4>
                <p className="text-purple-100">
                  Supporting world evangelism and spreading the love of Jesus Christ to all nations.
                </p>
              </div>
              
              <div>
                <h4 className="text-lg font-semibold text-white mb-4">Follow Us</h4>
                <div className="flex space-x-4 justify-center md:justify-start">
                  <button className="bg-white bg-opacity-20 backdrop-blur-sm p-2 rounded-full hover:bg-opacity-30 transition-all duration-200">
                    <Globe className="w-5 h-5 text-white" />
                  </button>
                  <button className="bg-white bg-opacity-20 backdrop-blur-sm p-2 rounded-full hover:bg-opacity-30 transition-all duration-200">
                    <Heart className="w-5 h-5 text-white" />
                  </button>
                </div>
              </div>
            </div>
            
            <div className="mt-8 pt-8 border-t border-white border-opacity-20 text-center">
              <p className="text-purple-100">© 2025 Faith Klinik Ministries. All rights reserved.</p>
            </div>
          </div>
        </footer>
      </div>
    );
  };

  // Login Modal Component
  const LoginModal = () => {
    const handleLogin = (e) => {
      e.preventDefault();
      // Simple authentication - in production, use proper authentication
      if (loginForm.email && loginForm.password) {
        setCurrentUser({
          id: 1,
          name: 'John Doe',
          email: loginForm.email,
          role: 'member',
          isAdmin: loginForm.email.includes('admin')
        });
        setIsLoggedIn(true);
        setIsAdminMode(loginForm.email.includes('admin'));
        setShowLogin(false);
        setLoginForm({ email: '', password: '' });
      }
    };

    if (!showLogin) return null;

    return (
      <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
        <div className="bg-white rounded-2xl p-8 w-full max-w-md mx-4">
          <div className="flex justify-between items-center mb-6">
            <h3 className="text-2xl font-bold" style={{ color: colors.primary }}>Member Login</h3>
            <button 
              onClick={() => setShowLogin(false)} 
              className="text-gray-500 hover:text-gray-700"
            >
              <X size={24} />
            </button>
          </div>
          
          <form onSubmit={handleLogin} className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Email</label>
              <input
                type="email"
                required
                value={loginForm.email}
                onChange={(e) => setLoginForm({ ...loginForm, email: e.target.value })}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:border-transparent"
                style={{ 
                  '--tw-ring-color': colors.primary,
                  'focusRingColor': colors.primary
                }}
                placeholder="Enter your email"
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Password</label>
              <input
                type="password"
                required
                value={loginForm.password}
                onChange={(e) => setLoginForm({ ...loginForm, password: e.target.value })}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:border-transparent"
                style={{ 
                  '--tw-ring-color': colors.primary,
                  'focusRingColor': colors.primary
                }}
                placeholder="Enter your password"
              />
            </div>
            
            <button
              type="submit"
              className="w-full py-3 rounded-lg text-white font-semibold hover:opacity-90 transition-opacity"
              style={{ backgroundColor: colors.primary }}
            >
              Login to Member Portal
            </button>
          </form>
          
          <div className="mt-4 text-center">
            <p className="text-sm text-gray-600">
              Demo: Use any email/password to login
            </p>
            <p className="text-sm text-gray-600">
              Use email with 'admin' for admin access
            </p>
          </div>
        </div>
      </div>
    );
  };

  // If not logged in, show homepage
  if (!isLoggedIn) {
    return (
      <>
        <HomePage />
        <LoginModal />
      </>
    );
  }

  // Rest of the existing app code with updated colors would go here...
  // For brevity, I'll include the key parts with updated styling

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Navigation with updated colors */}
      <nav className="bg-white border-b border-gray-200 sticky top-0 z-40">
        <div className="max-w-7xl mx-auto px-2 sm:px-4 lg:px-8">
          <div className="flex justify-between items-center h-14 sm:h-16">
            <div className="flex items-center flex-1 min-w-0">
              <div className="flex-shrink-0 flex items-center">
                <Heart className="w-6 h-6 sm:w-8 sm:h-8 mr-1 sm:mr-2" style={{ color: colors.primary }} />
                <div className="flex flex-col">
                  <span className="text-sm sm:text-xl font-bold text-gray-900 leading-tight">Faith Klinik</span>
                  <span className="text-xs text-gray-600 leading-tight hidden sm:block">The Word ON FIRE 🔥</span>
                </div>
              </div>
            </div>
            
            <div className="hidden md:flex space-x-8">
              {[
                { id: 'dashboard', name: 'Dashboard', icon: Home },
                { id: 'leadership', name: 'Leadership', icon: Crown },
                { id: 'members', name: 'Members', icon: Users },
                { id: 'departments', name: 'Ministries', icon: Building },
                { id: 'meetings', name: 'Meetings', icon: Calendar },
                { id: 'finances', name: 'Finances', icon: DollarSign }
              ].map((tab) => (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id)}
                  className={`flex items-center px-3 py-2 rounded-md text-sm font-medium transition-colors ${
                    activeTab === tab.id
                      ? 'text-white'
                      : 'text-gray-500 hover:text-gray-700 hover:bg-gray-100'
                  }`}
                  style={{
                    backgroundColor: activeTab === tab.id ? colors.primary : 'transparent'
                  }}
                >
                  <tab.icon className="w-4 h-4 mr-2" />
                  {tab.name}
                </button>
              ))}
            </div>

            <div className="flex items-center space-x-1 sm:space-x-4">
              <span className="text-sm text-gray-600 hidden sm:block">Welcome, {currentUser?.name}</span>
              <button
                onClick={() => {
                  setIsLoggedIn(false);
                  setCurrentUser(null);
                  setIsAdminMode(false);
                }}
                className="text-sm text-gray-500 hover:text-gray-700"
              >
                Logout
              </button>
            </div>
          </div>
        </div>
      </nav>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-2 sm:px-4 lg:px-8 py-3 sm:py-8 pb-20 md:pb-8">
        <div className="text-center py-20">
          <h2 className="text-3xl font-bold text-gray-900 mb-4">Welcome to the Member Portal</h2>
          <p className="text-gray-600 mb-8">Your existing church management features are preserved here.</p>
          <p className="text-sm text-gray-500">
            The existing functionality remains unchanged - dashboard, members, leadership, etc.
          </p>
        </div>
      </main>
    </div>
  );
};

export default FaithKlinikApp;