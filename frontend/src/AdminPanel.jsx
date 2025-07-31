import React, { useState } from 'react';

export default function AdminPanel() {
  const [activeTab, setActiveTab] = useState('students');
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedService, setSelectedService] = useState('');

  // Sample student data
  const students = [
    { id: 'UGR/20210001', name: 'Eyoal Admasu', year: 2021, course: 'Software Engineering' },
    { id: 'UGR/20210002', name: 'Kidus Dereje', year: 2021, course: 'Software Engineering' },
    { id: 'UGR/20220003', name: 'Estifanos Wondwossen', year: 2022, course: 'Software Engineering' },
    { id: 'UGR/20220004', name: 'Kidus Amare', year: 2022, course: 'Software Engineering' },
    { id: 'UGR/20230005', name: 'Asha Jamal', year: 2023, course: 'Information Systems' },
    { id: 'UGR/20230006', name: 'Tilahun Zemecha', year: 2023, course: 'Information Systems' },
    { id: 'UGR/20210007', name: 'Maria Jamal', year: 2021, course: 'Information Systems' },
    { id: 'UGR/20220008', name: 'Amen Sengi', year: 2022, course: 'Information Systems' },
    { id: 'UGR/20230009', name: 'Nathan Berhanu', year: 2023, course: 'Information Systems' },
    { id: 'UGR/20210010', name: 'Kaleb Aron', year: 2021, course: 'Information Systems' },
  ];

  return (
    <div className="min-h-screen bg-white p-6 font-sans">
      {/* Header */}
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-900">Bits Pay</h1>
        <h2 className="text-xl font-semibold text-gray-700 mt-1">
          {activeTab === 'students' ? 'Students' : 'Account Settings'}
        </h2>
      </div>

      {/* Tabs */}
      <div className="flex border-b border-gray-200 mb-6">
        <button
          className={`py-2 px-4 font-medium text-sm ${
            activeTab === 'students' 
              ? 'text-custom-green border-b-2 border-custom-green' 
              : 'text-gray-500 hover:text-gray-700'
          }`}
          onClick={() => setActiveTab('students')}
        >
          Manage Students
        </button>
        <button
          className={`py-2 px-4 font-medium text-sm ${
            activeTab === 'settings' 
              ? 'text-custom-green border-b-2 border-custom-green' 
              : 'text-gray-500 hover:text-gray-700'
          }`}
          onClick={() => setActiveTab('settings')}
        >
          Account Settings
        </button>
      </div>

      {/* Students Tab */}
      {activeTab === 'students' && (
        <div>
          <div className="flex justify-between items-center mb-4">
            <div className="relative w-64">
              <input
                type="text"
                placeholder="Search students"
                className="w-full pl-8 pr-4 py-2 border border-gray-300 rounded focus:outline-none focus:ring-1 focus:ring-green-500 text-sm"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
              />
              <svg
                className="absolute left-2 top-2.5 h-4 w-4 text-gray-400"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
                xmlns="http://www.w3.org/2000/svg"
              >
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
              </svg>
            </div>
            <button className="bg-custom-green hover:bg-green-600 text-white px-6 py-2 rounded text-sm font-medium focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-custom-green transition-colors">
              Create Student
            </button>
          </div>

          <div className="border border-gray-200 rounded overflow-hidden">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th scope="col" className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider border-b border-gray-200">
                    <input type="checkbox" className="h-4 w-4 text-custom-green rounded border-gray-300" />
                  </th>
                  <th scope="col" className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider border-b border-gray-200">
                    Student ID
                  </th>
                  <th scope="col" className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider border-b border-gray-200">
                    Name
                  </th>
                  <th scope="col" className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider border-b border-gray-200">
                    Enrollment Year
                  </th>
                  <th scope="col" className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider border-b border-gray-200">
                    Course
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {students.map((student) => (
                  <tr key={student.id}>
                    <td className="px-4 py-3 whitespace-nowrap text-sm text-gray-500 border-b border-gray-200">
                      <input type="checkbox" className="h-4 w-4 text-custom-green rounded border-gray-300" />
                    </td>
                    <td className="px-4 py-3 whitespace-nowrap text-sm font-medium text-gray-900 border-b border-gray-200">
                      {student.id}
                    </td>
                    <td className="px-4 py-3 whitespace-nowrap text-sm text-gray-500 border-b border-gray-200">
                      {student.name}
                    </td>
                    <td className="px-4 py-3 whitespace-nowrap text-sm text-gray-500 border-b border-gray-200">
                      {student.year}
                    </td>
                    <td className="px-4 py-3 whitespace-nowrap text-sm text-gray-500 border-b border-gray-200">
                      {student.course}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* Account Settings Tab */}
      {activeTab === 'settings' && (
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <h2 className="text-lg font-medium text-gray-900 mb-6">Account Settings</h2>
          
          <div className="space-y-4">
            <div>
              <label htmlFor="service-type" className="block text-sm font-medium text-gray-700 mb-1">
                Service Type
              </label>
              <select
                id="service-type"
                className="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-custom-green focus:border-custom-green sm:text-sm"
              >
                <option value="">Select a service</option>
                <option value="tuition">Tuition</option>
                <option value="cafeteria">Cafeteria Services</option>
                <option value="juice">Juice Services</option>
                <option value="market">Mini Market</option>
              </select>
            </div>
            
            <div>
              <label htmlFor="account-number" className="block text-sm font-medium text-gray-700 mb-1">
                Account Number
              </label>
              <input
                type="text"
                id="account-number"
                className="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-custom-green focus:border-custom-green sm:text-sm"
                placeholder="Enter account number"
              />
            </div>
            
            <div className="pt-2">
              <button
                type="button"
                className="w-40 flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-custom-green hover:bg-green-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-custom-green transition-colors"
              >
                Set Account
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}