import React, { useState } from 'react';
import { 
  Heart, Users, Calendar, Home, Building, DollarSign, BookOpen, 
  Settings, Plus, Edit, Eye, Crown, Globe, Music, Baby, Utensils,
  Shield, Hand, Sparkles, Bell, Search, Menu, X, LogIn
} from 'lucide-react';

const EnhancedApp = () => {
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [currentUser, setCurrentUser] = useState(null);
  const [activeTab, setActiveTab] = useState('dashboard');
  const [showMobileMenu, setShowMobileMenu] = useState(false);
  const [showEditProfile, setShowEditProfile] = useState(false);
  const [editingMember, setEditingMember] = useState(null);

  // Sample data with all Faith Klinik info
  const [members, setMembers] = useState([
    {
      id: 1,
      name: 'Rev. Ebenezer Adarquah-Yiadom',
      email: 'pastor@faithklinikministries.com',
      phone: '(614) 555-0100',
      role: 'pastor',
      birthDate: '1975-03-15',
      address: '123 Faith Avenue, Columbus, OH 43215',
      ministryInvolvement: ['Executive Pastor', 'Prayer Ministry'],
      status: 'Leadership'
    },
    {
      id: 2,
      name: 'Rev. Lucie Adarquah-Yiadom',
      email: 'residentpastor@faithklinikministries.com',
      phone: '(614) 555-0101',
      role: 'admin',
      birthDate: '1978-07-22',
      address: '123 Faith Avenue, Columbus, OH 43215',
      ministryInvolvement: ['Resident Pastor', 'Women\'s Ministry'],
      status: 'Leadership'
    },
    {
      id: 3,
      name: 'Gloria Adarquah-Yiadom',
      email: 'elder.gloria@faithklinikministries.com',
      phone: '(614) 555-0102',
      role: 'leader',
      birthDate: '1965-11-30',
      address: '456 Elder Street, Columbus, OH 43216',
      ministryInvolvement: ['Elder', 'Prayer Ministry'],
      status: 'Leadership'
    },
    {
      id: 4,
      name: 'Deaconness Esinam Segoh',
      email: 'esinam@faithklinikministries.com',
      phone: '(614) 555-0103',
      role: 'leader',
      birthDate: '1970-09-12',
      ministryInvolvement: ['Food Pantry Ministry'],
      status: 'Active'
    },
    {
      id: 5,
      name: 'Enam Egyir',
      email: 'enam@faithklinikministries.com',
      phone: '(614) 555-0104',
      role: 'leader',
      birthDate: '1985-05-20',
      ministryInvolvement: ['Faith Klinik Dance Ministers'],
      status: 'Active'
    },
    {
      id: 6,
      name: 'Jedidiah Adarquah-Yiadom',
      email: 'jedidiah@faithklinikministries.com',
      phone: '(614) 555-0105',
      role: 'leader',
      birthDate: '1990-12-08',
      ministryInvolvement: ['League of Anointed Ministers'],
      status: 'Active'
    }
  ]);

  const [departments, setDepartments] = useState([
    {
      id: 1,
      name: 'Food Pantry Ministry',
      leaders: ['Deaconness Esinam Segoh'],
      members: 15,
      membersList: [],
      description: 'Providing food assistance to families in need in our community',
      meetingDay: 'Wednesday',
      meetingTime: '6:00 PM',
      joinRequests: []
    },
    {
      id: 2,
      name: 'Faith Klinik Dance Ministers',
      leaders: ['Enam Egyir'],
      teacher: 'Samuel Ghartey',
      members: 12,
      membersList: ['Eyram Kwauvi', 'Edem Kwauvi'],
      description: 'Expressing worship through dance and movement',
      meetingDay: 'Every Saturday',
      meetingTime: '10:00 AM',
      joinRequests: []
    },
    {
      id: 3,
      name: 'League of Anointed Ministers (Music Ministry)',
      leaders: ['Jedidiah Adarquah-Yiadom'],
      members: 20,
      membersList: [],
      description: 'Leading congregation in worship through music and praise',
      meetingDay: 'Every Thursday',
      meetingTime: '7:00 PM',
      joinRequests: []
    },
    {
      id: 4,
      name: 'Media Ministry',
      leaders: ['Jasper D.'],
      members: 8,
      membersList: [],
      description: 'Managing audio, video, and digital media for church services',
      meetingDay: 'Second Saturday of the month',
      meetingTime: '2:00 PM',
      joinRequests: []
    },
    {
      id: 5,
      name: 'Youth Ministry',
      leaders: ['Jeshurun Adarquah-Yiadom'],
      members: 25,
      membersList: [],
      description: 'Engaging and discipling the next generation in their faith journey',
      meetingDay: 'Every Friday',
      meetingTime: '7:00 PM',
      joinRequests: []
    },
    {
      id: 6,
      name: 'Prayer Ministry',
      leaders: ['Rev. Ebenezer Adarquah-Yiadom', 'Rev. Lucie Adarquah-Yiadom', 'Gloria Adarquah-Yiadom'],
      members: 30,
      membersList: [],
      description: 'Coordinating prayer meetings and intercession for the church and community',
      meetingDay: 'Multiple days - see prayer schedule',
      meetingTime: 'Various times',
      joinRequests: []
    }
  ]);

  const prayerSchedule = [
    { day: 'Monday', time: '8:00 PM - 9:00 PM', leader: 'Rev. Ebenezer Adarquah-Yiadom', type: 'Daily Prayer' },
    { day: 'Tuesday', time: '8:00 PM - 9:00 PM', leader: 'Rev. Lucie Adarquah-Yiadom', type: 'Daily Prayer' },
    { day: 'Wednesday', time: '8:00 PM - 9:00 PM', leader: 'Gloria Adarquah-Yiadom', type: 'Daily Prayer' },
    { day: 'Thursday', time: '8:00 PM - 9:00 PM', leader: 'Rev. Ebenezer Adarquah-Yiadom', type: 'Daily Prayer' },
    { day: 'Friday', time: '8:00 PM - 9:30 PM', leader: 'Rev. Lucie Adarquah-Yiadom', type: 'Bible Study' },
    { day: 'Saturday', time: '6:00 AM - 9:00 AM', leaders: ['Rev. Ebenezer Adarquah-Yiadom', 'Rev. Lucie Adarquah-Yiadom', 'Gloria Adarquah-Yiadom'], type: 'Morning Prayer' },
    { day: 'Sunday', time: '9:30 AM - 11:00 AM', leader: 'Rev. Ebenezer Adarquah-Yiadom', type: 'Pre-Service Prayer' }
  ];

  // Helper functions
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

  const formatBirthday = (birthDate) => {
    if (!birthDate) return 'Not provided';
    const date = new Date(birthDate);
    return date.toLocaleDateString('en-US', { month: 'long', day: 'numeric' });
  };

  // Handlers
  const handleLogin = (role = 'pastor') => {
    const user = members.find(m => m.role === role) || members[0];
    setCurrentUser(user);
    setIsLoggedIn(true);
  };

  const handleEditProfile = (member) => {
    setEditingMember({...member});
    setShowEditProfile(true);
  };

  const handleSaveProfile = () => {
    setMembers(members.map(m => 
      m.id === editingMember.id ? editingMember : m
    ));
    
    if (currentUser && currentUser.id === editingMember.id) {
      setCurrentUser(editingMember);
    }
    
    setShowEditProfile(false);
    setEditingMember(null);
  };

  const handleJoinMinistry = (departmentId) => {
    const department = departments.find(d => d.id === departmentId);
    if (!department || !currentUser) return;

    const updatedDepartments = departments.map(d => {
      if (d.id === departmentId) {
        const existingRequest = d.joinRequests?.find(r => r.memberId === currentUser.id);
        if (existingRequest) return d;

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

  const getNavigationItems = () => {
    if (!currentUser) return [];
    
    const baseItems = [
      { id: 'dashboard', name: 'Home', icon: Home },
      { id: 'ministries', name: 'Ministries', icon: Building },
      { id: 'prayer', name: 'Prayer', icon: Heart }
    ];

    switch(currentUser.role) {
      case 'pastor':
        return [...baseItems, 
          { id: 'members', name: 'Members', icon: Users },
          { id: 'analytics', name: 'Analytics', icon: BookOpen }
        ];
      case 'admin':
        return [...baseItems,
          { id: 'members', name: 'Members', icon: Users },
          { id: 'settings', name: 'Settings', icon: Settings }
        ];
      case 'leader':
        return [...baseItems,
          { id: 'my-ministry', name: 'My Ministry', icon: Crown },
          { id: 'events', name: 'Events', icon: Calendar }
        ];
      default:
        return [...baseItems,
          { id: 'profile', name: 'Profile', icon: Users },
          { id: 'events', name: 'Events', icon: Calendar }
        ];
    }
  };

  // Login screen
  if (!isLoggedIn) {
    return (
      <div className="min-h-screen bg-purple-50 flex items-center justify-center">
        <div className="bg-white p-8 rounded-lg shadow-md max-w-md w-full mx-4">
          <div className="text-center mb-6">
            <Heart className="w-16 h-16 text-purple-600 mx-auto mb-4" />
            <h1 className="text-2xl font-bold text-purple-800">Faith Klinik Ministries</h1>
            <p className="text-gray-600">Columbus, OH</p>
          </div>
          
          <div className="space-y-3">
            <button
              onClick={() => handleLogin('pastor')}
              className="w-full bg-purple-600 text-white py-3 px-4 rounded-lg hover:bg-purple-700 transition-colors"
            >
              Login as Pastor
            </button>
            <button
              onClick={() => handleLogin('admin')}
              className="w-full bg-blue-600 text-white py-3 px-4 rounded-lg hover:bg-blue-700 transition-colors"
            >
              Login as Admin
            </button>
            <button
              onClick={() => handleLogin('leader')}
              className="w-full bg-green-600 text-white py-3 px-4 rounded-lg hover:bg-green-700 transition-colors"
            >
              Login as Leader
            </button>
            <button
              onClick={() => handleLogin('member')}
              className="w-full bg-gray-600 text-white py-3 px-4 rounded-lg hover:bg-gray-700 transition-colors"
            >
              Login as Member
            </button>
          </div>
        </div>
      </div>
    );
  }

  // Main app
  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-4 py-4">
          <div className="flex justify-between items-center">
            <div>
              <h1 className="text-xl font-bold text-purple-800">Faith Klinik Ministries</h1>
              <p className="text-sm text-gray-600">Welcome, {currentUser.name}</p>
            </div>
            
            <div className="flex items-center space-x-4">
              <button
                onClick={() => setShowMobileMenu(!showMobileMenu)}
                className="md:hidden text-gray-600 hover:text-gray-800"
              >
                <Menu className="w-6 h-6" />
              </button>
              
              <button
                onClick={() => setIsLoggedIn(false)}
                className="text-purple-600 hover:text-purple-800 flex items-center"
              >
                <LogIn className="w-4 h-4 mr-1" />
                Logout
              </button>
            </div>
          </div>
        </div>
      </header>

      {/* Navigation */}
      <nav className="bg-white border-b">
        <div className="max-w-7xl mx-auto px-4">
          <div className="hidden md:flex space-x-8">
            {getNavigationItems().map(tab => (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={`flex items-center py-4 px-2 border-b-2 transition-colors ${
                  activeTab === tab.id
                    ? 'border-purple-500 text-purple-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700'
                }`}
              >
                <tab.icon className="w-5 h-5 mr-2" />
                {tab.name}
              </button>
            ))}
          </div>
        </div>
      </nav>

      {/* Mobile Navigation */}
      {showMobileMenu && (
        <div className="md:hidden bg-white border-b shadow-lg">
          <div className="px-2 pt-2 pb-3 space-y-1">
            {getNavigationItems().map(tab => (
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
                <tab.icon className="w-5 h-5 mr-2" />
                {tab.name}
              </button>
            ))}
          </div>
        </div>
      )}

      {/* Content */}
      <main className="max-w-7xl mx-auto px-4 py-8">
        {/* Dashboard */}
        {activeTab === 'dashboard' && (
          <div className="space-y-6">
            <div className="flex justify-between items-center">
              <h2 className="text-2xl font-bold text-gray-900">Dashboard</h2>
              <div className="text-sm text-gray-500">
                {new Date().toLocaleDateString('en-US', { 
                  weekday: 'long', 
                  year: 'numeric', 
                  month: 'long', 
                  day: 'numeric' 
                })}
              </div>
            </div>

            {/* Today's Birthdays */}
            {getTodaysBirthdays().length > 0 && (
              <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-4">
                <h3 className="font-semibold text-yellow-800 mb-2">🎂 Today's Birthdays</h3>
                <div className="space-y-1">
                  {getTodaysBirthdays().map(member => (
                    <p key={member.id} className="text-yellow-700">
                      {member.name} - Wish them a happy birthday!
                    </p>
                  ))}
                </div>
              </div>
            )}
            
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
              <div className="bg-white p-6 rounded-lg shadow">
                <div className="flex items-center">
                  <Users className="w-8 h-8 text-blue-600 mr-3" />
                  <div>
                    <p className="text-sm text-gray-600">Total Members</p>
                    <p className="text-2xl font-bold text-blue-600">{members.length}</p>
                  </div>
                </div>
              </div>
              
              <div className="bg-white p-6 rounded-lg shadow">
                <div className="flex items-center">
                  <Building className="w-8 h-8 text-green-600 mr-3" />
                  <div>
                    <p className="text-sm text-gray-600">Active Ministries</p>
                    <p className="text-2xl font-bold text-green-600">{departments.length}</p>
                  </div>
                </div>
              </div>
              
              <div className="bg-white p-6 rounded-lg shadow">
                <div className="flex items-center">
                  <Heart className="w-8 h-8 text-red-600 mr-3" />
                  <div>
                    <p className="text-sm text-gray-600">Prayer Sessions</p>
                    <p className="text-2xl font-bold text-red-600">{prayerSchedule.length}</p>
                  </div>
                </div>
              </div>
              
              <div className="bg-white p-6 rounded-lg shadow">
                <div className="flex items-center">
                  <Crown className="w-8 h-8 text-purple-600 mr-3" />
                  <div>
                    <p className="text-sm text-gray-600">Leaders</p>
                    <p className="text-2xl font-bold text-purple-600">
                      {members.filter(m => m.role === 'leader' || m.role === 'admin' || m.role === 'pastor').length}
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Ministries */}
        {activeTab === 'ministries' && (
          <div className="space-y-6">
            <div className="flex justify-between items-center">
              <h2 className="text-2xl font-bold text-gray-900">Ministries & Departments</h2>
              {currentUser.role === 'member' && (
                <p className="text-sm text-gray-500">
                  Click "Request to Join" to join any ministry
                </p>
              )}
            </div>
            
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {departments.map(dept => (
                <div key={dept.id} className="bg-white p-6 rounded-lg shadow">
                  <h3 className="font-semibold text-gray-900 mb-2">{dept.name}</h3>
                  <p className="text-sm text-gray-600 mb-3">{dept.description}</p>
                  
                  <div className="space-y-2 mb-4">
                    <div className="flex justify-between text-sm">
                      <span className="text-gray-500">Leaders:</span>
                      <span className="text-gray-900">{dept.leaders.join(', ')}</span>
                    </div>
                    {dept.teacher && (
                      <div className="flex justify-between text-sm">
                        <span className="text-gray-500">Teacher:</span>
                        <span className="text-gray-900">{dept.teacher}</span>
                      </div>
                    )}
                    <div className="flex justify-between text-sm">
                      <span className="text-gray-500">Members:</span>
                      <span className="text-gray-900">{dept.members}</span>
                    </div>
                    <div className="flex justify-between text-sm">
                      <span className="text-gray-500">Meets:</span>
                      <span className="text-gray-900">{dept.meetingDay} {dept.meetingTime}</span>
                    </div>
                  </div>

                  {dept.membersList && dept.membersList.length > 0 && (
                    <div className="mb-4">
                      <p className="text-xs text-gray-500 mb-1">Current Members:</p>
                      <div className="flex flex-wrap gap-1">
                        {dept.membersList.map((member, index) => (
                          <span key={index} className="text-xs bg-gray-100 px-2 py-1 rounded">
                            {member}
                          </span>
                        ))}
                      </div>
                    </div>
                  )}

                  {currentUser.role === 'member' && (
                    <button
                      onClick={() => handleJoinMinistry(dept.id)}
                      className="w-full bg-purple-600 text-white py-2 px-4 rounded hover:bg-purple-700 transition-colors text-sm"
                    >
                      Request to Join
                    </button>
                  )}

                  {(currentUser.role === 'admin' || 
                    (currentUser.role === 'leader' && dept.leaders.includes(currentUser.name))) && 
                    dept.joinRequests && dept.joinRequests.length > 0 && (
                    <div className="mt-4 p-3 bg-yellow-50 rounded-lg">
                      <p className="text-sm font-medium text-yellow-800 mb-2">
                        {dept.joinRequests.length} Pending Request(s)
                      </p>
                      {dept.joinRequests.map(request => (
                        <div key={request.id} className="text-xs text-yellow-700">
                          {request.memberName} - {request.requestDate}
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Prayer Schedule */}
        {activeTab === 'prayer' && (
          <div className="space-y-6">
            <h2 className="text-2xl font-bold text-gray-900">Prayer Schedule</h2>
            
            <div className="bg-white rounded-lg shadow overflow-hidden">
              <div className="px-6 py-4 bg-purple-50 border-b">
                <h3 className="text-lg font-semibold text-purple-800">Weekly Prayer Times</h3>
                <p className="text-sm text-purple-600">All prayer meetings are held at Faith Klinik Ministries</p>
              </div>
              
              <div className="overflow-x-auto">
                <table className="min-w-full">
                  <thead className="bg-gray-50">
                    <tr>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Day</th>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Time</th>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Leader(s)</th>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Type</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-200">
                    {prayerSchedule.map((schedule, index) => (
                      <tr key={index} className="hover:bg-gray-50">
                        <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                          {schedule.day}
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                          {schedule.time}
                        </td>
                        <td className="px-6 py-4 text-sm text-gray-500">
                          {schedule.leaders ? schedule.leaders.join(', ') : schedule.leader}
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                          <span className={`px-2 py-1 rounded-full text-xs ${
                            schedule.type === 'Bible Study' ? 'bg-blue-100 text-blue-800' :
                            schedule.type === 'Morning Prayer' ? 'bg-yellow-100 text-yellow-800' :
                            'bg-purple-100 text-purple-800'
                          }`}>
                            {schedule.type}
                          </span>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        )}

        {/* Profile */}
        {activeTab === 'profile' && (
          <div className="space-y-6">
            <div className="flex justify-between items-center">
              <h2 className="text-2xl font-bold text-gray-900">My Profile</h2>
              <button
                onClick={() => handleEditProfile(currentUser)}
                className="bg-purple-600 text-white px-4 py-2 rounded hover:bg-purple-700 transition-colors flex items-center"
              >
                <Edit className="w-4 h-4 mr-2" />
                Edit Profile
              </button>
            </div>
            
            <div className="bg-white rounded-lg shadow p-6">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <h3 className="text-lg font-semibold text-gray-900 mb-4">Personal Information</h3>
                  <div className="space-y-3">
                    <div>
                      <label className="block text-sm font-medium text-gray-700">Name</label>
                      <p className="mt-1 text-sm text-gray-900">{currentUser.name}</p>
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700">Email</label>
                      <p className="mt-1 text-sm text-gray-900">{currentUser.email}</p>
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700">Phone</label>
                      <p className="mt-1 text-sm text-gray-900">{currentUser.phone}</p>
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700">Birthday</label>
                      <p className="mt-1 text-sm text-gray-900">{formatBirthday(currentUser.birthDate)}</p>
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700">Address</label>
                      <p className="mt-1 text-sm text-gray-900">{currentUser.address || 'Not provided'}</p>
                    </div>
                  </div>
                </div>
                
                <div>
                  <h3 className="text-lg font-semibold text-gray-900 mb-4">Ministry Involvement</h3>
                  <div className="space-y-2">
                    {currentUser.ministryInvolvement && currentUser.ministryInvolvement.length > 0 ? (
                      currentUser.ministryInvolvement.map((ministry, index) => (
                        <span key={index} className="inline-block bg-purple-100 text-purple-800 px-2 py-1 rounded text-sm mr-2 mb-2">
                          {ministry}
                        </span>
                      ))
                    ) : (
                      <p className="text-gray-500">No ministry involvement yet</p>
                    )}
                  </div>
                  
                  <h3 className="text-lg font-semibold text-gray-900 mt-6 mb-4">Role</h3>
                  <span className={`inline-block px-3 py-1 rounded-full text-sm ${
                    currentUser.role === 'pastor' ? 'bg-purple-100 text-purple-800' :
                    currentUser.role === 'admin' ? 'bg-blue-100 text-blue-800' :
                    currentUser.role === 'leader' ? 'bg-green-100 text-green-800' :
                    'bg-gray-100 text-gray-800'
                  }`}>
                    {currentUser.role.charAt(0).toUpperCase() + currentUser.role.slice(1)}
                  </span>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Members (Admin/Pastor only) */}
        {activeTab === 'members' && (currentUser.role === 'admin' || currentUser.role === 'pastor') && (
          <div className="space-y-6">
            <h2 className="text-2xl font-bold text-gray-900">Church Members</h2>
            
            <div className="bg-white rounded-lg shadow overflow-hidden">
              <div className="px-6 py-4 bg-gray-50 border-b">
                <h3 className="text-lg font-semibold text-gray-900">Member Directory</h3>
              </div>
              
              <div className="overflow-x-auto">
                <table className="min-w-full">
                  <thead className="bg-gray-50">
                    <tr>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Name</th>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Role</th>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Ministry</th>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Birthday</th>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Actions</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-200">
                    {members.map(member => (
                      <tr key={member.id} className="hover:bg-gray-50">
                        <td className="px-6 py-4 whitespace-nowrap">
                          <div>
                            <div className="text-sm font-medium text-gray-900">{member.name}</div>
                            <div className="text-sm text-gray-500">{member.email}</div>
                          </div>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap">
                          <span className={`px-2 py-1 rounded-full text-xs ${
                            member.role === 'pastor' ? 'bg-purple-100 text-purple-800' :
                            member.role === 'admin' ? 'bg-blue-100 text-blue-800' :
                            member.role === 'leader' ? 'bg-green-100 text-green-800' :
                            'bg-gray-100 text-gray-800'
                          }`}>
                            {member.role}
                          </span>
                        </td>
                        <td className="px-6 py-4 text-sm text-gray-500">
                          {member.ministryInvolvement ? member.ministryInvolvement.slice(0, 2).join(', ') : 'None'}
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                          {formatBirthday(member.birthDate)}
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                          <button
                            onClick={() => handleEditProfile(member)}
                            className="text-purple-600 hover:text-purple-900"
                          >
                            Edit
                          </button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        )}
      </main>

      {/* Edit Profile Modal */}
      {showEditProfile && editingMember && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg shadow-xl max-w-md w-full max-h-96 overflow-y-auto">
            <div className="p-6">
              <div className="flex justify-between items-center mb-4">
                <h3 className="text-lg font-semibold text-gray-900">Edit Profile</h3>
                <button
                  onClick={() => setShowEditProfile(false)}
                  className="text-gray-400 hover:text-gray-600"
                >
                  <X className="w-6 h-6" />
                </button>
              </div>
              
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700">Name</label>
                  <input
                    type="text"
                    value={editingMember.name}
                    onChange={(e) => setEditingMember({...editingMember, name: e.target.value})}
                    className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500"
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700">Email</label>
                  <input
                    type="email"
                    value={editingMember.email}
                    onChange={(e) => setEditingMember({...editingMember, email: e.target.value})}
                    className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500"
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700">Phone</label>
                  <input
                    type="tel"
                    value={editingMember.phone}
                    onChange={(e) => setEditingMember({...editingMember, phone: e.target.value})}
                    className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500"
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700">Birthday</label>
                  <input
                    type="date"
                    value={editingMember.birthDate}
                    onChange={(e) => setEditingMember({...editingMember, birthDate: e.target.value})}
                    className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500"
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700">Address</label>
                  <textarea
                    value={editingMember.address || ''}
                    onChange={(e) => setEditingMember({...editingMember, address: e.target.value})}
                    className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500"
                    rows={2}
                  />
                </div>
              </div>
              
              <div className="flex space-x-3 mt-6">
                <button
                  onClick={() => setShowEditProfile(false)}
                  className="flex-1 px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition-colors"
                >
                  Cancel
                </button>
                <button
                  onClick={handleSaveProfile}
                  className="flex-1 px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors"
                >
                  Save Changes
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default EnhancedApp;