import React, { useState } from 'react';
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
  X
} from 'lucide-react';

const FaithKlinikApp = () => {
  const [activeTab, setActiveTab] = useState('dashboard');
  const [showAddMember, setShowAddMember] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');
  
  // Sample data with mission focus
  const [members, setMembers] = useState([
    { 
      id: 1, 
      name: 'John Doe', 
      email: 'john@email.com', 
      phone: '(614) 555-0123', 
      department: 'Missions', 
      membershipDate: '2022-01-15',
      tithe: 500,
      missions: 200,
      building: 100,
      status: 'Active',
      ministryInvolvement: ['Missions Team', 'Worship Team'],
      emergencyContact: 'Jane Doe - (614) 555-0124'
    },
    { 
      id: 2, 
      name: 'Jane Smith', 
      email: 'jane@email.com', 
      phone: '(614) 555-0456', 
      department: 'Worship', 
      membershipDate: '2021-08-22',
      tithe: 350,
      missions: 150,
      building: 75,
      status: 'Active',
      ministryInvolvement: ['Worship Team', 'Prayer Ministry'],
      emergencyContact: 'Bob Smith - (614) 555-0457'
    },
    { 
      id: 3, 
      name: 'Pastor Michael Johnson', 
      email: 'pastor@faithklinikministries.com', 
      phone: '(614) 555-0789', 
      department: 'Leadership', 
      membershipDate: '2019-05-10',
      tithe: 800,
      missions: 400,
      building: 200,
      status: 'Leadership',
      ministryInvolvement: ['Senior Pastor', 'Missions Director'],
      emergencyContact: 'Sarah Johnson - (614) 555-0790'
    }
  ]);

  const [departments] = useState([
    { 
      id: 1, 
      name: 'Missions Ministry', 
      leader: 'Pastor Michael Johnson', 
      members: 25, 
      budget: 50000,
      expenses: 32000,
      description: 'Supporting world evangelism through short-term and long-term missions',
      meetingDay: 'First Saturday',
      projects: ['Guatemala Mission Trip', 'Local Outreach', 'Missionary Support']
    },
    { 
      id: 2, 
      name: 'Worship Ministry', 
      leader: 'Jane Smith', 
      members: 18, 
      budget: 15000,
      expenses: 8500,
      description: 'Leading the congregation in praise and worship',
      meetingDay: 'Every Wednesday',
      projects: ['Christmas Concert', 'Easter Service', 'Youth Worship Night']
    },
    { 
      id: 3, 
      name: 'Youth Ministry', 
      leader: 'David Wilson', 
      members: 32, 
      budget: 12000,
      expenses: 7200,
      description: 'Discipling and mentoring young people',
      meetingDay: 'Every Friday',
      projects: ['Summer Camp', 'Youth Conference', 'Mission Trip Training']
    },
    { 
      id: 4, 
      name: 'Prayer Ministry', 
      leader: 'Mary Thompson', 
      members: 15, 
      budget: 5000,
      expenses: 2100,
      description: 'Interceding for the church and community',
      meetingDay: 'Daily 6 AM',
      projects: ['24/7 Prayer Chain', 'Healing Services', 'Community Prayer Walks']
    }
  ]);

  const [meetings] = useState([
    { 
      id: 1, 
      title: 'Sunday Worship Service', 
      date: '2024-07-07', 
      time: '10:00 AM', 
      location: 'Main Sanctuary',
      type: 'Worship',
      attendees: 150,
      leader: 'Pastor Michael Johnson',
      description: 'Weekly worship service with communion'
    },
    { 
      id: 2, 
      title: 'Missions Committee Meeting', 
      date: '2024-07-08', 
      time: '7:00 PM', 
      location: 'Conference Room',
      type: 'Ministry',
      attendees: 12,
      leader: 'Pastor Michael Johnson',
      description: 'Planning upcoming mission trips and outreach programs'
    },
    { 
      id: 3, 
      title: 'Youth Bible Study', 
      date: '2024-07-10', 
      time: '7:00 PM', 
      location: 'Youth Center',
      type: 'Study',
      attendees: 28,
      leader: 'David Wilson',
      description: 'Weekly Bible study for teens and young adults'
    },
    { 
      id: 4, 
      title: 'Prayer Meeting', 
      date: '2024-07-11', 
      time: '6:00 AM', 
      location: 'Prayer Room',
      type: 'Prayer',
      attendees: 18,
      leader: 'Mary Thompson',
      description: 'Daily morning prayer and intercession'
    }
  ]);

  const totalTithes = members.reduce((sum, member) => sum + member.tithe, 0);
  const totalMissions = members.reduce((sum, member) => sum + member.missions, 0);
  const totalBuilding = members.reduce((sum, member) => sum + member.building, 0);
  const totalMembers = members.length;
  const activeMembers = members.filter(m => m.status === 'Active').length;

  const filteredMembers = members.filter(member =>
    member.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    member.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
    member.department.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const AddMemberModal = () => {
    const [formData, setFormData] = useState({
      name: '',
      email: '',
      phone: '',
      department: '',
      emergencyContact: ''
    });

    const handleSubmit = (e) => {
      e.preventDefault();
      const newMember = {
        id: members.length + 1,
        ...formData,
        membershipDate: new Date().toISOString().split('T')[0],
        tithe: 0,
        missions: 0,
        building: 0,
        status: 'Active',
        ministryInvolvement: []
      };
      setMembers([...members, newMember]);
      setShowAddMember(false);
      setFormData({ name: '', email: '', phone: '', department: '', emergencyContact: '' });
    };

    return (
      <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
        <div className="bg-white rounded-xl p-6 w-full max-w-md mx-4">
          <div className="flex justify-between items-center mb-4">
            <h3 className="text-lg font-semibold text-gray-900">Add New Member</h3>
            <button onClick={() => setShowAddMember(false)} className="text-gray-500 hover:text-gray-700">
              <X size={20} />
            </button>
          </div>
          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Full Name</label>
              <input
                type="text"
                required
                value={formData.name}
                onChange={(e) => setFormData({...formData, name: e.target.value})}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                placeholder="Enter full name"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Email</label>
              <input
                type="email"
                required
                value={formData.email}
                onChange={(e) => setFormData({...formData, email: e.target.value})}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                placeholder="Enter email address"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Phone</label>
              <input
                type="tel"
                required
                value={formData.phone}
                onChange={(e) => setFormData({...formData, phone: e.target.value})}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                placeholder="(614) 555-0123"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Department</label>
              <select
                required
                value={formData.department}
                onChange={(e) => setFormData({...formData, department: e.target.value})}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              >
                <option value="">Select Department</option>
                <option value="Missions">Missions Ministry</option>
                <option value="Worship">Worship Ministry</option>
                <option value="Youth">Youth Ministry</option>
                <option value="Prayer">Prayer Ministry</option>
                <option value="Leadership">Leadership</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Emergency Contact</label>
              <input
                type="text"
                required
                value={formData.emergencyContact}
                onChange={(e) => setFormData({...formData, emergencyContact: e.target.value})}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                placeholder="Name - Phone"
              />
            </div>
            <div className="flex space-x-3 pt-4">
              <button
                type="button"
                onClick={() => setShowAddMember(false)}
                className="flex-1 px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition-colors"
              >
                Cancel
              </button>
              <button
                type="submit"
                className="flex-1 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
              >
                Add Member
              </button>
            </div>
          </form>
        </div>
      </div>
    );
  };

  const renderDashboard = () => (
    <div className="space-y-6">
      {/* Header */}
      <div className="bg-gradient-to-r from-blue-600 to-purple-600 rounded-xl p-6 text-white">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold mb-2">Faith Klinik Ministries</h1>
            <p className="text-blue-100">Supporting world evangelism through missions • Columbus, Ohio</p>
          </div>
          <div className="text-right">
            <div className="text-sm text-blue-100">Today's Date</div>
            <div className="text-xl font-semibold">{new Date().toLocaleDateString()}</div>
          </div>
        </div>
      </div>

      {/* Key Statistics */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        <div className="bg-white rounded-lg p-4 border border-gray-200 hover:shadow-lg transition-shadow">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Total Members</p>
              <p className="text-2xl font-bold text-gray-900">{totalMembers}</p>
              <p className="text-xs text-green-600">↑ {activeMembers} Active</p>
            </div>
            <div className="p-3 bg-blue-100 rounded-full">
              <Users className="w-6 h-6 text-blue-600" />
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg p-4 border border-gray-200 hover:shadow-lg transition-shadow">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Monthly Tithes</p>
              <p className="text-2xl font-bold text-gray-900">${totalTithes.toLocaleString()}</p>
              <p className="text-xs text-green-600">↑ 12% from last month</p>
            </div>
            <div className="p-3 bg-green-100 rounded-full">
              <DollarSign className="w-6 h-6 text-green-600" />
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg p-4 border border-gray-200 hover:shadow-lg transition-shadow">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Missions Fund</p>
              <p className="text-2xl font-bold text-gray-900">${totalMissions.toLocaleString()}</p>
              <p className="text-xs text-purple-600">↑ 8% from last month</p>
            </div>
            <div className="p-3 bg-purple-100 rounded-full">
              <Globe className="w-6 h-6 text-purple-600" />
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg p-4 border border-gray-200 hover:shadow-lg transition-shadow">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Building Fund</p>
              <p className="text-2xl font-bold text-gray-900">${totalBuilding.toLocaleString()}</p>
              <p className="text-xs text-orange-600">↑ 5% from last month</p>
            </div>
            <div className="p-3 bg-orange-100 rounded-full">
              <Building className="w-6 h-6 text-orange-600" />
            </div>
          </div>
        </div>
      </div>

      {/* Recent Activity & Upcoming Events */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-white rounded-lg p-6 border border-gray-200">
          <h3 className="text-lg font-semibold mb-4 flex items-center">
            <Activity className="w-5 h-5 mr-2 text-blue-600" />
            Recent Activity
          </h3>
          <div className="space-y-3">
            <div className="flex items-center p-3 bg-blue-50 rounded-lg">
              <UserPlus className="w-4 h-4 text-blue-600 mr-3" />
              <div>
                <p className="text-sm font-medium">New member joined</p>
                <p className="text-xs text-gray-600">Sarah Williams - Missions Ministry</p>
              </div>
            </div>
            <div className="flex items-center p-3 bg-green-50 rounded-lg">
              <DollarSign className="w-4 h-4 text-green-600 mr-3" />
              <div>
                <p className="text-sm font-medium">Monthly tithes updated</p>
                <p className="text-xs text-gray-600">$1,650 total received this week</p>
              </div>
            </div>
            <div className="flex items-center p-3 bg-purple-50 rounded-lg">
              <Globe className="w-4 h-4 text-purple-600 mr-3" />
              <div>
                <p className="text-sm font-medium">Mission trip planning</p>
                <p className="text-xs text-gray-600">Guatemala mission scheduled for August</p>
              </div>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg p-6 border border-gray-200">
          <h3 className="text-lg font-semibold mb-4 flex items-center">
            <Calendar className="w-5 h-5 mr-2 text-purple-600" />
            Upcoming Events
          </h3>
          <div className="space-y-3">
            {meetings.slice(0, 3).map((meeting) => (
              <div key={meeting.id} className="flex items-center p-3 bg-gray-50 rounded-lg">
                <div className="flex-shrink-0 w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center">
                  <Calendar className="w-5 h-5 text-purple-600" />
                </div>
                <div className="ml-3 flex-1">
                  <p className="text-sm font-medium">{meeting.title}</p>
                  <p className="text-xs text-gray-600">{meeting.date} at {meeting.time}</p>
                  <p className="text-xs text-gray-500">{meeting.location}</p>
                </div>
                <ChevronRight className="w-4 h-4 text-gray-400" />
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Ministry Overview */}
      <div className="bg-white rounded-lg p-6 border border-gray-200">
        <h3 className="text-lg font-semibold mb-4 flex items-center">
          <Target className="w-5 h-5 mr-2 text-green-600" />
          Ministry Overview
        </h3>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          {departments.map((dept) => (
            <div key={dept.id} className="p-4 bg-gradient-to-br from-gray-50 to-gray-100 rounded-lg">
              <h4 className="font-medium text-gray-900 mb-2">{dept.name}</h4>
              <p className="text-sm text-gray-600 mb-2">{dept.members} members</p>
              <p className="text-xs text-gray-500">{dept.leader}</p>
              <div className="mt-3 flex items-center">
                <div className="w-full bg-gray-200 rounded-full h-2">
                  <div 
                    className="bg-green-600 h-2 rounded-full" 
                    style={{ width: `${(dept.expenses / dept.budget) * 100}%` }}
                  ></div>
                </div>
                <span className="ml-2 text-xs text-gray-600">
                  {Math.round((dept.expenses / dept.budget) * 100)}%
                </span>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );

  const renderMembers = () => (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h2 className="text-2xl font-bold text-gray-900">Church Members</h2>
          <p className="text-gray-600">Manage and track member information</p>
        </div>
        <button
          onClick={() => setShowAddMember(true)}
          className="flex items-center px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
        >
          <Plus className="w-4 h-4 mr-2" />
          Add Member
        </button>
      </div>

      <div className="bg-white rounded-lg border border-gray-200 p-4">
        <div className="flex items-center mb-4">
          <div className="relative flex-1 max-w-md">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
            <input
              type="text"
              placeholder="Search members..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="border-b border-gray-200">
                <th className="text-left py-3 px-4 font-medium text-gray-900">Name</th>
                <th className="text-left py-3 px-4 font-medium text-gray-900">Department</th>
                <th className="text-left py-3 px-4 font-medium text-gray-900">Contact</th>
                <th className="text-left py-3 px-4 font-medium text-gray-900">Contributions</th>
                <th className="text-left py-3 px-4 font-medium text-gray-900">Status</th>
                <th className="text-left py-3 px-4 font-medium text-gray-900">Actions</th>
              </tr>
            </thead>
            <tbody>
              {filteredMembers.map((member) => (
                <tr key={member.id} className="border-b border-gray-100 hover:bg-gray-50">
                  <td className="py-4 px-4">
                    <div>
                      <div className="font-medium text-gray-900">{member.name}</div>
                      <div className="text-sm text-gray-500">Member since {member.membershipDate}</div>
                    </div>
                  </td>
                  <td className="py-4 px-4">
                    <span className="px-2 py-1 text-xs font-medium bg-blue-100 text-blue-800 rounded-full">
                      {member.department}
                    </span>
                  </td>
                  <td className="py-4 px-4">
                    <div className="text-sm">
                      <div className="flex items-center mb-1">
                        <Mail className="w-3 h-3 mr-1 text-gray-400" />
                        {member.email}
                      </div>
                      <div className="flex items-center">
                        <Phone className="w-3 h-3 mr-1 text-gray-400" />
                        {member.phone}
                      </div>
                    </div>
                  </td>
                  <td className="py-4 px-4">
                    <div className="text-sm space-y-1">
                      <div>Tithe: ${member.tithe}</div>
                      <div>Missions: ${member.missions}</div>
                      <div>Building: ${member.building}</div>
                    </div>
                  </td>
                  <td className="py-4 px-4">
                    <span className={`px-2 py-1 text-xs font-medium rounded-full ${
                      member.status === 'Active' ? 'bg-green-100 text-green-800' : 
                      member.status === 'Leadership' ? 'bg-purple-100 text-purple-800' : 
                      'bg-yellow-100 text-yellow-800'
                    }`}>
                      {member.status}
                    </span>
                  </td>
                  <td className="py-4 px-4">
                    <div className="flex space-x-2">
                      <button className="p-1 text-blue-600 hover:bg-blue-100 rounded">
                        <Eye className="w-4 h-4" />
                      </button>
                      <button className="p-1 text-green-600 hover:bg-green-100 rounded">
                        <Edit className="w-4 h-4" />
                      </button>
                      <button className="p-1 text-red-600 hover:bg-red-100 rounded">
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );

  const renderDepartments = () => (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h2 className="text-2xl font-bold text-gray-900">Ministry Departments</h2>
          <p className="text-gray-600">Manage church ministries and departments</p>
        </div>
        <button className="flex items-center px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors">
          <Plus className="w-4 h-4 mr-2" />
          Add Department
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {departments.map((dept) => (
          <div key={dept.id} className="bg-white rounded-lg border border-gray-200 p-6 hover:shadow-lg transition-shadow">
            <div className="flex items-start justify-between mb-4">
              <div>
                <h3 className="text-lg font-semibold text-gray-900">{dept.name}</h3>
                <p className="text-sm text-gray-600 mt-1">{dept.description}</p>
              </div>
              <button className="text-gray-400 hover:text-gray-600">
                <Settings className="w-5 h-5" />
              </button>
            </div>

            <div className="grid grid-cols-2 gap-4 mb-4">
              <div className="text-center p-3 bg-blue-50 rounded-lg">
                <Users className="w-5 h-5 text-blue-600 mx-auto mb-1" />
                <div className="text-xl font-bold text-blue-600">{dept.members}</div>
                <div className="text-xs text-gray-600">Members</div>
              </div>
              <div className="text-center p-3 bg-green-50 rounded-lg">
                <DollarSign className="w-5 h-5 text-green-600 mx-auto mb-1" />
                <div className="text-xl font-bold text-green-600">${dept.budget.toLocaleString()}</div>
                <div className="text-xs text-gray-600">Budget</div>
              </div>
            </div>

            <div className="mb-4">
              <div className="flex justify-between text-sm mb-1">
                <span>Budget Used</span>
                <span>{Math.round((dept.expenses / dept.budget) * 100)}%</span>
              </div>
              <div className="w-full bg-gray-200 rounded-full h-2">
                <div 
                  className="bg-green-600 h-2 rounded-full" 
                  style={{ width: `${(dept.expenses / dept.budget) * 100}%` }}
                ></div>
              </div>
            </div>

            <div className="space-y-2 mb-4">
              <div className="flex items-center justify-between text-sm">
                <span className="text-gray-600">Leader:</span>
                <span className="font-medium">{dept.leader}</span>
              </div>
              <div className="flex items-center justify-between text-sm">
                <span className="text-gray-600">Meeting:</span>
                <span className="font-medium">{dept.meetingDay}</span>
              </div>
              <div className="flex items-center justify-between text-sm">
                <span className="text-gray-600">Expenses:</span>
                <span className="font-medium">${dept.expenses.toLocaleString()}</span>
              </div>
            </div>

            <div className="mb-4">
              <h4 className="text-sm font-medium text-gray-900 mb-2">Current Projects</h4>
              <div className="space-y-1">
                {dept.projects.map((project, index) => (
                  <div key={index} className="flex items-center text-sm">
                    <CheckCircle className="w-3 h-3 text-green-500 mr-2" />
                    <span className="text-gray-600">{project}</span>
                  </div>
                ))}
              </div>
            </div>

            <div className="flex space-x-2">
              <button className="flex-1 px-3 py-2 text-sm bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors">
                View Details
              </button>
              <button className="px-3 py-2 text-sm border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors">
                Edit
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );

  const renderMeetings = () => (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h2 className="text-2xl font-bold text-gray-900">Meetings & Events</h2>
          <p className="text-gray-600">Schedule and manage church meetings</p>
        </div>
        <button className="flex items-center px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors">
          <Plus className="w-4 h-4 mr-2" />
          Add Meeting
        </button>
      </div>

      <div className="bg-white rounded-lg border border-gray-200">
        <div className="p-4 border-b border-gray-200">
          <h3 className="text-lg font-semibold">Upcoming Meetings</h3>
        </div>
        <div className="divide-y divide-gray-200">
          {meetings.map((meeting) => (
            <div key={meeting.id} className="p-4 hover:bg-gray-50 transition-colors">
              <div className="flex items-start justify-between">
                <div className="flex-1">
                  <div className="flex items-center gap-3 mb-2">
                    <div className={`p-2 rounded-lg ${
                      meeting.type === 'Worship' ? 'bg-purple-100' :
                      meeting.type === 'Ministry' ? 'bg-blue-100' :
                      meeting.type === 'Study' ? 'bg-green-100' :
                      'bg-orange-100'
                    }`}>
                      {meeting.type === 'Worship' ? <Heart className="w-4 h-4 text-purple-600" /> :
                       meeting.type === 'Ministry' ? <Building className="w-4 h-4 text-blue-600" /> :
                       meeting.type === 'Study' ? <BookOpen className="w-4 h-4 text-green-600" /> :
                       <Bell className="w-4 h-4 text-orange-600" />}
                    </div>
                    <div>
                      <h4 className="font-semibold text-gray-900">{meeting.title}</h4>
                      <p className="text-sm text-gray-600">{meeting.description}</p>
                    </div>
                  </div>
                  
                  <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 text-sm">
                    <div className="flex items-center">
                      <Calendar className="w-4 h-4 text-gray-400 mr-2" />
                      <span>{meeting.date}</span>
                    </div>
                    <div className="flex items-center">
                      <Clock className="w-4 h-4 text-gray-400 mr-2" />
                      <span>{meeting.time}</span>
                    </div>
                    <div className="flex items-center">
                      <MapPin className="w-4 h-4 text-gray-400 mr-2" />
                      <span>{meeting.location}</span>
                    </div>
                  </div>

                  <div className="flex items-center justify-between mt-3">
                    <div className="flex items-center text-sm text-gray-600">
                      <Users className="w-4 h-4 mr-1" />
                      <span>{meeting.attendees} expected attendees</span>
                    </div>
                    <div className="text-sm text-gray-600">
                      Led by {meeting.leader}
                    </div>
                  </div>
                </div>

                <div className="flex space-x-2 ml-4">
                  <button className="p-2 text-blue-600 hover:bg-blue-100 rounded-lg transition-colors">
                    <Edit className="w-4 h-4" />
                  </button>
                  <button className="p-2 text-green-600 hover:bg-green-100 rounded-lg transition-colors">
                    <Eye className="w-4 h-4" />
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );

  const renderFinances = () => (
    <div className="space-y-6">
      <div>
        <h2 className="text-2xl font-bold text-gray-900">Financial Overview</h2>
        <p className="text-gray-600">Track tithes, offerings, and ministry finances</p>
      </div>

      {/* Financial Summary Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="bg-gradient-to-br from-green-500 to-green-600 rounded-lg p-6 text-white">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-semibold">Total Tithes</h3>
            <DollarSign className="w-6 h-6" />
          </div>
          <p className="text-3xl font-bold">${totalTithes.toLocaleString()}</p>
          <p className="text-green-100 text-sm mt-2">↑ 12% from last month</p>
        </div>

        <div className="bg-gradient-to-br from-purple-500 to-purple-600 rounded-lg p-6 text-white">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-semibold">Missions Fund</h3>
            <Globe className="w-6 h-6" />
          </div>
          <p className="text-3xl font-bold">${totalMissions.toLocaleString()}</p>
          <p className="text-purple-100 text-sm mt-2">Supporting world evangelism</p>
        </div>

        <div className="bg-gradient-to-br from-orange-500 to-orange-600 rounded-lg p-6 text-white">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-semibold">Building Fund</h3>
            <Building className="w-6 h-6" />
          </div>
          <p className="text-3xl font-bold">${totalBuilding.toLocaleString()}</p>
          <p className="text-orange-100 text-sm mt-2">Church facilities & expansion</p>
        </div>
      </div>

      {/* Department Budgets */}
      <div className="bg-white rounded-lg border border-gray-200 p-6">
        <h3 className="text-lg font-semibold mb-4 flex items-center">
          <BarChart3 className="w-5 h-5 mr-2 text-blue-600" />
          Department Budget Overview
        </h3>
        <div className="space-y-4">
          {departments.map((dept) => (
            <div key={dept.id} className="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
              <div className="flex-1">
                <div className="flex items-center justify-between mb-2">
                  <h4 className="font-medium text-gray-900">{dept.name}</h4>
                  <span className="text-sm font-medium text-gray-600">
                    ${dept.expenses.toLocaleString()} / ${dept.budget.toLocaleString()}
                  </span>
                </div>
                <div className="w-full bg-gray-200 rounded-full h-2">
                  <div 
                    className={`h-2 rounded-full ${
                      (dept.expenses / dept.budget) > 0.8 ? 'bg-red-500' :
                      (dept.expenses / dept.budget) > 0.6 ? 'bg-yellow-500' : 'bg-green-500'
                    }`}
                    style={{ width: `${Math.min((dept.expenses / dept.budget) * 100, 100)}%` }}
                  ></div>
                </div>
                <div className="flex justify-between text-xs text-gray-600 mt-1">
                  <span>{Math.round((dept.expenses / dept.budget) * 100)}% used</span>
                  <span>${(dept.budget - dept.expenses).toLocaleString()} remaining</span>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Recent Transactions */}
      <div className="bg-white rounded-lg border border-gray-200 p-6">
        <h3 className="text-lg font-semibold mb-4 flex items-center">
          <Activity className="w-5 h-5 mr-2 text-green-600" />
          Recent Transactions
        </h3>
        <div className="space-y-3">
          <div className="flex items-center justify-between p-3 bg-green-50 rounded-lg">
            <div className="flex items-center">
              <div className="w-8 h-8 bg-green-100 rounded-full flex items-center justify-center mr-3">
                <DollarSign className="w-4 h-4 text-green-600" />
              </div>
              <div>
                <p className="font-medium text-gray-900">Tithe - John Doe</p>
                <p className="text-sm text-gray-600">July 7, 2024</p>
              </div>
            </div>
            <span className="font-semibold text-green-600">+$500</span>
          </div>
          
          <div className="flex items-center justify-between p-3 bg-purple-50 rounded-lg">
            <div className="flex items-center">
              <div className="w-8 h-8 bg-purple-100 rounded-full flex items-center justify-center mr-3">
                <Globe className="w-4 h-4 text-purple-600" />
              </div>
              <div>
                <p className="font-medium text-gray-900">Missions Offering - Jane Smith</p>
                <p className="text-sm text-gray-600">July 6, 2024</p>
              </div>
            </div>
            <span className="font-semibold text-purple-600">+$150</span>
          </div>
          
          <div className="flex items-center justify-between p-3 bg-red-50 rounded-lg">
            <div className="flex items-center">
              <div className="w-8 h-8 bg-red-100 rounded-full flex items-center justify-center mr-3">
                <TrendingUp className="w-4 h-4 text-red-600" />
              </div>
              <div>
                <p className="font-medium text-gray-900">Missions Equipment</p>
                <p className="text-sm text-gray-600">July 5, 2024</p>
              </div>
            </div>
            <span className="font-semibold text-red-600">-$320</span>
          </div>
        </div>
      </div>
    </div>
  );

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Navigation */}
      <nav className="bg-white border-b border-gray-200 sticky top-0 z-40">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <div className="flex items-center">
              <div className="flex-shrink-0 flex items-center">
                <Heart className="w-8 h-8 text-blue-600 mr-2" />
                <span className="text-xl font-bold text-gray-900">Faith Klinik</span>
              </div>
            </div>
            
            <div className="hidden md:flex space-x-8">
              {[
                { id: 'dashboard', name: 'Dashboard', icon: Home },
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
                      ? 'bg-blue-100 text-blue-700'
                      : 'text-gray-500 hover:text-gray-700 hover:bg-gray-100'
                  }`}
                >
                  <tab.icon className="w-4 h-4 mr-2" />
                  {tab.name}
                </button>
              ))}
            </div>

            <div className="flex items-center space-x-4">
              <button className="p-2 text-gray-400 hover:text-gray-600 relative">
                <Bell className="w-5 h-5" />
                <span className="absolute -top-1 -right-1 w-3 h-3 bg-red-500 rounded-full"></span>
              </button>
              <button className="p-2 text-gray-400 hover:text-gray-600">
                <Settings className="w-5 h-5" />
              </button>
            </div>
          </div>
        </div>

        {/* Mobile Navigation */}
        <div className="md:hidden border-t border-gray-200">
          <div className="px-2 py-3 space-y-1">
            {[
              { id: 'dashboard', name: 'Dashboard', icon: Home },
              { id: 'members', name: 'Members', icon: Users },
              { id: 'departments', name: 'Ministries', icon: Building },
              { id: 'meetings', name: 'Meetings', icon: Calendar },
              { id: 'finances', name: 'Finances', icon: DollarSign }
            ].map((tab) => (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={`flex items-center w-full px-3 py-2 rounded-md text-sm font-medium transition-colors ${
                  activeTab === tab.id
                    ? 'bg-blue-100 text-blue-700'
                    : 'text-gray-500 hover:text-gray-700 hover:bg-gray-100'
                }`}
              >
                <tab.icon className="w-4 h-4 mr-3" />
                {tab.name}
              </button>
            ))}
          </div>
        </div>
      </nav>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {activeTab === 'dashboard' && renderDashboard()}
        {activeTab === 'members' && renderMembers()}
        {activeTab === 'departments' && renderDepartments()}
        {activeTab === 'meetings' && renderMeetings()}
        {activeTab === 'finances' && renderFinances()}
      </main>

      {/* Modals */}
      {showAddMember && <AddMemberModal />}

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