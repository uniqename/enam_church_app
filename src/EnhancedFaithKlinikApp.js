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
  BellRing,
  MessageSquare,
  MessageCircle,
  Megaphone,
  ExternalLink,
  Star,
  Award,
  Users2,
  Share2,
  Flag,
  UserX,
  Shield,
  Eye,
  EyeOff,
  AlertTriangle,
  Lock,
  Unlock
} from 'lucide-react';

const FaithKlinikApp = () => {
  // Loading state
  const [isLoading, setIsLoading] = useState(true);

  // Navigation and UI states
  const [activeTab, setActiveTab] = useState('dashboard');
  const [showMobileMenu, setShowMobileMenu] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');

  // Authentication
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [showLogin, setShowLogin] = useState(false);
  const [currentUser, setCurrentUser] = useState(null);
  const [loginForm, setLoginForm] = useState({ username: '', password: '' });

  // Modals and popups
  const [showAddMember, setShowAddMember] = useState(false);
  const [showAddDepartment, setShowAddDepartment] = useState(false);
  const [showAddLeadership, setShowAddLeadership] = useState(false);
  const [showCommunication, setShowCommunication] = useState(false);
  const [showMeetingMinutes, setShowMeetingMinutes] = useState(false);
  const [showPaymentModal, setShowPaymentModal] = useState(false);
  const [showNotificationSettings, setShowNotificationSettings] = useState(false);
  const [showManageDepartment, setShowManageDepartment] = useState(false);
  const [showMemberProfile, setShowMemberProfile] = useState(false);
  const [showDepartmentApplication, setShowDepartmentApplication] = useState(false);
  const [showEditProfile, setShowEditProfile] = useState(false);

  // NEW FEATURE STATES
  const [showAnnouncements, setShowAnnouncements] = useState(false);
  const [showAddAnnouncement, setShowAddAnnouncement] = useState(false);
  const [showPrayerRequest, setShowPrayerRequest] = useState(false);
  const [showAddPrayerRequest, setShowAddPrayerRequest] = useState(false);
  const [showDepartmentChat, setShowDepartmentChat] = useState(false);
  const [showBibleApps, setShowBibleApps] = useState(false);
  const [showKidsLogin, setShowKidsLogin] = useState(false);
  const [showDepartmentMessages, setShowDepartmentMessages] = useState(false);
  
  // STREAMING & SERMON STATES
  const [showLiveStreams, setShowLiveStreams] = useState(false);
  
  // SAFETY & MODERATION FEATURES
  const [showReportModal, setShowReportModal] = useState(false);
  const [showBlockModal, setShowBlockModal] = useState(false);
  const [showPrivacySettings, setShowPrivacySettings] = useState(false);
  const [showModerationPanel, setShowModerationPanel] = useState(false);
  const [selectedReportItem, setSelectedReportItem] = useState(null);
  const [selectedBlockUser, setSelectedBlockUser] = useState(null);
  const [reportForm, setReportForm] = useState({
    type: 'inappropriate',
    description: '',
    severity: 'medium'
  });
  const [showSermonLibrary, setShowSermonLibrary] = useState(false);
  const [showAddSermon, setShowAddSermon] = useState(false);
  const [showVideoPlayer, setShowVideoPlayer] = useState(false);
  const [selectedVideo, setSelectedVideo] = useState(null);
  const [showAddLiveStream, setShowAddLiveStream] = useState(false);

  // Selected items
  const [selectedMeeting, setSelectedMeeting] = useState(null);
  const [selectedDepartment, setSelectedDepartment] = useState(null);
  const [selectedMember, setSelectedMember] = useState(null);
  const [editingMember, setEditingMember] = useState(null);
  const [selectedAnnouncement, setSelectedAnnouncement] = useState(null);
  const [selectedPrayerRequest, setSelectedPrayerRequest] = useState(null);

  // Form data
  const [meetingMinutes, setMeetingMinutes] = useState('');
  const [paymentType, setPaymentType] = useState('tithe');
  const [paymentAmount, setPaymentAmount] = useState('');
  const [announcementForm, setAnnouncementForm] = useState({
    title: '',
    content: '',
    priority: 'medium',
    department: 'all',
    expiryDate: ''
  });
  const [prayerRequestForm, setPrayerRequestForm] = useState({
    title: '',
    content: '',
    anonymous: false,
    urgent: false
  });
  const [chatMessage, setChatMessage] = useState('');
  const [sermonForm, setSermonForm] = useState({
    title: '',
    description: '',
    pastor: '',
    videoUrl: '',
    platform: 'youtube',
    tags: '',
    category: 'sermon'
  });
  const [liveStreamForm, setLiveStreamForm] = useState({
    title: '',
    description: '',
    platform: 'youtube',
    startTime: '',
    url: '',
    meetingId: '',
    passcode: ''
  });

  // Data states
  const [prayerSchedule, setPrayerSchedule] = useState([
    { 
      id: 1, 
      day: 'Monday', 
      time: '6:00 AM', 
      leader: 'Pastor Johnson', 
      type: 'Morning Prayer', 
      platform: 'zoom',
      zoomLink: 'https://zoom.us/j/123456789',
      meetingId: '123 456 789',
      passcode: 'pray123'
    },
    { 
      id: 2, 
      day: 'Tuesday', 
      time: '6:00 AM', 
      leader: 'Elder Sarah', 
      type: 'Morning Prayer', 
      platform: 'zoom',
      zoomLink: 'https://zoom.us/j/123456789',
      meetingId: '123 456 789',
      passcode: 'pray123'
    },
    { 
      id: 3, 
      day: 'Wednesday', 
      time: '6:00 AM', 
      leader: 'Deacon Mike', 
      type: 'Morning Prayer', 
      platform: 'zoom',
      zoomLink: 'https://zoom.us/j/123456789',
      meetingId: '123 456 789',
      passcode: 'pray123'
    },
    { 
      id: 4, 
      day: 'Thursday', 
      time: '6:00 AM', 
      leader: 'Sister Grace', 
      type: 'Morning Prayer', 
      platform: 'zoom',
      zoomLink: 'https://zoom.us/j/123456789',
      meetingId: '123 456 789',
      passcode: 'pray123'
    },
    { 
      id: 5, 
      day: 'Friday', 
      time: '6:00 AM', 
      leader: 'Minister David', 
      type: 'Morning Prayer', 
      platform: 'zoom',
      zoomLink: 'https://zoom.us/j/123456789',
      meetingId: '123 456 789',
      passcode: 'pray123'
    },
    { 
      id: 6, 
      day: 'Saturday', 
      time: '6:00 AM', 
      leader: 'Elder Mary', 
      type: 'Morning Prayer', 
      platform: 'zoom',
      zoomLink: 'https://zoom.us/j/123456789',
      meetingId: '123 456 789',
      passcode: 'pray123'
    },
    { 
      id: 7, 
      day: 'Sunday', 
      time: '5:00 AM', 
      leader: 'Pastor Johnson', 
      type: 'Pre-Service Prayer', 
      platform: 'church',
      location: 'Church Premises - Prayer Room'
    },
    { 
      id: 8, 
      day: 'Half Night (Various)', 
      time: '10:00 PM - 2:00 AM', 
      leader: 'Rotating Leadership', 
      type: 'Half Night Prayer', 
      platform: 'church',
      location: 'Church Premises - Main Hall'
    }
  ]);

  const [sermons, setSermons] = useState([
    {
      id: 1,
      title: "Walking in Faith",
      pastor: "Pastor Johnson",
      date: "2024-01-07",
      duration: "45 min",
      views: 234,
      description: "Understanding what it means to truly walk by faith and not by sight.",
      type: "recorded",
      videoUrl: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
      thumbnailUrl: "/api/placeholder/320/180",
      tags: ["faith", "christian living"],
      saved: true
    },
    {
      id: 2,
      title: "The Power of Prayer",
      pastor: "Elder Sarah",
      date: "2024-01-14",
      duration: "38 min",
      views: 189,
      description: "Discovering the transformative power of consistent prayer in our daily lives.",
      type: "recorded",
      videoUrl: "https://www.facebook.com/video/sample",
      thumbnailUrl: "/api/placeholder/320/180",
      tags: ["prayer", "spiritual growth"],
      saved: true
    },
    {
      id: 3,
      title: "Living in God's Grace",
      pastor: "Pastor Johnson",
      date: "2024-01-21",
      duration: "52 min",
      views: 156,
      description: "Understanding and receiving God's amazing grace in our daily walk.",
      type: "recorded",
      videoUrl: "https://zoom.us/rec/share/samplerecording",
      thumbnailUrl: "/api/placeholder/320/180",
      tags: ["grace", "salvation"],
      saved: true
    }
  ]);

  // NEW DATA: Live Streaming
  const [liveStreams, setLiveStreams] = useState([
    {
      id: 1,
      title: "Sunday Morning Service",
      isLive: true,
      startTime: "2024-01-28 10:00",
      platform: "youtube",
      url: "https://www.youtube.com/watch?v=live_stream_id",
      viewers: 45,
      description: "Join us for our weekly Sunday morning worship service"
    },
    {
      id: 2,
      title: "Wednesday Bible Study",
      isLive: false,
      startTime: "2024-01-31 19:00",
      platform: "zoom",
      url: "https://zoom.us/j/123456789",
      meetingId: "123 456 789",
      passcode: "faith123",
      description: "Mid-week Bible study and prayer meeting"
    },
    {
      id: 3,
      title: "Youth Service",
      isLive: false,
      startTime: "2024-02-02 18:00",
      platform: "facebook",
      url: "https://www.facebook.com/faithklinik/live",
      description: "Special youth service with contemporary worship"
    }
  ]);

  // NEW DATA: Saved/Archived Videos
  const [archivedVideos, setArchivedVideos] = useState([
    {
      id: 1,
      title: "Christmas Special Service 2023",
      date: "2023-12-25",
      platform: "youtube",
      url: "https://www.youtube.com/watch?v=christmas2023",
      duration: "1h 15m",
      views: 892,
      category: "special events"
    },
    {
      id: 2,
      title: "Baptism Service",
      date: "2024-01-14",
      platform: "facebook",
      url: "https://www.facebook.com/video/baptism2024",
      duration: "45m",
      views: 234,
      category: "baptisms"
    },
    {
      id: 3,
      title: "Prayer Meeting Recording",
      date: "2024-01-17",
      platform: "zoom",
      url: "https://zoom.us/rec/share/prayer_meeting_jan17",
      duration: "1h 30m",
      views: 67,
      category: "prayer meetings"
    }
  ]);

  const [prayerRequests, setPrayerRequests] = useState([
    {
      id: 1,
      title: "Healing for Sister Mary",
      requester: "John Doe",
      date: "2024-01-20",
      status: "active",
      urgent: true,
      anonymous: false,
      content: "Please pray for Sister Mary's recovery from surgery."
    },
    {
      id: 2,
      title: "Job Interview Success",
      requester: "Anonymous",
      date: "2024-01-19",
      status: "active",
      urgent: false,
      anonymous: true,
      content: "Prayers needed for upcoming job interview this week."
    }
  ]);

  // NEW DATA: Announcements
  const [announcements, setAnnouncements] = useState([
    {
      id: 1,
      title: "Church Retreat - February 15-17",
      content: "Join us for our annual church retreat at Mountain View Resort. Registration closes February 1st.",
      author: "Pastor Johnson",
      date: "2024-01-20",
      priority: "high",
      department: "all",
      expiryDate: "2024-02-01",
      views: 145
    },
    {
      id: 2,
      title: "Youth Ministry Meeting",
      content: "All youth leaders please attend the monthly planning meeting this Friday at 7 PM.",
      author: "Elder Sarah",
      date: "2024-01-19",
      priority: "medium",
      department: "youth",
      expiryDate: "2024-01-25",
      views: 67
    }
  ]);

  // NEW DATA: Department Chat Messages
  const [departmentChats, setDepartmentChats] = useState({
    'youth': [
      {
        id: 1,
        sender: "Elder Sarah",
        message: "Don't forget about youth service preparation meeting tomorrow!",
        timestamp: "2024-01-20 10:30 AM",
        type: "text"
      },
      {
        id: 2,
        sender: "Michael Johnson",
        message: "I'll bring the sound equipment.",
        timestamp: "2024-01-20 10:35 AM",
        type: "text"
      }
    ],
    'worship': [
      {
        id: 1,
        sender: "Minister David",
        message: "Rehearsal moved to 5 PM today. Please confirm attendance.",
        timestamp: "2024-01-20 09:15 AM",
        type: "text"
      }
    ]
  });

  const [kidsBadges, setKidsBadges] = useState([
    { id: 1, name: "Bible Scholar", description: "Read 10 Bible stories", earned: false, progress: 7 },
    { id: 2, name: "Prayer Warrior", description: "Pray for 7 days straight", earned: true, progress: 7 },
    { id: 3, name: "Helper", description: "Help in church activities", earned: false, progress: 3 },
    { id: 4, name: "Friend Maker", description: "Invite 3 friends to church", earned: false, progress: 1 }
  ]);

  const [members, setMembers] = useState([
    {
      id: 1,
      name: "John Doe",
      role: "Member",
      department: "Youth Ministry",
      phone: "+233 24 123 4567",
      email: "john@email.com",
      address: "123 Church Street, Accra",
      joinDate: "2023-06-15",
      birthDate: "1990-05-20",
      membershipStatus: "Active",
      emergencyContact: "Jane Doe - +233 24 765 4321"
    },
    {
      id: 2,
      name: "Sister Mary",
      role: "Elder",
      department: "Women's Ministry",
      phone: "+233 20 987 6543",
      email: "mary@email.com",
      address: "456 Faith Avenue, Kumasi",
      joinDate: "2020-03-10",
      birthDate: "1975-08-15",
      membershipStatus: "Active",
      emergencyContact: "Paul Mary - +233 20 123 4567"
    }
  ]);

  const [departments, setDepartments] = useState([
    {
      id: 1,
      name: "Youth Ministry",
      head: "Elder Sarah",
      members: 45,
      description: "Ministering to young people aged 13-35",
      meetingDay: "Friday",
      meetingTime: "7:00 PM",
      activities: ["Bible Study", "Outreach", "Worship", "Sports"],
      whatsappGroup: "https://chat.whatsapp.com/youth-ministry",
      slackChannel: "#youth-ministry"
    },
    {
      id: 2,
      name: "Women's Ministry",
      head: "Sister Grace",
      members: 38,
      description: "Empowering and supporting women in faith",
      meetingDay: "Saturday",
      meetingTime: "10:00 AM",
      activities: ["Prayer", "Fellowship", "Counseling", "Outreach"],
      whatsappGroup: "https://chat.whatsapp.com/women-ministry",
      slackChannel: "#women-ministry"
    },
    {
      id: 3,
      name: "Children's Ministry",
      head: "Teacher Linda",
      members: 62,
      description: "Teaching and nurturing children in Christ",
      meetingDay: "Sunday",
      meetingTime: "9:00 AM",
      activities: ["Sunday School", "Bible Stories", "Games", "Crafts"],
      whatsappGroup: "https://chat.whatsapp.com/children-ministry",
      slackChannel: "#children-ministry"
    }
  ]);

  // SAFETY & MODERATION DATA
  const [blockedUsers, setBlockedUsers] = useState([]);
  const [reportedContent, setReportedContent] = useState([]);
  const [privacySettings, setPrivacySettings] = useState({
    allowMessagesFrom: 'church-members', // 'everyone', 'church-members', 'friends-only'
    allowPrayerRequestsFrom: 'everyone',
    showOnlineStatus: true,
    allowProfileViewing: 'church-members',
    moderateChildrenContent: true,
    requireApprovalForPosts: false
  });
  const [moderationQueue, setModerationQueue] = useState([]);

  // User permissions
  const userPermissions = {
    pastor: {
      canManageMembers: true,
      canManageFinances: true,
      canManageSermons: true,
      canViewAnalytics: true,
      canManageAnnouncements: true,
      canManagePrayerRequests: true,
      canEditPrayerSchedule: true,
      canMessageDepartments: true,
      canModerateContent: true,
      canViewReports: true,
      canBlockUsers: true,
      canManagePrivacy: true
    },
    admin: {
      canManageMembers: true,
      canManageFinances: true,
      canManageSermons: false,
      canViewAnalytics: true,
      canManageAnnouncements: true,
      canManagePrayerRequests: true,
      canMessageDepartments: true,
      canModerateContent: true,
      canViewReports: true,
      canBlockUsers: true,
      canManagePrivacy: false
    },
    leader: {
      canManageMembers: false,
      canManageFinances: false,
      canManageSermons: false,
      canViewAnalytics: false,
      canManageAnnouncements: true,
      canManagePrayerRequests: true,
      canMessageDepartments: true,
      canModerateContent: false,
      canViewReports: false,
      canBlockUsers: false,
      canManagePrivacy: false
    },
    member: {
      canManageMembers: false,
      canManageFinances: false,
      canManageSermons: false,
      canViewAnalytics: false,
      canManageAnnouncements: false,
      canManagePrayerRequests: false,
      canMessageDepartments: false,
      canModerateContent: false,
      canViewReports: false,
      canBlockUsers: false,
      canManagePrivacy: false
    },
    child: {
      canManageMembers: false,
      canManageFinances: false,
      canManageSermons: false,
      canViewAnalytics: false,
      canManageAnnouncements: false,
      canManagePrayerRequests: false,
      canMessageDepartments: false,
      canModerateContent: false,
      canViewReports: false,
      canBlockUsers: false,
      canManagePrivacy: false
    }
  };

  // Sample users for login
  const sampleUsers = [
    { id: 1, username: 'pastor', password: 'pastor123', name: 'Pastor Johnson', role: 'pastor', department: 'Leadership' },
    { id: 2, username: 'admin', password: 'admin123', name: 'Admin Grace', role: 'admin', department: 'Administration' },
    { id: 3, username: 'leader', password: 'leader123', name: 'Elder Sarah', role: 'leader', department: 'Youth Ministry' },
    { id: 4, username: 'member', password: 'member123', name: 'John Doe', role: 'member', department: 'Youth Ministry' },
    { id: 5, username: 'child', password: 'child123', name: 'Little Timothy', role: 'child', department: 'Children Ministry', age: 8 },
    { id: 6, username: 'visitor', password: 'visitor123', name: 'Jane Smith', role: 'visitor', department: 'Visitors' }
  ];

  // Initialize loading
  useEffect(() => {
    setTimeout(() => setIsLoading(false), 100);
  }, []);

  // Mobile optimization
  useEffect(() => {
    console.log('Faith Klinik App loading...', window.innerWidth, 'x', window.innerHeight);
    
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

  // Navigation items based on user role
  const getNavigationItems = () => {
    if (!currentUser) return [];
    
    const baseItems = [
      { id: 'dashboard', name: 'Home', icon: Home },
      { id: 'announcements', name: 'Announcements', icon: Megaphone },
      { id: 'prayer', name: 'Prayer Ministry', icon: Heart },
      { id: 'sermons', name: 'Sermons', icon: BookOpen },
      { id: 'live-streams', name: 'Live Streams', icon: Activity },
    ];

    switch(currentUser.role) {
      case 'pastor':
        return [
          ...baseItems,
          { id: 'departments', name: 'Ministries', icon: Building },
          { id: 'members', name: 'Members', icon: Users },
          { id: 'leadership', name: 'Leadership', icon: Crown },
          { id: 'finances', name: 'Finances', icon: DollarSign },
          { id: 'analytics', name: 'Analytics', icon: BarChart3 },
          { id: 'moderation', name: 'Moderation', icon: Shield },
          { id: 'bible-apps', name: 'Bible Apps', icon: BookOpen }
        ];
      
      case 'admin':
        return [
          ...baseItems,
          { id: 'departments', name: 'Ministries', icon: Building },
          { id: 'members', name: 'Members', icon: Users },
          { id: 'finances', name: 'Finances', icon: DollarSign },
          { id: 'meetings', name: 'Meetings', icon: Calendar },
          { id: 'moderation', name: 'Moderation', icon: Shield },
          { id: 'bible-apps', name: 'Bible Apps', icon: BookOpen },
          { id: 'settings', name: 'Settings', icon: Settings }
        ];
      
      case 'leader':
        return [
          ...baseItems,
          { id: 'my-ministry', name: 'My Ministry', icon: Building },
          { id: 'team', name: 'Team', icon: Users },
          { id: 'events', name: 'Events', icon: Calendar },
          { id: 'meetings', name: 'Meetings', icon: Calendar },
          { id: 'bible-apps', name: 'Bible Apps', icon: BookOpen }
        ];
      
      case 'child':
        return [
          { id: 'kids-home', name: '🏠 Home', icon: Home },
          { id: 'announcements', name: '📢 News', icon: Megaphone },
          { id: 'prayer', name: '🙏 Prayer', icon: Heart },
          { id: 'bible-stories', name: '📖 Stories', icon: BookOpen },
          { id: 'games', name: '🎮 Games', icon: Sparkles },
          { id: 'badges', name: '⭐ Badges', icon: Crown },
          { id: 'bible-apps', name: '📱 Bible Apps', icon: BookOpen },
          { id: 'friends', name: '👫 Friends', icon: Users }
        ];
      
      case 'visitor':
        return [
          { id: 'welcome', name: 'Welcome', icon: Heart },
          { id: 'announcements', name: 'Announcements', icon: Megaphone },
          { id: 'sermons', name: 'Sermons', icon: BookOpen },
          { id: 'services', name: 'Services', icon: Calendar },
          { id: 'about', name: 'About Us', icon: Building },
          { id: 'connect', name: 'Connect', icon: Users }
        ];
      
      default: // member
        return [
          ...baseItems,
          { id: 'community', name: 'Community', icon: Users },
          { id: 'profile', name: 'My Profile', icon: Users },
          { id: 'giving', name: 'Giving', icon: DollarSign },
          { id: 'bible-apps', name: 'Bible Apps', icon: BookOpen }
        ];
    }
  };

  // Handle login
  const handleLogin = (e) => {
    e.preventDefault();
    const user = sampleUsers.find(u => 
      u.username === loginForm.username && u.password === loginForm.password
    );
    
    if (user) {
      setCurrentUser(user);
      setIsLoggedIn(true);
      setShowLogin(false);
      setActiveTab('dashboard');
      setLoginForm({ username: '', password: '' });
    } else {
      alert('Invalid credentials. Try: pastor/pastor123, admin/admin123, child/child123');
    }
  };

  // Handle announcement submission
  const handleAnnouncementSubmit = (e) => {
    e.preventDefault();
    const newAnnouncement = {
      id: announcements.length + 1,
      ...announcementForm,
      author: currentUser.name,
      date: new Date().toISOString().split('T')[0],
      views: 0
    };
    setAnnouncements([newAnnouncement, ...announcements]);
    setAnnouncementForm({
      title: '',
      content: '',
      priority: 'medium',
      department: 'all',
      expiryDate: ''
    });
    setShowAddAnnouncement(false);
  };

  // Handle prayer request submission
  const handlePrayerRequestSubmit = (e) => {
    e.preventDefault();
    const newPrayerRequest = {
      id: prayerRequests.length + 1,
      ...prayerRequestForm,
      requester: prayerRequestForm.anonymous ? 'Anonymous' : currentUser.name,
      date: new Date().toISOString().split('T')[0],
      status: 'active'
    };
    setPrayerRequests([newPrayerRequest, ...prayerRequests]);
    setPrayerRequestForm({
      title: '',
      content: '',
      anonymous: false,
      urgent: false
    });
    setShowAddPrayerRequest(false);
  };

  // Handle department chat message
  const handleSendChatMessage = (department) => {
    if (!chatMessage.trim()) return;
    
    const newMessage = {
      id: (departmentChats[department]?.length || 0) + 1,
      sender: currentUser.name,
      message: chatMessage,
      timestamp: new Date().toLocaleString(),
      type: "text"
    };

    setDepartmentChats(prev => ({
      ...prev,
      [department]: [...(prev[department] || []), newMessage]
    }));
    setChatMessage('');
  };

  // Handle sermon submission
  const handleSermonSubmit = (e) => {
    e.preventDefault();
    const newSermon = {
      id: sermons.length + 1,
      ...sermonForm,
      pastor: sermonForm.pastor || currentUser.name,
      date: new Date().toISOString().split('T')[0],
      views: 0,
      type: 'recorded',
      tags: sermonForm.tags.split(',').map(tag => tag.trim()),
      saved: true,
      thumbnailUrl: "/api/placeholder/320/180"
    };
    setSermons([newSermon, ...sermons]);
    setSermonForm({
      title: '',
      description: '',
      pastor: '',
      videoUrl: '',
      platform: 'youtube',
      tags: '',
      category: 'sermon'
    });
    setShowAddSermon(false);
  };

  // Handle live stream submission
  const handleLiveStreamSubmit = (e) => {
    e.preventDefault();
    const newStream = {
      id: liveStreams.length + 1,
      ...liveStreamForm,
      isLive: false,
      viewers: 0
    };
    setLiveStreams([newStream, ...liveStreams]);
    setLiveStreamForm({
      title: '',
      description: '',
      platform: 'youtube',
      startTime: '',
      url: '',
      meetingId: '',
      passcode: ''
    });
    setShowAddLiveStream(false);
  };

  // Handle video play
  const handlePlayVideo = (video) => {
    setSelectedVideo(video);
    setShowVideoPlayer(true);
  };

  // Get platform icon
  const getPlatformIcon = (platform) => {
    switch (platform) {
      case 'youtube': return '📺';
      case 'facebook': return '📘';
      case 'zoom': return '🎥';
      default: return '📱';
    }
  };

  // SAFETY & MODERATION FUNCTIONS
  const handleReportContent = (type, id, contentType) => {
    setSelectedReportItem({ type, id, contentType });
    setShowReportModal(true);
  };

  const handleBlockUser = (userId) => {
    setSelectedBlockUser(userId);
    setShowBlockModal(true);
  };

  const submitReport = (e) => {
    e.preventDefault();
    const newReport = {
      id: Date.now(),
      ...reportForm,
      contentType: selectedReportItem.contentType,
      contentId: selectedReportItem.id,
      reportedBy: currentUser.username,
      timestamp: new Date().toISOString(),
      status: 'pending'
    };
    setReportedContent([...reportedContent, newReport]);
    setModerationQueue([...moderationQueue, newReport]);
    setShowReportModal(false);
    setReportForm({ type: 'inappropriate', description: '', severity: 'medium' });
    alert('Report submitted successfully. Our moderation team will review it.');
  };

  const confirmBlockUser = () => {
    if (selectedBlockUser && !blockedUsers.includes(selectedBlockUser)) {
      setBlockedUsers([...blockedUsers, selectedBlockUser]);
      alert('User has been blocked. They will no longer be able to contact you.');
    }
    setShowBlockModal(false);
    setSelectedBlockUser(null);
  };

  const unblockUser = (userId) => {
    setBlockedUsers(blockedUsers.filter(id => id !== userId));
    alert('User has been unblocked.');
  };

  const isUserBlocked = (userId) => {
    return blockedUsers.includes(userId);
  };

  const canUserSendMessage = (fromUserId, toUserId) => {
    if (blockedUsers.includes(fromUserId)) return false;
    if (privacySettings.allowMessagesFrom === 'friends-only') return false; // Implement friend system later
    if (privacySettings.allowMessagesFrom === 'church-members') {
      const user = members.find(m => m.id === fromUserId);
      return user && user.role !== 'visitor';
    }
    return true;
  };

  const moderateContent = (content) => {
    // Simple content filtering - in production, use more sophisticated filtering
    const inappropriate = ['badword1', 'badword2', 'spam'];
    const lowercaseContent = content.toLowerCase();
    return !inappropriate.some(word => lowercaseContent.includes(word));
  };

  const approveContent = (reportId) => {
    setModerationQueue(moderationQueue.filter(item => item.id !== reportId));
    setReportedContent(reportedContent.map(report => 
      report.id === reportId ? { ...report, status: 'approved' } : report
    ));
  };

  const removeContent = (reportId) => {
    setModerationQueue(moderationQueue.filter(item => item.id !== reportId));
    setReportedContent(reportedContent.map(report => 
      report.id === reportId ? { ...report, status: 'removed' } : report
    ));
    // Here you would also remove the actual content from its original location
  };

  // Get platform color
  const getPlatformColor = (platform) => {
    switch (platform) {
      case 'youtube': return 'bg-red-500';
      case 'facebook': return 'bg-blue-600';
      case 'zoom': return 'bg-blue-400';
      default: return 'bg-gray-500';
    }
  };

  // Bible Apps data
  const bibleApps = [
    {
      name: "YouVersion Bible",
      url: "https://www.bible.com/",
      description: "World's most popular Bible app with KJV, ESV and many other versions",
      icon: "📖",
      kidsFriendly: true,
      versions: ["KJV", "ESV", "NIV", "NLT"]
    },
    {
      name: "Bible Gateway",
      url: "https://www.biblegateway.com/",
      description: "Read and search the Bible in multiple languages and versions",
      icon: "🌐",
      kidsFriendly: true,
      versions: ["KJV", "ESV", "NIV", "NASB"]
    },
    {
      name: "ESV Bible",
      url: "https://www.esv.org/",
      description: "Official ESV Bible app with study tools",
      icon: "📚",
      kidsFriendly: true,
      versions: ["ESV"]
    },
    {
      name: "Bible for Kids",
      url: "https://www.bible.com/kids",
      description: "Interactive Bible stories and games for children",
      icon: "🎮",
      kidsFriendly: true,
      versions: ["Kid-friendly stories"]
    }
  ];

  // Homepage component
  const HomePage = () => (
    <div className="min-h-screen bg-gradient-to-br from-purple-50 to-indigo-100">
      {/* Header */}
      <header className="bg-white shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <div className="flex items-center">
              <Heart className="w-8 h-8 text-purple-600 mr-2" />
              <h1 className="text-xl font-bold text-gray-900">Faith Klinik Ministries</h1>
            </div>
            <div className="flex space-x-4">
              <button
                onClick={() => setShowLogin(true)}
                className="bg-purple-600 text-white px-4 py-2 rounded-lg hover:bg-purple-700 transition-colors flex items-center"
              >
                <LogIn className="w-4 h-4 mr-2" />
                Login
              </button>
              <button
                onClick={() => setShowKidsLogin(true)}
                className="bg-green-500 text-white px-4 py-2 rounded-lg hover:bg-green-600 transition-colors flex items-center"
              >
                <Baby className="w-4 h-4 mr-2" />
                Kids Login
              </button>
            </div>
          </div>
        </div>
      </header>

      {/* Hero Section */}
      <section className="py-20">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <Heart className="w-16 h-16 text-purple-600 mx-auto mb-6" />
          <h2 className="text-4xl font-bold text-gray-900 mb-4">
            Welcome to Faith Klinik Ministries
          </h2>
          <p className="text-xl text-gray-600 mb-8 max-w-2xl mx-auto">
            A place where faith meets community. Join us in worship, fellowship, and service to God and others.
          </p>
          
          {/* Quick Stats */}
          <div className="grid md:grid-cols-3 gap-8 mt-12">
            <div className="bg-white p-6 rounded-lg shadow-sm">
              <Users className="w-8 h-8 text-purple-600 mx-auto mb-4" />
              <h3 className="text-2xl font-bold text-gray-900">150+</h3>
              <p className="text-gray-600">Members</p>
            </div>
            <div className="bg-white p-6 rounded-lg shadow-sm">
              <Building className="w-8 h-8 text-purple-600 mx-auto mb-4" />
              <h3 className="text-2xl font-bold text-gray-900">8</h3>
              <p className="text-gray-600">Ministries</p>
            </div>
            <div className="bg-white p-6 rounded-lg shadow-sm">
              <Heart className="w-8 h-8 text-purple-600 mx-auto mb-4" />
              <h3 className="text-2xl font-bold text-gray-900">5</h3>
              <p className="text-gray-600">Years Serving</p>
            </div>
          </div>
        </div>
      </section>

      {/* Service Times */}
      <section className="py-16 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-12">
            <h3 className="text-3xl font-bold text-gray-900 mb-4">Service Times</h3>
            <p className="text-gray-600">Join us for worship and fellowship</p>
          </div>
          
          <div className="grid md:grid-cols-2 gap-8">
            <div className="bg-purple-50 p-6 rounded-lg">
              <Calendar className="w-8 h-8 text-purple-600 mb-4" />
              <h4 className="text-xl font-bold text-gray-900 mb-2">Sunday Worship</h4>
              <p className="text-gray-600 mb-2">8:00 AM - 11:00 AM</p>
              <p className="text-sm text-gray-500">Main sanctuary worship service</p>
            </div>
            <div className="bg-purple-50 p-6 rounded-lg">
              <Users className="w-8 h-8 text-purple-600 mb-4" />
              <h4 className="text-xl font-bold text-gray-900 mb-2">Bible Study</h4>
              <p className="text-gray-600 mb-2">Wednesday 7:00 PM</p>
              <p className="text-sm text-gray-500">Mid-week Bible study and prayer</p>
            </div>
          </div>
        </div>
      </section>
    </div>
  );

  // Login Modal
  const LoginModal = () => (
    showLogin && (
      <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
        <div className="bg-white rounded-lg max-w-md w-full p-6">
          <div className="flex justify-between items-center mb-4">
            <h3 className="text-lg font-semibold">Login to Faith Klinik</h3>
            <button 
              onClick={() => setShowLogin(false)}
              className="text-gray-400 hover:text-gray-600"
            >
              <X className="w-5 h-5" />
            </button>
          </div>
          
          <form onSubmit={handleLogin}>
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Username
                </label>
                <input
                  type="text"
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
                  value={loginForm.username}
                  onChange={(e) => setLoginForm(prev => ({...prev, username: e.target.value}))}
                  required
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Password
                </label>
                <input
                  type="password"
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
                  value={loginForm.password}
                  onChange={(e) => setLoginForm(prev => ({...prev, password: e.target.value}))}
                  required
                />
              </div>
            </div>
            
            <div className="mt-6 space-y-2">
              <button
                type="submit"
                className="w-full bg-purple-600 text-white py-2 px-4 rounded-md hover:bg-purple-700 transition-colors"
              >
                Login
              </button>
            </div>
            
            <div className="mt-4 p-3 bg-gray-50 rounded-md">
              <p className="text-xs text-gray-600 mb-2">Sample accounts:</p>
              <div className="space-y-1 text-xs text-gray-500">
                <p>Pastor: pastor/pastor123</p>
                <p>Admin: admin/admin123</p>
                <p>Leader: leader/leader123</p>
                <p>Member: member/member123</p>
                <p>Child: child/child123</p>
              </div>
            </div>
          </form>
        </div>
      </div>
    )
  );

  // Kids Login Modal
  const KidsLoginModal = () => (
    showKidsLogin && (
      <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
        <div className="bg-gradient-to-br from-yellow-50 to-green-50 rounded-lg max-w-md w-full p-6">
          <div className="flex justify-between items-center mb-4">
            <h3 className="text-lg font-semibold text-green-800">Kids Login 🌟</h3>
            <button 
              onClick={() => setShowKidsLogin(false)}
              className="text-gray-400 hover:text-gray-600"
            >
              <X className="w-5 h-5" />
            </button>
          </div>
          
          <form onSubmit={handleLogin}>
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-green-700 mb-1">
                  Your Name
                </label>
                <input
                  type="text"
                  placeholder="Type 'child' for demo"
                  className="w-full px-3 py-2 border border-green-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500 text-lg"
                  value={loginForm.username}
                  onChange={(e) => setLoginForm(prev => ({...prev, username: e.target.value}))}
                  required
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-green-700 mb-1">
                  Secret Code
                </label>
                <input
                  type="password"
                  placeholder="Type 'child123' for demo"
                  className="w-full px-3 py-2 border border-green-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500 text-lg"
                  value={loginForm.password}
                  onChange={(e) => setLoginForm(prev => ({...prev, password: e.target.value}))}
                  required
                />
              </div>
            </div>
            
            <button
              type="submit"
              className="w-full mt-6 bg-green-500 text-white py-3 px-4 rounded-md hover:bg-green-600 transition-colors text-lg font-semibold"
            >
              Enter Kids Zone! 🎉
            </button>
          </form>
        </div>
      </div>
    )
  );

  // Loading screen
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

  // Show homepage if not logged in
  if (!isLoggedIn) {
    return (
      <>
        <HomePage />
        <LoginModal />
        <KidsLoginModal />
      </>
    );
  }

  // Main app for logged-in users
  return (
    <div className={`min-h-screen ${currentUser?.role === 'child' ? 'bg-gradient-to-br from-yellow-50 to-green-50' : 'bg-gray-50'}`}>
      {/* Navigation */}
      <nav className={`${currentUser?.role === 'child' ? 'bg-gradient-to-r from-yellow-400 to-green-400' : 'bg-white'} border-b border-gray-200 sticky top-0 z-50 safe-area-top`}>
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 safe-area-left safe-area-right">
          <div className="flex justify-between items-center h-16">
            <div className="flex items-center">
              <button
                onClick={() => setShowMobileMenu(!showMobileMenu)}
                className="md:hidden p-2 text-gray-600 hover:text-gray-900 mr-2"
              >
                <Menu className="w-6 h-6" />
              </button>
              
              <div className="flex-shrink-0 flex items-center">
                <Heart className={`w-8 h-8 ${currentUser?.role === 'child' ? 'text-white' : 'text-purple-600'} mr-2`} />
                <span className={`text-xl font-bold ${currentUser?.role === 'child' ? 'text-white' : 'text-gray-900'}`}>
                  {currentUser?.role === 'child' ? 'Kids Zone' : 'Faith Klinik'}
                </span>
              </div>
            </div>
            
            {/* Desktop Navigation */}
            <div className="hidden md:flex space-x-8">
              {getNavigationItems().map((tab) => (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id)}
                  className={`flex items-center px-3 py-2 text-sm font-medium rounded-md transition-colors ${
                    activeTab === tab.id
                      ? (currentUser?.role === 'child' ? 'bg-white bg-opacity-20 text-white' : 'bg-purple-100 text-purple-700')
                      : (currentUser?.role === 'child' ? 'text-white hover:bg-white hover:bg-opacity-10' : 'text-gray-500 hover:text-gray-700 hover:bg-gray-100')
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
                className={`p-2 ${currentUser?.role === 'child' ? 'text-white hover:text-yellow-200' : 'text-gray-400 hover:text-gray-600'} relative`}
              >
                <Bell className="w-5 h-5" />
                <span className="absolute -top-1 -right-1 w-3 h-3 bg-red-500 rounded-full"></span>
              </button>
              
              <div className="hidden md:flex items-center space-x-3">
                <div className="text-right">
                  <p className={`text-sm font-medium ${currentUser?.role === 'child' ? 'text-white' : 'text-gray-900'}`}>
                    {currentUser?.name} {currentUser?.role === 'child' ? '⭐' : ''}
                  </p>
                  <p className={`text-xs ${currentUser?.role === 'child' ? 'text-yellow-200' : 'text-purple-600'} capitalize`}>
                    {currentUser?.role === 'child' ? 'Super Kid' : currentUser?.role}
                  </p>
                </div>
                <button
                  onClick={() => {
                    setIsLoggedIn(false);
                    setCurrentUser(null);
                    setActiveTab('dashboard');
                  }}
                  className={`text-sm ${currentUser?.role === 'child' ? 'text-white hover:text-yellow-200' : 'text-gray-500 hover:text-gray-700'}`}
                >
                  Logout
                </button>
              </div>
            </div>
          </div>
        </div>

        {/* Mobile Navigation */}
        {showMobileMenu && (
          <div className={`md:hidden ${currentUser?.role === 'child' ? 'bg-green-400' : 'bg-white'} border-t border-gray-200 shadow-lg`}>
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
                      ? (currentUser?.role === 'child' ? 'bg-white bg-opacity-20 text-white' : 'bg-purple-100 text-purple-700')
                      : (currentUser?.role === 'child' ? 'text-white hover:bg-white hover:bg-opacity-10' : 'text-gray-500 hover:text-gray-700 hover:bg-gray-100')
                  }`}
                >
                  <tab.icon className="w-4 h-4 mr-3" />
                  {tab.name}
                </button>
              ))}
            </div>
          </div>
        )}
      </nav>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8">
        
        {/* Dashboard */}
        {activeTab === 'dashboard' && (
          <div className="space-y-6">
            <div className="text-center">
              <h1 className={`text-3xl font-bold ${currentUser?.role === 'child' ? 'text-green-800' : 'text-gray-900'} mb-2`}>
                Welcome back, {currentUser?.name}! {currentUser?.role === 'child' ? '🌟' : ''}
              </h1>
              <p className={`${currentUser?.role === 'child' ? 'text-green-600' : 'text-gray-600'}`}>
                {currentUser?.role === 'child' ? 'Ready for another fun day at church?' : 'Here\'s what\'s happening in your ministry today.'}
              </p>
            </div>

            {/* Quick Actions */}
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
              <button
                onClick={() => setActiveTab('announcements')}
                className={`p-4 ${currentUser?.role === 'child' ? 'bg-yellow-100 hover:bg-yellow-200' : 'bg-white hover:bg-gray-50'} rounded-lg shadow-sm border border-gray-200 transition-colors`}
              >
                <Megaphone className={`w-6 h-6 ${currentUser?.role === 'child' ? 'text-yellow-600' : 'text-purple-600'} mx-auto mb-2`} />
                <p className={`text-sm font-medium ${currentUser?.role === 'child' ? 'text-yellow-800' : 'text-gray-900'}`}>
                  {currentUser?.role === 'child' ? 'News!' : 'Announcements'}
                </p>
              </button>

              <button
                onClick={() => setActiveTab('prayer')}
                className={`p-4 ${currentUser?.role === 'child' ? 'bg-green-100 hover:bg-green-200' : 'bg-white hover:bg-gray-50'} rounded-lg shadow-sm border border-gray-200 transition-colors`}
              >
                <Heart className={`w-6 h-6 ${currentUser?.role === 'child' ? 'text-green-600' : 'text-purple-600'} mx-auto mb-2`} />
                <p className={`text-sm font-medium ${currentUser?.role === 'child' ? 'text-green-800' : 'text-gray-900'}`}>
                  {currentUser?.role === 'child' ? 'Prayers' : 'Prayer Requests'}
                </p>
              </button>

              <button
                onClick={() => setActiveTab('bible-apps')}
                className={`p-4 ${currentUser?.role === 'child' ? 'bg-blue-100 hover:bg-blue-200' : 'bg-white hover:bg-gray-50'} rounded-lg shadow-sm border border-gray-200 transition-colors`}
              >
                <BookOpen className={`w-6 h-6 ${currentUser?.role === 'child' ? 'text-blue-600' : 'text-purple-600'} mx-auto mb-2`} />
                <p className={`text-sm font-medium ${currentUser?.role === 'child' ? 'text-blue-800' : 'text-gray-900'}`}>
                  Bible Apps
                </p>
              </button>

              <button
                onClick={() => setShowDepartmentChat(true)}
                className={`p-4 ${currentUser?.role === 'child' ? 'bg-pink-100 hover:bg-pink-200' : 'bg-white hover:bg-gray-50'} rounded-lg shadow-sm border border-gray-200 transition-colors`}
              >
                <MessageSquare className={`w-6 h-6 ${currentUser?.role === 'child' ? 'text-pink-600' : 'text-purple-600'} mx-auto mb-2`} />
                <p className={`text-sm font-medium ${currentUser?.role === 'child' ? 'text-pink-800' : 'text-gray-900'}`}>
                  {currentUser?.role === 'child' ? 'Chat' : 'Department Chat'}
                </p>
              </button>
            </div>

            {/* Recent Activity for non-child users */}
            {currentUser?.role !== 'child' && (
              <div className="grid md:grid-cols-2 gap-6">
                <div className="bg-white rounded-lg shadow-sm p-6">
                  <h3 className="text-lg font-semibold text-gray-900 mb-4">Recent Announcements</h3>
                  <div className="space-y-3">
                    {announcements.slice(0, 3).map((announcement) => (
                      <div key={announcement.id} className="flex justify-between items-start">
                        <div className="flex-1">
                          <p className="text-sm font-medium text-gray-900">{announcement.title}</p>
                          <p className="text-xs text-gray-500">{announcement.date}</p>
                        </div>
                        <span className={`px-2 py-1 text-xs rounded-full ${
                          announcement.priority === 'high' ? 'bg-red-100 text-red-800' :
                          announcement.priority === 'medium' ? 'bg-yellow-100 text-yellow-800' :
                          'bg-green-100 text-green-800'
                        }`}>
                          {announcement.priority}
                        </span>
                      </div>
                    ))}
                  </div>
                </div>

                <div className="bg-white rounded-lg shadow-sm p-6">
                  <h3 className="text-lg font-semibold text-gray-900 mb-4">Prayer Requests</h3>
                  <div className="space-y-3">
                    {prayerRequests.slice(0, 3).map((request) => (
                      <div key={request.id} className="flex justify-between items-start">
                        <div className="flex-1">
                          <p className="text-sm font-medium text-gray-900">{request.title}</p>
                          <p className="text-xs text-gray-500">by {request.requester}</p>
                        </div>
                        {request.urgent && (
                          <span className="px-2 py-1 text-xs bg-red-100 text-red-800 rounded-full">
                            Urgent
                          </span>
                        )}
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            )}

            {/* Kids specific dashboard */}
            {currentUser?.role === 'child' && (
              <div className="grid md:grid-cols-2 gap-6">
                <div className="bg-white rounded-lg shadow-sm p-6 border-4 border-yellow-200">
                  <h3 className="text-lg font-semibold text-green-800 mb-4 flex items-center">
                    <Star className="w-5 h-5 mr-2 text-yellow-500" />
                    Your Badges
                  </h3>
                  <div className="space-y-3">
                    {kidsBadges.slice(0, 3).map((badge) => (
                      <div key={badge.id} className="flex items-center justify-between">
                        <div className="flex items-center">
                          <div className={`w-8 h-8 rounded-full ${badge.earned ? 'bg-yellow-400' : 'bg-gray-200'} flex items-center justify-center mr-3`}>
                            {badge.earned ? '⭐' : '🔒'}
                          </div>
                          <div>
                            <p className="text-sm font-medium text-gray-900">{badge.name}</p>
                            <p className="text-xs text-gray-500">{badge.progress}/{badge.description.match(/\d+/)?.[0] || '?'}</p>
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                  <button
                    onClick={() => setActiveTab('badges')}
                    className="mt-4 w-full bg-yellow-400 text-yellow-900 py-2 px-4 rounded-lg hover:bg-yellow-500 transition-colors font-semibold"
                  >
                    View All Badges
                  </button>
                </div>

                <div className="bg-white rounded-lg shadow-sm p-6 border-4 border-green-200">
                  <h3 className="text-lg font-semibold text-green-800 mb-4 flex items-center">
                    <BookOpen className="w-5 h-5 mr-2 text-green-600" />
                    Bible Stories
                  </h3>
                  <div className="space-y-3">
                    <div className="p-3 bg-green-50 rounded-lg">
                      <p className="text-sm font-medium text-gray-900">📖 David and Goliath</p>
                      <p className="text-xs text-gray-500">Last read: Yesterday</p>
                    </div>
                    <div className="p-3 bg-blue-50 rounded-lg">
                      <p className="text-sm font-medium text-gray-900">🐟 Jesus Feeds 5000</p>
                      <p className="text-xs text-gray-500">New story!</p>
                    </div>
                  </div>
                  <button
                    onClick={() => setActiveTab('bible-stories')}
                    className="mt-4 w-full bg-green-400 text-green-900 py-2 px-4 rounded-lg hover:bg-green-500 transition-colors font-semibold"
                  >
                    Read Stories
                  </button>
                </div>
              </div>
            )}
          </div>
        )}

        {/* Announcements Section */}
        {activeTab === 'announcements' && (
          <div className="space-y-6">
            <div className="flex justify-between items-center">
              <h1 className="text-3xl font-bold text-gray-900">
                {currentUser?.role === 'child' ? '📢 Church News!' : 'Announcements'}
              </h1>
              {userPermissions[currentUser?.role]?.canManageAnnouncements && (
                <button
                  onClick={() => setShowAddAnnouncement(true)}
                  className="bg-purple-600 text-white px-4 py-2 rounded-lg hover:bg-purple-700 transition-colors flex items-center"
                >
                  <Plus className="w-4 h-4 mr-2" />
                  Add Announcement
                </button>
              )}
            </div>

            <div className="space-y-4">
              {announcements.map((announcement) => (
                <div key={announcement.id} className={`${currentUser?.role === 'child' ? 'bg-yellow-50 border-yellow-200' : 'bg-white'} rounded-lg shadow-sm p-6 border`}>
                  <div className="flex justify-between items-start mb-3">
                    <div className="flex items-start space-x-3">
                      <div className={`p-2 ${
                        announcement.priority === 'high' ? 'bg-red-100 text-red-600' :
                        announcement.priority === 'medium' ? 'bg-yellow-100 text-yellow-600' :
                        'bg-green-100 text-green-600'
                      } rounded-lg`}>
                        <Megaphone className="w-4 h-4" />
                      </div>
                      <div className="flex-1">
                        <h3 className="text-lg font-semibold text-gray-900 mb-1">
                          {currentUser?.role === 'child' ? `🌟 ${announcement.title}` : announcement.title}
                        </h3>
                        <p className="text-gray-600 mb-2">{announcement.content}</p>
                        <div className="flex items-center space-x-4 text-sm text-gray-500">
                          <span>By {announcement.author}</span>
                          <span>{announcement.date}</span>
                          <span>{announcement.views} views</span>
                        </div>
                      </div>
                    </div>
                    <div className="flex items-center space-x-2">
                      <span className={`px-2 py-1 text-xs rounded-full ${
                        announcement.priority === 'high' ? 'bg-red-100 text-red-800' :
                        announcement.priority === 'medium' ? 'bg-yellow-100 text-yellow-800' :
                        'bg-green-100 text-green-800'
                      }`}>
                        {announcement.priority}
                      </span>
                      {announcement.department !== 'all' && (
                        <span className="px-2 py-1 text-xs bg-blue-100 text-blue-800 rounded-full">
                          {announcement.department}
                        </span>
                      )}
                      
                      {/* Report & Block buttons */}
                      {currentUser?.role !== 'child' && (
                        <div className="flex space-x-1">
                          <button 
                            onClick={() => handleReportContent('announcement', announcement.id, 'announcement')}
                            className="p-1 text-orange-600 hover:bg-orange-100 rounded"
                            title="Report content"
                          >
                            <Flag className="w-3 h-3" />
                          </button>
                          <button 
                            onClick={() => handleBlockUser(announcement.authorId)}
                            className="p-1 text-red-600 hover:bg-red-100 rounded"
                            title="Block user"
                          >
                            <UserX className="w-3 h-3" />
                          </button>
                        </div>
                      )}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Enhanced Prayer Section */}
        {activeTab === 'prayer' && (
          <div className="space-y-6">
            <div className="flex justify-between items-center">
              <h1 className="text-3xl font-bold text-gray-900">
                {currentUser?.role === 'child' ? '🙏 Prayer Corner' : 'Prayer Ministry'}
              </h1>
              <div className="flex space-x-3">
                <button
                  onClick={() => setShowAddPrayerRequest(true)}
                  className="bg-purple-600 text-white px-4 py-2 rounded-lg hover:bg-purple-700 transition-colors flex items-center"
                >
                  <Plus className="w-4 h-4 mr-2" />
                  {currentUser?.role === 'child' ? 'Add Prayer' : 'Submit Request'}
                </button>
                {userPermissions[currentUser?.role]?.canEditPrayerSchedule && (
                  <button
                    onClick={() => setShowDepartmentChat(true)}
                    className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors flex items-center"
                  >
                    <MessageSquare className="w-4 h-4 mr-2" />
                    Manage Schedule
                  </button>
                )}
              </div>
            </div>

            {/* Prayer Schedule Section */}
            <div className="bg-white rounded-lg shadow-sm p-6">
              <h3 className="text-xl font-semibold text-gray-900 mb-4 flex items-center">
                <Calendar className="w-5 h-5 mr-2 text-blue-600" />
                Prayer Schedule
              </h3>
              <div className="grid md:grid-cols-2 gap-4">
                {prayerSchedule.map((prayer) => (
                  <div key={prayer.id} className={`p-4 rounded-lg border ${
                    prayer.platform === 'zoom' ? 'bg-blue-50 border-blue-200' : 'bg-green-50 border-green-200'
                  }`}>
                    <div className="flex items-start justify-between">
                      <div className="flex-1">
                        <h4 className="font-semibold text-gray-900 mb-1">
                          {prayer.day} - {prayer.type}
                        </h4>
                        <p className="text-sm text-gray-600 mb-2">{prayer.time}</p>
                        <p className="text-sm text-gray-500">Led by {prayer.leader}</p>
                        
                        {prayer.platform === 'zoom' && (
                          <div className="mt-3 p-3 bg-white rounded-lg">
                            <div className="flex items-center space-x-4 text-sm">
                              <span><strong>Meeting ID:</strong> {prayer.meetingId}</span>
                              <span><strong>Passcode:</strong> {prayer.passcode}</span>
                            </div>
                          </div>
                        )}
                        
                        {prayer.platform === 'church' && (
                          <div className="mt-3 p-3 bg-white rounded-lg">
                            <p className="text-sm"><strong>Location:</strong> {prayer.location}</p>
                          </div>
                        )}
                      </div>
                      <div className="flex flex-col space-y-2 ml-4">
                        {prayer.platform === 'zoom' && (
                          <a
                            href={prayer.zoomLink}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="bg-blue-600 text-white px-3 py-1 rounded-lg text-sm hover:bg-blue-700 transition-colors text-center"
                          >
                            🎥 Join Zoom
                          </a>
                        )}
                        {prayer.platform === 'church' && (
                          <div className="bg-green-600 text-white px-3 py-1 rounded-lg text-sm text-center">
                            🏛️ In Person
                          </div>
                        )}
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Prayer Requests Grid */}
            <div className="bg-white rounded-lg shadow-sm p-6">
              <h3 className="text-xl font-semibold text-gray-900 mb-4 flex items-center">
                <Heart className="w-5 h-5 mr-2 text-purple-600" />
                Prayer Requests
              </h3>
              <div className="grid gap-4">
                {prayerRequests.map((request) => (
                  <div key={request.id} className={`${currentUser?.role === 'child' ? 'bg-yellow-50 border-yellow-200' : 'bg-gray-50'} rounded-lg p-4 border`}>
                    <div className="flex justify-between items-start">
                      <div className="flex items-start space-x-3 flex-1">
                        <div className={`p-2 ${request.urgent ? 'bg-red-100 text-red-600' : 'bg-purple-100 text-purple-600'} rounded-lg`}>
                          <Heart className="w-4 h-4" />
                        </div>
                        <div className="flex-1">
                          <h4 className="font-semibold text-gray-900 mb-1">
                            {currentUser?.role === 'child' ? `❤️ ${request.title}` : request.title}
                          </h4>
                          <p className="text-gray-600 text-sm mb-2">{request.content}</p>
                          <div className="flex items-center space-x-4 text-xs text-gray-500">
                            <span>By {request.requester}</span>
                            <span>{request.date}</span>
                            <span className={`px-2 py-1 rounded-full ${
                              request.status === 'active' ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'
                            }`}>
                              {request.status}
                            </span>
                          </div>
                        </div>
                      </div>
                      <div className="flex items-center space-x-2">
                        {request.urgent && (
                          <span className="px-2 py-1 text-xs bg-red-100 text-red-800 rounded-full">
                            Urgent
                          </span>
                        )}
                        {request.anonymous && (
                          <span className="px-2 py-1 text-xs bg-gray-100 text-gray-800 rounded-full">
                            Anonymous
                          </span>
                        )}
                        <div className="flex space-x-1">
                          {/* Report & Block buttons for all users */}
                          {currentUser?.role !== 'child' && (
                            <>
                              <button 
                                onClick={() => handleReportContent('prayer-request', request.id, 'prayer-request')}
                                className="p-1 text-orange-600 hover:bg-orange-100 rounded"
                                title="Report content"
                              >
                                <Flag className="w-3 h-3" />
                              </button>
                              <button 
                                onClick={() => handleBlockUser(request.requesterId)}
                                className="p-1 text-red-600 hover:bg-red-100 rounded"
                                title="Block user"
                              >
                                <UserX className="w-3 h-3" />
                              </button>
                            </>
                          )}
                          
                          {/* Admin/Pastor management buttons */}
                          {userPermissions[currentUser?.role]?.canManagePrayerRequests && (
                            <>
                              <button className="p-1 text-blue-600 hover:bg-blue-100 rounded">
                                <Edit className="w-3 h-3" />
                              </button>
                              <button className="p-1 text-red-600 hover:bg-red-100 rounded">
                                <Trash2 className="w-3 h-3" />
                              </button>
                            </>
                          )}
                        </div>
                      </div>
                    </div>
                    
                    <div className="mt-3 flex space-x-2">
                      <button className={`${currentUser?.role === 'child' ? 'bg-green-500 hover:bg-green-600' : 'bg-purple-500 hover:bg-purple-600'} text-white px-3 py-1 rounded-lg transition-colors text-sm`}>
                        {currentUser?.role === 'child' ? '🙏 Pray' : '🙏 Pray for this'}
                      </button>
                      <button className="bg-gray-200 text-gray-700 px-3 py-1 rounded-lg hover:bg-gray-300 transition-colors text-sm">
                        Share
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        )}

        {/* Bible Apps Section */}
        {activeTab === 'bible-apps' && (
          <div className="space-y-6">
            <h1 className="text-3xl font-bold text-gray-900">
              {currentUser?.role === 'child' ? '📖 Bible Apps for Kids' : 'Bible Reading Apps'}
            </h1>
            
            <div className="grid md:grid-cols-2 gap-6">
              {bibleApps
                .filter(app => currentUser?.role === 'child' ? app.kidsFriendly : true)
                .map((app, index) => (
                <div key={index} className={`${currentUser?.role === 'child' ? 'bg-yellow-50 border-yellow-200' : 'bg-white'} rounded-lg shadow-sm p-6 border`}>
                  <div className="flex items-start space-x-4">
                    <div className="text-4xl">{app.icon}</div>
                    <div className="flex-1">
                      <h3 className="text-lg font-semibold text-gray-900 mb-2">{app.name}</h3>
                      <p className="text-gray-600 mb-3">{app.description}</p>
                      
                      <div className="mb-4">
                        <p className="text-sm font-medium text-gray-700 mb-2">Available Versions:</p>
                        <div className="flex flex-wrap gap-2">
                          {app.versions.map((version, vIndex) => (
                            <span key={vIndex} className="px-2 py-1 text-xs bg-blue-100 text-blue-800 rounded-full">
                              {version}
                            </span>
                          ))}
                        </div>
                      </div>

                      <div className="flex space-x-3">
                        <a
                          href={app.url}
                          target="_blank"
                          rel="noopener noreferrer"
                          className={`${currentUser?.role === 'child' ? 'bg-green-500 hover:bg-green-600' : 'bg-purple-600 hover:bg-purple-700'} text-white px-4 py-2 rounded-lg transition-colors flex items-center text-sm`}
                        >
                          <ExternalLink className="w-4 h-4 mr-2" />
                          {currentUser?.role === 'child' ? 'Open App! 🚀' : 'Open App'}
                        </a>
                        {currentUser?.role === 'child' && (
                          <button className="bg-yellow-400 text-yellow-900 px-4 py-2 rounded-lg hover:bg-yellow-500 transition-colors text-sm font-semibold">
                            ⭐ Favorite
                          </button>
                        )}
                      </div>
                    </div>
                  </div>
                </div>
              ))}
            </div>
            
            {currentUser?.role === 'child' && (
              <div className="bg-gradient-to-r from-blue-100 to-purple-100 rounded-lg p-6 border-2 border-blue-200">
                <div className="text-center">
                  <BookOpen className="w-12 h-12 text-blue-600 mx-auto mb-4" />
                  <h3 className="text-xl font-bold text-blue-900 mb-2">📚 Reading Challenge!</h3>
                  <p className="text-blue-700 mb-4">Read Bible stories every day to earn the "Bible Scholar" badge!</p>
                  <div className="bg-white rounded-lg p-3 inline-block">
                    <p className="text-sm font-medium text-gray-700">Progress: 7/10 stories read ⭐</p>
                    <div className="w-32 bg-gray-200 rounded-full h-2 mt-2">
                      <div className="bg-blue-500 h-2 rounded-full" style={{width: '70%'}}></div>
                    </div>
                  </div>
                </div>
              </div>
            )}
          </div>
        )}

        {/* Kids Home */}
        {activeTab === 'kids-home' && currentUser?.role === 'child' && (
          <div className="space-y-6">
            <div className="text-center">
              <h1 className="text-4xl font-bold text-green-800 mb-2">
                Welcome to Kids Zone! 🌟
              </h1>
              <p className="text-green-600 text-lg">
                Hi {currentUser?.name}! Ready for some fun with Jesus?
              </p>
            </div>

            {/* Quick Games */}
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
              {[
                { name: 'Bible Stories', icon: '📖', color: 'bg-blue-400', tab: 'bible-stories' },
                { name: 'Fun Games', icon: '🎮', color: 'bg-green-400', tab: 'games' },
                { name: 'My Badges', icon: '⭐', color: 'bg-yellow-400', tab: 'badges' },
                { name: 'Friends', icon: '👨‍👩‍👧‍👦', color: 'bg-pink-400', tab: 'friends' }
              ].map((item, index) => (
                <button
                  key={index}
                  onClick={() => setActiveTab(item.tab)}
                  className={`${item.color} text-white p-6 rounded-xl shadow-lg hover:shadow-xl transition-all transform hover:scale-105`}
                >
                  <div className="text-4xl mb-2">{item.icon}</div>
                  <p className="font-bold text-lg">{item.name}</p>
                </button>
              ))}
            </div>

            {/* Today's Verse */}
            <div className="bg-gradient-to-r from-purple-400 to-pink-400 rounded-xl p-6 text-white text-center">
              <h3 className="text-2xl font-bold mb-4">🌟 Today's Verse</h3>
              <p className="text-lg mb-2">"Jesus said, 'Let the little children come to me.'"</p>
              <p className="text-sm opacity-90">- Matthew 19:14</p>
            </div>

            {/* Fun Activities */}
            <div className="bg-white rounded-xl shadow-sm p-6 border-4 border-yellow-200">
              <h3 className="text-2xl font-bold text-gray-800 mb-4 text-center">
                🎨 Fun Activities Today!
              </h3>
              <div className="grid md:grid-cols-3 gap-4">
                <div className="bg-blue-100 p-4 rounded-lg text-center">
                  <div className="text-3xl mb-2">🎵</div>
                  <h4 className="font-bold text-blue-800">Sing Songs</h4>
                  <p className="text-sm text-blue-600">Praise songs at 10 AM</p>
                </div>
                <div className="bg-green-100 p-4 rounded-lg text-center">
                  <div className="text-3xl mb-2">🖍️</div>
                  <h4 className="font-bold text-green-800">Bible Coloring</h4>
                  <p className="text-sm text-green-600">After Sunday School</p>
                </div>
                <div className="bg-pink-100 p-4 rounded-lg text-center">
                  <div className="text-3xl mb-2">🍪</div>
                  <h4 className="font-bold text-pink-800">Snack Time</h4>
                  <p className="text-sm text-pink-600">Cookies & Juice!</p>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Kids Bible Stories */}
        {activeTab === 'bible-stories' && currentUser?.role === 'child' && (
          <div className="space-y-6">
            <h1 className="text-3xl font-bold text-green-800 text-center">
              📖 Amazing Bible Stories!
            </h1>
            
            <div className="grid md:grid-cols-2 gap-6">
              {[
                { title: 'David and Goliath', emoji: '⚔️', color: 'bg-red-100', difficulty: 'Easy' },
                { title: 'Noah\'s Ark', emoji: '🚢', color: 'bg-blue-100', difficulty: 'Easy' },
                { title: 'Jesus Feeds 5000', emoji: '🐟', color: 'bg-green-100', difficulty: 'Medium' },
                { title: 'The Good Samaritan', emoji: '❤️', color: 'bg-yellow-100', difficulty: 'Medium' },
                { title: 'Moses and the Red Sea', emoji: '🌊', color: 'bg-purple-100', difficulty: 'Medium' },
                { title: 'Jesus Walks on Water', emoji: '🚶‍♂️', color: 'bg-teal-100', difficulty: 'Hard' }
              ].map((story, index) => (
                <div key={index} className={`${story.color} rounded-xl p-6 border-2 shadow-lg hover:shadow-xl transition-all cursor-pointer transform hover:scale-105`}>
                  <div className="text-center">
                    <div className="text-6xl mb-4">{story.emoji}</div>
                    <h3 className="text-xl font-bold text-gray-800 mb-2">{story.title}</h3>
                    <span className={`px-3 py-1 rounded-full text-sm font-semibold ${
                      story.difficulty === 'Easy' ? 'bg-green-200 text-green-800' :
                      story.difficulty === 'Medium' ? 'bg-yellow-200 text-yellow-800' :
                      'bg-red-200 text-red-800'
                    }`}>
                      {story.difficulty}
                    </span>
                    <div className="mt-4">
                      <button className="bg-blue-500 text-white px-6 py-2 rounded-lg hover:bg-blue-600 transition-colors font-bold">
                        📖 Read Story!
                      </button>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Kids Games */}
        {activeTab === 'games' && currentUser?.role === 'child' && (
          <div className="space-y-6">
            <h1 className="text-3xl font-bold text-green-800 text-center">
              🎮 Fun Bible Games!
            </h1>
            
            <div className="grid md:grid-cols-3 gap-6">
              {[
                { name: 'Bible Quiz', icon: '🧠', color: 'bg-purple-400', desc: 'Test your Bible knowledge!' },
                { name: 'Memory Verses', icon: '💭', color: 'bg-blue-400', desc: 'Learn verses by heart!' },
                { name: 'Bible Bingo', icon: '🎯', color: 'bg-green-400', desc: 'Match Bible characters!' },
                { name: 'Puzzle Time', icon: '🧩', color: 'bg-yellow-400', desc: 'Solve Bible puzzles!' },
                { name: 'Coloring Book', icon: '🎨', color: 'bg-pink-400', desc: 'Color Bible scenes!' },
                { name: 'Sing Along', icon: '🎵', color: 'bg-indigo-400', desc: 'Praise songs karaoke!' }
              ].map((game, index) => (
                <div key={index} className={`${game.color} text-white rounded-xl p-6 shadow-lg hover:shadow-xl transition-all cursor-pointer transform hover:scale-105`}>
                  <div className="text-center">
                    <div className="text-5xl mb-3">{game.icon}</div>
                    <h3 className="text-xl font-bold mb-2">{game.name}</h3>
                    <p className="text-sm opacity-90 mb-4">{game.desc}</p>
                    <button className="bg-white bg-opacity-20 px-4 py-2 rounded-lg hover:bg-opacity-30 transition-colors font-bold">
                      Play Now! 🚀
                    </button>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Kids Badges */}
        {activeTab === 'badges' && currentUser?.role === 'child' && (
          <div className="space-y-6">
            <h1 className="text-3xl font-bold text-green-800 text-center">
              ⭐ Your Amazing Badges!
            </h1>
            
            <div className="grid md:grid-cols-2 gap-6">
              {kidsBadges.map((badge) => (
                <div key={badge.id} className={`${badge.earned ? 'bg-gradient-to-r from-yellow-300 to-yellow-400' : 'bg-gray-100'} rounded-xl p-6 border-4 ${badge.earned ? 'border-yellow-500' : 'border-gray-300'} shadow-lg`}>
                  <div className="text-center">
                    <div className={`w-20 h-20 rounded-full ${badge.earned ? 'bg-yellow-500' : 'bg-gray-400'} flex items-center justify-center text-4xl mx-auto mb-4`}>
                      {badge.earned ? '⭐' : '🔒'}
                    </div>
                    <h3 className={`text-xl font-bold mb-2 ${badge.earned ? 'text-yellow-900' : 'text-gray-600'}`}>
                      {badge.name}
                    </h3>
                    <p className={`text-sm mb-4 ${badge.earned ? 'text-yellow-800' : 'text-gray-500'}`}>
                      {badge.description}
                    </p>
                    
                    <div className="bg-white rounded-lg p-3">
                      <p className="text-sm font-medium text-gray-700 mb-2">
                        Progress: {badge.progress}/{badge.description.match(/\d+/)?.[0] || '?'}
                      </p>
                      <div className="w-full bg-gray-200 rounded-full h-3">
                        <div 
                          className={`${badge.earned ? 'bg-green-500' : 'bg-blue-500'} h-3 rounded-full transition-all`}
                          style={{width: `${(badge.progress / (badge.description.match(/\d+/)?.[0] || 1)) * 100}%`}}
                        ></div>
                      </div>
                    </div>
                    
                    {badge.earned && (
                      <div className="mt-4 p-3 bg-white bg-opacity-30 rounded-lg">
                        <p className="font-bold text-yellow-900">🎉 Congratulations! 🎉</p>
                        <p className="text-sm text-yellow-800">You earned this badge!</p>
                      </div>
                    )}
                  </div>
                </div>
              ))}
            </div>
            
            <div className="text-center bg-gradient-to-r from-green-300 to-blue-300 rounded-xl p-6">
              <h3 className="text-2xl font-bold text-white mb-2">Keep Going! 💪</h3>
              <p className="text-white">Earn more badges by reading Bible stories, helping others, and coming to church!</p>
            </div>
          </div>
        )}

        {/* Enhanced Sermons Section */}
        {activeTab === 'sermons' && (
          <div className="space-y-6">
            <div className="flex justify-between items-center">
              <h1 className="text-3xl font-bold text-gray-900">
                {currentUser?.role === 'child' ? '📖 Sermon Stories' : 'Sermon Library'}
              </h1>
              {userPermissions[currentUser?.role]?.canManageSermons && (
                <button
                  onClick={() => setShowAddSermon(true)}
                  className="bg-purple-600 text-white px-4 py-2 rounded-lg hover:bg-purple-700 transition-colors flex items-center"
                >
                  <Plus className="w-4 h-4 mr-2" />
                  Add Sermon
                </button>
              )}
            </div>

            {/* Filter/Search Bar */}
            <div className="flex flex-col sm:flex-row gap-4 bg-white p-4 rounded-lg shadow-sm">
              <input
                type="text"
                placeholder="Search sermons..."
                className="flex-1 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
              />
              <select className="px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500">
                <option value="">All Categories</option>
                <option value="sermon">Sermons</option>
                <option value="bible-study">Bible Study</option>
                <option value="special">Special Events</option>
              </select>
            </div>

            {/* Sermons Grid */}
            <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
              {sermons.map((sermon) => (
                <div key={sermon.id} className={`${currentUser?.role === 'child' ? 'bg-yellow-50 border-yellow-200' : 'bg-white'} rounded-lg shadow-sm border overflow-hidden hover:shadow-md transition-shadow`}>
                  {/* Video Thumbnail */}
                  <div className="relative">
                    <div className="aspect-video bg-gray-200 flex items-center justify-center">
                      <div className="text-4xl">{getPlatformIcon(sermon.videoUrl?.includes('youtube') ? 'youtube' : sermon.videoUrl?.includes('facebook') ? 'facebook' : 'zoom')}</div>
                    </div>
                    <div className="absolute top-2 right-2">
                      <span className={`px-2 py-1 text-xs text-white rounded-full ${getPlatformColor(sermon.videoUrl?.includes('youtube') ? 'youtube' : sermon.videoUrl?.includes('facebook') ? 'facebook' : 'zoom')}`}>
                        {sermon.videoUrl?.includes('youtube') ? 'YouTube' : sermon.videoUrl?.includes('facebook') ? 'Facebook' : 'Zoom'}
                      </span>
                    </div>
                    <button
                      onClick={() => handlePlayVideo(sermon)}
                      className="absolute inset-0 flex items-center justify-center bg-black bg-opacity-30 hover:bg-opacity-50 transition-opacity group"
                    >
                      <div className="w-12 h-12 bg-white bg-opacity-80 rounded-full flex items-center justify-center group-hover:bg-opacity-100 transition-opacity">
                        <Activity className="w-6 h-6 text-gray-800 ml-1" />
                      </div>
                    </button>
                    <div className="absolute bottom-2 right-2 bg-black bg-opacity-70 text-white text-xs px-2 py-1 rounded">
                      {sermon.duration}
                    </div>
                  </div>

                  {/* Content */}
                  <div className="p-4">
                    <h3 className={`text-lg font-semibold ${currentUser?.role === 'child' ? 'text-green-800' : 'text-gray-900'} mb-2 line-clamp-2`}>
                      {currentUser?.role === 'child' ? `🙏 ${sermon.title}` : sermon.title}
                    </h3>
                    <p className="text-gray-600 text-sm mb-3 line-clamp-2">{sermon.description}</p>
                    
                    <div className="flex items-center justify-between text-sm text-gray-500 mb-3">
                      <span>By {sermon.pastor}</span>
                      <span>{sermon.date}</span>
                    </div>

                    {/* Tags */}
                    <div className="flex flex-wrap gap-1 mb-3">
                      {sermon.tags?.map((tag, index) => (
                        <span key={index} className="bg-gray-100 text-gray-600 text-xs px-2 py-1 rounded-full">
                          #{tag}
                        </span>
                      ))}
                    </div>

                    {/* Stats */}
                    <div className="flex items-center justify-between">
                      <div className="flex items-center space-x-4 text-sm text-gray-500">
                        <span className="flex items-center">
                          <Eye className="w-4 h-4 mr-1" />
                          {sermon.views}
                        </span>
                        {sermon.saved && (
                          <span className="text-green-600 flex items-center">
                            <CheckCircle className="w-4 h-4 mr-1" />
                            Saved
                          </span>
                        )}
                      </div>
                      <button
                        onClick={() => handlePlayVideo(sermon)}
                        className={`${currentUser?.role === 'child' ? 'bg-green-500 hover:bg-green-600' : 'bg-purple-500 hover:bg-purple-600'} text-white px-3 py-1 rounded-lg text-sm transition-colors`}
                      >
                        {currentUser?.role === 'child' ? '▶️ Watch' : 'Watch Now'}
                      </button>
                    </div>
                  </div>
                </div>
              ))}
            </div>

            {/* Archived Videos Section */}
            <div className="bg-white rounded-lg shadow-sm p-6">
              <h3 className="text-xl font-semibold text-gray-900 mb-4">📁 Archived Services</h3>
              <div className="space-y-3">
                {archivedVideos.map((video) => (
                  <div key={video.id} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                    <div className="flex items-center space-x-3">
                      <div className="text-2xl">{getPlatformIcon(video.platform)}</div>
                      <div>
                        <h4 className="font-medium text-gray-900">{video.title}</h4>
                        <div className="flex items-center space-x-4 text-sm text-gray-500">
                          <span>{video.date}</span>
                          <span>{video.duration}</span>
                          <span>{video.views} views</span>
                          <span className="bg-blue-100 text-blue-800 px-2 py-1 rounded-full text-xs">
                            {video.category}
                          </span>
                        </div>
                      </div>
                    </div>
                    <button
                      onClick={() => handlePlayVideo(video)}
                      className="bg-gray-600 text-white px-3 py-1 rounded-lg text-sm hover:bg-gray-700 transition-colors"
                    >
                      Watch
                    </button>
                  </div>
                ))}
              </div>
            </div>
          </div>
        )}

        {/* Live Streams Section */}
        {activeTab === 'live-streams' && (
          <div className="space-y-6">
            <div className="flex justify-between items-center">
              <h1 className="text-3xl font-bold text-gray-900">
                {currentUser?.role === 'child' ? '📺 Church TV' : 'Live Streams & Meetings'}
              </h1>
              {userPermissions[currentUser?.role]?.canManageSermons && (
                <button
                  onClick={() => setShowAddLiveStream(true)}
                  className="bg-red-600 text-white px-4 py-2 rounded-lg hover:bg-red-700 transition-colors flex items-center"
                >
                  <Plus className="w-4 h-4 mr-2" />
                  Schedule Stream
                </button>
              )}
            </div>

            {/* Live Now Section */}
            <div className="bg-gradient-to-r from-red-50 to-pink-50 rounded-lg p-6 border-2 border-red-200">
              <h3 className="text-xl font-semibold text-red-800 mb-4 flex items-center">
                <div className="w-3 h-3 bg-red-500 rounded-full mr-2 animate-pulse"></div>
                🔴 Live Now
              </h3>
              <div className="grid gap-4">
                {liveStreams.filter(stream => stream.isLive).map((stream) => (
                  <div key={stream.id} className="bg-white rounded-lg p-4 shadow-sm">
                    <div className="flex items-start justify-between">
                      <div className="flex-1">
                        <h4 className="font-semibold text-gray-900 mb-1">{stream.title}</h4>
                        <p className="text-gray-600 text-sm mb-2">{stream.description}</p>
                        <div className="flex items-center space-x-4 text-sm text-gray-500">
                          <span className="flex items-center">
                            <div className="text-lg mr-1">{getPlatformIcon(stream.platform)}</div>
                            {stream.platform.toUpperCase()}
                          </span>
                          <span className="flex items-center text-red-600">
                            <Users className="w-4 h-4 mr-1" />
                            {stream.viewers} watching
                          </span>
                        </div>
                      </div>
                      <div className="flex flex-col space-y-2">
                        <a
                          href={stream.url}
                          target="_blank"
                          rel="noopener noreferrer"
                          className={`${currentUser?.role === 'child' ? 'bg-red-500 hover:bg-red-600' : 'bg-red-600 hover:bg-red-700'} text-white px-4 py-2 rounded-lg text-sm transition-colors flex items-center`}
                        >
                          <Activity className="w-4 h-4 mr-2" />
                          {currentUser?.role === 'child' ? '📺 Watch Live!' : 'Join Live'}
                        </a>
                      </div>
                    </div>
                  </div>
                ))}
                
                {liveStreams.filter(stream => stream.isLive).length === 0 && (
                  <div className="text-center py-8">
                    <div className="text-4xl mb-4">📺</div>
                    <p className="text-gray-600">No live streams at the moment</p>
                    <p className="text-sm text-gray-500 mt-2">Check back during service times</p>
                  </div>
                )}
              </div>
            </div>

            {/* Upcoming Streams */}
            <div className="bg-white rounded-lg shadow-sm p-6">
              <h3 className="text-xl font-semibold text-gray-900 mb-4">📅 Upcoming Services</h3>
              <div className="space-y-4">
                {liveStreams.filter(stream => !stream.isLive).map((stream) => (
                  <div key={stream.id} className={`p-4 rounded-lg border ${currentUser?.role === 'child' ? 'bg-blue-50 border-blue-200' : 'bg-gray-50'}`}>
                    <div className="flex items-start justify-between">
                      <div className="flex-1">
                        <h4 className={`font-semibold ${currentUser?.role === 'child' ? 'text-blue-800' : 'text-gray-900'} mb-1`}>
                          {currentUser?.role === 'child' ? `📺 ${stream.title}` : stream.title}
                        </h4>
                        <p className="text-gray-600 text-sm mb-2">{stream.description}</p>
                        <div className="flex items-center space-x-4 text-sm text-gray-500">
                          <span className="flex items-center">
                            <Calendar className="w-4 h-4 mr-1" />
                            {new Date(stream.startTime).toLocaleString()}
                          </span>
                          <span className="flex items-center">
                            <div className="text-lg mr-1">{getPlatformIcon(stream.platform)}</div>
                            {stream.platform.toUpperCase()}
                          </span>
                        </div>
                        
                        {/* Zoom Meeting Details */}
                        {stream.platform === 'zoom' && stream.meetingId && (
                          <div className="mt-3 p-3 bg-blue-50 rounded-lg">
                            <div className="flex items-center space-x-4 text-sm">
                              <span><strong>Meeting ID:</strong> {stream.meetingId}</span>
                              {stream.passcode && (
                                <span><strong>Passcode:</strong> {stream.passcode}</span>
                              )}
                            </div>
                          </div>
                        )}
                      </div>
                      <div className="flex flex-col space-y-2">
                        <a
                          href={stream.url}
                          target="_blank"
                          rel="noopener noreferrer"
                          className={`${currentUser?.role === 'child' ? 'bg-blue-500 hover:bg-blue-600' : 'bg-gray-600 hover:bg-gray-700'} text-white px-4 py-2 rounded-lg text-sm transition-colors text-center`}
                        >
                          {stream.platform === 'zoom' ? '💻 Join Meeting' : '📺 View Link'}
                        </a>
                        <button className="bg-gray-100 text-gray-700 px-4 py-2 rounded-lg text-sm hover:bg-gray-200 transition-colors">
                          🔔 Remind Me
                        </button>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        )}

        {/* Department Management (Admin/Pastor) */}
        {activeTab === 'departments' && (
          <div className="space-y-6">
            <div className="flex justify-between items-center">
              <h1 className="text-3xl font-bold text-gray-900">Church Ministries</h1>
              {(currentUser?.role === 'pastor' || currentUser?.role === 'admin') && (
                <button
                  onClick={() => setShowAddDepartment(true)}
                  className="bg-purple-600 text-white px-4 py-2 rounded-lg hover:bg-purple-700 transition-colors flex items-center"
                >
                  <Plus className="w-4 h-4 mr-2" />
                  Add Ministry
                </button>
              )}
            </div>

            <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
              {departments.map((dept) => (
                <div key={dept.id} className="bg-white rounded-lg shadow-sm p-6 border border-gray-200 hover:shadow-md transition-shadow">
                  <div className="flex items-start justify-between mb-4">
                    <div className="flex items-center">
                      <Building className="w-8 h-8 text-purple-600 mr-3" />
                      <div>
                        <h3 className="text-lg font-semibold text-gray-900">{dept.name}</h3>
                        <p className="text-sm text-gray-500">Led by {dept.head}</p>
                      </div>
                    </div>
                    <span className="bg-purple-100 text-purple-800 text-xs px-2 py-1 rounded-full">
                      {dept.members} members
                    </span>
                  </div>
                  
                  <p className="text-gray-600 mb-4">{dept.description}</p>
                  
                  <div className="space-y-2 mb-4">
                    <div className="flex items-center text-sm text-gray-500">
                      <Calendar className="w-4 h-4 mr-2" />
                      {dept.meetingDay}s at {dept.meetingTime}
                    </div>
                  </div>
                  
                  <div className="flex flex-wrap gap-2 mb-4">
                    {dept.activities.map((activity, index) => (
                      <span key={index} className="bg-gray-100 text-gray-700 text-xs px-2 py-1 rounded-full">
                        {activity}
                      </span>
                    ))}
                  </div>

                  {/* Communication Links */}
                  <div className="flex space-x-2 mb-4">
                    {dept.whatsappGroup && (
                      <a
                        href={dept.whatsappGroup}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="bg-green-500 text-white px-3 py-1 rounded-lg text-sm hover:bg-green-600 transition-colors flex items-center"
                      >
                        <MessageSquare className="w-3 h-3 mr-1" />
                        WhatsApp
                      </a>
                    )}
                    {dept.slackChannel && (
                      <button
                        onClick={() => {
                          setSelectedDepartment(dept);
                          setShowDepartmentChat(true);
                        }}
                        className="bg-purple-500 text-white px-3 py-1 rounded-lg text-sm hover:bg-purple-600 transition-colors flex items-center"
                      >
                        <MessageCircle className="w-3 h-3 mr-1" />
                        Slack
                      </button>
                    )}
                  </div>
                  
                  <div className="flex space-x-2">
                    <button
                      onClick={() => {
                        setSelectedDepartment(dept);
                        setShowManageDepartment(true);
                      }}
                      className="flex-1 bg-purple-50 text-purple-700 px-3 py-2 rounded-lg text-sm hover:bg-purple-100 transition-colors"
                    >
                      View Details
                    </button>
                    {userPermissions[currentUser?.role]?.canMessageDepartments && (
                      <button
                        onClick={() => {
                          setSelectedDepartment(dept);
                          setShowDepartmentMessages(true);
                        }}
                        className="bg-blue-50 text-blue-700 px-3 py-2 rounded-lg text-sm hover:bg-blue-100 transition-colors flex items-center"
                      >
                        <Send className="w-3 h-3 mr-1" />
                        Message
                      </button>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* MODERATION PANEL */}
        {activeTab === 'moderation' && (currentUser?.role === 'pastor' || currentUser?.role === 'admin') && (
          <div className="space-y-6">
            <div className="flex justify-between items-center">
              <h1 className="text-3xl font-bold text-gray-900">🛡️ Content Moderation</h1>
              <button
                onClick={() => setShowPrivacySettings(true)}
                className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors flex items-center"
              >
                <Settings className="w-4 h-4 mr-2" />
                Privacy Settings
              </button>
            </div>

            {/* Moderation Queue */}
            <div className="bg-white rounded-lg shadow-sm p-6">
              <h2 className="text-xl font-semibold text-gray-900 mb-4 flex items-center">
                <AlertTriangle className="w-5 h-5 mr-2 text-orange-500" />
                Reports Queue ({moderationQueue.length})
              </h2>
              
              {moderationQueue.length === 0 ? (
                <p className="text-gray-500 text-center py-8">No reports pending review</p>
              ) : (
                <div className="space-y-4">
                  {moderationQueue.map((report) => (
                    <div key={report.id} className="border border-gray-200 rounded-lg p-4">
                      <div className="flex justify-between items-start">
                        <div className="flex-1">
                          <div className="flex items-center space-x-2 mb-2">
                            <Flag className="w-4 h-4 text-red-500" />
                            <span className="font-medium text-red-700">
                              {report.type.charAt(0).toUpperCase() + report.type.slice(1)} Content
                            </span>
                            <span className={`px-2 py-1 text-xs rounded-full ${
                              report.severity === 'high' ? 'bg-red-100 text-red-800' :
                              report.severity === 'medium' ? 'bg-orange-100 text-orange-800' :
                              'bg-yellow-100 text-yellow-800'
                            }`}>
                              {report.severity.toUpperCase()}
                            </span>
                          </div>
                          <p className="text-gray-700 mb-2">{report.description}</p>
                          <div className="text-sm text-gray-500 space-y-1">
                            <p>Reported by: {report.reportedBy}</p>
                            <p>Content type: {report.contentType}</p>
                            <p>Time: {new Date(report.timestamp).toLocaleString()}</p>
                          </div>
                        </div>
                        <div className="flex space-x-2 ml-4">
                          <button
                            onClick={() => approveContent(report.id)}
                            className="bg-green-600 text-white px-3 py-1 rounded text-sm hover:bg-green-700 transition-colors"
                          >
                            Approve
                          </button>
                          <button
                            onClick={() => removeContent(report.id)}
                            className="bg-red-600 text-white px-3 py-1 rounded text-sm hover:bg-red-700 transition-colors"
                          >
                            Remove
                          </button>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>

            {/* Blocked Users Management */}
            <div className="bg-white rounded-lg shadow-sm p-6">
              <h2 className="text-xl font-semibold text-gray-900 mb-4 flex items-center">
                <UserX className="w-5 h-5 mr-2 text-red-500" />
                Blocked Users ({blockedUsers.length})
              </h2>
              
              {blockedUsers.length === 0 ? (
                <p className="text-gray-500 text-center py-4">No users blocked</p>
              ) : (
                <div className="space-y-2">
                  {blockedUsers.map((userId) => {
                    const user = members.find(m => m.id === userId);
                    return (
                      <div key={userId} className="flex justify-between items-center p-3 border border-gray-200 rounded-lg">
                        <div>
                          <span className="font-medium">{user?.name || `User ${userId}`}</span>
                          <span className="text-sm text-gray-500 ml-2">({user?.role || 'Unknown'})</span>
                        </div>
                        <button
                          onClick={() => unblockUser(userId)}
                          className="bg-blue-600 text-white px-3 py-1 rounded text-sm hover:bg-blue-700 transition-colors"
                        >
                          Unblock
                        </button>
                      </div>
                    );
                  })}
                </div>
              )}
            </div>

            {/* Privacy Overview */}
            <div className="bg-white rounded-lg shadow-sm p-6">
              <h2 className="text-xl font-semibold text-gray-900 mb-4 flex items-center">
                <Eye className="w-5 h-5 mr-2 text-blue-500" />
                Current Privacy Settings
              </h2>
              <div className="grid md:grid-cols-2 gap-4 text-sm">
                <div>
                  <span className="font-medium">Messages from:</span>
                  <span className="ml-2 text-gray-600">{privacySettings.allowMessagesFrom}</span>
                </div>
                <div>
                  <span className="font-medium">Prayer requests from:</span>
                  <span className="ml-2 text-gray-600">{privacySettings.allowPrayerRequestsFrom}</span>
                </div>
                <div>
                  <span className="font-medium">Profile viewing:</span>
                  <span className="ml-2 text-gray-600">{privacySettings.allowProfileViewing}</span>
                </div>
                <div>
                  <span className="font-medium">Children's content moderation:</span>
                  <span className="ml-2 text-gray-600">{privacySettings.moderateChildrenContent ? 'Enabled' : 'Disabled'}</span>
                </div>
              </div>
            </div>
          </div>
        )}
      </main>

      {/* Add Announcement Modal */}
      {showAddAnnouncement && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg max-w-2xl w-full p-6 max-h-[90vh] overflow-y-auto">
            <div className="flex justify-between items-center mb-4">
              <h3 className="text-lg font-semibold">Add New Announcement</h3>
              <button 
                onClick={() => setShowAddAnnouncement(false)}
                className="text-gray-400 hover:text-gray-600"
              >
                <X className="w-5 h-5" />
              </button>
            </div>
            
            <form onSubmit={handleAnnouncementSubmit}>
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Title</label>
                  <input
                    type="text"
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
                    value={announcementForm.title}
                    onChange={(e) => setAnnouncementForm(prev => ({...prev, title: e.target.value}))}
                    required
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Content</label>
                  <textarea
                    rows={4}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
                    value={announcementForm.content}
                    onChange={(e) => setAnnouncementForm(prev => ({...prev, content: e.target.value}))}
                    required
                  />
                </div>
                
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Priority</label>
                    <select
                      className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
                      value={announcementForm.priority}
                      onChange={(e) => setAnnouncementForm(prev => ({...prev, priority: e.target.value}))}
                    >
                      <option value="low">Low</option>
                      <option value="medium">Medium</option>
                      <option value="high">High</option>
                    </select>
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Department</label>
                    <select
                      className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
                      value={announcementForm.department}
                      onChange={(e) => setAnnouncementForm(prev => ({...prev, department: e.target.value}))}
                    >
                      <option value="all">All Departments</option>
                      {departments.map((dept) => (
                        <option key={dept.id} value={dept.name.toLowerCase().replace(' ', '-')}>{dept.name}</option>
                      ))}
                    </select>
                  </div>
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Expiry Date (Optional)</label>
                  <input
                    type="date"
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
                    value={announcementForm.expiryDate}
                    onChange={(e) => setAnnouncementForm(prev => ({...prev, expiryDate: e.target.value}))}
                  />
                </div>
              </div>
              
              <div className="mt-6 flex space-x-3">
                <button
                  type="submit"
                  className="flex-1 bg-purple-600 text-white py-2 px-4 rounded-md hover:bg-purple-700 transition-colors"
                >
                  Post Announcement
                </button>
                <button
                  type="button"
                  onClick={() => setShowAddAnnouncement(false)}
                  className="px-4 py-2 text-gray-600 hover:text-gray-800"
                >
                  Cancel
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Add Prayer Request Modal */}
      {showAddPrayerRequest && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className={`${currentUser?.role === 'child' ? 'bg-green-50' : 'bg-white'} rounded-lg max-w-2xl w-full p-6 max-h-[90vh] overflow-y-auto`}>
            <div className="flex justify-between items-center mb-4">
              <h3 className={`text-lg font-semibold ${currentUser?.role === 'child' ? 'text-green-800' : 'text-gray-900'}`}>
                {currentUser?.role === 'child' ? '🙏 Add Prayer Request' : 'Add Prayer Request'}
              </h3>
              <button 
                onClick={() => setShowAddPrayerRequest(false)}
                className="text-gray-400 hover:text-gray-600"
              >
                <X className="w-5 h-5" />
              </button>
            </div>
            
            <form onSubmit={handlePrayerRequestSubmit}>
              <div className="space-y-4">
                <div>
                  <label className={`block text-sm font-medium ${currentUser?.role === 'child' ? 'text-green-700' : 'text-gray-700'} mb-1`}>
                    {currentUser?.role === 'child' ? 'What do you need prayer for?' : 'Title'}
                  </label>
                  <input
                    type="text"
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
                    value={prayerRequestForm.title}
                    onChange={(e) => setPrayerRequestForm(prev => ({...prev, title: e.target.value}))}
                    placeholder={currentUser?.role === 'child' ? 'Like "Help for my sick grandma"' : ''}
                    required
                  />
                </div>
                
                <div>
                  <label className={`block text-sm font-medium ${currentUser?.role === 'child' ? 'text-green-700' : 'text-gray-700'} mb-1`}>
                    {currentUser?.role === 'child' ? 'Tell us more (optional)' : 'Details'}
                  </label>
                  <textarea
                    rows={4}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
                    value={prayerRequestForm.content}
                    onChange={(e) => setPrayerRequestForm(prev => ({...prev, content: e.target.value}))}
                    placeholder={currentUser?.role === 'child' ? 'You can share more details here if you want...' : ''}
                  />
                </div>
                
                <div className="space-y-3">
                  <label className="flex items-center">
                    <input
                      type="checkbox"
                      className="mr-2"
                      checked={prayerRequestForm.urgent}
                      onChange={(e) => setPrayerRequestForm(prev => ({...prev, urgent: e.target.checked}))}
                    />
                    <span className={`text-sm ${currentUser?.role === 'child' ? 'text-green-700' : 'text-gray-700'}`}>
                      {currentUser?.role === 'child' ? '⚡ This is really urgent!' : 'Mark as urgent'}
                    </span>
                  </label>
                  
                  {currentUser?.role !== 'child' && (
                    <label className="flex items-center">
                      <input
                        type="checkbox"
                        className="mr-2"
                        checked={prayerRequestForm.anonymous}
                        onChange={(e) => setPrayerRequestForm(prev => ({...prev, anonymous: e.target.checked}))}
                      />
                      <span className="text-sm text-gray-700">Submit anonymously</span>
                    </label>
                  )}
                </div>
              </div>
              
              <div className="mt-6 flex space-x-3">
                <button
                  type="submit"
                  className={`flex-1 ${currentUser?.role === 'child' ? 'bg-green-500 hover:bg-green-600' : 'bg-purple-600 hover:bg-purple-700'} text-white py-2 px-4 rounded-md transition-colors`}
                >
                  {currentUser?.role === 'child' ? '🙏 Ask for Prayer' : 'Submit Request'}
                </button>
                <button
                  type="button"
                  onClick={() => setShowAddPrayerRequest(false)}
                  className="px-4 py-2 text-gray-600 hover:text-gray-800"
                >
                  Cancel
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Department Chat Modal */}
      {showDepartmentChat && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg max-w-2xl w-full h-[600px] flex flex-col">
            <div className="flex justify-between items-center p-4 border-b">
              <h3 className="text-lg font-semibold">Department Chat</h3>
              <button 
                onClick={() => setShowDepartmentChat(false)}
                className="text-gray-400 hover:text-gray-600"
              >
                <X className="w-5 h-5" />
              </button>
            </div>
            
            {/* Department Selection */}
            <div className="p-4 border-b">
              <select
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
                value={selectedDepartment?.name?.toLowerCase().replace(' ', '-') || ''}
                onChange={(e) => {
                  const dept = departments.find(d => d.name.toLowerCase().replace(' ', '-') === e.target.value);
                  setSelectedDepartment(dept);
                }}
              >
                <option value="">Select Department</option>
                {departments.map((dept) => (
                  <option key={dept.id} value={dept.name.toLowerCase().replace(' ', '-')}>
                    {dept.name}
                  </option>
                ))}
              </select>
            </div>
            
            {/* Chat Messages */}
            <div className="flex-1 overflow-y-auto p-4 space-y-3">
              {selectedDepartment && departmentChats[selectedDepartment.name.toLowerCase().replace(' ', '-')]?.map((message) => (
                <div
                  key={message.id}
                  className={`flex ${message.sender === currentUser?.name ? 'justify-end' : 'justify-start'}`}
                >
                  <div
                    className={`max-w-xs lg:max-w-md px-4 py-2 rounded-lg ${
                      message.sender === currentUser?.name
                        ? 'bg-purple-600 text-white'
                        : 'bg-gray-100 text-gray-900'
                    }`}
                  >
                    <p className="text-sm font-medium mb-1">{message.sender}</p>
                    <p className="text-sm">{message.message}</p>
                    <p className="text-xs mt-1 opacity-75">{message.timestamp}</p>
                  </div>
                </div>
              ))}
            </div>
            
            {/* Message Input */}
            <div className="p-4 border-t">
              <div className="flex space-x-2">
                <input
                  type="text"
                  className="flex-1 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
                  placeholder="Type your message..."
                  value={chatMessage}
                  onChange={(e) => setChatMessage(e.target.value)}
                  onKeyPress={(e) => {
                    if (e.key === 'Enter' && selectedDepartment) {
                      handleSendChatMessage(selectedDepartment.name.toLowerCase().replace(' ', '-'));
                    }
                  }}
                />
                <button
                  onClick={() => selectedDepartment && handleSendChatMessage(selectedDepartment.name.toLowerCase().replace(' ', '-'))}
                  disabled={!selectedDepartment || !chatMessage.trim()}
                  className="bg-purple-600 text-white px-4 py-2 rounded-md hover:bg-purple-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  <Send className="w-4 h-4" />
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Add Sermon Modal */}
      {showAddSermon && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg max-w-2xl w-full p-6 max-h-[90vh] overflow-y-auto">
            <div className="flex justify-between items-center mb-4">
              <h3 className="text-lg font-semibold">Add New Sermon</h3>
              <button 
                onClick={() => setShowAddSermon(false)}
                className="text-gray-400 hover:text-gray-600"
              >
                <X className="w-5 h-5" />
              </button>
            </div>
            
            <form onSubmit={handleSermonSubmit}>
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Title</label>
                  <input
                    type="text"
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
                    value={sermonForm.title}
                    onChange={(e) => setSermonForm(prev => ({...prev, title: e.target.value}))}
                    required
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Description</label>
                  <textarea
                    rows={3}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
                    value={sermonForm.description}
                    onChange={(e) => setSermonForm(prev => ({...prev, description: e.target.value}))}
                    required
                  />
                </div>
                
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Pastor/Speaker</label>
                    <input
                      type="text"
                      className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
                      value={sermonForm.pastor}
                      onChange={(e) => setSermonForm(prev => ({...prev, pastor: e.target.value}))}
                      placeholder={currentUser?.name}
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Platform</label>
                    <select
                      className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
                      value={sermonForm.platform}
                      onChange={(e) => setSermonForm(prev => ({...prev, platform: e.target.value}))}
                    >
                      <option value="youtube">YouTube</option>
                      <option value="facebook">Facebook</option>
                      <option value="zoom">Zoom Recording</option>
                      <option value="other">Other</option>
                    </select>
                  </div>
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Video URL</label>
                  <input
                    type="url"
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
                    value={sermonForm.videoUrl}
                    onChange={(e) => setSermonForm(prev => ({...prev, videoUrl: e.target.value}))}
                    placeholder="https://..."
                    required
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Tags (comma separated)</label>
                  <input
                    type="text"
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
                    value={sermonForm.tags}
                    onChange={(e) => setSermonForm(prev => ({...prev, tags: e.target.value}))}
                    placeholder="faith, prayer, salvation"
                  />
                </div>
              </div>
              
              <div className="mt-6 flex space-x-3">
                <button
                  type="submit"
                  className="flex-1 bg-purple-600 text-white py-2 px-4 rounded-md hover:bg-purple-700 transition-colors"
                >
                  Save Sermon
                </button>
                <button
                  type="button"
                  onClick={() => setShowAddSermon(false)}
                  className="px-4 py-2 text-gray-600 hover:text-gray-800"
                >
                  Cancel
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Add Live Stream Modal */}
      {showAddLiveStream && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg max-w-2xl w-full p-6 max-h-[90vh] overflow-y-auto">
            <div className="flex justify-between items-center mb-4">
              <h3 className="text-lg font-semibold">Schedule Live Stream</h3>
              <button 
                onClick={() => setShowAddLiveStream(false)}
                className="text-gray-400 hover:text-gray-600"
              >
                <X className="w-5 h-5" />
              </button>
            </div>
            
            <form onSubmit={handleLiveStreamSubmit}>
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Event Title</label>
                  <input
                    type="text"
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
                    value={liveStreamForm.title}
                    onChange={(e) => setLiveStreamForm(prev => ({...prev, title: e.target.value}))}
                    required
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Description</label>
                  <textarea
                    rows={3}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
                    value={liveStreamForm.description}
                    onChange={(e) => setLiveStreamForm(prev => ({...prev, description: e.target.value}))}
                    required
                  />
                </div>
                
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Platform</label>
                    <select
                      className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
                      value={liveStreamForm.platform}
                      onChange={(e) => setLiveStreamForm(prev => ({...prev, platform: e.target.value}))}
                    >
                      <option value="youtube">YouTube Live</option>
                      <option value="facebook">Facebook Live</option>
                      <option value="zoom">Zoom Meeting</option>
                    </select>
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Start Time</label>
                    <input
                      type="datetime-local"
                      className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
                      value={liveStreamForm.startTime}
                      onChange={(e) => setLiveStreamForm(prev => ({...prev, startTime: e.target.value}))}
                      required
                    />
                  </div>
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Stream URL</label>
                  <input
                    type="url"
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
                    value={liveStreamForm.url}
                    onChange={(e) => setLiveStreamForm(prev => ({...prev, url: e.target.value}))}
                    placeholder="https://..."
                    required
                  />
                </div>
                
                {liveStreamForm.platform === 'zoom' && (
                  <>
                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">Meeting ID</label>
                        <input
                          type="text"
                          className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
                          value={liveStreamForm.meetingId}
                          onChange={(e) => setLiveStreamForm(prev => ({...prev, meetingId: e.target.value}))}
                          placeholder="123 456 789"
                        />
                      </div>
                      
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">Passcode (Optional)</label>
                        <input
                          type="text"
                          className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
                          value={liveStreamForm.passcode}
                          onChange={(e) => setLiveStreamForm(prev => ({...prev, passcode: e.target.value}))}
                          placeholder="faith123"
                        />
                      </div>
                    </div>
                  </>
                )}
              </div>
              
              <div className="mt-6 flex space-x-3">
                <button
                  type="submit"
                  className="flex-1 bg-red-600 text-white py-2 px-4 rounded-md hover:bg-red-700 transition-colors"
                >
                  Schedule Stream
                </button>
                <button
                  type="button"
                  onClick={() => setShowAddLiveStream(false)}
                  className="px-4 py-2 text-gray-600 hover:text-gray-800"
                >
                  Cancel
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Video Player Modal */}
      {showVideoPlayer && selectedVideo && (
        <div className="fixed inset-0 bg-black bg-opacity-75 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg max-w-4xl w-full max-h-[90vh] overflow-hidden">
            <div className="flex justify-between items-center p-4 border-b">
              <div>
                <h3 className="text-lg font-semibold">{selectedVideo.title}</h3>
                <p className="text-sm text-gray-500">
                  {selectedVideo.pastor && `By ${selectedVideo.pastor} • `}
                  {selectedVideo.date || new Date().toISOString().split('T')[0]}
                </p>
              </div>
              <button 
                onClick={() => {
                  setShowVideoPlayer(false);
                  setSelectedVideo(null);
                }}
                className="text-gray-400 hover:text-gray-600"
              >
                <X className="w-6 h-6" />
              </button>
            </div>
            
            <div className="p-4">
              <div className="aspect-video bg-gray-900 rounded-lg flex items-center justify-center mb-4">
                <div className="text-center text-white">
                  <div className="text-6xl mb-4">{getPlatformIcon(
                    selectedVideo.videoUrl?.includes('youtube') ? 'youtube' : 
                    selectedVideo.videoUrl?.includes('facebook') ? 'facebook' : 
                    selectedVideo.platform || 'youtube'
                  )}</div>
                  <p className="text-lg mb-4">Click below to open video</p>
                  <a
                    href={selectedVideo.videoUrl || selectedVideo.url}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="bg-red-600 text-white px-6 py-3 rounded-lg hover:bg-red-700 transition-colors inline-flex items-center"
                  >
                    <ExternalLink className="w-5 h-5 mr-2" />
                    Open in {selectedVideo.videoUrl?.includes('youtube') ? 'YouTube' : 
                             selectedVideo.videoUrl?.includes('facebook') ? 'Facebook' : 
                             selectedVideo.platform === 'zoom' ? 'Zoom' : 'Browser'}
                  </a>
                </div>
              </div>
              
              {selectedVideo.description && (
                <div className="bg-gray-50 rounded-lg p-4">
                  <h4 className="font-medium text-gray-900 mb-2">Description</h4>
                  <p className="text-gray-600">{selectedVideo.description}</p>
                </div>
              )}
            </div>
          </div>
        </div>
      )}

      {/* REPORT CONTENT MODAL */}
      {showReportModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg max-w-md w-full p-6">
            <div className="flex justify-between items-center mb-4">
              <h3 className="text-lg font-semibold flex items-center">
                <Flag className="w-5 h-5 mr-2 text-red-500" />
                Report Content
              </h3>
              <button 
                onClick={() => setShowReportModal(false)}
                className="text-gray-400 hover:text-gray-600"
              >
                <X className="w-5 h-5" />
              </button>
            </div>
            
            <form onSubmit={submitReport}>
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Report Type</label>
                  <select
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-red-500"
                    value={reportForm.type}
                    onChange={(e) => setReportForm(prev => ({...prev, type: e.target.value}))}
                  >
                    <option value="inappropriate">Inappropriate Content</option>
                    <option value="harassment">Harassment</option>
                    <option value="spam">Spam</option>
                    <option value="hate-speech">Hate Speech</option>
                    <option value="other">Other</option>
                  </select>
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Severity</label>
                  <select
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-red-500"
                    value={reportForm.severity}
                    onChange={(e) => setReportForm(prev => ({...prev, severity: e.target.value}))}
                  >
                    <option value="low">Low</option>
                    <option value="medium">Medium</option>
                    <option value="high">High</option>
                  </select>
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Description</label>
                  <textarea
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-red-500"
                    value={reportForm.description}
                    onChange={(e) => setReportForm(prev => ({...prev, description: e.target.value}))}
                    placeholder="Please describe the issue..."
                    rows="3"
                    required
                  />
                </div>
              </div>
              
              <div className="flex justify-end space-x-3 mt-6">
                <button
                  type="button"
                  onClick={() => setShowReportModal(false)}
                  className="px-4 py-2 text-gray-700 border border-gray-300 rounded-md hover:bg-gray-50 transition-colors"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 bg-red-600 text-white rounded-md hover:bg-red-700 transition-colors"
                >
                  Submit Report
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* BLOCK USER MODAL */}
      {showBlockModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg max-w-md w-full p-6">
            <div className="flex justify-between items-center mb-4">
              <h3 className="text-lg font-semibold flex items-center">
                <UserX className="w-5 h-5 mr-2 text-red-500" />
                Block User
              </h3>
              <button 
                onClick={() => setShowBlockModal(false)}
                className="text-gray-400 hover:text-gray-600"
              >
                <X className="w-5 h-5" />
              </button>
            </div>
            
            <div className="mb-6">
              <p className="text-gray-700">
                Are you sure you want to block this user? They will no longer be able to:
              </p>
              <ul className="mt-3 text-sm text-gray-600 space-y-1">
                <li>• Send you messages</li>
                <li>• View your prayer requests</li>
                <li>• See your profile information</li>
                <li>• Interact with your content</li>
              </ul>
              <p className="mt-3 text-sm text-gray-500">
                You can unblock them later from your privacy settings.
              </p>
            </div>
            
            <div className="flex justify-end space-x-3">
              <button
                onClick={() => setShowBlockModal(false)}
                className="px-4 py-2 text-gray-700 border border-gray-300 rounded-md hover:bg-gray-50 transition-colors"
              >
                Cancel
              </button>
              <button
                onClick={confirmBlockUser}
                className="px-4 py-2 bg-red-600 text-white rounded-md hover:bg-red-700 transition-colors"
              >
                Block User
              </button>
            </div>
          </div>
        </div>
      )}

      {/* PRIVACY SETTINGS MODAL */}
      {showPrivacySettings && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg max-w-2xl w-full p-6 max-h-[90vh] overflow-y-auto">
            <div className="flex justify-between items-center mb-4">
              <h3 className="text-lg font-semibold flex items-center">
                <Eye className="w-5 h-5 mr-2 text-blue-500" />
                Privacy & Safety Settings
              </h3>
              <button 
                onClick={() => setShowPrivacySettings(false)}
                className="text-gray-400 hover:text-gray-600"
              >
                <X className="w-5 h-5" />
              </button>
            </div>
            
            <div className="space-y-6">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Who can send you messages?</label>
                <select
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  value={privacySettings.allowMessagesFrom}
                  onChange={(e) => setPrivacySettings(prev => ({...prev, allowMessagesFrom: e.target.value}))}
                >
                  <option value="everyone">Everyone</option>
                  <option value="church-members">Church Members Only</option>
                  <option value="friends-only">Friends Only</option>
                </select>
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Who can submit prayer requests to you?</label>
                <select
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  value={privacySettings.allowPrayerRequestsFrom}
                  onChange={(e) => setPrivacySettings(prev => ({...prev, allowPrayerRequestsFrom: e.target.value}))}
                >
                  <option value="everyone">Everyone</option>
                  <option value="church-members">Church Members Only</option>
                  <option value="prayer-team">Prayer Team Only</option>
                </select>
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Who can view your profile?</label>
                <select
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  value={privacySettings.allowProfileViewing}
                  onChange={(e) => setPrivacySettings(prev => ({...prev, allowProfileViewing: e.target.value}))}
                >
                  <option value="everyone">Everyone</option>
                  <option value="church-members">Church Members Only</option>
                  <option value="friends-only">Friends Only</option>
                </select>
              </div>
              
              <div className="flex items-center">
                <input
                  type="checkbox"
                  id="showOnlineStatus"
                  className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
                  checked={privacySettings.showOnlineStatus}
                  onChange={(e) => setPrivacySettings(prev => ({...prev, showOnlineStatus: e.target.checked}))}
                />
                <label htmlFor="showOnlineStatus" className="ml-2 block text-sm text-gray-700">
                  Show when you're online
                </label>
              </div>
              
              <div className="flex items-center">
                <input
                  type="checkbox"
                  id="moderateChildrenContent"
                  className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
                  checked={privacySettings.moderateChildrenContent}
                  onChange={(e) => setPrivacySettings(prev => ({...prev, moderateChildrenContent: e.target.checked}))}
                />
                <label htmlFor="moderateChildrenContent" className="ml-2 block text-sm text-gray-700">
                  Require approval for all children's content
                </label>
              </div>
              
              <div className="flex items-center">
                <input
                  type="checkbox"
                  id="requireApprovalForPosts"
                  className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
                  checked={privacySettings.requireApprovalForPosts}
                  onChange={(e) => setPrivacySettings(prev => ({...prev, requireApprovalForPosts: e.target.checked}))}
                />
                <label htmlFor="requireApprovalForPosts" className="ml-2 block text-sm text-gray-700">
                  Require approval for all public posts
                </label>
              </div>
            </div>
            
            <div className="flex justify-end space-x-3 mt-6">
              <button
                onClick={() => setShowPrivacySettings(false)}
                className="px-4 py-2 text-gray-700 border border-gray-300 rounded-md hover:bg-gray-50 transition-colors"
              >
                Cancel
              </button>
              <button
                onClick={() => {
                  setShowPrivacySettings(false);
                  alert('Privacy settings saved successfully!');
                }}
                className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors"
              >
                Save Settings
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default FaithKlinikApp;