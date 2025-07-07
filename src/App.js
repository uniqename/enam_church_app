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
  Sparkles
} from 'lucide-react';

const FaithKlinikApp = () => {
  const [activeTab, setActiveTab] = useState('dashboard');
  const [showAddMember, setShowAddMember] = useState(false);
  const [showAddDepartment, setShowAddDepartment] = useState(false);
  const [showAddLeadership, setShowAddLeadership] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');
  
  // Church Leadership Structure
  const [churchLeadership, setChurchLeadership] = useState([
    {
      id: 1,
      name: 'Pastor Michael Johnson',
      position: 'Executive Pastor',
      email: 'pastor@faithklinikministries.com',
      phone: '(614) 555-0789',
      yearsServing: 8,
      specialties: ['Preaching', 'Church Administration', 'Missions']
    },
    {
      id: 2,
      name: 'Rev. Sarah Thompson',
      position: 'Overseer',
      email: 'overseer@faithklinikministries.com',
      phone: '(614) 555-0790',
      yearsServing: 6,
      specialties: ['Pastoral Care', 'Women\'s Ministry', 'Counseling']
    },
    {
      id: 3,
      name: 'Elder James Wilson',
      position: 'Elder',
      email: 'elder1@faithklinikministries.com',
      phone: '(614) 555-0791',
      yearsServing: 12,
      specialties: ['Prayer Ministry', 'Spiritual Guidance']
    },
    {
      id: 4,
      name: 'Elder Mary Davis',
      position: 'Elder',
      email: 'elder2@faithklinikministries.com',
      phone: '(614) 555-0792',
      yearsServing: 10,
      specialties: ['Teaching', 'Discipleship']
    },
    {
      id: 5,
      name: 'Deacon Robert Brown',
      position: 'Deacon',
      email: 'deacon1@faithklinikministries.com',
      phone: '(614) 555-0793',
      yearsServing: 5,
      specialties: ['Finance', 'Administration']
    },
    {
      id: 6,
      name: 'Deaconess Linda Johnson',
      position: 'Deaconess',
      email: 'deaconess1@faithklinikministries.com',
      phone: '(614) 555-0794',
      yearsServing: 7,
      specialties: ['Community Outreach', 'Welfare']
    },
    {
      id: 7,
      name: 'Deacon David Miller',
      position: 'Deacon',
      email: 'deacon2@faithklinikministries.com',
      phone: '(614) 555-0795',
      yearsServing: 4,
      specialties: ['Building & Maintenance', 'Security']
    },
    {
      id: 8,
      name: 'Deaconess Patricia Wilson',
      position: 'Deaconess',
      email: 'deaconess2@faithklinikministries.com',
      phone: '(614) 555-0796',
      yearsServing: 6,
      specialties: ['Children\'s Ministry', 'Education']
    },
    {
      id: 9,
      name: 'Deacon Michael Anderson',
      position: 'Deacon',
      email: 'deacon3@faithklinikministries.com',
      phone: '(614) 555-0797',
      yearsServing: 3,
      specialties: ['Youth Ministry', 'Technology']
    },
    {
      id: 10,
      name: 'Deaconess Grace Taylor',
      position: 'Deaconess',
      email: 'deaconess3@faithklinikministries.com',
      phone: '(614) 555-0798',
      yearsServing: 8,
      specialties: ['Music Ministry', 'Worship']
    }
  ]);
  
  // Sample data with expanded member information
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
      ministryInvolvement: ['Missions Team', 'Men\'s Ministry'],
      emergencyContact: 'Jane Doe - (614) 555-0124',
      address: '123 Faith St, Columbus, OH 43215',
      birthDate: '1985-06-15',
      maritalStatus: 'Married'
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
      ministryInvolvement: ['Worship Team', 'Women\'s Ministry'],
      emergencyContact: 'Bob Smith - (614) 555-0457',
      address: '456 Hope Ave, Columbus, OH 43216',
      birthDate: '1990-03-22',
      maritalStatus: 'Single'
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
      emergencyContact: 'Sarah Johnson - (614) 555-0790',
      address: '789 Church Rd, Columbus, OH 43217',
      birthDate: '1975-12-10',
      maritalStatus: 'Married'
    }
  ]);

  // Enhanced departments with complete structure
  const [departments, setDepartments] = useState([
    { 
      id: 1, 
      name: 'Missions Ministry', 
      leader: 'Pastor Michael Johnson',
      assistant: 'John Doe',
      secretary: 'Mary Wilson',
      treasurer: 'David Brown',
      members: 25, 
      budget: 50000,
      expenses: 32000,
      description: 'Supporting world evangelism through short-term and long-term missions',
      meetingDay: 'First Saturday of the month',
      meetingTime: '10:00 AM',
      meetingLocation: 'Conference Room A',
      projects: ['Guatemala Mission Trip', 'Local Outreach', 'Missionary Support'],
      icon: Globe,
      color: 'purple'
    },
    { 
      id: 2, 
      name: 'Worship Ministry', 
      leader: 'Jane Smith',
      assistant: 'Grace Taylor',
      secretary: 'Michael Peters',
      treasurer: 'Lisa Johnson',
      members: 18, 
      budget: 15000,
      expenses: 8500,
      description: 'Leading the congregation in praise and worship',
      meetingDay: 'Every Wednesday',
      meetingTime: '7:00 PM',
      meetingLocation: 'Sanctuary',
      projects: ['Christmas Concert', 'Easter Service', 'Youth Worship Night'],
      icon: Music,
      color: 'blue'
    },
    { 
      id: 3, 
      name: 'Youth Ministry', 
      leader: 'David Wilson',
      assistant: 'Sarah Davis',
      secretary: 'Mark Thompson',
      treasurer: 'Emily Rodriguez',
      members: 32, 
      budget: 12000,
      expenses: 7200,
      description: 'Discipling and mentoring young people aged 13-25',
      meetingDay: 'Every Friday',
      meetingTime: '7:00 PM',
      meetingLocation: 'Youth Center',
      projects: ['Summer Camp', 'Youth Conference', 'Mission Trip Training'],
      icon: Users,
      color: 'green'
    },
    { 
      id: 4, 
      name: 'Prayer Warriors', 
      leader: 'Mary Thompson',
      assistant: 'Elder James Wilson',
      secretary: 'Patricia Miller',
      treasurer: 'Robert Jones',
      members: 15, 
      budget: 5000,
      expenses: 2100,
      description: 'Interceding for the church and community through prayer',
      meetingDay: 'Daily',
      meetingTime: '6:00 AM',
      meetingLocation: 'Prayer Room',
      projects: ['24/7 Prayer Chain', 'Healing Services', 'Community Prayer Walks'],
      icon: Heart,
      color: 'orange'
    },
    { 
      id: 5, 
      name: 'Children\'s Ministry', 
      leader: 'Deaconess Patricia Wilson',
      assistant: 'Susan Clark',
      secretary: 'Jennifer Adams',
      treasurer: 'Kevin White',
      members: 28, 
      budget: 8000,
      expenses: 4500,
      description: 'Nurturing and teaching children aged 0-12 in faith',
      meetingDay: 'Every Sunday',
      meetingTime: '10:00 AM',
      meetingLocation: 'Children\'s Wing',
      projects: ['Vacation Bible School', 'Children\'s Christmas Play', 'Sunday School'],
      icon: Baby,
      color: 'pink'
    },
    { 
      id: 6, 
      name: 'Women\'s Ministry', 
      leader: 'Rev. Sarah Thompson',
      assistant: 'Linda Johnson',
      secretary: 'Carol Martinez',
      treasurer: 'Nancy Williams',
      members: 45, 
      budget: 10000,
      expenses: 6200,
      description: 'Empowering and supporting women in their faith journey',
      meetingDay: 'Second Saturday',
      meetingTime: '9:00 AM',
      meetingLocation: 'Fellowship Hall',
      projects: ['Women\'s Conference', 'Bible Study Groups', 'Community Service'],
      icon: Heart,
      color: 'rose'
    },
    { 
      id: 7, 
      name: 'Men\'s Ministry', 
      leader: 'Elder James Wilson',
      assistant: 'Robert Brown',
      secretary: 'Thomas Garcia',
      treasurer: 'William Anderson',
      members: 35, 
      budget: 9000,
      expenses: 5800,
      description: 'Building strong Christian men and fathers',
      meetingDay: 'Third Saturday',
      meetingTime: '8:00 AM',
      meetingLocation: 'Men\'s Hall',
      projects: ['Men\'s Retreat', 'Father-Son Activities', 'Community Outreach'],
      icon: Shield,
      color: 'indigo'
    },
    { 
      id: 8, 
      name: 'Faith Klinik Dance Ministers', 
      leader: 'Grace Taylor',
      assistant: 'Maria Santos',
      secretary: 'Ashley Johnson',
      treasurer: 'Rachel Green',
      members: 20, 
      budget: 6000,
      expenses: 3200,
      description: 'Expressing worship through dance and movement',
      meetingDay: 'Every Thursday',
      meetingTime: '6:30 PM',
      meetingLocation: 'Dance Studio',
      projects: ['Worship Dance Performances', 'Dance Workshops', 'Community Events'],
      icon: Sparkles,
      color: 'purple'
    },
    { 
      id: 9, 
      name: 'Cleaning Ministry', 
      leader: 'Deacon David Miller',
      assistant: 'Sandra Lee',
      secretary: 'Betty Davis',
      treasurer: 'Carlos Rodriguez',
      members: 12, 
      budget: 4000,
      expenses: 2800,
      description: 'Maintaining the cleanliness and sanctity of God\'s house',
      meetingDay: 'Every Saturday',
      meetingTime: '8:00 AM',
      meetingLocation: 'Maintenance Room',
      projects: ['Weekly Church Cleaning', 'Deep Cleaning Projects', 'Equipment Maintenance'],
      icon: Sparkles,
      color: 'teal'
    },
    { 
      id: 10, 
      name: 'Evangelism Ministry', 
      leader: 'Pastor Michael Johnson',
      assistant: 'Steven Mitchell',
      secretary: 'Rebecca Turner',
      treasurer: 'Paul Jackson',
      members: 22, 
      budget: 12000,
      expenses: 7500,
      description: 'Spreading the Gospel and winning souls for Christ',
      meetingDay: 'Second Sunday',
      meetingTime: '2:00 PM',
      meetingLocation: 'Conference Room B',
      projects: ['Street Evangelism', 'Hospital Visits', 'Community Outreach'],
      icon: BookOpen,
      color: 'yellow'
    },
    { 
      id: 11, 
      name: 'Food Pantry Ministry', 
      leader: 'Deaconess Linda Johnson',
      assistant: 'Margaret Hill',
      secretary: 'Dorothy King',
      treasurer: 'Frank Wright',
      members: 18, 
      budget: 15000,
      expenses: 11200,
      description: 'Feeding the hungry and supporting families in need',
      meetingDay: 'Every Wednesday',
      meetingTime: '10:00 AM',
      meetingLocation: 'Food Pantry',
      projects: ['Weekly Food Distribution', 'Thanksgiving Baskets', 'Emergency Food Relief'],
      icon: Utensils,
      color: 'green'
    },
    { 
      id: 12, 
      name: 'Building Committee', 
      leader: 'Deacon David Miller',
      assistant: 'John Phillips',
      secretary: 'Angela Scott',
      treasurer: 'Gary Nelson',
      members: 10, 
      budget: 25000,
      expenses: 18500,
      description: 'Overseeing church facility maintenance and improvements',
      meetingDay: 'Last Sunday',
      meetingTime: '12:30 PM',
      meetingLocation: 'Board Room',
      projects: ['Roof Repair', 'HVAC Maintenance', 'Security System Upgrade'],
      icon: Hammer,
      color: 'gray'
    },
    { 
      id: 13, 
      name: 'Welfare Committee', 
      leader: 'Deaconess Patricia Wilson',
      assistant: 'Helen Carter',
      secretary: 'Ruth Parker',
      treasurer: 'James Edwards',
      members: 15, 
      budget: 8000,
      expenses: 5300,
      description: 'Providing support and assistance to members in need',
      meetingDay: 'Second Wednesday',
      meetingTime: '6:00 PM',
      meetingLocation: 'Welfare Office',
      projects: ['Emergency Assistance', 'Medical Support', 'Educational Scholarships'],
      icon: Hand,
      color: 'red'
    },
    { 
      id: 14, 
      name: 'Ushering and Protocol', 
      leader: 'Deacon Robert Brown',
      assistant: 'Charles Adams',
      secretary: 'Gloria Baker',
      treasurer: 'Victor Hall',
      members: 25, 
      budget: 3000,
      expenses: 1800,
      description: 'Maintaining order and hospitality during services',
      meetingDay: 'First Sunday',
      meetingTime: '8:00 AM',
      meetingLocation: 'Sanctuary',
      projects: ['Service Coordination', 'Guest Welcome Program', 'Security Training'],
      icon: DoorOpen,
      color: 'blue'
    },
    { 
      id: 15, 
      name: 'Administration Ministry', 
      leader: 'Pastor Michael Johnson',
      assistant: 'Michelle Young',
      secretary: 'Barbara Allen',
      treasurer: 'Richard Lewis',
      members: 8, 
      budget: 20000,
      expenses: 14200,
      description: 'Managing church operations and administrative functions',
      meetingDay: 'Every Tuesday',
      meetingTime: '10:00 AM',
      meetingLocation: 'Administration Office',
      projects: ['Database Management', 'Communication Systems', 'Policy Development'],
      icon: FileText,
      color: 'slate'
    },
    { 
      id: 16, 
      name: 'Finance Ministry', 
      leader: 'Deacon Robert Brown',
      assistant: 'Catherine Moore',
      secretary: 'Joyce Taylor',
      treasurer: 'Kenneth Wilson',
      members: 6, 
      budget: 5000,
      expenses: 2900,
      description: 'Managing church finances and stewardship programs',
      meetingDay: 'Last Tuesday',
      meetingTime: '7:00 PM',
      meetingLocation: 'Finance Office',
      projects: ['Budget Planning', 'Financial Reporting', 'Stewardship Education'],
      icon: Calculator,
      color: 'emerald'
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
      location: 'Conference Room A',
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
      title: 'Prayer Warriors Meeting', 
      date: '2024-07-11', 
      time: '6:00 AM', 
      location: 'Prayer Room',
      type: 'Prayer',
      attendees: 18,
      leader: 'Mary Thompson',
      description: 'Daily morning prayer and intercession'
    },
    { 
      id: 5, 
      title: 'Women\'s Ministry Conference', 
      date: '2024-07-13', 
      time: '9:00 AM', 
      location: 'Fellowship Hall',
      type: 'Conference',
      attendees: 45,
      leader: 'Rev. Sarah Thompson',
      description: 'Monthly women\'s fellowship and teaching'
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

  const AddMemberModal = () => {
    const [formData, setFormData] = useState({
      name: '',
      email: '',
      phone: '',
      department: '',
      emergencyContact: '',
      address: '',
      birthDate: '',
      maritalStatus: ''
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
      setFormData({ 
        name: '', email: '', phone: '', department: '', emergencyContact: '',
        address: '', birthDate: '', maritalStatus: ''
      });
    };

    return (
      <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
        <div className="bg-white rounded-xl p-6 w-full max-w-2xl mx-4 max-h-[90vh] overflow-y-auto">
          <div className="flex justify-between items-center mb-4">
            <h3 className="text-lg font-semibold text-gray-900">Add New Member</h3>
            <button onClick={() => setShowAddMember(false)} className="text-gray-500 hover:text-gray-700">
              <X size={20} />
            </button>
          </div>
          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
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
                  {departments.map(dept => (
                    <option key={dept.id} value={dept.name}>{dept.name}</option>
                  ))}
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Birth Date</label>
                <input
                  type="date"
                  value={formData.birthDate}
                  onChange={(e) => setFormData({...formData, birthDate: e.target.value})}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Marital Status</label>
                <select
                  value={formData.maritalStatus}
                  onChange={(e) => setFormData({...formData, maritalStatus: e.target.value})}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                >
                  <option value="">Select Status</option>
                  <option value="Single">Single</option>
                  <option value="Married">Married</option>
                  <option value="Divorced">Divorced</option>
                  <option value="Widowed">Widowed</option>
                </select>
              </div>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Address</label>
              <input
                type="text"
                value={formData.address}
                onChange={(e) => setFormData({...formData, address: e.target.value})}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                placeholder="Complete address"
              />
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
              <p className="text-2xl font-bold text-gray-900">{totalDepartmentMembers}</p>
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
              <p className="text-sm text-gray-600">Departments</p>
              <p className="text-2xl font-bold text-gray-900">{totalDepartments}</p>
              <p className="text-xs text-blue-600">Active Ministries</p>
            </div>
            <div className="p-3 bg-purple-100 rounded-full">
              <Building className="w-6 h-6 text-purple-600" />
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
            <div className="p-3 bg-orange-100 rounded-full">
              <Globe className="w-6 h-6 text-orange-600" />
            </div>
          </div>
        </div>
      </div>

      {/* Recent Activity & Church Leadership */}
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
                <p className="text-xs text-gray-600">Sarah Williams - Women's Ministry</p>
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
            <div className="flex items-center p-3 bg-yellow-50 rounded-lg">
              <Utensils className="w-4 h-4 text-yellow-600 mr-3" />
              <div>
                <p className="text-sm font-medium">Food pantry distribution</p>
                <p className="text-xs text-gray-600">50 families served this week</p>
              </div>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg p-6 border border-gray-200">
          <h3 className="text-lg font-semibold mb-4 flex items-center">
            <Crown className="w-5 h-5 mr-2 text-purple-600" />
            Church Leadership
          </h3>
          <div className="space-y-3">
            {churchLeadership.slice(0, 4).map((leader) => (
              <div key={leader.id} className="flex items-center p-3 bg-gray-50 rounded-lg">
                <div className="flex-shrink-0 w-10 h-10 bg-purple-100 rounded-full flex items-center justify-center">
                  {leader.position === 'Executive Pastor' ? <Crown className="w-5 h-5 text-purple-600" /> :
                   leader.position === 'Overseer' ? <Shield className="w-5 h-5 text-blue-600" /> :
                   <Users className="w-5 h-5 text-green-600" />}
                </div>
                <div className="ml-3 flex-1">
                  <p className="text-sm font-medium">{leader.name}</p>
                  <p className="text-xs text-gray-600">{leader.position}</p>
                  <p className="text-xs text-gray-500">{leader.yearsServing} years serving</p>
                </div>
              </div>
            ))}
            <button 
              onClick={() => setActiveTab('leadership')}
              className="w-full text-center text-sm text-blue-600 hover:text-blue-800 py-2"
            >
              View All Leadership →
            </button>
          </div>
        </div>
      </div>

      {/* Ministry Overview */}
      <div className="bg-white rounded-lg p-6 border border-gray-200">
        <h3 className="text-lg font-semibold mb-4 flex items-center">
          <Target className="w-5 h-5 mr-2 text-green-600" />
          Ministry Overview - Top Departments
        </h3>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          {departments.slice(0, 8).map((dept) => {
            const IconComponent = dept.icon;
            return (
              <div key={dept.id} className="p-4 bg-gradient-to-br from-gray-50 to-gray-100 rounded-lg">
                <div className="flex items-center mb-2">
                  <IconComponent className={`w-5 h-5 mr-2 text-${dept.color}-600`} />
                  <h4 className="font-medium text-gray-900 text-sm">{dept.name}</h4>
                </div>
                <p className="text-sm text-gray-600 mb-2">{dept.members} members</p>
                <p className="text-xs text-gray-500">{dept.leader}</p>
                <div className="mt-3 flex items-center">
                  <div className="w-full bg-gray-200 rounded-full h-2">
                    <div 
                      className={`bg-${dept.color}-600 h-2 rounded-full`} 
                      style={{ width: `${(dept.expenses / dept.budget) * 100}%` }}
                    ></div>
                  </div>
                  <span className="ml-2 text-xs text-gray-600">
                    {Math.round((dept.expenses / dept.budget) * 100)}%
                  </span>
                </div>
              </div>
            );
          })}
        </div>
        <div className="text-center mt-4">
          <button 
            onClick={() => setActiveTab('departments')}
            className="text-blue-600 hover:text-blue-800 text-sm font-medium"
          >
            View All {departments.length} Departments →
          </button>
        </div>
      </div>
    </div>
  );

  const renderLeadership = () => (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h2 className="text-2xl font-bold text-gray-900">Church Leadership</h2>
          <p className="text-gray-600">Manage church leadership structure and roles</p>
        </div>
        <button
          onClick={() => setShowAddLeadership(true)}
          className="flex items-center px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors"
        >
          <Plus className="w-4 h-4 mr-2" />
          Add Leadership
        </button>
      </div>

      {/* Leadership Structure Overview */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <div className="bg-gradient-to-br from-purple-500 to-purple-600 rounded-lg p-6 text-white">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-semibold">Executive Level</h3>
            <Crown className="w-6 h-6" />
          </div>
          <p className="text-3xl font-bold">2</p>
          <p className="text-purple-100 text-sm mt-2">Pastor & Overseer</p>
        </div>
        <div className="bg-gradient-to-br from-blue-500 to-blue-600 rounded-lg p-6 text-white">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-semibold">Elders</h3>
            <Shield className="w-6 h-6" />
          </div>
          <p className="text-3xl font-bold">2</p>
          <p className="text-blue-100 text-sm mt-2">Spiritual Leaders</p>
        </div>
        <div className="bg-gradient-to-br from-green-500 to-green-600 rounded-lg p-6 text-white">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-semibold">Deacons</h3>
            <Users className="w-6 h-6" />
          </div>
          <p className="text-3xl font-bold">6</p>
          <p className="text-green-100 text-sm mt-2">3 Deacons & 3 Deaconess</p>
        </div>
      </div>

      {/* Leadership Directory */}
      <div className="bg-white rounded-lg border border-gray-200 p-6">
        <h3 className="text-lg font-semibold mb-4">Leadership Directory</h3>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {churchLeadership.map((leader) => (
            <div key={leader.id} className="border border-gray-200 rounded-lg p-4 hover:shadow-md transition-shadow">
              <div className="flex items-start justify-between mb-4">
                <div className="flex items-center">
                  <div className={`p-3 rounded-full mr-4 ${
                    leader.position === 'Executive Pastor' ? 'bg-purple-100' :
                    leader.position === 'Overseer' ? 'bg-blue-100' :
                    leader.position === 'Elder' ? 'bg-indigo-100' :
                    'bg-green-100'
                  }`}>
                    {leader.position === 'Executive Pastor' ? <Crown className="w-6 h-6 text-purple-600" /> :
                     leader.position === 'Overseer' ? <Shield className="w-6 h-6 text-blue-600" /> :
                     leader.position === 'Elder' ? <BookOpen className="w-6 h-6 text-indigo-600" /> :
                     <Users className="w-6 h-6 text-green-600" />}
                  </div>
                  <div>
                    <h4 className="font-semibold text-gray-900">{leader.name}</h4>
                    <p className="text-sm font-medium text-blue-600">{leader.position}</p>
                    <p className="text-xs text-gray-500">{leader.yearsServing} years of service</p>
                  </div>
                </div>
                <div className="flex space-x-2">
                  <button className="p-2 text-blue-600 hover:bg-blue-100 rounded-lg transition-colors">
                    <Eye className="w-4 h-4" />
                  </button>
                  <button className="p-2 text-green-600 hover:bg-green-100 rounded-lg transition-colors">
                    <Edit className="w-4 h-4" />
                  </button>
                </div>
              </div>
              
              <div className="space-y-2 text-sm">
                <div className="flex items-center">
                  <Mail className="w-4 h-4 text-gray-400 mr-2" />
                  <span className="text-gray-600">{leader.email}</span>
                </div>
                <div className="flex items-center">
                  <Phone className="w-4 h-4 text-gray-400 mr-2" />
                  <span className="text-gray-600">{leader.phone}</span>
                </div>
              </div>
              
              <div className="mt-4">
                <h5 className="text-sm font-medium text-gray-900 mb-2">Specialties</h5>
                <div className="flex flex-wrap gap-1">
                  {leader.specialties.map((specialty, index) => (
                    <span key={index} className="px-2 py-1 text-xs bg-gray-100 text-gray-700 rounded-full">
                      {specialty}
                    </span>
                  ))}
                </div>
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
                <th className="text-left py-3 px-4 font-medium text-gray-900">Personal Info</th>
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
                      <div>Age: {member.birthDate ? new Date().getFullYear() - new Date(member.birthDate).getFullYear() : 'N/A'}</div>
                      <div>Status: {member.maritalStatus || 'N/A'}</div>
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
          <p className="text-gray-600">Manage all {departments.length} church ministries and departments</p>
        </div>
        <button
          onClick={() => setShowAddDepartment(true)}
          className="flex items-center px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors"
        >
          <Plus className="w-4 h-4 mr-2" />
          Add Department
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {departments.map((dept) => {
          const IconComponent = dept.icon;
          return (
            <div key={dept.id} className="bg-white rounded-lg border border-gray-200 p-6 hover:shadow-lg transition-shadow">
              <div className="flex items-start justify-between mb-4">
                <div className="flex items-center">
                  <div className={`p-3 rounded-lg mr-3 bg-${dept.color}-100`}>
                    <IconComponent className={`w-6 h-6 text-${dept.color}-600`} />
                  </div>
                  <div>
                    <h3 className="text-lg font-semibold text-gray-900">{dept.name}</h3>
                    <p className="text-sm text-gray-600">{dept.description}</p>
                  </div>
                </div>
                <button className="text-gray-400 hover:text-gray-600">
                  <Settings className="w-5 h-5" />
                </button>
              </div>

              {/* Department Leadership */}
              <div className="mb-4 p-3 bg-gray-50 rounded-lg">
                <h4 className="text-sm font-semibold text-gray-900 mb-2">Leadership Structure</h4>
                <div className="grid grid-cols-2 gap-2 text-xs">
                  <div>
                    <span className="text-gray-600">Leader:</span>
                    <p className="font-medium">{dept.leader}</p>
                  </div>
                  <div>
                    <span className="text-gray-600">Assistant:</span>
                    <p className="font-medium">{dept.assistant}</p>
                  </div>
                  <div>
                    <span className="text-gray-600">Secretary:</span>
                    <p className="font-medium">{dept.secretary}</p>
                  </div>
                  <div>
                    <span className="text-gray-600">Treasurer:</span>
                    <p className="font-medium">{dept.treasurer}</p>
                  </div>
                </div>
              </div>

              {/* Statistics */}
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

              {/* Budget Progress */}
              <div className="mb-4">
                <div className="flex justify-between text-sm mb-1">
                  <span>Budget Used</span>
                  <span>{Math.round((dept.expenses / dept.budget) * 100)}%</span>
                </div>
                <div className="w-full bg-gray-200 rounded-full h-2">
                  <div 
                    className={`h-2 rounded-full ${
                      (dept.expenses / dept.budget) > 0.8 ? 'bg-red-500' :
                      (dept.expenses / dept.budget) > 0.6 ? 'bg-yellow-500' : 'bg-green-500'
                    }`}
                    style={{ width: `${(dept.expenses / dept.budget) * 100}%` }}
                  ></div>
                </div>
                <div className="flex justify-between text-xs text-gray-600 mt-1">
                  <span>${dept.expenses.toLocaleString()} used</span>
                  <span>${(dept.budget - dept.expenses).toLocaleString()} remaining</span>
                </div>
              </div>

              {/* Meeting Information */}
              <div className="mb-4 text-sm">
                <div className="flex items-center justify-between mb-1">
                  <span className="text-gray-600">Meeting:</span>
                  <span className="font-medium">{dept.meetingDay}</span>
                </div>
                <div className="flex items-center justify-between mb-1">
                  <span className="text-gray-600">Time:</span>
                  <span className="font-medium">{dept.meetingTime}</span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-gray-600">Location:</span>
                  <span className="font-medium">{dept.meetingLocation}</span>
                </div>
              </div>

              {/* Current Projects */}
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

              {/* Action Buttons */}
              <div className="flex space-x-2">
                <button className="flex-1 px-3 py-2 text-sm bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors">
                  View Members
                </button>
                <button className="px-3 py-2 text-sm border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors">
                  Edit
                </button>
                <button className="px-3 py-2 text-sm bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors">
                  Add Member
                </button>
              </div>
            </div>
          );
        })}
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
                      meeting.type === 'Conference' ? 'bg-pink-100' :
                      'bg-orange-100'
                    }`}>
                      {meeting.type === 'Worship' ? <Heart className="w-4 h-4 text-purple-600" /> :
                       meeting.type === 'Ministry' ? <Building className="w-4 h-4 text-blue-600" /> :
                       meeting.type === 'Study' ? <BookOpen className="w-4 h-4 text-green-600" /> :
                       meeting.type === 'Conference' ? <Users className="w-4 h-4 text-pink-600" /> :
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
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {departments.map((dept) => (
            <div key={dept.id} className="p-4 bg-gray-50 rounded-lg">
              <div className="flex items-center justify-between mb-2">
                <div className="flex items-center">
                  <dept.icon className={`w-4 h-4 mr-2 text-${dept.color}-600`} />
                  <h4 className="font-medium text-gray-900">{dept.name}</h4>
                </div>
                <span className="text-sm font-medium text-gray-600">
                  ${dept.expenses.toLocaleString()} / ${dept.budget.toLocaleString()}
                </span>
              </div>
              <div className="w-full bg-gray-200 rounded-full h-2 mb-1">
                <div 
                  className={`h-2 rounded-full ${
                    (dept.expenses / dept.budget) > 0.8 ? 'bg-red-500' :
                    (dept.expenses / dept.budget) > 0.6 ? 'bg-yellow-500' : 'bg-green-500'
                  }`}
                  style={{ width: `${Math.min((dept.expenses / dept.budget) * 100, 100)}%` }}
                ></div>
              </div>
              <div className="flex justify-between text-xs text-gray-600">
                <span>{Math.round((dept.expenses / dept.budget) * 100)}% used</span>
                <span>${(dept.budget - dept.expenses).toLocaleString()} remaining</span>
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
          
          <div className="flex items-center justify-between p-3 bg-yellow-50 rounded-lg">
            <div className="flex items-center">
              <div className="w-8 h-8 bg-yellow-100 rounded-full flex items-center justify-center mr-3">
                <Utensils className="w-4 h-4 text-yellow-600" />
              </div>
              <div>
                <p className="font-medium text-gray-900">Food Pantry Supplies</p>
                <p className="text-sm text-gray-600">July 5, 2024</p>
              </div>
            </div>
            <span className="font-semibold text-red-600">-$320</span>
          </div>
          
          <div className="flex items-center justify-between p-3 bg-blue-50 rounded-lg">
            <div className="flex items-center">
              <div className="w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center mr-3">
                <Hammer className="w-4 h-4 text-blue-600" />
              </div>
              <div>
                <p className="font-medium text-gray-900">Building Maintenance</p>
                <p className="text-sm text-gray-600">July 4, 2024</p>
              </div>
            </div>
            <span className="font-semibold text-red-600">-$450</span>
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
              { id: 'leadership', name: 'Leadership', icon: Crown },
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
        {activeTab === 'leadership' && renderLeadership()}
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