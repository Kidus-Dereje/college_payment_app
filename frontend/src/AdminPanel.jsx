import React, { useState, useEffect } from 'react';
import axios from 'axios';

export default function AdminPanel() {
  // ...existing state and logic...

  // Bulk create users for selected students
  const handleBulkCreateUsers = async () => {
    if (selected.length === 0) return;
    try {
      const response = await axios.post('http://localhost:3000/api/students/bulk_create_users', {
        student_ids: selected
      });
      const { created, errors } = response.data;
      if (created && created.length > 0) {
        // Redirect to credentials summary view with created credentials
        const createdParam = encodeURIComponent(JSON.stringify(created));
        window.location.assign(`/students/credentials_summary?created=${createdParam}`);
        return;
      }
      let msg = '';
      if (errors && errors.length > 0) {
        msg += `${errors.length} users failed to create.`;
      }
      alert(msg || 'No users were created.');
      // Optionally, refresh the student list
      setSelected([]);
      if (typeof fetchStudents === 'function') fetchStudents();
    } catch (err) {
      alert('Bulk creation failed.');
    }
  };

  const [activeTab, setActiveTab] = useState('students');
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedService, setSelectedService] = useState('');

  const [students, setStudents] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [selected, setSelected] = useState([]); // array of selected student_ids

  // Filtered students based on searchTerm
  const filteredStudents = students.filter(student => {
    const search = searchTerm.toLowerCase();
    const name = `${student.first_name || ""} ${student.last_name || ""}`.toLowerCase();
    return (
      student.student_id?.toLowerCase().includes(search) ||
      name.includes(search)
    );
  });

  // Select all checkbox logic
  const allSelected = filteredStudents.length > 0 && filteredStudents.every(s => selected.includes(s.student_id));
  const someSelected = filteredStudents.some(s => selected.includes(s.student_id));

  const handleSelectAll = (e) => {
    if (e.target.checked) {
      setSelected(filteredStudents.map(s => s.student_id));
    } else {
      setSelected(selected.filter(id => !filteredStudents.map(s => s.student_id).includes(id)));
    }
  };

  const handleSelectOne = (student_id) => {
    setSelected(prev => prev.includes(student_id) ? prev.filter(id => id !== student_id) : [...prev, student_id]);
  };

  useEffect(() => {
    const fetchStudents = async () => {
      setLoading(true);
      setError(null);
      try {
        const response = await fetch('http://localhost:3000/api/students');
        if (!response.ok) throw new Error('Failed to fetch students');
        const data = await response.json();
        setStudents(data);
      } catch (err) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    };
    fetchStudents();
  }, []);

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
            <button
  className="bg-custom-green hover:bg-green-600 text-white px-6 py-2 rounded text-sm font-medium focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-custom-green transition-colors"
  onClick={handleBulkCreateUsers}
  disabled={selected.length === 0}
>
  Create Student
</button>
          </div>

          <div className="border border-gray-200 rounded overflow-hidden">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th scope="col" className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider border-b border-gray-200">
                  <input
                      type="checkbox"
                      className="h-4 w-4 text-custom-green rounded border-gray-300"
                      checked={allSelected}
                      ref={el => { if (el) el.indeterminate = !allSelected && someSelected; }}
                      onChange={handleSelectAll}
                    />
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
                    Email
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {loading ? (
                  <tr><td colSpan="5" className="text-center py-4">Loading...</td></tr>
                ) : error ? (
                  <tr><td colSpan="5" className="text-center text-red-500 py-4">{error}</td></tr>
                ) : filteredStudents.length === 0 ? (
                  <tr><td colSpan="5" className="text-center py-4">No students found.</td></tr>
                ) : (
                  filteredStudents.map((student) => (
                    <tr key={student.student_id}>
                      <td className="px-4 py-3 whitespace-nowrap text-sm text-gray-500 border-b border-gray-200">
                        <input
                          type="checkbox"
                          className="h-4 w-4 text-custom-green rounded border-gray-300"
                          checked={selected.includes(student.student_id)}
                          onChange={() => handleSelectOne(student.student_id)}
                        />
                      </td>
                      <td className="px-4 py-3 whitespace-nowrap text-sm font-medium text-gray-900 border-b border-gray-200">
                        {student.student_id}
                      </td>
                      <td className="px-4 py-3 whitespace-nowrap text-sm text-gray-500 border-b border-gray-200">
                        {student.first_name + ' ' + student.last_name}
                      </td>
                      <td className="px-4 py-3 whitespace-nowrap text-sm text-gray-500 border-b border-gray-200">
                        {student.enrollment_date ? new Date(student.enrollment_date).getFullYear() : ''}
                      </td>
                      <td className="px-4 py-3 whitespace-nowrap text-sm text-gray-500 border-b border-gray-200">
                        {student.email}
                      </td>
                    </tr>
                  ))
                )}
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