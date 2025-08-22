import React, { useState } from 'react';
import { Heart, Users, Calendar, Home } from 'lucide-react';

const SimpleApp = () => {
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [currentUser, setCurrentUser] = useState(null);
  const [activeTab, setActiveTab] = useState('dashboard');

  // Simple login handler
  const handleLogin = () => {
    setCurrentUser({
      id: 1,
      name: 'Rev. Ebenezer Adarquah-Yiadom',
      email: 'pastor@faithklinikministries.com',
      role: 'pastor'
    });
    setIsLoggedIn(true);
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
          
          <button
            onClick={handleLogin}
            className="w-full bg-purple-600 text-white py-3 px-4 rounded-lg hover:bg-purple-700 transition-colors"
          >
            Login as Pastor
          </button>
        </div>
      </div>
    );
  }

  // Main app
  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm">
        <div className="max-w-7xl mx-auto px-4 py-4">
          <div className="flex justify-between items-center">
            <div>
              <h1 className="text-xl font-bold text-purple-800">Faith Klinik Ministries</h1>
              <p className="text-sm text-gray-600">Welcome, {currentUser.name}</p>
            </div>
            <button
              onClick={() => setIsLoggedIn(false)}
              className="text-purple-600 hover:text-purple-800"
            >
              Logout
            </button>
          </div>
        </div>
      </header>

      {/* Navigation */}
      <nav className="bg-white border-b">
        <div className="max-w-7xl mx-auto px-4">
          <div className="flex space-x-8">
            {[
              { id: 'dashboard', name: 'Dashboard', icon: Home },
              { id: 'ministries', name: 'Ministries', icon: Users },
              { id: 'prayer', name: 'Prayer', icon: Heart },
              { id: 'events', name: 'Events', icon: Calendar }
            ].map(tab => (
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

      {/* Content */}
      <main className="max-w-7xl mx-auto px-4 py-8">
        {activeTab === 'dashboard' && (
          <div className="space-y-6">
            <h2 className="text-2xl font-bold text-gray-900">Dashboard</h2>
            
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
              <div className="bg-white p-6 rounded-lg shadow">
                <div className="flex items-center">
                  <Users className="w-8 h-8 text-blue-600 mr-3" />
                  <div>
                    <p className="text-sm text-gray-600">Total Members</p>
                    <p className="text-2xl font-bold text-blue-600">127</p>
                  </div>
                </div>
              </div>
              
              <div className="bg-white p-6 rounded-lg shadow">
                <div className="flex items-center">
                  <Heart className="w-8 h-8 text-red-600 mr-3" />
                  <div>
                    <p className="text-sm text-gray-600">Prayer Requests</p>
                    <p className="text-2xl font-bold text-red-600">8</p>
                  </div>
                </div>
              </div>
              
              <div className="bg-white p-6 rounded-lg shadow">
                <div className="flex items-center">
                  <Calendar className="w-8 h-8 text-green-600 mr-3" />
                  <div>
                    <p className="text-sm text-gray-600">Upcoming Events</p>
                    <p className="text-2xl font-bold text-green-600">3</p>
                  </div>
                </div>
              </div>
              
              <div className="bg-white p-6 rounded-lg shadow">
                <div className="flex items-center">
                  <Users className="w-8 h-8 text-purple-600 mr-3" />
                  <div>
                    <p className="text-sm text-gray-600">Active Ministries</p>
                    <p className="text-2xl font-bold text-purple-600">6</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        )}

        {activeTab === 'ministries' && (
          <div className="space-y-6">
            <h2 className="text-2xl font-bold text-gray-900">Ministries</h2>
            
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {[
                { name: 'Food Pantry Ministry', leader: 'Deaconness Esinam Segoh', members: 15 },
                { name: 'Faith Klinik Dance Ministers', leader: 'Enam Egyir', members: 12 },
                { name: 'League of Anointed Ministers', leader: 'Jedidiah Adarquah-Yiadom', members: 20 },
                { name: 'Media Ministry', leader: 'Jasper D.', members: 8 },
                { name: 'Youth Ministry', leader: 'Jeshurun Adarquah-Yiadom', members: 25 },
                { name: 'Prayer Ministry', leader: 'Rev. Ebenezer Adarquah-Yiadom', members: 30 }
              ].map((ministry, index) => (
                <div key={index} className="bg-white p-6 rounded-lg shadow">
                  <h3 className="font-semibold text-gray-900 mb-2">{ministry.name}</h3>
                  <p className="text-sm text-gray-600 mb-1">Leader: {ministry.leader}</p>
                  <p className="text-sm text-gray-500">{ministry.members} members</p>
                </div>
              ))}
            </div>
          </div>
        )}

        {activeTab === 'prayer' && (
          <div className="space-y-6">
            <h2 className="text-2xl font-bold text-gray-900">Prayer Schedule</h2>
            
            <div className="bg-white rounded-lg shadow overflow-hidden">
              <table className="min-w-full">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Day</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Time</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Leader</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Type</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-200">
                  {[
                    { day: 'Monday', time: '8:00 PM - 9:00 PM', leader: 'Rev. Ebenezer Adarquah-Yiadom', type: 'Daily Prayer' },
                    { day: 'Tuesday', time: '8:00 PM - 9:00 PM', leader: 'Rev. Lucie Adarquah-Yiadom', type: 'Daily Prayer' },
                    { day: 'Wednesday', time: '8:00 PM - 9:00 PM', leader: 'Gloria Adarquah-Yiadom', type: 'Daily Prayer' },
                    { day: 'Thursday', time: '8:00 PM - 9:00 PM', leader: 'Rev. Ebenezer Adarquah-Yiadom', type: 'Daily Prayer' },
                    { day: 'Friday', time: '8:00 PM - 9:30 PM', leader: 'Rev. Lucie Adarquah-Yiadom', type: 'Bible Study' },
                    { day: 'Saturday', time: '6:00 AM - 9:00 AM', leader: 'Multiple Leaders', type: 'Morning Prayer' },
                    { day: 'Sunday', time: '9:30 AM - 11:00 AM', leader: 'Rev. Ebenezer Adarquah-Yiadom', type: 'Pre-Service Prayer' }
                  ].map((schedule, index) => (
                    <tr key={index}>
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">{schedule.day}</td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{schedule.time}</td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{schedule.leader}</td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{schedule.type}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        )}

        {activeTab === 'events' && (
          <div className="space-y-6">
            <h2 className="text-2xl font-bold text-gray-900">Upcoming Events</h2>
            
            <div className="bg-white rounded-lg shadow p-6">
              <div className="space-y-4">
                {[
                  { title: 'Sunday Worship Service', date: '2024-07-28', time: '10:00 AM' },
                  { title: 'Youth Ministry Meeting', date: '2024-07-26', time: '7:00 PM' },
                  { title: 'Food Pantry Distribution', date: '2024-07-31', time: '6:00 PM' }
                ].map((event, index) => (
                  <div key={index} className="flex justify-between items-center p-4 bg-gray-50 rounded-lg">
                    <div>
                      <h3 className="font-medium text-gray-900">{event.title}</h3>
                      <p className="text-sm text-gray-500">{event.date} at {event.time}</p>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        )}
      </main>
    </div>
  );
};

export default SimpleApp;