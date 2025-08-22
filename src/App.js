import EnhancedFaithKlinikApp from './EnhancedFaithKlinikApp';

const App = () => {
  return <EnhancedFaithKlinikApp />;
};

export default App;

/* 
ORIGINAL APP CODE PRESERVED BELOW FOR REFERENCE

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
  Menu,
  CreditCard,
  Smartphone,
  AlertCircle,
  CheckCircle2,
  Receipt,
  Send,
  BellRing
} from 'lucide-react';

const FaithKlinikApp = () => {
  // Early return for loading state
  const [isLoading, setIsLoading] = useState(true);

  // Debug mobile loading
  useEffect(() => {
    // Set loading to false after initial render
    setTimeout(() => setIsLoading(false), 100);
  }, []);

  useEffect(() => {
    console.log('Faith Klinik App loading...', window.innerWidth, 'x', window.innerHeight);
    
    // Add mobile-specific styles
    const style = document.createElement('style');
    style.textContent = `
      * {
        -webkit-tap-highlight-color: rgba(0,0,0,0);
        -webkit-touch-callout: none;
        -webkit-user-select: none;
        -khtml-user-select: none;
        -moz-user-select: none;
        -ms-user-select: none;
        user-select: none;
      }
      
      input, textarea {
        -webkit-user-select: text;
        -khtml-user-select: text;
        -moz-user-select: text;
        -ms-user-select: text;
        user-select: text;
      }
      
      button {
        cursor: pointer;
        touch-action: manipulation;
      }
    `;
    document.head.appendChild(style);
    
    return () => {
      document.head.removeChild(style);
    };
  }, []);

  const [activeTab, setActiveTab] = useState('dashboard');
  const [showAddMember, setShowAddMember] = useState(false);
  const [showAddDepartment, setShowAddDepartment] = useState(false);
  const [showAddLeadership, setShowAddLeadership] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [showLogin, setShowLogin] = useState(false);
  const [currentUser, setCurrentUser] = useState(null);
  const [loginForm, setLoginForm] = useState({ username: '', password: '' });
  const [showCommunication, setShowCommunication] = useState(false);
  const [showMeetingMinutes, setShowMeetingMinutes] = useState(false);
  const [selectedMeeting, setSelectedMeeting] = useState(null);
  const [meetingMinutes, setMeetingMinutes] = useState('');
  const [showMobileMenu, setShowMobileMenu] = useState(false);
  const [showPaymentModal, setShowPaymentModal] = useState(false);
  const [showNotificationSettings, setShowNotificationSettings] = useState(false);
  const [paymentType, setPaymentType] = useState('tithe');
  const [paymentAmount, setPaymentAmount] = useState('');
  
  // Department and member management state
  const [showManageDepartment, setShowManageDepartment] = useState(false);
  const [selectedDepartment, setSelectedDepartment] = useState(null);
  const [showMemberProfile, setShowMemberProfile] = useState(false);
  const [selectedMember, setSelectedMember] = useState(null);
  const [showDepartmentApplication, setShowDepartmentApplication] = useState(false);
  const [showEditProfile, setShowEditProfile] = useState(false);
  const [editingMember, setEditingMember] = useState(null);

  // Prayer Schedule State
  const [prayerSchedule, setPrayerSchedule] = useState([
    { day: 'Monday', time: '8:00 PM - 9:00 PM', leader: 'Rev. Ebenezer Adarquah-Yiadom', type: 'Daily Prayer' },
    { day: 'Tuesday', time: '8:00 PM - 9:00 PM', leader: 'Rev. Lucie Adarquah-Yiadom', type: 'Daily Prayer' },
    { day: 'Wednesday', time: '8:00 PM - 9:00 PM', leader: 'Gloria Adarquah-Yiadom', type: 'Daily Prayer' },
    { day: 'Thursday', time: '8:00 PM - 9:00 PM', leader: 'Rev. Ebenezer Adarquah-Yiadom', type: 'Daily Prayer' },
    { day: 'Friday', time: '8:00 PM - 9:30 PM', leader: 'Rev. Lucie Adarquah-Yiadom', type: 'Bible Study' },
    { day: 'Saturday', time: '6:00 AM - 9:00 AM', leaders: ['Rev. Ebenezer Adarquah-Yiadom', 'Rev. Lucie Adarquah-Yiadom', 'Gloria Adarquah-Yiadom'], type: 'Morning Prayer' },
    { day: 'Sunday', time: '9:30 AM - 11:00 AM', leader: 'Rev. Ebenezer Adarquah-Yiadom', type: 'Pre-Service Prayer' }
  ]);

  // New enhanced features state
  const [sermons, setSermons] = useState([
    {
      id: 1,
      title: "Walking in Faith",
      date: "2024-07-28",
      series: "Living Boldly",
      scripture: "Hebrews 11:1",
      audioUrl: "/sermons/walking-in-faith.mp3",
      videoUrl: "/sermons/walking-in-faith.mp4",
      notes: "Key points about faith and trust in God's promises...",
      downloads: 45,
      views: 120,
      pastor: "Rev. Ebenezer Adarquah-Yiadom"
    },
    {
      id: 2,
      title: "Love Your Neighbor",
      date: "2024-07-21",
      series: "Living Boldly",
      scripture: "Matthew 22:39",
      audioUrl: "/sermons/love-your-neighbor.mp3",
      videoUrl: "/sermons/love-your-neighbor.mp4",
      notes: "Understanding what it means to truly love others...",
      downloads: 67,
      views: 198,
      pastor: "Rev. Ebenezer Adarquah-Yiadom"
    }
  ]);

  const [prayerRequests, setPrayerRequests] = useState([
    {
      id: 1,
      request: "Please pray for my family's health and healing",
      author: "Anonymous",
      authorId: null,
      date: "2024-07-25",
      prayers: 12,
      answered: false,
      isPublic: true,
      category: "Health"
    },
    {
      id: 2,
      request: "Seeking God's guidance for career decision",
      author: "Mary Johnson",
      authorId: 2,
      date: "2024-07-24",
      prayers: 8,
      answered: false,
      isPublic: true,
      category: "Guidance"
    }
  ]);

  const [kidsBadges, setKidsBadges] = useState([
    { id: 1, name: "Bible Reader", description: "Read 10 Bible stories", earned: true, date: "2024-07-20", icon: "📖" },
    { id: 2, name: "Helper", description: "Help with 5 church activities", earned: false, progress: 60, icon: "🤝" },
    { id: 3, name: "Prayer Warrior", description: "Pray daily for 7 days", earned: true, date: "2024-07-15", icon: "🙏" },
    { id: 4, name: "Memory Master", description: "Memorize 5 Bible verses", earned: false, progress: 40, icon: "🧠" }
  ]);

  const [visitorInfo, setVisitorInfo] = useState({
    name: '',
    email: '',
    phone: '',
    interests: [],
    visitReason: '',
    followUpPreference: 'email',
    ageGroup: 'adult',
    familySize: 1
  });

  const [liveService, setLiveService] = useState({
    isLive: false,
    title: "Sunday Morning Worship",
    startTime: "2024-07-28T10:00:00",
    viewers: 0,
    streamUrl: "https://stream.faithklinik.com/live"
  });

  const [smallGroups, setSmallGroups] = useState([
    {
      id: 1,
      name: "Young Adults Fellowship",
      leader: "Pastor Mike",
      schedule: "Wednesdays 7:00 PM",
      location: "Youth Center",
      members: 15,
      maxMembers: 20,
      description: "A group for young adults aged 18-35 to grow in faith together"
    },
    {
      id: 2,
      name: "Women's Bible Study",
      leader: "Sister Grace",
      schedule: "Saturdays 9:00 AM",
      location: "Conference Room",
      members: 12,
      maxMembers: 15,
      description: "Weekly Bible study focusing on women's spiritual growth"
    }
  ]);

  const [devotionals, setDevotionals] = useState([
    {
      id: 1,
      date: "2024-07-28",
      title: "Trust in His Timing",
      verse: "Ecclesiastes 3:1",
      verseText: "To every thing there is a season, and a time to every purpose under the heaven.",
      content: "God's timing is perfect, even when we don't understand it. Today, let's trust in His perfect plan for our lives...",
      author: "Rev. Ebenezer Adarquah-Yiadom"
    }
  ]);
  const [paymentHistory, setPaymentHistory] = useState([
    {
      id: 1,
      memberId: 1,
      memberName: 'Rev. Ebenezer Adarquah-Yiadom',
      type: 'tithe',
      amount: 500,
      date: '2024-07-15',
      status: 'paid',
      method: 'cash',
      dueDate: '2024-07-31'
    },
    {
      id: 2,
      memberId: 2,
      memberName: 'Rev. Lucie Adarquah-Yiadom',
      type: 'missions',
      amount: 200,
      date: '2024-07-10',
      status: 'paid',
      method: 'bank_transfer',
      dueDate: '2024-07-31'
    }
  ]);
  const [smsNotifications, setSmsNotifications] = useState({
    enabled: true,
    reminderDays: 7,
    phone: '',
    messages: []
  });
  const [messages, setMessages] = useState([
    {
      id: 1,
      from: 'Admin',
      to: 'All Members',
      subject: 'Welcome to Faith Klinik Church Management',
      message: 'Welcome to our new church management system! Please update your profile information.',
      timestamp: new Date().toISOString(),
      read: false
    }
  ]);
  const [userPermissions, setUserPermissions] = useState({
    // Pastor permissions - highest level access
    pastor: {
      canEditAll: true,
      canEditMembers: true,
      canEditLeadership: true,
      canEditDepartments: true,
      canEditFinances: true,
      canEditMeetings: true,
      canAssignPermissions: true,
      canCommunicate: true,
      canAccessPastoralCare: true,
      canManageSermons: true,
      canViewAnalytics: true,
      canLiveStream: true
    },
    // Admin permissions
    admin: {
      canEditAll: true,
      canEditMembers: true,
      canEditLeadership: true,
      canEditDepartments: true,
      canEditFinances: true,
      canEditMeetings: true,
      canAssignPermissions: true,
      canCommunicate: true,
      canAccessPastoralCare: false,
      canManageSermons: false,
      canViewAnalytics: true,
      canLiveStream: false
    },
    // Ministry leader permissions
    leader: {
      canEditAll: false,
      canEditMembers: false,
      canEditLeadership: false,
      canEditDepartments: false,
      canEditFinances: false,
      canEditMeetings: false,
      canAssignPermissions: false,
      canCommunicate: true,
      canAccessPastoralCare: false,
      canManageSermons: false,
      canViewAnalytics: false,
      canLiveStream: false,
      canManageMinistry: true,
      canScheduleEvents: true
    },
    // Regular member permissions
    member: {
      canEditAll: false,
      canEditMembers: false,
      canEditLeadership: false,
      canEditDepartments: false,
      canEditFinances: false,
      canEditMeetings: false,
      canAssignPermissions: false,
      canCommunicate: true,
      canAccessPastoralCare: false,
      canManageSermons: false,
      canViewAnalytics: false,
      canLiveStream: false,
      canSubmitPrayerRequest: true,
      canJoinGroups: true,
      canGive: true
    },
    // Child permissions - safe & moderated
    child: {
      canEditAll: false,
      canEditMembers: false,
      canEditLeadership: false,
      canEditDepartments: false,
      canEditFinances: false,
      canEditMeetings: false,
      canAssignPermissions: false,
      canCommunicate: true, // moderated
      canAccessPastoralCare: false,
      canManageSermons: false,
      canViewAnalytics: false,
      canLiveStream: false,
      canAccessKidsContent: true,
      canEarnBadges: true,
      canPlayGames: true
    },
    // Visitor permissions - limited access
    visitor: {
      canEditAll: false,
      canEditMembers: false,
      canEditLeadership: false,
      canEditDepartments: false,
      canEditFinances: false,
      canEditMeetings: false,
      canAssignPermissions: false,
      canCommunicate: false,
      canAccessPastoralCare: false,
      canManageSermons: false,
      canViewAnalytics: false,
      canLiveStream: false,
      canViewPublicContent: true,
      canRequestInfo: true,
      canWatchServices: true
    }
  });

  // Faith Klinik color scheme - purple prominent with website blues
  const colors = {
    primary: '#4a046a',      // Deep purple (prominent)
    secondary: '#094880',     // Deep blue from website
    accent: '#85e1f7',       // Light blue from website
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
      name: 'Rev. Ebenezer Adarquah-Yiadom',
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
  
  // Church Members Data - Start with real leadership, others can be added by admin
  const [members, setMembers] = useState([
    { 
      id: 1, 
      name: 'Rev. Ebenezer Adarquah-Yiadom', 
      email: 'pastor@faithklinikministries.com', 
      phone: '(614) 555-0100', 
      department: 'Leadership', 
      membershipDate: '2019-05-10',
      tithe: 0,
      missions: 0,
      building: 0,
      status: 'Leadership',
      ministryInvolvement: ['Executive Pastor', 'Missions Director'],
      emergencyContact: 'Rev. Lucie Adarquah-Yiadom - (614) 555-0101',
      address: '123 Faith Avenue, Columbus, OH 43215',
      birthDate: '1975-03-15',
      maritalStatus: 'Married',
      familyId: 1,
      familyRole: 'head',
      canEdit: [2], // Can edit spouse
      role: 'admin'
    },
    { 
      id: 2, 
      name: 'Rev. Lucie Adarquah-Yiadom', 
      email: 'residentpastor@faithklinikministries.com', 
      phone: '(614) 555-0101', 
      department: 'Leadership', 
      membershipDate: '2019-05-10',
      tithe: 0,
      missions: 0,
      building: 0,
      status: 'Leadership',
      ministryInvolvement: ['Resident Pastor', 'Women\'s Ministry'],
      emergencyContact: 'Rev. Ebenezer Adarquah-Yiadom - (614) 555-0100',
      address: '123 Faith Avenue, Columbus, OH 43215',
      birthDate: '1978-07-22',
      maritalStatus: 'Married',
      familyId: 1,
      familyRole: 'spouse',
      canEdit: [1], // Can edit spouse
      role: 'admin'
    },
    { 
      id: 3, 
      name: 'Gloria Adarquah-Yiadom', 
      email: 'elder.gloria@faithklinikministries.com', 
      phone: '(614) 555-0102', 
      department: 'Leadership', 
      membershipDate: '2019-05-10',
      tithe: 0,
      missions: 0,
      building: 0,
      status: 'Leadership',
      ministryInvolvement: ['Elder', 'Prayer Ministry'],
      emergencyContact: 'Rev. Ebenezer Adarquah-Yiadom - (614) 555-0100',
      address: '456 Elder Street, Columbus, OH 43216',
      birthDate: '1965-11-30',
      maritalStatus: 'Single'
    }
  ]);

  // Communication Component
  const CommunicationModal = () => {
    const [newMessage, setNewMessage] = useState({
      to: '',
      subject: '',
      message: ''
    });
    const [showNewMessage, setShowNewMessage] = useState(false);

    const handleSendMessage = (e) => {
      e.preventDefault();
      const message = {
        id: messages.length + 1,
        from: currentUser.name,
        to: newMessage.to,
        subject: newMessage.subject,
        message: newMessage.message,
        timestamp: new Date().toISOString(),
        read: false
      };
      setMessages([...messages, message]);
      setNewMessage({ to: '', subject: '', message: '' });
      setShowNewMessage(false);
    };

    if (!showCommunication) return null;

    return (
      <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
        <div className="bg-white rounded-xl w-full max-w-4xl mx-4 max-h-[90vh] overflow-y-auto">
          <div className="p-6 border-b border-gray-200">
            <div className="flex justify-between items-center">
              <h3 className="text-xl font-semibold text-gray-900">Communication Center</h3>
              <button 
                onClick={() => setShowCommunication(false)}
                className="text-gray-500 hover:text-gray-700"
              >
                <X size={24} />
              </button>
            </div>
          </div>
          
          <div className="p-6">
            <div className="flex justify-between items-center mb-4">
              <h4 className="text-lg font-medium text-gray-900">Messages</h4>
              <button
                onClick={() => setShowNewMessage(true)}
                className="flex items-center px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors"
              >
                <Plus className="w-4 h-4 mr-2" />
                New Message
              </button>
            </div>
            
            {showNewMessage && (
              <div className="mb-6 p-4 bg-gray-50 rounded-lg">
                <form onSubmit={handleSendMessage} className="space-y-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">To</label>
                    <select
                      required
                      value={newMessage.to}
                      onChange={(e) => setNewMessage({...newMessage, to: e.target.value})}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                    >
                      <option value="">Select recipient</option>
                      <option value="All Members">All Members</option>
                      <option value="All Leaders">All Leaders</option>
                      {departments.map(dept => (
                        <option key={dept.id} value={dept.name}>{dept.name}</option>
                      ))}
                    </select>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Subject</label>
                    <input
                      type="text"
                      required
                      value={newMessage.subject}
                      onChange={(e) => setNewMessage({...newMessage, subject: e.target.value})}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                      placeholder="Enter message subject"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Message</label>
                    <textarea
                      required
                      value={newMessage.message}
                      onChange={(e) => setNewMessage({...newMessage, message: e.target.value})}
                      rows={4}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                      placeholder="Enter your message"
                    />
                  </div>
                  <div className="flex space-x-3">
                    <button
                      type="button"
                      onClick={() => setShowNewMessage(false)}
                      className="flex-1 px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition-colors"
                    >
                      Cancel
                    </button>
                    <button
                      type="submit"
                      className="flex-1 px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors"
                    >
                      Send Message
                    </button>
                  </div>
                </form>
              </div>
            )}
            
            <div className="space-y-3">
              {messages.map((message) => (
                <div key={message.id} className="p-4 bg-gray-50 rounded-lg">
                  <div className="flex justify-between items-start mb-2">
                    <div>
                      <h5 className="font-medium text-gray-900">{message.subject}</h5>
                      <p className="text-sm text-gray-600">From: {message.from} • To: {message.to}</p>
                    </div>
                    <span className="text-xs text-gray-500">
                      {new Date(message.timestamp).toLocaleDateString()}
                    </span>
                  </div>
                  <p className="text-gray-700">{message.message}</p>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    );
  };

  // Enhanced departments with complete structure
  const [departments, setDepartments] = useState([
    { 
      id: 1, 
      name: 'Food Pantry Ministry', 
      leaders: ['Deaconness Esinam Segoh'],
      assistant: '',
      secretary: '',
      treasurer: '',
      members: 15, 
      membersList: [],
      budget: 30000,
      expenses: 22000,
      description: 'Providing food assistance to families in need in our community',
      meetingDay: 'Wednesday',
      meetingTime: '6:00 PM',
      meetingLocation: 'Fellowship Hall',
      projects: ['Weekly Food Distribution', 'Holiday Food Baskets', 'Community Outreach'],
      icon: Utensils,
      color: 'green',
      joinRequests: []
    },
    { 
      id: 2, 
      name: 'Faith Klinik Dance Ministers', 
      leaders: ['Enam Egyir'],
      teacher: 'Samuel Ghartey',
      assistant: '',
      secretary: '',
      treasurer: '',
      members: 12, 
      membersList: ['Eyram Kwauvi', 'Edem Kwauvi'],
      budget: 15000,
      expenses: 8000,
      description: 'Expressing worship through dance and movement',
      meetingDay: 'Every Saturday',
      meetingTime: '10:00 AM',
      meetingLocation: 'Main Sanctuary',
      projects: ['Sunday Morning Worship', 'Special Events', 'Youth Dance Training'],
      icon: Music,
      color: 'purple',
      joinRequests: []
    },
    { 
      id: 3, 
      name: 'League of Anointed Ministers (Music Ministry)', 
      leaders: ['Jedidiah Adarquah-Yiadom'],
      assistant: '',
      secretary: '',
      treasurer: '',
      members: 20, 
      membersList: [],
      budget: 35000,
      expenses: 25000,
      description: 'Leading congregation in worship through music and praise',
      meetingDay: 'Every Thursday',
      meetingTime: '7:00 PM',
      meetingLocation: 'Music Room',
      projects: ['Sunday Worship', 'Special Concerts', 'Music Training'],
      icon: Music,
      color: 'blue',
      joinRequests: []
    },
    { 
      id: 4, 
      name: 'Media Ministry', 
      leaders: ['Jasper D.'],
      assistant: '',
      secretary: '',
      treasurer: '',
      members: 8, 
      membersList: [],
      budget: 25000,
      expenses: 18000,
      description: 'Managing audio, video, and digital media for church services',
      meetingDay: 'Second Saturday of the month',
      meetingTime: '2:00 PM',
      meetingLocation: 'Media Room',
      projects: ['Live Streaming', 'Service Recording', 'Website Management'],
      icon: Globe,
      color: 'red',
      joinRequests: []
    },
    { 
      id: 5, 
      name: 'Youth Ministry', 
      leaders: ['Jeshurun Adarquah-Yiadom'],
      assistant: '',
      secretary: '',
      treasurer: '',
      members: 25, 
      membersList: [],
      budget: 30000,
      expenses: 20000,
      description: 'Engaging and discipling the next generation in their faith journey',
      meetingDay: 'Every Friday',
      meetingTime: '7:00 PM',
      meetingLocation: 'Youth Room',
      projects: ['Youth Retreat', 'Community Service', 'Bible Study Groups'],
      icon: Users,
      color: 'orange',
      joinRequests: []
    },
    { 
      id: 6, 
      name: 'Prayer Ministry', 
      leaders: ['Rev. Ebenezer Adarquah-Yiadom', 'Rev. Lucie Adarquah-Yiadom', 'Gloria Adarquah-Yiadom'],
      assistant: '',
      secretary: '',
      treasurer: '',
      members: 30, 
      membersList: [],
      budget: 5000,
      expenses: 2000,
      description: 'Coordinating prayer meetings and intercession for the church and community',
      meetingDay: 'Multiple days - see prayer schedule',
      meetingTime: 'Various times',
      meetingLocation: 'Prayer Room',
      projects: ['Daily Prayer Meetings', 'Prayer Chain', 'Intercession Groups'],
      icon: Heart,
      color: 'pink',
      joinRequests: []
    }
  ]);

  const [meetings, setMeetings] = useState([
    { 
      id: 1, 
      title: 'Sunday Worship Service', 
      date: '2024-07-07', 
      time: '10:00 AM',
      attendees: [],
      minutes: '',
      location: 'Main Sanctuary'
    },
    { 
      id: 2, 
      title: 'Prayer Group Meeting', 
      date: '2024-07-08', 
      time: '7:00 PM',
      attendees: [],
      minutes: '',
      location: 'Prayer Room'
    },
    { 
      id: 3, 
      title: 'Women\'s Ministry Fellowship', 
      date: '2024-07-10', 
      time: '9:00 AM',
      attendees: [],
      minutes: '',  
      location: 'Fellowship Hall'
    }
  ]);

  const totalTithes = members.reduce((sum, member) => sum + member.tithe, 0);
  const totalMissions = members.reduce((sum, member) => sum + member.missions, 0);
  const totalBuilding = members.reduce((sum, member) => sum + member.building, 0);
  const totalMembers = members.length;
  const activeMembers = members.filter(m => m.status === 'Active').length;
  const totalDepartments = departments.length;
  const totalDepartmentMembers = departments.reduce((sum, dept) => sum + dept.members, 0);

  const filteredMembers = members.filter(member =>
    member.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    member.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
    member.department.toLowerCase().includes(searchTerm.toLowerCase())
  );

  // SMS Notification Functions
  const sendSMSNotification = (phoneNumber, message) => {
    // In a real app, this would integrate with SMS service
    console.log(`SMS to ${phoneNumber}: ${message}`);
  };

  // Payment processing functions
  const processPayment = (paymentData) => {
    const newPayment = {
      id: Date.now(),
      memberId: currentUser.id,
      memberName: currentUser.name,
      amount: parseFloat(paymentData.amount),
      type: paymentData.type,
      date: new Date().toISOString().split('T')[0],
      method: paymentData.method || 'Credit Card',
      status: 'Completed',
      dueDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0]
    };
    
    setPaymentHistory([...paymentHistory, newPayment]);
    
    // Update member's payment record
    const updatedMembers = members.map(member => {
      if (member.id === currentUser.id) {
        return {
          ...member,
          [paymentData.type]: member[paymentData.type] + parseFloat(paymentData.amount)
        };
      }
      return member;
    });
    
    setMembers(updatedMembers);
    
    // Send confirmation SMS if enabled
    if (smsNotifications.enabled && currentUser.phone) {
      sendSMSNotification(currentUser.phone, `Payment confirmed: $${paymentData.amount} for ${paymentData.type}. Thank you for your contribution!`);
    }
    
    return newPayment;
  };

  const checkOverduePayments = () => {
    const today = new Date().toISOString().split('T')[0];
    const overdueMembers = members.filter(member => {
      const lastPayment = paymentHistory.find(p => p.memberId === member.id && p.type === 'tithe');
      if (!lastPayment) return true;
      return lastPayment.dueDate < today;
    });
    
    // Send SMS reminders for overdue payments
    overdueMembers.forEach(member => {
      if (member.phone) {
        sendSMSNotification(member.phone, `Reminder: Your monthly tithe payment is overdue. Please make your payment at your earliest convenience.`);
      }
    });
    
    return overdueMembers;
  };

  const sendBulkSMSReminders = () => {
    const overdueMembers = checkOverduePayments();
    let sentCount = 0;
    
    overdueMembers.forEach(member => {
      if (member.phone) {
        sendSMSNotification(member.phone, `Faith Klinik Ministries: Your monthly tithe payment is overdue. Please visit the app to make your payment.`);
        sentCount++;
      }
    });
    
    return sentCount;
  };

  // Auto-run payment checks on component mount
  useEffect(() => {
    if (currentUser?.role === 'admin') {
      const overdueCount = checkOverduePayments().length;
      if (overdueCount > 0) {
        console.log(`${overdueCount} members have overdue payments`);
      }
    }
  }, [currentUser]);

  // Get navigation items based on user role
  // Helper functions for birthdays
  const getTodaysBirthdays = () => {
    const today = new Date();
    const todayMonth = today.getMonth() + 1;
    const todayDate = today.getDate();
    
    return members.filter(member => {
      if (!member.birthDate) return false;
      const birthDate = new Date(member.birthDate);
      return birthDate.getMonth() + 1 === todayMonth && birthDate.getDate() === todayDate;
    });
  };

  const getUpcomingBirthdays = () => {
    const today = new Date();
    const next7Days = new Date(today.getTime() + 7 * 24 * 60 * 60 * 1000);
    
    return members.filter(member => {
      if (!member.birthDate) return false;
      const birthDate = new Date(member.birthDate);
      const thisYear = today.getFullYear();
      const birthdayThisYear = new Date(thisYear, birthDate.getMonth(), birthDate.getDate());
      
      return birthdayThisYear >= today && birthdayThisYear <= next7Days;
    });
  };

  const formatBirthday = (birthDate) => {
    if (!birthDate) return 'Not provided';
    const date = new Date(birthDate);
    return date.toLocaleDateString('en-US', { month: 'long', day: 'numeric' });
  };

  // Profile editing functions
  const handleEditProfile = (member) => {
    setEditingMember({...member});
    setShowEditProfile(true);
  };

  const handleSaveProfile = () => {
    setMembers(members.map(m => 
      m.id === editingMember.id ? editingMember : m
    ));
    setShowEditProfile(false);
    setEditingMember(null);
    
    // Update current user if editing own profile
    if (currentUser && currentUser.id === editingMember.id) {
      setCurrentUser(editingMember);
    }
  };

  const handleJoinMinistry = (departmentId) => {
    const department = departments.find(d => d.id === departmentId);
    if (!department || !currentUser) return;

    // Add join request
    const updatedDepartments = departments.map(d => {
      if (d.id === departmentId) {
        const existingRequest = d.joinRequests?.find(r => r.memberId === currentUser.id);
        if (existingRequest) return d; // Already requested

        return {
          ...d,
          joinRequests: [...(d.joinRequests || []), {
            id: Date.now(),
            memberId: currentUser.id,
            memberName: currentUser.name,
            memberEmail: currentUser.email,
            requestDate: new Date().toISOString().split('T')[0],
            status: 'pending'
          }]
        };
      }
      return d;
    });

    setDepartments(updatedDepartments);
    alert(`Your request to join ${department.name} has been submitted!`);
  };

  const handleApproveJoinRequest = (departmentId, requestId, approve) => {
    const updatedDepartments = departments.map(d => {
      if (d.id === departmentId) {
        const request = d.joinRequests?.find(r => r.id === requestId);
        if (!request) return d;

        if (approve) {
          // Add member to ministry involvement
          const updatedMembers = members.map(m => {
            if (m.id === request.memberId) {
              return {
                ...m,
                ministryInvolvement: [...(m.ministryInvolvement || []), d.name]
              };
            }
            return m;
          });
          setMembers(updatedMembers);

          // Increase member count
          return {
            ...d,
            members: d.members + 1,
            membersList: [...(d.membersList || []), request.memberName],
            joinRequests: d.joinRequests.filter(r => r.id !== requestId)
          };
        } else {
          // Remove request
          return {
            ...d,
            joinRequests: d.joinRequests.filter(r => r.id !== requestId)
          };
        }
      }
      return d;
    });

    setDepartments(updatedDepartments);
  };

  // Permission checking functions
  const canEditMember = (memberId) => {
    if (!currentUser) return false;
    
    // Admin can edit anyone
    if (currentUser.role === 'admin') return true;
    
    // Can edit themselves
    if (currentUser.id === memberId) return true;
    
    // Can edit family members
    const member = members.find(m => m.id === memberId);
    if (member && member.familyId === currentUser.familyId) return true;
    
    // Can edit members in their canEdit array
    if (currentUser.canEdit && currentUser.canEdit.includes(memberId)) return true;
    
    // Leaders can edit their ministry members
    if (currentUser.role === 'leader') {
      const userDepartments = departments.filter(d => d.leaders && d.leaders.includes(currentUser.name));
      const memberDepartments = member?.ministryInvolvement || [];
      return userDepartments.some(dept => memberDepartments.includes(dept.name));
    }
    
    return false;
  };
  
  const canManageDepartment = (departmentName) => {
    if (!currentUser) return false;
    
    // Admin can manage all departments
    if (currentUser.role === 'admin') return true;
    
    // Leaders can manage their own departments
    if (currentUser.role === 'leader') {
      const department = departments.find(d => d.name === departmentName);
      return department && department.leaders && department.leaders.includes(currentUser.name);
    }
    
    return false;
  };
  
  const getNavigationItems = () => {
    if (!currentUser) return [];
    
    const baseItems = [
      { id: 'dashboard', name: 'Home', icon: Home },
      { id: 'services', name: 'Services', icon: Calendar },
      { id: 'community', name: 'Community', icon: Users }
    ];

    switch(currentUser.role) {
      case 'pastor':
        return [
          ...baseItems,
          { id: 'sermons', name: 'Sermons', icon: BookOpen },
          { id: 'pastoral-care', name: 'Pastoral Care', icon: Heart },
          { id: 'analytics', name: 'Analytics', icon: BarChart3 },
          { id: 'members', name: 'Members', icon: Users },
          { id: 'leadership', name: 'Leadership', icon: Crown },
          { id: 'finances', name: 'Finances', icon: DollarSign }
        ];
      
      case 'admin':
        return [
          ...baseItems,
          { id: 'members', name: 'Members', icon: Users },
          { id: 'departments', name: 'Ministries', icon: Building },
          { id: 'finances', name: 'Finances', icon: DollarSign },
          { id: 'meetings', name: 'Meetings', icon: Calendar },
          { id: 'settings', name: 'Settings', icon: Settings }
        ];
      
      case 'leader':
        return [
          ...baseItems,
          { id: 'my-ministry', name: 'My Ministry', icon: Building },
          { id: 'team', name: 'Team', icon: Users },
          { id: 'events', name: 'Events', icon: Calendar },
          { id: 'meetings', name: 'Meetings', icon: Calendar }
        ];
      
      case 'child':
        return [
          { id: 'kids-home', name: 'Home', icon: Home },
          { id: 'bible-stories', name: 'Stories', icon: BookOpen },
          { id: 'games', name: 'Games', icon: Sparkles },
          { id: 'friends', name: 'Friends', icon: Users },
          { id: 'badges', name: 'Badges', icon: Crown }
        ];
      
      case 'visitor':
        return [
          { id: 'welcome', name: 'Welcome', icon: DoorOpen },
          { id: 'about', name: 'About Us', icon: Building2 },
          { id: 'services', name: 'Services', icon: Calendar },
          { id: 'connect', name: 'Connect', icon: Users }
        ];
      
      case 'treasurer':
        return [
          ...baseItems,
          { id: 'finances', name: 'Finances', icon: DollarSign },
          { id: 'departments', name: 'Ministries', icon: Building }
        ];
      
      default: // member
        return [
          ...baseItems,
          { id: 'prayer', name: 'Prayer', icon: Heart },
          { id: 'groups', name: 'Groups', icon: Users },
          { id: 'giving', name: 'Give', icon: CreditCard },
          { id: 'profile', name: 'Profile', icon: Users }
        ];
    }
  };

  // Login Modal Component
  const LoginModal = () => {
    const [localUsername, setLocalUsername] = useState(loginForm.username);
    const [localPassword, setLocalPassword] = useState(loginForm.password);
    
    const handleLogin = (e) => {
      e.preventDefault();
      // Enhanced authentication with role-based access
      if (localUsername && localPassword) {
        let user = null;
        
        // Pastor login
        if (localUsername === 'pastor' && localPassword === 'pastor123') {
          user = {
            id: 1,
            name: 'Rev. Ebenezer Adarquah-Yiadom',
            email: 'pastor@faithklinikministries.com',
            role: 'pastor',
            permissions: userPermissions.pastor,
            ministries: ['Leadership', 'Pastoral Care'],
            familyId: 1,
            familyRole: 'head',
            canEdit: [2, 3, 4, 5]
          };
        }
        // Admin login
        else if (localUsername === 'admin' && localPassword === 'admin123') {
          user = {
            id: 2,
            name: 'Church Administrator',
            email: 'admin@faithklinikministries.com',
            role: 'admin',
            permissions: userPermissions.admin,
            ministries: ['Administration'],
            familyId: 2,
            familyRole: 'head',
            canEdit: [3, 4, 5]
          };
        }
        // Ministry Leader login
        else if (localUsername === 'leader' && localPassword === 'leader123') {
          user = {
            id: 3,
            name: 'Ministry Leader',
            email: 'leader@faithklinikministries.com',
            role: 'leader',
            permissions: userPermissions.leader,
            ministries: ['Youth Ministry', 'Outreach'],
            familyId: 3,
            familyRole: 'head',
            canEdit: []
          };
        }
        // Child login
        else if (localUsername === 'child' && localPassword === 'child123') {
          user = {
            id: 5,
            name: 'Emma Johnson',
            email: 'child@faithklinikministries.com',
            role: 'child',
            permissions: userPermissions.child,
            ministries: ['Children Ministry'],
            familyId: 4,
            familyRole: 'child',
            canEdit: [],
            age: 10
          };
        }
        // Visitor login
        else if (localUsername === 'visitor' && localPassword === 'visitor123') {
          user = {
            id: 6,
            name: 'Guest User',
            email: 'guest@example.com',
            role: 'visitor',
            permissions: userPermissions.visitor,
            ministries: [],
            familyId: null,
            familyRole: null,
            canEdit: []
          };
        }
        // Treasurer login
        else if (localUsername === 'treasurer' && localPassword === 'treasurer123') {
          user = {
            id: 4,
            name: 'Church Treasurer',
            email: 'treasurer@faithklinikministries.com',
            role: 'treasurer',
            permissions: {
              ...userPermissions.member,
              canEditFinances: true,
              canEditDepartments: false
            },
            ministries: ['Finance Ministry'],
            familyId: 4,
            familyRole: 'head',
            canEdit: []
          };
        }
        // Regular member login
        else if (localUsername && localPassword) {
          user = {
            id: 7,
            name: localUsername,
            email: localUsername + '@faithklinikministries.com',
            role: 'member',
            permissions: userPermissions.member,
            ministries: ['Small Groups'],
            familyId: 5,
            familyRole: 'member',
            canEdit: []
          };
        }
        
        if (user) {
          setCurrentUser(user);
          setIsLoggedIn(true);
          setShowLogin(false);
          setLoginForm({ username: '', password: '' });
          setLocalUsername('');
          setLocalPassword('');
        }
      }
    };

    const handleUsernameChange = (e) => {
      setLocalUsername(e.target.value);
    };

    const handlePasswordChange = (e) => {
      setLocalPassword(e.target.value);
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
              <label className="block text-sm font-medium text-gray-700 mb-1">Username</label>
              <input
                type="text"
                required
                value={localUsername}
                onChange={handleUsernameChange}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                placeholder="Enter your username"
                autoComplete="username"
                style={{ fontSize: '16px' }}
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Password</label>
              <input
                type="password"
                required
                value={localPassword}
                onChange={handlePasswordChange}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                placeholder="Enter your password"
                autoComplete="current-password"
                style={{ fontSize: '16px' }}
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
            <div className="text-sm text-gray-600 space-y-1">
              <p><strong>🔐 Demo Accounts:</strong></p>
              <div className="grid grid-cols-2 gap-2 text-xs">
                <p>👨‍💼 Pastor: pastor / pastor123</p>
                <p>⚙️ Admin: admin / admin123</p>
                <p>👥 Leader: leader / leader123</p>
                <p>💰 Treasurer: treasurer / treasurer123</p>
                <p>👶 Child: child / child123</p>
                <p>🚪 Visitor: visitor / visitor123</p>
              </div>
              <p className="text-xs mt-2">👤 Member: any username / any password</p>
            </div>
          </div>
        </div>
      </div>
    );
  };

  // Meeting Minutes Modal
  const MeetingMinutesModal = () => {
    const handleSaveMinutes = (e) => {
      e.preventDefault();
      const updatedMeetings = meetings.map(meeting => 
        meeting.id === selectedMeeting.id 
          ? { ...meeting, minutes: meetingMinutes }
          : meeting
      );
      setMeetings(updatedMeetings);
      setShowMeetingMinutes(false);
      setSelectedMeeting(null);
      setMeetingMinutes('');
    };

    const handleOpenMinutes = (meeting) => {
      setSelectedMeeting(meeting);
      setMeetingMinutes(meeting.minutes || '');
      setShowMeetingMinutes(true);
    };

    if (!showMeetingMinutes) return null;

    return (
      <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
        <div className="bg-white rounded-xl w-full max-w-2xl mx-4 max-h-[90vh] overflow-y-auto">
          <div className="p-6 border-b border-gray-200">
            <div className="flex justify-between items-center">
              <h3 className="text-xl font-semibold text-gray-900">Meeting Minutes</h3>
              <button 
                onClick={() => setShowMeetingMinutes(false)}
                className="text-gray-500 hover:text-gray-700"
              >
                <X size={24} />
              </button>
            </div>
          </div>
          
          <div className="p-6">
            <div className="mb-4">
              <h4 className="text-lg font-medium text-gray-900">{selectedMeeting?.title}</h4>
              <p className="text-sm text-gray-600">{selectedMeeting?.date} at {selectedMeeting?.time}</p>
              <p className="text-sm text-gray-600">Led by {selectedMeeting?.leader}</p>
            </div>
            
            <form onSubmit={handleSaveMinutes} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Minutes</label>
                <textarea
                  value={meetingMinutes}
                  onChange={(e) => setMeetingMinutes(e.target.value)}
                  rows={10}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                  placeholder="Enter meeting minutes..."
                  readOnly={!hasPermission('canEditMeetings')}
                />
              </div>
              
              {hasPermission('canEditMeetings') && (
                <div className="flex space-x-3">
                  <button
                    type="button"
                    onClick={() => setShowMeetingMinutes(false)}
                    className="flex-1 px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition-colors"
                  >
                    Cancel
                  </button>
                  <button
                    type="submit"
                    className="flex-1 px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors"
                  >
                    Save Minutes
                  </button>
                </div>
              )}
            </form>
          </div>
        </div>
      </div>
    );
  };

  // Payment Modal Component
  const PaymentModal = () => {
    const [localPaymentData, setLocalPaymentData] = useState({
      type: 'tithe',
      amount: '',
      method: 'cash',
      notes: ''
    });

    const handlePayment = (e) => {
      e.preventDefault();
      if (localPaymentData.amount && parseFloat(localPaymentData.amount) > 0) {
        processPayment(localPaymentData);
        setShowPaymentModal(false);
        setLocalPaymentData({
          type: 'tithe',
          amount: '',
          method: 'cash',
          notes: ''
        });
        
        // Show success message
        alert(`Payment of $${localPaymentData.amount} for ${localPaymentData.type} processed successfully!`);
      }
    };

    if (!showPaymentModal) return null;

    return (
      <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
        <div className="bg-white rounded-xl w-full max-w-md mx-4 max-h-[90vh] overflow-y-auto">
          <div className="p-6 border-b border-gray-200">
            <div className="flex justify-between items-center">
              <h3 className="text-xl font-semibold text-gray-900">Make Payment</h3>
              <button 
                onClick={() => setShowPaymentModal(false)}
                className="text-gray-500 hover:text-gray-700"
              >
                <X size={24} />
              </button>
            </div>
          </div>
          
          <div className="p-6">
            <form onSubmit={handlePayment} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Payment Type</label>
                <select
                  value={localPaymentData.type}
                  onChange={(e) => setLocalPaymentData({...localPaymentData, type: e.target.value})}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                >
                  <option value="tithe">Tithe</option>
                  <option value="missions">Missions Fund</option>
                  <option value="building">Building Fund</option>
                  <option value="offering">Special Offering</option>
                </select>
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Amount ($)</label>
                <input
                  type="number"
                  step="0.01"
                  min="0"
                  required
                  value={localPaymentData.amount}
                  onChange={(e) => setLocalPaymentData({...localPaymentData, amount: e.target.value})}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                  placeholder="Enter amount"
                  style={{ fontSize: '16px' }}
                />
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Payment Method</label>
                <select
                  value={localPaymentData.method}
                  onChange={(e) => setLocalPaymentData({...localPaymentData, method: e.target.value})}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                >
                  <option value="cash">Cash</option>
                  <option value="check">Check</option>
                  <option value="bank_transfer">Bank Transfer</option>
                  <option value="credit_card">Credit Card</option>
                  <option value="mobile_payment">Mobile Payment</option>
                </select>
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Notes (Optional)</label>
                <textarea
                  value={localPaymentData.notes}
                  onChange={(e) => setLocalPaymentData({...localPaymentData, notes: e.target.value})}
                  rows={3}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                  placeholder="Add any notes about this payment"
                />
              </div>
              
              <div className="flex space-x-3 pt-4">
                <button
                  type="button"
                  onClick={() => setShowPaymentModal(false)}
                  className="flex-1 px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition-colors"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="flex-1 px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors"
                >
                  Process Payment
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>
    );
  };

  // SMS Notification Settings Modal
  const SMSNotificationModal = () => {
    const [localSMSSettings, setLocalSMSSettings] = useState({
      enabled: smsNotifications.enabled,
      reminderDays: smsNotifications.reminderDays,
      phone: smsNotifications.phone
    });

    const handleSaveSettings = (e) => {
      e.preventDefault();
      setSmsNotifications(prev => ({
        ...prev,
        enabled: localSMSSettings.enabled,
        reminderDays: localSMSSettings.reminderDays,
        phone: localSMSSettings.phone
      }));
      setShowNotificationSettings(false);
      alert('SMS notification settings saved successfully!');
    };

    const handleSendTestSMS = () => {
      if (localSMSSettings.phone) {
        sendSMSNotification(localSMSSettings.phone, 'Test message from Faith Klinik Ministries app. SMS notifications are working!');
        alert('Test SMS sent successfully!');
      }
    };

    if (!showNotificationSettings) return null;

    return (
      <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
        <div className="bg-white rounded-xl w-full max-w-md mx-4 max-h-[90vh] overflow-y-auto">
          <div className="p-6 border-b border-gray-200">
            <div className="flex justify-between items-center">
              <h3 className="text-xl font-semibold text-gray-900">SMS Notifications</h3>
              <button 
                onClick={() => setShowNotificationSettings(false)}
                className="text-gray-500 hover:text-gray-700"
              >
                <X size={24} />
              </button>
            </div>
          </div>
          
          <div className="p-6">
            <form onSubmit={handleSaveSettings} className="space-y-4">
              <div className="flex items-center justify-between">
                <label className="text-sm font-medium text-gray-700">Enable SMS Notifications</label>
                <label className="relative inline-flex items-center cursor-pointer">
                  <input
                    type="checkbox"
                    checked={localSMSSettings.enabled}
                    onChange={(e) => setLocalSMSSettings({...localSMSSettings, enabled: e.target.checked})}
                    className="sr-only peer"
                  />
                  <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-purple-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-purple-600"></div>
                </label>
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Phone Number</label>
                <input
                  type="tel"
                  value={localSMSSettings.phone}
                  onChange={(e) => setLocalSMSSettings({...localSMSSettings, phone: e.target.value})}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                  placeholder="(614) 555-0123"
                  style={{ fontSize: '16px' }}
                />
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Reminder Days Before Due</label>
                <select
                  value={localSMSSettings.reminderDays}
                  onChange={(e) => setLocalSMSSettings({...localSMSSettings, reminderDays: parseInt(e.target.value)})}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                >
                  <option value={3}>3 days</option>
                  <option value={5}>5 days</option>
                  <option value={7}>7 days</option>
                  <option value={14}>14 days</option>
                </select>
              </div>
              
              <div className="pt-4">
                <button
                  type="button"
                  onClick={handleSendTestSMS}
                  className="w-full mb-3 px-4 py-2 border border-purple-300 text-purple-700 rounded-lg hover:bg-purple-50 transition-colors"
                >
                  Send Test SMS
                </button>
              </div>
              
              <div className="flex space-x-3">
                <button
                  type="button"
                  onClick={() => setShowNotificationSettings(false)}
                  className="flex-1 px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition-colors"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="flex-1 px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors"
                >
                  Save Settings
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>
    );
  };

  // Add Member Modal Component
  const AddMemberModal = () => {
    const [newMember, setNewMember] = useState({
      name: '',
      email: '',
      phone: '',
      role: 'member'
    });

    const handleSubmit = (e) => {
      e.preventDefault();
      const member = {
        id: members.length + 1,
        ...newMember
      };
      setMembers([...members, member]);
      setNewMember({ name: '', email: '', phone: '', role: 'member' });
      setShowAddMember(false);
      alert(`${newMember.name} has been added successfully!`);
    };

    if (!showAddMember) return null;

    return (
      <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
        <div className="bg-white rounded-lg shadow-xl w-full max-w-md mx-4">
          <div className="p-6">
            <div className="flex justify-between items-center mb-4">
              <h3 className="text-lg font-semibold text-gray-900">Add New Member</h3>
              <button
                onClick={() => setShowAddMember(false)}
                className="text-gray-400 hover:text-gray-600"
              >
                <X className="w-5 h-5" />
              </button>
            </div>
            
            <form onSubmit={handleSubmit} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Name</label>
                <input
                  type="text"
                  required
                  value={newMember.name}
                  onChange={(e) => setNewMember({...newMember, name: e.target.value})}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                  placeholder="Enter member name"
                />
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Email</label>
                <input
                  type="email"
                  required
                  value={newMember.email}
                  onChange={(e) => setNewMember({...newMember, email: e.target.value})}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                  placeholder="Enter email address"
                />
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Phone</label>
                <input
                  type="tel"
                  required
                  value={newMember.phone}
                  onChange={(e) => setNewMember({...newMember, phone: e.target.value})}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                  placeholder="Enter phone number"
                />
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Role</label>
                <select
                  value={newMember.role}
                  onChange={(e) => setNewMember({...newMember, role: e.target.value})}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                >
                  <option value="member">Member</option>
                  <option value="leader">Leader</option>
                  {currentUser?.role === 'admin' && (
                    <>
                      <option value="treasurer">Treasurer</option>
                      <option value="admin">Admin</option>
                    </>
                  )}
                </select>
              </div>
              
              <div className="flex space-x-3">
                <button
                  type="button"
                  onClick={() => setShowAddMember(false)}
                  className="flex-1 px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition-colors"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="flex-1 px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors"
                >
                  Add Member
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>
    );
  };

  // Department Management Modal
  const DepartmentManagementModal = () => {
    if (!showManageDepartment || !selectedDepartment) return null;

    const departmentMembers = members.filter(m => 
      m.ministryInvolvement && m.ministryInvolvement.includes(selectedDepartment.name)
    );

    return (
      <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
        <div className="bg-white rounded-lg shadow-xl w-full max-w-2xl mx-4 max-h-[90vh] overflow-y-auto">
          <div className="p-6">
            <div className="flex justify-between items-center mb-6">
              <h3 className="text-xl font-semibold text-gray-900">
                Manage {selectedDepartment.name}
              </h3>
              <button
                onClick={() => {
                  setShowManageDepartment(false);
                  setSelectedDepartment(null);
                }}
                className="text-gray-400 hover:text-gray-600"
              >
                <X className="w-6 h-6" />
              </button>
            </div>

            <div className="space-y-6">
              {/* Department Info */}
              <div className="bg-gray-50 p-4 rounded-lg">
                <h4 className="font-medium text-gray-900 mb-2">Department Information</h4>
                <p className="text-sm text-gray-600 mb-2">{selectedDepartment.description}</p>
                <p className="text-sm text-purple-600">Leader: {selectedDepartment.leader}</p>
              </div>

              {/* Members */}
              <div>
                <h4 className="font-medium text-gray-900 mb-3">
                  Department Members ({departmentMembers.length})
                </h4>
                <div className="space-y-2">
                  {departmentMembers && departmentMembers.length > 0 ? departmentMembers.map(member => (
                    <div key={member.id} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                      <div>
                        <p className="font-medium text-gray-900">{member.name}</p>
                        <p className="text-sm text-gray-600">{member.email}</p>
                      </div>
                      <div className="flex space-x-2">
                        <button
                          onClick={() => {
                            setSelectedMember(member);
                            setShowMemberProfile(true);
                          }}
                          className="text-xs bg-purple-100 text-purple-800 px-2 py-1 rounded hover:bg-purple-200"
                        >
                          View Profile
                        </button>
                        {canEditMember(member.id) && (
                          <button
                            onClick={() => {
                              setSelectedMember(member);
                              setShowAddMember(true);
                            }}
                            className="text-xs bg-blue-100 text-blue-800 px-2 py-1 rounded hover:bg-blue-200"
                          >
                            Edit
                          </button>
                        )}
                      </div>
                    </div>
                  )) : <p className="text-gray-500 text-center py-4">No members found in this department.</p>}
                </div>
              </div>

              {/* Add Member to Department */}
              {(currentUser?.role === 'admin' || canManageDepartment(selectedDepartment.name)) && (
                <div>
                  <h4 className="font-medium text-gray-900 mb-3">Add Member to Department</h4>
                  <button
                    onClick={() => {
                      setShowAddMember(true);
                    }}
                    className="bg-purple-600 text-white px-4 py-2 rounded-lg hover:bg-purple-700 transition-colors"
                  >
                    Add Member
                  </button>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    );
  };

  // Member Profile Modal
  const MemberProfileModal = () => {
    if (!showMemberProfile || !selectedMember) return null;

    return (
      <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
        <div className="bg-white rounded-lg shadow-xl w-full max-w-md mx-4">
          <div className="p-6">
            <div className="flex justify-between items-center mb-4">
              <h3 className="text-lg font-semibold text-gray-900">Member Profile</h3>
              <button
                onClick={() => {
                  setShowMemberProfile(false);
                  setSelectedMember(null);
                }}
                className="text-gray-400 hover:text-gray-600"
              >
                <X className="w-5 h-5" />
              </button>
            </div>
            
            <div className="space-y-4">
              <div>
                <h4 className="font-medium text-gray-900">{selectedMember.name}</h4>
                <p className="text-sm text-gray-600">{selectedMember.email}</p>
                <p className="text-sm text-gray-600">{selectedMember.phone}</p>
              </div>
              
              <div>
                <h5 className="font-medium text-gray-900 mb-2">Ministry Involvement</h5>
                <div className="flex flex-wrap gap-1">
                  {selectedMember.ministryInvolvement?.map((ministry, index) => (
                    <span key={index} className="text-xs bg-purple-100 text-purple-800 px-2 py-1 rounded">
                      {ministry}
                    </span>
                  ))}
                </div>
              </div>
              
              <div>
                <h5 className="font-medium text-gray-900 mb-2">Contact Info</h5>
                <p className="text-sm text-gray-600">Emergency: {selectedMember.emergencyContact}</p>
                <p className="text-sm text-gray-600">Status: {selectedMember.status}</p>
              </div>

              {canEditMember(selectedMember.id) && (
                <div className="pt-4 border-t">
                  <button
                    onClick={() => {
                      alert(`Profile editing for ${selectedMember.name} would be implemented here`);
                    }}
                    className="w-full bg-purple-600 text-white px-4 py-2 rounded-lg hover:bg-purple-700 transition-colors"
                  >
                    Edit Profile
                  </button>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    );
  };

  // Department Application Modal
  const DepartmentApplicationModal = () => {
    const [application, setApplication] = useState({
      department: '',
      reason: '',
      experience: '',
      availability: ''
    });

    const handleSubmit = (e) => {
      e.preventDefault();
      // Here you would typically send the application to the server
      alert(`Application submitted for ${application.department}!\n\nYour application has been sent to the ministry leader for review. You will be notified once it's processed.`);
      setApplication({ department: '', reason: '', experience: '', availability: '' });
      setShowDepartmentApplication(false);
    };

    if (!showDepartmentApplication) return null;

    return (
      <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
        <div className="bg-white rounded-lg shadow-xl w-full max-w-md mx-4">
          <div className="p-6">
            <div className="flex justify-between items-center mb-4">
              <h3 className="text-lg font-semibold text-gray-900">Apply for Ministry</h3>
              <button
                onClick={() => setShowDepartmentApplication(false)}
                className="text-gray-400 hover:text-gray-600"
              >
                <X className="w-5 h-5" />
              </button>
            </div>
            
            <form onSubmit={handleSubmit} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Select Ministry</label>
                <select
                  required
                  value={application.department}
                  onChange={(e) => setApplication({...application, department: e.target.value})}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                >
                  <option value="">Choose a ministry...</option>
                  {departments.map(dept => (
                    <option key={dept.id} value={dept.name}>{dept.name}</option>
                  ))}
                </select>
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Why do you want to join this ministry?</label>
                <textarea
                  required
                  value={application.reason}
                  onChange={(e) => setApplication({...application, reason: e.target.value})}
                  rows={3}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                  placeholder="Share your passion and calling..."
                />
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Relevant Experience</label>
                <textarea
                  value={application.experience}
                  onChange={(e) => setApplication({...application, experience: e.target.value})}
                  rows={2}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                  placeholder="Any relevant experience or skills..."
                />
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Availability</label>
                <input
                  type="text"
                  value={application.availability}
                  onChange={(e) => setApplication({...application, availability: e.target.value})}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                  placeholder="e.g., Sundays, Wednesdays, etc."
                />
              </div>
              
              <div className="flex space-x-3">
                <button
                  type="button"
                  onClick={() => setShowDepartmentApplication(false)}
                  className="flex-1 px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition-colors"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="flex-1 px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors"
                >
                  Submit Application
                </button>
              </div>
            </form>
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

  // Show loading screen
  if (isLoading) {
    return (
      <div className="min-h-screen bg-purple-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-pulse">
            <Heart className="w-16 h-16 text-purple-600 mx-auto mb-4" />
          </div>
          <h1 className="text-2xl font-bold text-purple-800 mb-2">Faith Klinik Ministries</h1>
          <p className="text-purple-600">Loading...</p>
        </div>
      </div>
    );
  }

  // Main return statement for logged-in users
  return (
    <div className="min-h-screen bg-gray-50">
      {/* Navigation */}
      <nav className="bg-white border-b border-gray-200 sticky top-0 z-50 safe-area-top">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 safe-area-left safe-area-right">
          <div className="flex justify-between items-center h-16">
            <div className="flex items-center">
              {/* Mobile menu button - moved to left side */}
              <button
                onClick={() => setShowMobileMenu(!showMobileMenu)}
                className="md:hidden p-2 text-gray-600 hover:text-gray-900 mr-2"
              >
                <Menu className="w-6 h-6" />
              </button>
              
              <div className="flex-shrink-0 flex items-center">
                <Heart className="w-8 h-8 text-purple-600 mr-2" />
                <span className="text-xl font-bold text-gray-900">Faith Klinik</span>
              </div>
            </div>
            
            {/* Desktop Navigation */}
            <div className="hidden md:flex space-x-8">
              {getNavigationItems().map((tab) => (
                <button
                  key={tab.id}
                  onClick={() => {
                    console.log('Tab clicked:', tab.id);
                    setActiveTab(tab.id);
                  }}
                  className={`flex items-center px-3 py-2 text-sm font-medium rounded-md transition-colors ${
                    activeTab === tab.id
                      ? 'bg-purple-100 text-purple-700'
                      : 'text-gray-500 hover:text-gray-700 hover:bg-gray-100'
                  }`}
                >
                  <tab.icon className="w-4 h-4 mr-2" />
                  {tab.name}
                </button>
              ))}
            </div>

            {/* User Menu */}
            <div className="flex items-center space-x-4">
              <button 
                onClick={() => setShowCommunication(true)}
                className="p-2 text-gray-400 hover:text-gray-600 relative"
              >
                <Bell className="w-5 h-5" />
                <span className="absolute -top-1 -right-1 w-3 h-3 bg-red-500 rounded-full"></span>
              </button>
              
              <div className="hidden md:flex items-center space-x-3">
                <div className="text-right">
                  <p className="text-sm font-medium text-gray-900">{currentUser?.name}</p>
                  <p className="text-xs text-purple-600 capitalize">{currentUser?.role}</p>
                </div>
                <button
                  onClick={() => {
                    setIsLoggedIn(false);
                    setCurrentUser(null);
                    setActiveTab('dashboard');
                  }}
                  className="text-sm text-gray-500 hover:text-gray-700"
                >
                  Logout
                </button>
              </div>
            </div>
          </div>
        </div>

        {/* Mobile Navigation Dropdown */}
        {showMobileMenu && (
          <div className="md:hidden bg-white border-t border-gray-200 shadow-lg">
            <div className="px-2 pt-2 pb-3 space-y-1">
              {getNavigationItems().map((tab) => (
                <button
                  key={tab.id}
                  onClick={() => {
                    setActiveTab(tab.id);
                    setShowMobileMenu(false);
                  }}
                  className={`flex items-center w-full px-3 py-2 rounded-md text-sm font-medium transition-colors ${
                    activeTab === tab.id
                      ? 'bg-purple-100 text-purple-700'
                      : 'text-gray-500 hover:text-gray-700 hover:bg-gray-100'
                  }`}
                >
                  <tab.icon className="w-4 h-4 mr-3" />
                  {tab.name}
                </button>
              ))}
            </div>
            
            {/* Mobile User Actions */}
            <div className="px-2 pb-3 border-t border-gray-200">
              <div className="flex items-center justify-between px-3 py-2">
                <div>
                  <p className="text-sm text-gray-600">{currentUser?.name}</p>
                  <p className="text-xs text-purple-600 capitalize">{currentUser?.role}</p>
                </div>
                <div className="flex items-center space-x-2">
                  <button 
                    onClick={() => {
                      setShowCommunication(true);
                      setShowMobileMenu(false);
                    }}
                    className="p-2 text-gray-400 hover:text-gray-600 relative"
                  >
                    <Bell className="w-5 h-5" />
                    <span className="absolute -top-1 -right-1 w-3 h-3 bg-red-500 rounded-full"></span>
                  </button>
                  <button
                    onClick={() => {
                      setIsLoggedIn(false);
                      setCurrentUser(null);
                      setActiveTab('dashboard');
                      setShowMobileMenu(false);
                    }}
                    className="text-sm text-gray-500 hover:text-gray-700 px-3 py-2 rounded-md"
                  >
                    Logout
                  </button>
                </div>
              </div>
            </div>
          </div>
        )}
      </nav>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 md:py-8">
        {activeTab === 'dashboard' && (
          <div className="space-y-6">
            {/* Daily Devotional Widget */}
            <div className="bg-gradient-to-r from-purple-50 to-blue-50 rounded-lg shadow p-6">
              <div className="flex items-center mb-4">
                <BookOpen className="w-6 h-6 text-purple-600 mr-2" />
                <h3 className="text-lg font-semibold">Today's Devotional</h3>
              </div>
              {devotionals.length > 0 && (
                <>
                  <p className="text-sm text-gray-600 mb-2">{devotionals[0].verse}</p>
                  <p className="font-medium mb-3 text-purple-700">"{devotionals[0].verseText}"</p>
                  <p className="text-sm text-gray-700 mb-4">{devotionals[0].content.substring(0, 150)}...</p>
                  <button 
                    onClick={() => setActiveTab('devotionals')}
                    className="text-purple-600 text-sm hover:underline"
                  >
                    Read Full Devotional
                  </button>
                </>
              )}
            </div>

            {/* Live Service Indicator */}
            {liveService.isLive ? (
              <div className="bg-red-50 border border-red-200 rounded-lg p-4">
                <div className="flex items-center">
                  <div className="w-3 h-3 bg-red-500 rounded-full animate-pulse mr-3"></div>
                  <span className="text-red-800 font-medium">Service is LIVE now!</span>
                  <button 
                    onClick={() => window.open(liveService.streamUrl, '_blank')}
                    className="ml-auto bg-red-600 text-white px-4 py-2 rounded text-sm hover:bg-red-700"
                  >
                    Join Live
                  </button>
                </div>
              </div>
            ) : (
              <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
                <div className="flex items-center">
                  <Clock className="w-5 h-5 text-blue-600 mr-3" />
                  <span className="text-blue-800 font-medium">Next Service: Sunday 10:00 AM</span>
                  <button className="ml-auto bg-blue-600 text-white px-4 py-2 rounded text-sm hover:bg-blue-700">
                    Set Reminder
                  </button>
                </div>
              </div>
            )}

            <div className="bg-white rounded-lg shadow p-6">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">Welcome, {currentUser?.name}!</h2>
              <div className="mb-4 p-3 bg-blue-50 rounded-lg">
                <p className="text-sm text-blue-800">Role: <span className="font-semibold capitalize">{currentUser?.role}</span></p>
              </div>
              
              {/* Pastor Dashboard */}
              {currentUser?.role === 'pastor' && (
                <div className="space-y-6">
                  <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                    <div className="bg-purple-50 p-4 rounded-lg">
                      <div className="flex items-center">
                        <Users className="w-8 h-8 text-purple-600 mr-3" />
                        <div>
                          <p className="text-sm text-gray-600">Total Members</p>
                          <p className="text-2xl font-bold text-purple-600">{members.length}</p>
                        </div>
                      </div>
                    </div>
                    <div className="bg-green-50 p-4 rounded-lg">
                      <div className="flex items-center">
                        <BookOpen className="w-8 h-8 text-green-600 mr-3" />
                        <div>
                          <p className="text-sm text-gray-600">Sermons</p>
                          <p className="text-2xl font-bold text-green-600">{sermons.length}</p>
                        </div>
                      </div>
                    </div>
                    <div className="bg-blue-50 p-4 rounded-lg">
                      <div className="flex items-center">
                        <Heart className="w-8 h-8 text-blue-600 mr-3" />
                        <div>
                          <p className="text-sm text-gray-600">Prayer Requests</p>
                          <p className="text-2xl font-bold text-blue-600">{prayerRequests.length}</p>
                        </div>
                      </div>
                    </div>
                    <div className="bg-yellow-50 p-4 rounded-lg">
                      <div className="flex items-center">
                        <DollarSign className="w-8 h-8 text-yellow-600 mr-3" />
                        <div>
                          <p className="text-sm text-gray-600">Monthly Giving</p>
                          <p className="text-2xl font-bold text-yellow-600">$12,450</p>
                        </div>
                      </div>
                    </div>
                  </div>
                  <div className="bg-orange-50 border border-orange-200 rounded-lg p-4">
                    <h4 className="font-semibold text-orange-800 mb-2">Pastoral Care Needed</h4>
                    <p className="text-sm text-orange-700">3 members need pastoral visits this week</p>
                    <button 
                      onClick={() => setActiveTab('pastoral-care')}
                      className="mt-2 text-orange-600 text-sm hover:underline"
                    >
                      View Care List
                    </button>
                  </div>
                </div>
              )}
              
              {/* Admin Dashboard */}
              {currentUser?.role === 'admin' && (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                  <div className="bg-purple-50 p-4 rounded-lg">
                    <div className="flex items-center">
                      <Users className="w-8 h-8 text-purple-600 mr-3" />
                      <div>
                        <p className="text-sm text-gray-600">Total Members</p>
                        <p className="text-2xl font-bold text-purple-600">{members.length}</p>
                      </div>
                    </div>
                  </div>
                  <div className="bg-blue-50 p-4 rounded-lg">
                    <div className="flex items-center">
                      <Building className="w-8 h-8 text-blue-600 mr-3" />
                      <div>
                        <p className="text-sm text-gray-600">Ministries</p>
                        <p className="text-2xl font-bold text-blue-600">{departments.length}</p>
                      </div>
                    </div>
                  </div>
                  <div className="bg-green-50 p-4 rounded-lg">
                    <div className="flex items-center">
                      <Calendar className="w-8 h-8 text-green-600 mr-3" />
                      <div>
                        <p className="text-sm text-gray-600">Meetings</p>
                        <p className="text-2xl font-bold text-green-600">{meetings.length}</p>
                      </div>
                    </div>
                  </div>
                  <div className="bg-yellow-50 p-4 rounded-lg">
                    <div className="flex items-center">
                      <DollarSign className="w-8 h-8 text-yellow-600 mr-3" />
                      <div>
                        <p className="text-sm text-gray-600">Finances</p>
                        <p className="text-2xl font-bold text-yellow-600">$12,450</p>
                      </div>
                    </div>
                  </div>
                </div>
              )}
              
              {/* Leader Dashboard */}
              {currentUser?.role === 'leader' && (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                  <div className="bg-purple-50 p-4 rounded-lg">
                    <div className="flex items-center">
                      <Users className="w-8 h-8 text-purple-600 mr-3" />
                      <div>
                        <p className="text-sm text-gray-600">My Ministry Members</p>
                        <p className="text-2xl font-bold text-purple-600">{members.filter(m => m.role === 'member').length}</p>
                      </div>
                    </div>
                  </div>
                  <div className="bg-blue-50 p-4 rounded-lg">
                    <div className="flex items-center">
                      <Building className="w-8 h-8 text-blue-600 mr-3" />
                      <div>
                        <p className="text-sm text-gray-600">My Ministries</p>
                        <p className="text-2xl font-bold text-blue-600">2</p>
                      </div>
                    </div>
                  </div>
                  <div className="bg-green-50 p-4 rounded-lg">
                    <div className="flex items-center">
                      <Calendar className="w-8 h-8 text-green-600 mr-3" />
                      <div>
                        <p className="text-sm text-gray-600">Upcoming Events</p>
                        <p className="text-2xl font-bold text-green-600">{meetings.length}</p>
                      </div>
                    </div>
                  </div>
                </div>
              )}

              {/* Member Dashboard */}
              {currentUser?.role === 'member' && (
                <div className="space-y-6">
                  {/* Quick Actions */}
                  <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                    <button 
                      onClick={() => setActiveTab('prayer')}
                      className="bg-white p-4 rounded-lg shadow text-center hover:shadow-md border border-gray-200"
                    >
                      <Heart className="w-8 h-8 text-red-500 mx-auto mb-2" />
                      <span className="text-sm font-medium">Prayer Request</span>
                    </button>
                    <button 
                      onClick={() => setActiveTab('groups')}
                      className="bg-white p-4 rounded-lg shadow text-center hover:shadow-md border border-gray-200"
                    >
                      <Users className="w-8 h-8 text-blue-500 mx-auto mb-2" />
                      <span className="text-sm font-medium">Small Groups</span>
                    </button>
                    <button 
                      onClick={() => setActiveTab('community')}
                      className="bg-white p-4 rounded-lg shadow text-center hover:shadow-md border border-gray-200"
                    >
                      <Hand className="w-8 h-8 text-green-500 mx-auto mb-2" />
                      <span className="text-sm font-medium">Volunteer</span>
                    </button>
                    <button 
                      onClick={() => setActiveTab('giving')}
                      className="bg-white p-4 rounded-lg shadow text-center hover:shadow-md border border-gray-200"
                    >
                      <CreditCard className="w-8 h-8 text-purple-500 mx-auto mb-2" />
                      <span className="text-sm font-medium">Give</span>
                    </button>
                  </div>

                  {/* Member Stats */}
                  <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                    <div className="bg-purple-50 p-4 rounded-lg">
                      <div className="flex items-center">
                        <Building className="w-8 h-8 text-purple-600 mr-3" />
                        <div>
                          <p className="text-sm text-gray-600">My Ministries</p>
                          <p className="text-2xl font-bold text-purple-600">3</p>
                        </div>
                      </div>
                    </div>
                    <div className="bg-blue-50 p-4 rounded-lg">
                      <div className="flex items-center">
                        <Users className="w-8 h-8 text-blue-600 mr-3" />
                        <div>
                          <p className="text-sm text-gray-600">Small Groups</p>
                          <p className="text-2xl font-bold text-blue-600">1</p>
                        </div>
                      </div>
                    </div>
                    <div className="bg-green-50 p-4 rounded-lg">
                      <div className="flex items-center">
                        <Calendar className="w-8 h-8 text-green-600 mr-3" />
                        <div>
                          <p className="text-sm text-gray-600">Events Attended</p>
                          <p className="text-2xl font-bold text-green-600">12</p>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              )}

              {/* Child Dashboard */}
              {currentUser?.role === 'child' && (
                <div className="space-y-6">
                  <div className="bg-gradient-to-r from-yellow-50 to-orange-50 p-6 rounded-lg">
                    <h3 className="text-lg font-bold text-orange-800 mb-2">🌟 Your Progress</h3>
                    <div className="grid grid-cols-2 gap-4">
                      <div className="text-center">
                        <p className="text-2xl font-bold text-orange-600">{kidsBadges.filter(b => b.earned).length}</p>
                        <p className="text-sm text-orange-700">Badges Earned</p>
                      </div>
                      <div className="text-center">
                        <p className="text-2xl font-bold text-orange-600">7</p>
                        <p className="text-sm text-orange-700">Stories Read</p>
                      </div>
                    </div>
                  </div>
                  
                  <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                    <button 
                      onClick={() => setActiveTab('bible-stories')}
                      className="bg-blue-100 p-4 rounded-lg text-center hover:bg-blue-200"
                    >
                      <BookOpen className="w-8 h-8 text-blue-600 mx-auto mb-2" />
                      <span className="text-sm font-medium">Bible Stories</span>
                    </button>
                    <button 
                      onClick={() => setActiveTab('games')}
                      className="bg-green-100 p-4 rounded-lg text-center hover:bg-green-200"
                    >
                      <Sparkles className="w-8 h-8 text-green-600 mx-auto mb-2" />
                      <span className="text-sm font-medium">Fun Games</span>
                    </button>
                    <button 
                      onClick={() => setActiveTab('badges')}
                      className="bg-yellow-100 p-4 rounded-lg text-center hover:bg-yellow-200"
                    >
                      <Crown className="w-8 h-8 text-yellow-600 mx-auto mb-2" />
                      <span className="text-sm font-medium">My Badges</span>
                    </button>
                    <button 
                      onClick={() => setActiveTab('friends')}
                      className="bg-purple-100 p-4 rounded-lg text-center hover:bg-purple-200"
                    >
                      <Users className="w-8 h-8 text-purple-600 mx-auto mb-2" />
                      <span className="text-sm font-medium">Friends</span>
                    </button>
                  </div>
                </div>
              )}

              {/* Visitor Dashboard */}
              {currentUser?.role === 'visitor' && (
                <div className="space-y-6">
                  <div className="bg-gradient-to-r from-blue-50 to-purple-50 p-6 rounded-lg text-center">
                    <DoorOpen className="w-12 h-12 text-purple-600 mx-auto mb-4" />
                    <h3 className="text-xl font-bold text-purple-800 mb-2">Welcome to Faith Klinik!</h3>
                    <p className="text-purple-700 mb-4">We're so glad you're here. Let us help you feel at home.</p>
                    <button 
                      onClick={() => setActiveTab('connect')}
                      className="bg-purple-600 text-white px-6 py-2 rounded-lg hover:bg-purple-700"
                    >
                      Connect With Us
                    </button>
                  </div>
                  
                  <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                    <button 
                      onClick={() => setActiveTab('about')}
                      className="bg-white p-6 rounded-lg shadow text-center hover:shadow-md border border-gray-200"
                    >
                      <Building2 className="w-8 h-8 text-blue-500 mx-auto mb-2" />
                      <span className="font-medium">About Our Church</span>
                      <p className="text-sm text-gray-600 mt-1">Learn our story & beliefs</p>
                    </button>
                    <button 
                      onClick={() => setActiveTab('services')}
                      className="bg-white p-6 rounded-lg shadow text-center hover:shadow-md border border-gray-200"
                    >
                      <Calendar className="w-8 h-8 text-green-500 mx-auto mb-2" />
                      <span className="font-medium">Service Times</span>
                      <p className="text-sm text-gray-600 mt-1">When & where we meet</p>
                    </button>
                    <button 
                      onClick={() => setActiveTab('connect')}
                      className="bg-white p-6 rounded-lg shadow text-center hover:shadow-md border border-gray-200"
                    >
                      <Users className="w-8 h-8 text-purple-500 mx-auto mb-2" />
                      <span className="font-medium">Get Connected</span>
                      <p className="text-sm text-gray-600 mt-1">Join our community</p>
                    </button>
                  </div>
                </div>
              )}
            </div>
            
            {/* Recent Activity */}
            {currentUser?.role !== 'visitor' && currentUser?.role !== 'child' && (
              <div className="bg-white rounded-lg shadow p-6">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">Recent Activity</h3>
                <div className="space-y-3">
                  <div className="flex items-start space-x-3">
                    <div className="flex-shrink-0">
                      <UserPlus className="w-5 h-5 text-green-600" />
                    </div>
                    <div>
                      <p className="text-sm font-medium text-gray-900">New member joined</p>
                      <p className="text-xs text-gray-500">2 hours ago</p>
                    </div>
                  </div>
                  <div className="flex items-start space-x-3">
                    <div className="flex-shrink-0">
                      <Heart className="w-5 h-5 text-red-600" />
                    </div>
                    <div>
                      <p className="text-sm font-medium text-gray-900">New prayer request submitted</p>
                      <p className="text-xs text-gray-500">4 hours ago</p>
                    </div>
                  </div>
                  <div className="flex items-start space-x-3">
                    <div className="flex-shrink-0">
                      <DollarSign className="w-5 h-5 text-yellow-600" />
                    </div>
                    <div>
                      <p className="text-sm font-medium text-gray-900">Tithe payment received</p>
                      <p className="text-xs text-gray-500">1 day ago</p>
                    </div>
                  </div>
                </div>
              </div>
            )}
          </div>
        )}
        
        {activeTab === 'leadership' && (currentUser?.role === 'pastor' || currentUser?.role === 'admin') && (
          <div className="bg-white rounded-lg shadow p-6">
            <h2 className="text-2xl font-bold text-gray-900 mb-6">Church Leadership</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {churchLeadership.map((leader) => (
                <div key={leader.id} className="border border-gray-200 rounded-lg p-4">
                  <h3 className="font-semibold text-gray-900">{leader.name}</h3>
                  <p className="text-purple-600 text-sm">{leader.position}</p>
                  <p className="text-gray-600 text-sm mt-2">{leader.email}</p>
                  <p className="text-gray-600 text-sm">{leader.phone}</p>
                  <div className="mt-3 flex space-x-2">
                    <button className="text-xs bg-purple-100 text-purple-800 px-2 py-1 rounded">
                      Edit
                    </button>
                    <button className="text-xs bg-gray-100 text-gray-800 px-2 py-1 rounded">
                      Contact
                    </button>
                  </div>
                </div>
              ))}
            </div>
            
            {churchLeadership.length === 0 && (
              <div className="text-center py-8 text-gray-500">
                <Crown className="w-12 h-12 mx-auto mb-4 text-gray-300" />
                <p>No leadership members found</p>
              </div>
            )}
          </div>
        )}
        
        {activeTab === 'members' && (currentUser?.role === 'pastor' || currentUser?.role === 'admin') && (
          <div className="bg-white rounded-lg shadow p-6">
            <div className="flex justify-between items-center mb-6">
              <h2 className="text-2xl font-bold text-gray-900">Members</h2>
              <button
                onClick={() => setShowAddMember(true)}
                className="bg-purple-600 text-white px-4 py-2 rounded-lg hover:bg-purple-700 transition-colors flex items-center"
              >
                <Plus className="w-4 h-4 mr-2" />
                Add Member
              </button>
            </div>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              {members.map((member) => (
                <div key={member.id} className="border border-gray-200 rounded-lg p-4">
                  <h3 className="font-semibold text-gray-900">{member.name}</h3>
                  <p className="text-gray-600 text-sm">{member.email}</p>
                  <p className="text-gray-600 text-sm">{member.phone}</p>
                  <p className="text-purple-600 text-sm mt-2">Role: {member.role}</p>
                  <div className="mt-3 flex space-x-2">
                    <button 
                      onClick={() => {
                        setSelectedMember(member);
                        setShowMemberProfile(true);
                      }}
                      className="text-xs bg-purple-100 text-purple-800 px-2 py-1 rounded hover:bg-purple-200"
                    >
                      View Profile
                    </button>
                    {canEditMember(member.id) && (
                      <button 
                        onClick={() => {
                          alert(`Editing ${member.name}'s information`);
                        }}
                        className="text-xs bg-gray-100 text-gray-800 px-2 py-1 rounded hover:bg-gray-200"
                      >
                        Edit
                      </button>
                    )}
                    {(currentUser?.role === 'admin' || currentUser?.role === 'treasurer') && (
                      <button 
                        onClick={() => setShowPaymentModal(true)}
                        className="text-xs bg-green-100 text-green-800 px-2 py-1 rounded hover:bg-green-200"
                      >
                        Payment
                      </button>
                    )}
                  </div>
                </div>
              ))}
            </div>
            
            {members.length === 0 && (
              <div className="text-center py-8 text-gray-500">
                <Users className="w-12 h-12 mx-auto mb-4 text-gray-300" />
                <p>No members found</p>
              </div>
            )}
          </div>
        )}
        
        {activeTab === 'departments' && (currentUser?.role === 'pastor' || currentUser?.role === 'admin' || currentUser?.role === 'treasurer') && (
          <div className="bg-white rounded-lg shadow p-6">
            <div className="flex justify-between items-center mb-6">
              <h2 className="text-2xl font-bold text-gray-900">Ministries & Departments</h2>
              {currentUser?.role === 'admin' && (
                <button
                  onClick={() => {
                    setShowAddDepartment(true);
                  }}
                  className="bg-purple-600 text-white px-4 py-2 rounded-lg hover:bg-purple-700 transition-colors flex items-center"
                >
                  <Plus className="w-4 h-4 mr-2" />
                  Add Department
                </button>
              )}
            </div>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {departments.map((dept) => (
                <div key={dept.id} className="border border-gray-200 rounded-lg p-4">
                  <h3 className="font-semibold text-gray-900">{dept.name}</h3>
                  <p className="text-gray-600 text-sm mt-2">{dept.description}</p>
                  <p className="text-purple-600 text-sm mt-2">Leader: {dept.leader}</p>
                  <p className="text-gray-500 text-sm">Members: {dept.members?.length || 0}</p>
                  <div className="mt-3 flex space-x-2">
                    <button 
                      onClick={() => {
                        alert(`Viewing ${dept.name} details`);
                      }}
                      className="text-xs bg-purple-100 text-purple-800 px-2 py-1 rounded hover:bg-purple-200"
                    >
                      View Details
                    </button>
                    {(currentUser?.role === 'admin' || currentUser?.role === 'leader') && (
                      <button 
                        onClick={() => {
                          setSelectedDepartment(dept);
                          setShowManageDepartment(true);
                        }}
                        className="text-xs bg-blue-100 text-blue-800 px-2 py-1 rounded hover:bg-blue-200"
                      >
                        Manage
                      </button>
                    )}
                  </div>
                </div>
              ))}
            </div>
            
            {departments.length === 0 && (
              <div className="text-center py-8 text-gray-500">
                <Building className="w-12 h-12 mx-auto mb-4 text-gray-300" />
                <p>No departments found</p>
              </div>
            )}
          </div>
        )}
        
        {activeTab === 'meetings' && (currentUser?.role === 'pastor' || currentUser?.role === 'admin' || currentUser?.role === 'leader') && (
          <div className="bg-white rounded-lg shadow p-6">
            <div className="flex justify-between items-center mb-6">
              <h2 className="text-2xl font-bold text-gray-900">Meetings & Events</h2>
              {(currentUser?.role === 'admin' || currentUser?.role === 'leader') && (
                <button
                  onClick={() => {
                    const newMeeting = {
                      id: Date.now(),
                      title: prompt('Meeting title:') || 'New Meeting',
                      date: new Date().toISOString().split('T')[0],
                      time: '10:00 AM',
                      attendees: []
                    };
                    setMeetings([...meetings, newMeeting]);
                  }}
                  className="bg-purple-600 text-white px-4 py-2 rounded-lg hover:bg-purple-700 transition-colors flex items-center"
                >
                  <Plus className="w-4 h-4 mr-2" />
                  Add Meeting
                </button>
              )}
            </div>
            <div className="space-y-4">
              {meetings.map((meeting) => (
                <div key={meeting.id} className="border border-gray-200 rounded-lg p-4">
                  <div className="flex justify-between items-start">
                    <div className="flex-1">
                      <h3 className="font-semibold text-gray-900">{meeting.title}</h3>
                      <p className="text-gray-600 text-sm mt-1">{meeting.description}</p>
                      <div className="flex items-center mt-2 text-sm text-gray-500">
                        <Calendar className="w-4 h-4 mr-1" />
                        {meeting.date} at {meeting.time}
                      </div>
                      <div className="flex items-center mt-1 text-sm text-gray-500">
                        <MapPin className="w-4 h-4 mr-1" />
                        {meeting.location}
                      </div>
                      <div className="mt-3 flex space-x-2">
                        <button 
                          onClick={() => {
                            alert(`Viewing details for ${meeting.title}`);
                          }}
                          className="text-xs bg-purple-100 text-purple-800 px-2 py-1 rounded hover:bg-purple-200"
                        >
                          View Details
                        </button>
                        <button 
                          onClick={() => {
                            const updatedMeetings = meetings.map(m => {
                              if (m.id === meeting.id) {
                                const attendees = m.attendees || [];
                                const isAttending = attendees.includes(currentUser.id);
                                
                                if (isAttending) {
                                  return {
                                    ...m,
                                    attendees: attendees.filter(id => id !== currentUser.id)
                                  };
                                } else {
                                  return {
                                    ...m,
                                    attendees: [...attendees, currentUser.id]
                                  };
                                }
                              }
                              return m;
                            });
                            setMeetings(updatedMeetings);
                            
                            const isCurrentlyAttending = meeting.attendees?.includes(currentUser.id);
                            alert(isCurrentlyAttending ? 
                              `You have cancelled your RSVP for ${meeting.title}` : 
                              `You have RSVP'd for ${meeting.title}!`
                            );
                          }}
                          className={`text-xs px-2 py-1 rounded hover:opacity-80 ${
                            meeting.attendees?.includes(currentUser.id) 
                              ? 'bg-green-600 text-white' 
                              : 'bg-green-100 text-green-800'
                          }`}
                        >
                          {meeting.attendees?.includes(currentUser.id) ? 'Cancel RSVP' : 'RSVP'}
                        </button>
                        {(currentUser?.role === 'admin' || currentUser?.role === 'leader') && (
                          <button 
                            onClick={() => {
                              alert(`Editing ${meeting.title}`);
                            }}
                            className="text-xs bg-gray-100 text-gray-800 px-2 py-1 rounded hover:bg-gray-200"
                          >
                            Edit
                          </button>
                        )}
                      </div>
                    </div>
                    <span className={`px-2 py-1 text-xs font-medium rounded-full ${
                      meeting.type === 'Worship' ? 'bg-purple-100 text-purple-800' :
                      meeting.type === 'Prayer' ? 'bg-blue-100 text-blue-800' :
                      'bg-green-100 text-green-800'
                    }`}>
                      {meeting.type}
                    </span>
                  </div>
                </div>
              ))}
            </div>
            
            {meetings.length === 0 && (
              <div className="text-center py-8 text-gray-500">
                <Calendar className="w-12 h-12 mx-auto mb-4 text-gray-300" />
                <p>No meetings scheduled</p>
              </div>
            )}
          </div>
        )}
        
        {activeTab === 'finances' && (currentUser?.role === 'pastor' || currentUser?.role === 'admin' || currentUser?.role === 'treasurer') && (
          <div className="space-y-6">
            <div className="bg-white rounded-lg shadow p-6">
              <h2 className="text-2xl font-bold text-gray-900 mb-6">Financial Overview</h2>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
                <div className="bg-green-50 p-4 rounded-lg">
                  <h3 className="font-semibold text-green-800">Total Income</h3>
                  <p className="text-2xl font-bold text-green-600">$15,430</p>
                </div>
                <div className="bg-blue-50 p-4 rounded-lg">
                  <h3 className="font-semibold text-blue-800">Total Expenses</h3>
                  <p className="text-2xl font-bold text-blue-600">$8,920</p>
                </div>
                <div className="bg-purple-50 p-4 rounded-lg">
                  <h3 className="font-semibold text-purple-800">Net Balance</h3>
                  <p className="text-2xl font-bold text-purple-600">$6,510</p>
                </div>
              </div>
              
              <div className="mt-6">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">Recent Transactions</h3>
                <div className="space-y-3">
                  {paymentHistory.slice(-5).map((payment) => (
                    <div key={payment.id} className="flex justify-between items-center p-3 bg-gray-50 rounded-lg">
                      <div>
                        <p className="font-medium text-gray-900">{payment.memberName}</p>
                        <p className="text-sm text-gray-600">{payment.type}</p>
                      </div>
                      <div className="text-right">
                        <p className="font-semibold text-green-600">${payment.amount}</p>
                        <p className="text-xs text-gray-500">{payment.date}</p>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
            
            {(currentUser?.role === 'admin' || currentUser?.role === 'treasurer') && (
              <div className="bg-white rounded-lg shadow p-6">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">Payment Processing</h3>
                <button
                  onClick={() => setShowPaymentModal(true)}
                  className="bg-purple-600 text-white px-4 py-2 rounded-lg hover:bg-purple-700 transition-colors flex items-center"
                >
                  <CreditCard className="w-4 h-4 mr-2" />
                  Process Payment
                </button>
              </div>
            )}
          </div>
        )}

        {/* Prayer Wall */}
        {activeTab === 'prayer' && (
          <div className="space-y-6">
            <div className="bg-white rounded-lg shadow p-6">
              <div className="flex justify-between items-center mb-6">
                <h2 className="text-2xl font-bold text-gray-900">Prayer Wall</h2>
                <button 
                  onClick={() => {
                    const request = prompt('Enter your prayer request:');
                    if (request) {
                      setPrayerRequests([...prayerRequests, {
                        id: prayerRequests.length + 1,
                        request,
                        author: currentUser?.name || 'Anonymous',
                        authorId: currentUser?.id || null,
                        date: new Date().toISOString().split('T')[0],
                        prayers: 0,
                        answered: false,
                        isPublic: true,
                        category: 'General'
                      }]);
                    }
                  }}
                  className="bg-purple-600 text-white px-4 py-2 rounded-lg hover:bg-purple-700 flex items-center"
                >
                  <Plus className="w-4 h-4 mr-2" />
                  Add Prayer Request
                </button>
              </div>
              
              <div className="space-y-4">
                {prayerRequests.map((prayer) => (
                  <div key={prayer.id} className="bg-gray-50 rounded-lg p-4">
                    <div className="flex justify-between items-start mb-2">
                      <div>
                        <p className="font-medium text-gray-900">{prayer.author}</p>
                        <p className="text-xs text-gray-500">{prayer.date}</p>
                      </div>
                      <span className={`px-2 py-1 rounded text-xs font-medium ${
                        prayer.answered ? 'bg-green-100 text-green-800' : 'bg-blue-100 text-blue-800'
                      }`}>
                        {prayer.answered ? '✅ Answered' : '🙏 Praying'}
                      </span>
                    </div>
                    <p className="text-gray-700 mb-3">{prayer.request}</p>
                    <div className="flex items-center space-x-4">
                      <button 
                        onClick={() => {
                          setPrayerRequests(prayerRequests.map(p => 
                            p.id === prayer.id ? {...p, prayers: p.prayers + 1} : p
                          ));
                        }}
                        className="flex items-center text-purple-600 hover:text-purple-700"
                      >
                        <Heart className="w-4 h-4 mr-1" />
                        <span>{prayer.prayers} prayers</span>
                      </button>
                      {(currentUser?.role === 'pastor' || currentUser?.role === 'admin' || prayer.authorId === currentUser?.id) && (
                        <button 
                          onClick={() => {
                            setPrayerRequests(prayerRequests.map(p => 
                              p.id === prayer.id ? {...p, answered: !p.answered} : p
                            ));
                          }}
                          className="text-green-600 hover:text-green-700 text-sm"
                        >
                          {prayer.answered ? 'Mark as Unanswered' : 'Mark as Answered'}
                        </button>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        )}

        {/* Sermons */}
        {activeTab === 'sermons' && userPermissions[currentUser?.role]?.canManageSermons && (
          <div className="space-y-6">
            <div className="bg-white rounded-lg shadow p-6">
              <div className="flex justify-between items-center mb-6">
                <h2 className="text-2xl font-bold text-gray-900">Sermon Management</h2>
                <button 
                  onClick={() => {
                    const title = prompt('Sermon title:');
                    const scripture = prompt('Scripture reference:');
                    if (title && scripture) {
                      setSermons([...sermons, {
                        id: sermons.length + 1,
                        title,
                        date: new Date().toISOString().split('T')[0],
                        series: 'Current Series',
                        scripture,
                        audioUrl: '',
                        videoUrl: '',
                        notes: 'Sermon notes will be added here...',
                        downloads: 0,
                        views: 0,
                        pastor: currentUser?.name
                      }]);
                    }
                  }}
                  className="bg-purple-600 text-white px-4 py-2 rounded-lg hover:bg-purple-700 flex items-center"
                >
                  <Plus className="w-4 h-4 mr-2" />
                  Add Sermon
                </button>
              </div>
              
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {sermons.map((sermon) => (
                  <div key={sermon.id} className="border border-gray-200 rounded-lg p-4">
                    <h3 className="font-semibold text-gray-900 mb-2">{sermon.title}</h3>
                    <p className="text-purple-600 text-sm mb-1">{sermon.scripture}</p>
                    <p className="text-gray-600 text-sm mb-2">{sermon.date}</p>
                    <p className="text-gray-700 text-sm mb-4">{sermon.notes.substring(0, 100)}...</p>
                    
                    <div className="flex justify-between items-center text-xs text-gray-500 mb-4">
                      <span>👁 {sermon.views} views</span>
                      <span>⬇ {sermon.downloads} downloads</span>
                    </div>
                    
                    <div className="flex space-x-2">
                      <button className="flex-1 bg-purple-100 text-purple-800 px-3 py-1 rounded text-xs hover:bg-purple-200">
                        ▶ Play
                      </button>
                      <button className="flex-1 bg-blue-100 text-blue-800 px-3 py-1 rounded text-xs hover:bg-blue-200">
                        📝 Edit
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        )}

        {/* Kids Zone - Bible Stories */}
        {activeTab === 'bible-stories' && currentUser?.role === 'child' && (
          <div className="space-y-6">
            <div className="bg-gradient-to-r from-blue-50 to-purple-50 rounded-lg shadow p-6">
              <h2 className="text-2xl font-bold text-purple-800 mb-4">📖 Bible Stories</h2>
              <p className="text-purple-700 mb-6">Learn amazing stories from the Bible!</p>
              
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                {[
                  { title: 'David and Goliath', lesson: 'God helps the brave', emoji: '⚡' },
                  { title: 'Noah\'s Ark', lesson: 'God protects His people', emoji: '🌈' },
                  { title: 'Daniel and the Lions', lesson: 'God is always with us', emoji: '🦁' },
                  { title: 'Moses and the Red Sea', lesson: 'God does miracles', emoji: '🌊' },
                  { title: 'Jesus Feeds 5000', lesson: 'Jesus cares for everyone', emoji: '🍞' },
                  { title: 'The Good Samaritan', lesson: 'Love your neighbor', emoji: '❤️' }
                ].map((story, index) => (
                  <div key={index} className="bg-white rounded-lg p-4 shadow hover:shadow-md cursor-pointer">
                    <div className="text-3xl mb-2">{story.emoji}</div>
                    <h3 className="font-bold text-gray-900 mb-1">{story.title}</h3>
                    <p className="text-sm text-gray-600">{story.lesson}</p>
                    <button className="mt-3 bg-blue-500 text-white px-3 py-1 rounded text-sm hover:bg-blue-600">
                      Read Story
                    </button>
                  </div>
                ))}
              </div>
            </div>
          </div>
        )}

        {/* Kids Zone - Badges */}
        {activeTab === 'badges' && currentUser?.role === 'child' && (
          <div className="space-y-6">
            <div className="bg-gradient-to-r from-yellow-50 to-orange-50 rounded-lg shadow p-6">
              <h2 className="text-2xl font-bold text-orange-800 mb-4">🏆 My Badges</h2>
              <p className="text-orange-700 mb-6">Earn badges by being awesome for Jesus!</p>
              
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                {kidsBadges.map((badge) => (
                  <div key={badge.id} className={`rounded-lg p-4 ${
                    badge.earned ? 'bg-green-100 border-2 border-green-300' : 'bg-gray-100 border-2 border-gray-200'
                  }`}>
                    <div className="text-center">
                      <div className="text-3xl mb-2">{badge.icon}</div>
                      <h3 className={`font-bold mb-1 ${badge.earned ? 'text-green-800' : 'text-gray-600'}`}>
                        {badge.name}
                      </h3>
                      <p className={`text-sm mb-3 ${badge.earned ? 'text-green-700' : 'text-gray-500'}`}>
                        {badge.description}
                      </p>
                      
                      {badge.earned ? (
                        <div className="bg-green-500 text-white px-3 py-1 rounded-full text-sm font-medium">
                          ✅ Earned {badge.date}
                        </div>
                      ) : (
                        <div className={`bg-gray-200 rounded-full h-2 mb-2`}>
                          <div 
                            className="bg-orange-500 h-2 rounded-full transition-all duration-300"
                            style={{width: `${badge.progress}%`}}
                          ></div>
                        </div>
                      )}
                      
                      {!badge.earned && (
                        <p className="text-xs text-gray-600">{badge.progress}% complete</p>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        )}

        {/* Small Groups */}
        {activeTab === 'groups' && (
          <div className="space-y-6">
            <div className="bg-white rounded-lg shadow p-6">
              <div className="flex justify-between items-center mb-6">
                <h2 className="text-2xl font-bold text-gray-900">Small Groups</h2>
                {userPermissions[currentUser?.role]?.canScheduleEvents && (
                  <button className="bg-purple-600 text-white px-4 py-2 rounded-lg hover:bg-purple-700 flex items-center">
                    <Plus className="w-4 h-4 mr-2" />
                    Create Group
                  </button>
                )}
              </div>
              
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {smallGroups.map((group) => (
                  <div key={group.id} className="border border-gray-200 rounded-lg p-4">
                    <h3 className="font-semibold text-gray-900 mb-2">{group.name}</h3>
                    <p className="text-purple-600 text-sm mb-1">Led by {group.leader}</p>
                    <p className="text-gray-600 text-sm mb-2">{group.schedule}</p>
                    <p className="text-gray-600 text-sm mb-2">📍 {group.location}</p>
                    <p className="text-gray-700 text-sm mb-4">{group.description}</p>
                    
                    <div className="flex justify-between items-center mb-4">
                      <span className="text-sm text-gray-500">
                        {group.members}/{group.maxMembers} members
                      </span>
                      <div className="bg-gray-200 rounded-full h-2 flex-1 ml-3">
                        <div 
                          className="bg-purple-500 h-2 rounded-full"
                          style={{width: `${(group.members / group.maxMembers) * 100}%`}}
                        ></div>
                      </div>
                    </div>
                    
                    <button className="w-full bg-purple-600 text-white px-4 py-2 rounded hover:bg-purple-700">
                      {group.members < group.maxMembers ? 'Join Group' : 'Join Waitlist'}
                    </button>
                  </div>
                ))}
              </div>
            </div>
          </div>
        )}

        {/* Visitor Welcome */}
        {activeTab === 'welcome' && currentUser?.role === 'visitor' && (
          <div className="space-y-6">
            <div className="bg-gradient-to-r from-purple-50 to-blue-50 rounded-lg shadow p-8 text-center">
              <DoorOpen className="w-16 h-16 text-purple-600 mx-auto mb-4" />
              <h1 className="text-3xl font-bold text-purple-800 mb-4">Welcome to Faith Klinik Ministries!</h1>
              <p className="text-lg text-purple-700 mb-6">
                We're thrilled you're here. Our heart is to help you discover God's love and purpose for your life.
              </p>
              
              <div className="bg-white rounded-lg p-6 max-w-md mx-auto">
                <h3 className="text-xl font-semibold text-gray-900 mb-4">Tell us about yourself</h3>
                <div className="space-y-4">
                  <input 
                    type="text" 
                    placeholder="Your name"
                    value={visitorInfo.name}
                    onChange={(e) => setVisitorInfo({...visitorInfo, name: e.target.value})}
                    className="w-full px-3 py-2 border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-purple-500"
                  />
                  <input 
                    type="email" 
                    placeholder="Email address"
                    value={visitorInfo.email}
                    onChange={(e) => setVisitorInfo({...visitorInfo, email: e.target.value})}
                    className="w-full px-3 py-2 border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-purple-500"
                  />
                  <select 
                    value={visitorInfo.visitReason}
                    onChange={(e) => setVisitorInfo({...visitorInfo, visitReason: e.target.value})}
                    className="w-full px-3 py-2 border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-purple-500"
                  >
                    <option value="">What brings you here?</option>
                    <option value="curious">Just curious about faith</option>
                    <option value="new-to-area">New to the area</option>
                    <option value="spiritual-growth">Seeking spiritual growth</option>
                    <option value="community">Looking for community</option>
                    <option value="crisis">Going through difficult time</option>
                  </select>
                  <button 
                    onClick={() => {
                      alert('Thank you! Someone will reach out to you soon.');
                      setVisitorInfo({name: '', email: '', phone: '', interests: [], visitReason: '', followUpPreference: 'email', ageGroup: 'adult', familySize: 1});
                    }}
                    className="w-full bg-purple-600 text-white py-2 rounded hover:bg-purple-700"
                  >
                    Connect with us!
                  </button>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Leader My Ministry Tab */}
        {activeTab === 'my-ministry' && currentUser?.role === 'leader' && (
          <div className="space-y-6">
            <div className="bg-white rounded-lg shadow p-6">
              <h2 className="text-2xl font-bold text-gray-900 mb-6">My Ministry Dashboard</h2>
              
              {/* Ministry Overview Cards */}
              <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
                <div className="bg-purple-50 rounded-lg p-4">
                  <div className="flex items-center">
                    <Users className="w-8 h-8 text-purple-600 mr-3" />
                    <div>
                      <p className="text-sm text-gray-600">Ministry Members</p>
                      <p className="text-2xl font-bold text-purple-600">
                        {members.filter(m => 
                          m.ministryInvolvement && 
                          departments.find(d => d.leaders && d.leaders.includes(currentUser.name) && m.ministryInvolvement.includes(d.name))
                        ).length}
                      </p>
                    </div>
                  </div>
                </div>
                
                <div className="bg-blue-50 rounded-lg p-4">
                  <div className="flex items-center">
                    <Calendar className="w-8 h-8 text-blue-600 mr-3" />
                    <div>
                      <p className="text-sm text-gray-600">Upcoming Events</p>
                      <p className="text-2xl font-bold text-blue-600">3</p>
                    </div>
                  </div>
                </div>
                
                <div className="bg-green-50 rounded-lg p-4">
                  <div className="flex items-center">
                    <Target className="w-8 h-8 text-green-600 mr-3" />
                    <div>
                      <p className="text-sm text-gray-600">Monthly Goal</p>
                      <p className="text-2xl font-bold text-green-600">85%</p>
                    </div>
                  </div>
                </div>
              </div>

              {/* My Departments */}
              <div className="mb-8">
                <h3 className="text-xl font-semibold text-gray-900 mb-4">My Departments</h3>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  {departments && departments.filter(d => d.leaders && d.leaders.includes(currentUser?.name)).length > 0 ? departments.filter(d => d.leaders && d.leaders.includes(currentUser.name)).map((dept) => (
                    <div key={dept.id} className="border border-gray-200 rounded-lg p-4">
                      <div className="flex justify-between items-start mb-2">
                        <h4 className="font-semibold text-gray-900">{dept.name}</h4>
                        <button
                          onClick={() => {
                            setSelectedDepartment(dept);
                            setShowManageDepartment(true);
                          }}
                          className="text-sm bg-purple-100 text-purple-800 px-2 py-1 rounded hover:bg-purple-200"
                        >
                          Manage
                        </button>
                      </div>
                      <p className="text-sm text-gray-600 mb-2">{dept.description}</p>
                      <p className="text-sm text-gray-500">{dept.members} members</p>
                    </div>
                  )) : <p className="text-gray-500 text-center py-4">You are not assigned as a leader to any departments yet.</p>}
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Leader Team Tab */}
        {activeTab === 'team' && currentUser?.role === 'leader' && (
          <div className="space-y-6">
            <div className="bg-white rounded-lg shadow p-6">
              <h2 className="text-2xl font-bold text-gray-900 mb-6">My Team Members</h2>
              
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                {(() => {
                  const teamMembers = members && departments ? members.filter(m => 
                    m.ministryInvolvement && 
                    departments.find(d => d.leaders && d.leaders.includes(currentUser?.name) && m.ministryInvolvement.includes(d.name))
                  ) : [];
                  
                  return teamMembers.length > 0 ? teamMembers.map((member) => (
                    <div key={member.id} className="border border-gray-200 rounded-lg p-4">
                      <h3 className="font-semibold text-gray-900">{member.name}</h3>
                      <p className="text-sm text-gray-600">{member.email}</p>
                      <p className="text-sm text-gray-500 mb-3">Role: {member.role}</p>
                      
                      <div className="flex space-x-2">
                        <button
                          onClick={() => {
                            setSelectedMember(member);
                            setShowMemberProfile(true);
                          }}
                          className="text-xs bg-blue-100 text-blue-800 px-2 py-1 rounded hover:bg-blue-200"
                        >
                          View
                        </button>
                        <button
                          onClick={() => {
                            const message = `Message sent to ${member.name}`;
                            alert(message);
                          }}
                          className="text-xs bg-green-100 text-green-800 px-2 py-1 rounded hover:bg-green-200"
                        >
                          Message
                        </button>
                      </div>
                    </div>
                  )) : <p className="text-gray-500 text-center py-8">No team members found. Members will appear here once they join your ministries.</p>;
                })()}
              </div>
            </div>
          </div>
        )}

        {/* Leader Events Tab */}
        {activeTab === 'events' && currentUser?.role === 'leader' && (
          <div className="space-y-6">
            <div className="bg-white rounded-lg shadow p-6">
              <div className="flex justify-between items-center mb-6">
                <h2 className="text-2xl font-bold text-gray-900">Ministry Events</h2>
                <button
                  onClick={() => {
                    const newEvent = {
                      id: Date.now(),
                      title: prompt('Event title:') || 'New Event',
                      date: new Date().toISOString().split('T')[0],
                      ministry: departments.find(d => d.leaders && d.leaders.includes(currentUser.name))?.name || 'My Ministry',
                      attendees: 0
                    };
                    alert(`Event "${newEvent.title}" created successfully!`);
                  }}
                  className="bg-purple-600 text-white px-4 py-2 rounded hover:bg-purple-700 flex items-center"
                >
                  <Plus className="w-4 h-4 mr-2" />
                  Add Event
                </button>
              </div>
              
              <div className="space-y-4">
                {[
                  { id: 1, title: 'Ministry Team Meeting', date: '2024-08-01', attendees: 12 },
                  { id: 2, title: 'Community Outreach', date: '2024-08-05', attendees: 25 },
                  { id: 3, title: 'Training Workshop', date: '2024-08-10', attendees: 8 }
                ].map((event) => (
                  <div key={event.id} className="border border-gray-200 rounded-lg p-4">
                    <div className="flex justify-between items-start">
                      <div>
                        <h3 className="font-semibold text-gray-900">{event.title}</h3>
                        <p className="text-sm text-gray-600">Date: {event.date}</p>
                        <p className="text-sm text-gray-500">Expected Attendees: {event.attendees}</p>
                      </div>
                      <div className="flex space-x-2">
                        <button
                          onClick={() => alert(`Editing ${event.title}`)}
                          className="text-xs bg-blue-100 text-blue-800 px-2 py-1 rounded hover:bg-blue-200"
                        >
                          Edit
                        </button>
                        <button
                          onClick={() => {
                            if (confirm(`Delete ${event.title}?`)) {
                              alert('Event deleted');
                            }
                          }}
                          className="text-xs bg-red-100 text-red-800 px-2 py-1 rounded hover:bg-red-200"
                        >
                          Delete
                        </button>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        )}

        {/* Member Profile Tab */}
        {activeTab === 'profile' && currentUser?.role === 'member' && (
          <div className="space-y-6">
            <div className="bg-white rounded-lg shadow p-6">
              <h2 className="text-2xl font-bold text-gray-900 mb-6">My Profile</h2>
              
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <h3 className="text-lg font-semibold text-gray-900 mb-4">Personal Information</h3>
                  <div className="space-y-3">
                    <div>
                      <label className="block text-sm font-medium text-gray-700">Name</label>
                      <input
                        type="text"
                        value={currentUser.name}
                        className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500"
                        readOnly
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700">Email</label>
                      <input
                        type="email"
                        value={currentUser.email}
                        className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500"
                        readOnly
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700">Phone</label>
                      <input
                        type="tel"
                        value={currentUser.phone || '(614) XXX-XXXX'}
                        className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500"
                        readOnly
                      />
                    </div>
                  </div>
                </div>
                
                <div>
                  <h3 className="text-lg font-semibold text-gray-900 mb-4">Ministry Involvement</h3>
                  <div className="space-y-2">
                    {(() => {
                      const ministries = currentUser?.ministryInvolvement;
                      return ministries && ministries.length > 0 ? ministries.map((ministry, index) => (
                        <span key={index} className="inline-block bg-purple-100 text-purple-800 px-2 py-1 rounded text-sm mr-2 mb-2">
                          {ministry}
                        </span>
                      )) : <p className="text-gray-500">No ministry involvement yet</p>;
                    })()}
                  </div>
                  
                  <h3 className="text-lg font-semibold text-gray-900 mt-6 mb-4">Giving Summary</h3>
                  <div className="space-y-2">
                    <div className="flex justify-between">
                      <span>Tithes (YTD):</span>
                      <span className="font-medium">${currentUser.tithe || 0}</span>
                    </div>
                    <div className="flex justify-between">
                      <span>Missions (YTD):</span>
                      <span className="font-medium">${currentUser.missions || 0}</span>
                    </div>
                    <div className="flex justify-between">
                      <span>Building Fund (YTD):</span>
                      <span className="font-medium">${currentUser.building || 0}</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Member Giving Tab */}
        {activeTab === 'giving' && currentUser?.role === 'member' && (
          <div className="space-y-6">
            <div className="bg-white rounded-lg shadow p-6">
              <h2 className="text-2xl font-bold text-gray-900 mb-6">Give Online</h2>
              
              <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
                <div className="text-center p-6 border border-gray-200 rounded-lg">
                  <Heart className="w-12 h-12 text-red-500 mx-auto mb-3" />
                  <h3 className="font-semibold text-gray-900 mb-2">Tithes & Offerings</h3>
                  <p className="text-sm text-gray-600 mb-4">Support the general ministry</p>
                  <button
                    onClick={() => alert('Tithe payment processing would be implemented here')}
                    className="bg-red-600 text-white px-4 py-2 rounded hover:bg-red-700 w-full"
                  >
                    Give Now
                  </button>
                </div>
                
                <div className="text-center p-6 border border-gray-200 rounded-lg">
                  <Globe className="w-12 h-12 text-blue-500 mx-auto mb-3" />
                  <h3 className="font-semibold text-gray-900 mb-2">Missions</h3>
                  <p className="text-sm text-gray-600 mb-4">Support global outreach</p>
                  <button
                    onClick={() => alert('Missions payment processing would be implemented here')}
                    className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700 w-full"
                  >
                    Give Now
                  </button>
                </div>
                
                <div className="text-center p-6 border border-gray-200 rounded-lg">
                  <Building className="w-12 h-12 text-green-500 mx-auto mb-3" />
                  <h3 className="font-semibold text-gray-900 mb-2">Building Fund</h3>
                  <p className="text-sm text-gray-600 mb-4">Support facility improvements</p>
                  <button
                    onClick={() => alert('Building fund payment processing would be implemented here')}
                    className="bg-green-600 text-white px-4 py-2 rounded hover:bg-green-700 w-full"
                  >
                    Give Now
                  </button>
                </div>
              </div>
              
              <div className="bg-gray-50 rounded-lg p-4">
                <h3 className="font-semibold text-gray-900 mb-2">Your Giving This Year</h3>
                <div className="grid grid-cols-3 gap-4 text-center">
                  <div>
                    <p className="text-lg font-bold text-red-600">${currentUser.tithe || 0}</p>
                    <p className="text-sm text-gray-600">Tithes</p>
                  </div>
                  <div>
                    <p className="text-lg font-bold text-blue-600">${currentUser.missions || 0}</p>
                    <p className="text-sm text-gray-600">Missions</p>
                  </div>
                  <div>
                    <p className="text-lg font-bold text-green-600">${currentUser.building || 0}</p>
                    <p className="text-sm text-gray-600">Building</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Services Tab */}
        {activeTab === 'services' && (
          <div className="space-y-6">
            <div className="bg-white rounded-lg shadow p-6">
              <h2 className="text-2xl font-bold text-gray-900 mb-6">Service Times & Events</h2>
              
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div className="border border-gray-200 rounded-lg p-6">
                  <h3 className="text-xl font-semibold text-purple-600 mb-4">📅 Weekly Services</h3>
                  <div className="space-y-3">
                    <div className="flex justify-between">
                      <span className="font-medium">Sunday Worship</span>
                      <span className="text-gray-600">10:00 AM</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="font-medium">Bible Study</span>
                      <span className="text-gray-600">Wednesday 7:00 PM</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="font-medium">Prayer Meeting</span>
                      <span className="text-gray-600">Friday 6:00 PM</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="font-medium">Youth Service</span>
                      <span className="text-gray-600">Saturday 4:00 PM</span>
                    </div>
                  </div>
                </div>
                
                <div className="border border-gray-200 rounded-lg p-6">
                  <h3 className="text-xl font-semibold text-purple-600 mb-4">📍 Location</h3>
                  <div className="space-y-2">
                    <p className="font-medium">Faith Klinik Ministries</p>
                    <p className="text-gray-600">123 Faith Avenue</p>
                    <p className="text-gray-600">Columbus, OH 43215</p>
                    <p className="text-gray-600">📞 (614) XXX-XXXX</p>
                  </div>
                  <button className="mt-4 bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">
                    Get Directions
                  </button>
                </div>
              </div>
              
              {liveService.isLive && (
                <div className="mt-6 bg-red-50 border border-red-200 rounded-lg p-6 text-center">
                  <div className="flex items-center justify-center mb-4">
                    <div className="w-3 h-3 bg-red-500 rounded-full animate-pulse mr-3"></div>
                    <h3 className="text-xl font-bold text-red-800">Service is LIVE now!</h3>
                  </div>
                  <button 
                    onClick={() => window.open(liveService.streamUrl, '_blank')}
                    className="bg-red-600 text-white px-6 py-3 rounded-lg hover:bg-red-700 text-lg font-medium"
                  >
                    🔴 Watch Live Service
                  </button>
                </div>
              )}
            </div>
          </div>
        )}
      </main>

      {/* Modals */}
      {showAddMember && <AddMemberModal />}
      <CommunicationModal />
      <MeetingMinutesModal />
      <PaymentModal />
      <SMSNotificationModal />
      <DepartmentManagementModal />
      <MemberProfileModal />
      <DepartmentApplicationModal />

      {/* Footer */}
      <footer className="bg-white border-t border-gray-200 mt-12">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <div className="flex flex-col md:flex-row justify-between items-center">
            <div className="flex items-center mb-4 md:mb-0">
              <Heart className="w-5 h-5 text-blue-600 mr-2" />
              <span className="text-gray-600">Faith Klinik Ministries</span>
            </div>
            <div className="flex items-center space-x-6 text-sm text-gray-600">
              <a href="https://faithklinikministries.com" className="hover:text-blue-600 transition-colors">
                Website
              </a>
              <span>Columbus, Ohio</span>
              <span>Supporting World Evangelism</span>
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
};

export default FaithKlinikApp;
