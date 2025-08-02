import { useState, useEffect } from "react";
import axios from "axios";

export default function BitsPayWallet() {
  const [balance, setBalance] = useState(null);
  // TODO: Replace with your actual user_id retrieval logic (e.g., from localStorage, context, or props)
  const userId = localStorage.getItem('user_id');

  useEffect(() => {
    if (userId) {
      axios.get(`http://localhost:3000/api/wallet/${userId}/balance`)
        .then(res => setBalance(res.data.balance))
        .catch(() => setBalance('Error'));
    }
  }, [userId]);
  const [activeSection, setActiveSection] = useState("Home")
  const [selectedMajor, setSelectedMajor] = useState("")
  const [selectedYear, setSelectedYear] = useState(1)
  const [showBalance, setShowBalance] = useState(false)
  const [depositAmount, setDepositAmount] = useState("")
  const [paymentAmount, setPaymentAmount] = useState("")
  const [paymentType, setPaymentType] = useState("full-tuition")
  const [showPaymentPopup, setShowPaymentPopup] = useState(false)
  const [paymentUrl, setPaymentUrl] = useState("")

  // Chapa configuration 
  const CHAPA_PUBLIC_KEY = "CHAPUBK_TEST-NeIrAl3Gw1751zvQf0FQ0yMnQAinVo7g"

  // Generate unique transaction reference
  const generateTxRef = (type) => {
    const timestamp = Date.now()
    const random = Math.random().toString(36).substring(2, 15)
    return `${type}-${timestamp}-${random}`
  }

  // Create and submit Chapa payment form
  const submitChapaPayment = (paymentData) => {
    const form = document.createElement("form")
    form.method = "POST"
    form.action = "https://api.chapa.co/v1/hosted/pay"
    form.style.display = "none"

    const fields = {
      public_key: CHAPA_PUBLIC_KEY,
      tx_ref: paymentData.tx_ref,
      amount: paymentData.amount,
      currency: "ETB",
      email: "user@bitspay.com",
      first_name: "BitsPay",
      last_name: "User",
      title: paymentData.title,
      description: paymentData.description,
      logo: "https://chapa.link/asset/images/chapa_swirl.svg",
      callback_url: `${window.location.origin}/payment-callback`,
      return_url: `${window.location.origin}/wallet`,
      "meta[title]": "BitsPay Transaction",
    }

    Object.entries(fields).forEach(([key, value]) => {
      const input = document.createElement("input")
      input.type = "hidden"
      input.name = key
      input.value = value
      form.appendChild(input)
    })

    // Show popup with iframe
    // setPaymentUrl("https://api.chapa.co/v1/hosted/pay")
    // setShowPaymentPopup(true)

    // Submit form to iframe
    document.body.appendChild(form)
    setTimeout(() => {
      form.target = "chapa-payment-frame"
      form.submit()
      document.body.removeChild(form)
    }, 100)
  }
  

  // Handle deposit button click
  const handleDeposit = async() => {
    if (!depositAmount || Number.parseFloat(depositAmount) <= 0) {
      alert("Please enter a valid deposit amount")
      return
    }
    try {
      const response = await axios.post("http://localhost:3000/api/v1/payments/topup",{
       amount: depositAmount
        });
      const { checkout_url} = response.data;
      
      if (checkout_url){
        window.location.href=checkout_url;
      }else{
        alert( "Failed to initiate payment");
      }
    } catch (error){
      console.error("Deposit error:" , error);
      const message = error.response?.data?.error ||"something went wrong. Please try again later";
      alert(message);
    }

    const paymentData = {
      tx_ref: generateTxRef("DEPOSIT"),
      amount: depositAmount,
      title: "BitsPay Wallet Deposit",
      description: `Deposit ${depositAmount} ETB to BitsPay wallet`,
    }

    submitChapaPayment(paymentData)
  }
  const[wallet, setWallet] = useState(null);

  useEffect(() => {
    const txRef = new URLSearchParams(window.location.search).get("tx_ref");
    if (txRef) {
      axios
      .post("http://localhost:3000/api/v1/payments/callback", { tx_ref: txRef })
      .then(()=>{

        axios.get("http://localhost:3000/app/models/wallet")
        .then((res)=>{
          setWallet(res.data);
        });
      })
      .catch((err)=>{
        console.error("Payment verification failed:",err);
      });
    }
      
  },[]);


  const handlePayment = async() => {
    if (!paymentAmount || Number.parseFloat(paymentAmount) <= 0) {
      alert("Please enter a valid payment amount")
      return
    }

    const selectedServiceId = serviceIdMapping[paymentType];
    try {
      const reponse = await fetch("http://localhost:3000/api/v1/payments", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          payment: {
            amount: paymentAmount,
            service_id: selectedServiceId,
          },
        }),
      });
      const data = await reponse.json();
      if (reponse.ok && data.checkout_url) {
        window.location.href = data.checkout_url;
        } else {
        alert(data.error || "Failed to initiate payment");
      }
    } catch (error) {
      console.error("Payment error:", error);
      alert("Something went wrong. Please try again .");

          
        

    };

    const paymentTypeLabels = {
      "full-tuition": "Full Tuition Payment",
      "tuition-60": "60% Tuition Payment", 
      "tuition-40": "40% Tuition Payment",
      cafeteria: "Cafeteria Services",
      juice: "Juice Services",
      "mini-market": "Mini Market Services",
    }

    const paymentData = {
      tx_ref: generateTxRef("PAYMENT"),
      amount: paymentAmount,
      title: paymentTypeLabels[paymentType],
      description: `Payment for ${paymentTypeLabels[paymentType]} - ${paymentAmount} ETB`,
    }

    submitChapaPayment(paymentData)
  }

  // Notifications section removed - only 4 navigation items
  const navigationItems = ["Home", "Courses", "Payments", "Transaction History"]

  const coursesData = {
    SWE: {
      1: {
        1: [
          { name: "Introduction to Programming", credits: 3, cost: "5,400" },
          { name: "Mathematics for Computing I", credits: 4, cost: "7,200" },
          { name: "Computer Systems Fundamentals", credits: 3, cost: "5,400" },
          { name: "English Communication", credits: 2, cost: "3,600" },
          { name: "Physics for Engineers", credits: 3, cost: "5,400" },
          { name: "Introduction to Software Engineering", credits: 3, cost: "5,400" },
        ],
        2: [
          { name: "Object-Oriented Programming", credits: 4, cost: "7,200" },
          { name: "Mathematics for Computing II", credits: 4, cost: "7,200" },
          { name: "Data Structures", credits: 3, cost: "5,400" },
          { name: "Digital Logic Design", credits: 3, cost: "5,400" },
          { name: "Technical Writing", credits: 2, cost: "3,600" },
          { name: "Ethics in Computing", credits: 2, cost: "3,600" },
        ],
      },
      2: {
        1: [
          { name: "Algorithms and Complexity", credits: 4, cost: "7,200" },
          { name: "Database Systems", credits: 3, cost: "5,400" },
          { name: "Computer Networks", credits: 3, cost: "5,400" },
          { name: "Software Design Patterns", credits: 3, cost: "5,400" },
          { name: "Statistics for Computing", credits: 3, cost: "5,400" },
          { name: "Web Development", credits: 3, cost: "5,400" },
        ],
        2: [
          { name: "Operating Systems", credits: 4, cost: "7,200" },
          { name: "Software Testing", credits: 3, cost: "5,400" },
          { name: "Human-Computer Interaction", credits: 3, cost: "5,400" },
          { name: "Mobile App Development", credits: 3, cost: "5,400" },
          { name: "Project Management", credits: 2, cost: "3,600" },
          { name: "Software Architecture", credits: 3, cost: "5,400" },
        ],
      },
      3: {
        1: [
          { name: "Advanced Algorithms", credits: 4, cost: "7,200" },
          { name: "Software Engineering Principles", credits: 3, cost: "5,400" },
          { name: "Machine Learning Fundamentals", credits: 3, cost: "5,400" },
          { name: "Distributed Systems", credits: 3, cost: "5,400" },
          { name: "Cybersecurity Basics", credits: 3, cost: "5,400" },
          { name: "Agile Development", credits: 2, cost: "3,600" },
        ],
        2: [
          { name: "Advanced Database Systems", credits: 3, cost: "5,400" },
          { name: "Cloud Computing", credits: 3, cost: "5,400" },
          { name: "Software Quality Assurance", credits: 3, cost: "5,400" },
          { name: "DevOps and CI/CD", credits: 3, cost: "5,400" },
          { name: "Research Methods", credits: 2, cost: "3,600" },
          { name: "Internship Preparation", credits: 2, cost: "3,600" },
        ],
      },
      4: {
        1: [
          { name: "Senior Project I", credits: 4, cost: "7,200" },
          { name: "Advanced Software Architecture", credits: 3, cost: "5,400" },
          { name: "Artificial Intelligence", credits: 3, cost: "5,400" },
          { name: "Software Entrepreneurship", credits: 2, cost: "3,600" },
          { name: "Advanced Web Technologies", credits: 3, cost: "5,400" },
          { name: "Professional Ethics", credits: 2, cost: "3,600" },
        ],
        2: [
          { name: "Senior Project II", credits: 4, cost: "7,200" },
          { name: "Industry Internship", credits: 6, cost: "10,800" },
          { name: "Emerging Technologies", credits: 3, cost: "5,400" },
          { name: "Software Maintenance", credits: 2, cost: "3,600" },
          { name: "Career Development", credits: 1, cost: "1,800" },
          { name: "Capstone Presentation", credits: 2, cost: "3,600" },
        ],
      },
    },
    ITS: {
      1: {
        1: [
          { name: "Introduction to IT", credits: 3, cost: "5,400" },
          { name: "Mathematics for IT I", credits: 4, cost: "7,200" },
          { name: "Computer Hardware Fundamentals", credits: 3, cost: "5,400" },
          { name: "English Communication", credits: 2, cost: "3,600" },
          { name: "Basic Programming", credits: 3, cost: "5,400" },
          { name: "Information Systems Concepts", credits: 3, cost: "5,400" },
        ],
        2: [
          { name: "Programming Fundamentals", credits: 4, cost: "7,200" },
          { name: "Mathematics for IT II", credits: 4, cost: "7,200" },
          { name: "Network Fundamentals", credits: 3, cost: "5,400" },
          { name: "Database Concepts", credits: 3, cost: "5,400" },
          { name: "Technical Communication", credits: 2, cost: "3,600" },
          { name: "IT Ethics and Law", credits: 2, cost: "3,600" },
        ],
      },
      2: {
        1: [
          { name: "System Analysis and Design", credits: 4, cost: "7,200" },
          { name: "Database Management Systems", credits: 3, cost: "5,400" },
          { name: "Network Administration", credits: 3, cost: "5,400" },
          { name: "Web Technologies", credits: 3, cost: "5,400" },
          { name: "Statistics for IT", credits: 3, cost: "5,400" },
          { name: "Business Information Systems", credits: 3, cost: "5,400" },
        ],
        2: [
          { name: "Enterprise Systems", credits: 4, cost: "7,200" },
          { name: "IT Security Fundamentals", credits: 3, cost: "5,400" },
          { name: "Data Analytics", credits: 3, cost: "5,400" },
          { name: "Mobile Computing", credits: 3, cost: "5,400" },
          { name: "IT Project Management", credits: 2, cost: "3,600" },
          { name: "Systems Integration", credits: 3, cost: "5,400" },
        ],
      },
      3: {
        1: [
          { name: "Advanced Database Systems", credits: 4, cost: "7,200" },
          { name: "IT Infrastructure Management", credits: 3, cost: "5,400" },
          { name: "Business Intelligence", credits: 3, cost: "5,400" },
          { name: "Cloud Technologies", credits: 3, cost: "5,400" },
          { name: "Cybersecurity Management", credits: 3, cost: "5,400" },
          { name: "IT Service Management", credits: 2, cost: "3,600" },
        ],
        2: [
          { name: "Enterprise Architecture", credits: 3, cost: "5,400" },
          { name: "Data Warehousing", credits: 3, cost: "5,400" },
          { name: "IT Governance", credits: 3, cost: "5,400" },
          { name: "Digital Transformation", credits: 3, cost: "5,400" },
          { name: "Research Methodology", credits: 2, cost: "3,600" },
          { name: "Industry Preparation", credits: 2, cost: "3,600" },
        ],
      },
      4: {
        1: [
          { name: "Senior Project I", credits: 4, cost: "7,200" },
          { name: "Advanced IT Strategy", credits: 3, cost: "5,400" },
          { name: "Emerging IT Trends", credits: 3, cost: "5,400" },
          { name: "IT Consulting", credits: 2, cost: "3,600" },
          { name: "Advanced Analytics", credits: 3, cost: "5,400" },
          { name: "Professional Development", credits: 2, cost: "3,600" },
        ],
        2: [
          { name: "Senior Project II", credits: 4, cost: "7,200" },
          { name: "Industry Internship", credits: 6, cost: "10,800" },
          { name: "IT Innovation", credits: 3, cost: "5,400" },
          { name: "Systems Maintenance", credits: 2, cost: "3,600" },
          { name: "Career Planning", credits: 1, cost: "1,800" },
          { name: "Final Presentation", credits: 2, cost: "3,600" },
        ],
      },
    },
  }

  const recentActivity = [
    { type: "Credit", description: "Chapa Deposit", amount: "12,000.00", icon: "💰" },
    { type: "Debit", description: "Tuition Payment", amount: "17,500.00", icon: "🛒" },
    { type: "Credit", description: "Chapa Deposit", amount: "20,000.00", icon: "💰" },
    { type: "Credit", description: "Chapa Deposit", amount: "300.00", icon: "💰" },
    { type: "Credit", description: "Chapa Deposit", amount: "100.00", icon: "💰" },
  ]

  const renderContent = () => {
    switch (activeSection) {
      case "Home":
        return (
          <div className="max-w-md mx-auto mt-8 space-y-6 px-4">
            <div className="text-center space-y-2">
              <h1 className="text-2xl font-bold text-gray-800">Account Balance</h1>
              <p className="text-gray-600">Your current balance across all accounts</p>
            </div>
            {/* Updated balance card with your green color and eye toggle */}
            <div className="bg-custom-green bg-opacity-30 border-0 relative rounded-lg p-6">
              <div className="flex justify-between items-start">
                <div>
                  <p className="text-gray-600 text-sm mb-2">Balance</p>
                  <p className="text-2xl font-bold text-gray-800 tracking-wider">
                    {showBalance ? (balance !== null ? `ETB ${Number(balance).toLocaleString(undefined, {minimumFractionDigits:2, maximumFractionDigits:2})}` : 'Loading...') : "ETB ****.**"}
                  </p>
                </div>
                <button
                  onClick={() => setShowBalance(!showBalance)}
                  className="w-8 h-8 bg-custom-green rounded-full flex items-center justify-center hover:bg-custom-green/80 transition-colors"
                >
                  <div className="w-4 h-4 bg-white rounded-full flex items-center justify-center">
                    {showBalance ? (
                     <svg className="w-2 h-2 text-custom-green" fill="currentColor" viewBox="0 0 20 20">
                        <path d="M10 12a2 2 0 100-4 2 2 0 000 4z" />
                        <path
                          fillRule="evenodd"
                          d="M.458 10C1.732 5.943 5.522 3 10 3s8.268 2.943 9.542 7c-1.274 4.057-5.064 7-9.542 7S1.732 14.057.458 10zM14 10a4 4 0 11-8 0 4 4 0 018 0z"
                          clipRule="evenodd"
                        />
                      </svg>
                    ) : (
                      <svg className="w-2 h-2 text-custom-green" fill="currentColor" viewBox="0 0 20 20">
                        <path
                          fillRule="evenodd"
                          d="M3.707 2.293a1 1 0 00-1.414 1.414l14 14a1 1 0 001.414-1.414l-1.473-1.473A10.014 10.014 0 0019.542 10C18.268 5.943 14.478 3 10 3a9.958 9.958 0 00-4.512 1.074l-1.78-1.781zm4.261 4.26l1.514 1.515a2.003 2.003 0 012.45 2.45l1.514 1.514a4 4 0 00-5.478-5.478z"
                          clipRule="evenodd"
                        />
                        <path d="M12.454 16.697L9.75 13.992a4 4 0 01-3.742-3.741L2.335 6.578A9.98 9.98 0 00.458 10c1.274 4.057 5.065 7 9.542 7 .847 0 1.669-.105 2.454-.303z" />
                      </svg>
                    )}
                  </div>
                </button>
              </div>
            </div>
            <div className="space-y-4">
              <h2 className="text-xl font-bold text-gray-800 text-center">Recent Activity</h2>
              <div className="space-y-2">
                {recentActivity.map((activity, index) => (
                  <div key={index} className="bg-gray-100 border-0 rounded-lg p-4">
                    <div className="flex items-center space-x-3">
                      <div className="w-10 h-10 bg-yellow-200 rounded-full flex items-center justify-center">
                        <span className="text-lg">{activity.icon}</span>
                      </div>
                      <div className="flex-1">
                        <p className="font-semibold text-gray-800">{activity.type}</p>
                        <p className="text-sm text-gray-600">{activity.description}</p>
                      </div>
                      <p className="font-semibold text-gray-800">{showBalance ? activity.amount : "****.**"}</p>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        )
      case "Courses":
        return (
          <div className="max-w-4xl mx-auto mt-8 space-y-6 px-4">
            <div className="bg-white border-0 shadow-lg rounded-lg p-6">
              <h1 className="text-2xl font-bold text-center text-gray-800 mb-6">Courses & Costs</h1>
              <div className="space-y-2 mb-6">
                <label className="text-sm font-medium text-gray-700">Select Major:</label>
                <select
                  value={selectedMajor}
                  onChange={(e) => setSelectedMajor(e.target.value)}
                  className="w-full border border-gray-300 rounded-md px-3 py-2 bg-white focus:outline-none focus:ring-2 focus:ring-custom-green focus:border-transparent"
                >
                  <option value="">Choose your major</option>
                  <option value="SWE">Software Engineering (SWE)</option>
                  <option value="ITS">Information Technology Systems (ITS)</option>
                </select>
              </div>
              {selectedMajor && (
                <div className="space-y-4">
                  <div className="flex justify-center space-x-2 flex-wrap gap-2">
                    {[1, 2, 3, 4].map((year) => (
                      <button
                        key={year}
                        onClick={() => setSelectedYear(year)}
                        className={`px-4 py-2 rounded-md font-medium transition-colors ${
                          selectedYear === year
                            ? "bg-custom-green text-white"
                            : "bg-white border border-gray-300 text-gray-700 hover:bg-gray-50"
                        }`}
                      >
                        {year}
                        {year === 1 ? "st" : year === 2 ? "nd" : year === 3 ? "rd" : "th"} Year
                      </button>
                    ))}
                  </div>
                  <div className="grid md:grid-cols-2 gap-6">
                    <div className="space-y-3">
                      <h3 className="text-lg font-semibold text-center text-gray-800 bg-gray-100 py-2 rounded">
                        Semester 1
                      </h3>
                      <div className="space-y-2">
                        {coursesData[selectedMajor][selectedYear][1].map((course, index) => (
                          <div key={index} className="flex justify-between items-center p-3 bg-gray-50 rounded border">
                            <div>
                              <p className="font-medium text-gray-800">{course.name}</p>
                              <p className="text-sm text-gray-600">{course.credits} Credit Hours</p>
                            </div>
                            <p className="font-semibold text-gray-800">{course.cost} ETB</p>
                          </div>
                        ))}
                      </div>
                      <div className="text-right font-bold text-gray-800 border-t pt-2">
                        Total:{" "}
                        {coursesData[selectedMajor][selectedYear][1]
                          .reduce((sum, course) => sum + Number.parseInt(course.cost.replace(",", "")), 0)
                          .toLocaleString()}{" "}
                        ETB
                      </div>
                    </div>
                    <div className="space-y-3">
                      <h3 className="text-lg font-semibold text-center text-gray-800 bg-gray-100 py-2 rounded">
                        Semester 2
                      </h3>
                      <div className="space-y-2">
                        {coursesData[selectedMajor][selectedYear][2].map((course, index) => (
                          <div key={index} className="flex justify-between items-center p-3 bg-gray-50 rounded border">
                            <div>
                              <p className="font-medium text-gray-800">{course.name}</p>
                              <p className="text-sm text-gray-600">{course.credits} Credit Hours</p>
                            </div>
                            <p className="font-semibold text-gray-800">{course.cost} ETB</p>
                          </div>
                        ))}
                      </div>
                      <div className="text-right font-bold text-gray-800 border-t pt-2">
                        Total:{" "}
                        {coursesData[selectedMajor][selectedYear][2]
                          .reduce((sum, course) => sum + Number.parseInt(course.cost.replace(",", "")), 0)
                          .toLocaleString()}{" "}
                        ETB
                      </div>
                    </div>
                  </div>
                  <div className="text-center text-lg font-bold text-gray-800 bg-custom-green/10 p-4 rounded">
                    Year {selectedYear} Total:{" "}
                    {(
                      coursesData[selectedMajor][selectedYear][1].reduce(
                        (sum, course) => sum + Number.parseInt(course.cost.replace(",", "")),
                        0,
                      ) +
                      coursesData[selectedMajor][selectedYear][2].reduce(
                        (sum, course) => sum + Number.parseInt(course.cost.replace(",", "")),
                        0,
                      )
                    ).toLocaleString()}{" "}
                    ETB
                  </div>
                </div>
              )}
            </div>
          </div>
        )
      case "Payments":
        return (
          <div className="max-w-md mx-auto mt-8 px-4">
            <div className="bg-white border-0 shadow-lg rounded-lg p-6">
              <h1 className="text-2xl font-bold text-center text-gray-800 mb-8">Payments</h1>
              <div className="space-y-8">
                <div className="space-y-4">
                  <h3 className="text-lg font-semibold text-center text-gray-800">Deposit</h3>
                  <input
                    type="number"
                    placeholder="Amount to deposit"
                    value={depositAmount}
                    onChange={(e) => setDepositAmount(e.target.value)}
                    className="w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-custom-green focus:border-transparent"
                  />
                  <button 
                    onClick={handleDeposit}
                    className="w-full bg-custom-green hover:bg-custom-green/90 text-white py-3 rounded-md font-medium transition-colors"
                  >
                    Deposit
                  </button>
                </div>
                <div className="space-y-4">
                  <h3 className="text-lg font-semibold text-center text-gray-800">Make Payment</h3>
                  <select
                    value={paymentType}
                    onChange={(e) => setPaymentType(e.target.value)}
                    className="w-full border border-gray-300 rounded-md px-3 py-2 bg-white focus:outline-none focus:ring-2 focus:ring-custom-green focus:border-transparent"
                  >
                    <option value="full-tuition">Full Tuition</option>
                    <option value="tuition-60">60% (tuition)</option>
                    <option value="tuition-40">40% (tuition)</option>
                    <option value="cafeteria">Cafeteria Services</option>
                    <option value="juice">Juice Services</option>
                    <option value="mini-market">Mini Market Services</option>
                  </select>
                  <input
                    type="number"
                    placeholder="Enter Amount"
                    value={paymentAmount}
                    onChange={(e) => setPaymentAmount(e.target.value)}
                    className="w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-custom-green focus:border-transparent"
                  />
                  <button 
                    onClick={handlePayment}
                    className="w-full bg-custom-green hover:bg-custom-green/90 text-white py-3 rounded-md font-medium transition-colors"
                  >
                    Pay
                  </button>
                </div>
              </div>
            </div>
          </div>
        )
        case "Transaction History":
          return (
            <div className="max-w-2xl mx-auto mt-8 px-4">
              <h1 className="text-3xl font-bold text-gray-800 mb-8 text-center">Transaction History</h1>
                      
              <div className="space-y-4">
                {/* Transaction 1 */}
                <div className="bg-white rounded-lg shadow-sm p-6">
                  <div className="flex items-center space-x-4">
                    <div className="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
                      <svg className="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path
                          strokeLinecap="round"
                          strokeLinejoin="round"
                          strokeWidth={2}
                          d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z"
                        />
                      </svg>
                    </div>
                    <div className="flex-1">
                      <div className="flex items-center space-x-3">
                        <span className="font-semibold text-gray-800">tuition</span>
                        <span className="font-bold text-lg">17,500.00ETB</span>
                      </div>
                      <div className="text-sm text-gray-600 mt-1">
                        <div>Year: 2025 Ref: TUIT-6870B3A755E28</div>
                        <div>Status: paid</div>
                      </div>
                    </div>
                  </div>
                </div>
                        
                {/* Transaction 2 */}
                <div className="bg-white rounded-lg shadow-sm p-6">
                  <div className="flex items-center space-x-4">
                    <div className="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
                      <svg className="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path
                          strokeLinecap="round"
                          strokeLinejoin="round"
                          strokeWidth={2}
                          d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z"
                        />
                      </svg>
                    </div>
                    <div className="flex-1">
                      <div className="flex items-center space-x-3">
                        <span className="font-semibold text-gray-800">tuition</span>
                        <span className="font-bold text-lg">100.00ETB</span>
                      </div>
                      <div className="text-sm text-gray-600 mt-1">
                        <div>Year: 2025 Ref: TUIT-686E6DE52A71E</div>
                        <div>Status: paid</div>
                      </div>
                    </div>
                  </div>
                </div>
                        
                {/* Transaction 3 */}
                <div className="bg-white rounded-lg shadow-sm p-6">
                  <div className="flex items-center space-x-4">
                    <div className="w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center">
                      <svg className="w-6 h-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path
                          strokeLinecap="round"
                          strokeLinejoin="round"
                          strokeWidth={2}
                          d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1"
                        />
                      </svg>
                    </div>
                    <div className="flex-1">
                      <div className="flex items-center space-x-3">
                        <span className="font-semibold text-gray-800">cafeteria</span>
                        <span className="font-bold text-lg">450.00ETB</span>
                      </div>
                      <div className="text-sm text-gray-600 mt-1">
                        <div>Year: 2025 Ref: CAFE-A8B2C3D4E5F6</div>
                        <div>Status: paid</div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          )
      default:
        return null
    }
  }

  // Payment popup component
  const PaymentPopup = () => {
    if (!showPaymentPopup) return null

    const handleClose = () => {
      setShowPaymentPopup(false)
      setPaymentUrl("")
    }

    // Listen for payment completion messages
    useEffect(() => {
      // Check if this is a return from Chapa payment
      const urlParams = new URLSearchParams(window.location.search)
      if (urlParams.get('status') === 'success' || urlParams.get('tx_ref')) {
        alert("Payment completed successfully!")
        // Clean up URL
        window.history.replaceState({}, document.title, window.location.pathname)
      }
    }, [])

    return (
      <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
        <div className="bg-white rounded-lg w-11/12 h-5/6 max-w-4xl relative">
          <div className="flex justify-between items-center p-4 border-b">
            <h3 className="text-lg font-semibold">Complete Payment</h3>
            <button
              onClick={handleClose}
              className="w-8 h-8 bg-gray-200 hover:bg-gray-300 rounded-full flex items-center justify-center transition-colors"
            >
              <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>
          <iframe
            name="chapa-payment-frame"
            src="about:blank"
            className="w-full h-full border-0 rounded-b-lg"
            title="Chapa Payment"
          />
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-gradient-to-r from-white to-green-50 shadow-lg border-b-2 border-[#7EC143]/20">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <div className="flex items-center">
              <h1 className="text-2xl font-bold">
              <span className="text-custom-green">Bits</span>
                <span className="text-black">Pay</span>
              </h1>
            </div>
            <nav className="flex items-center space-x-1">
              {navigationItems.map((item) => (
                <button
                  key={item}
                  onClick={() => setActiveSection(item)}
                  className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                    activeSection === item
                      ? "bg-custom-green/20 text-gray-800"
                      : "text-gray-600 hover:text-gray-800 hover:bg-gray-100"
                  }`}
                >
                  {item}
                </button>
              ))}
              <button
                className="ml-4 bg-custom-green hover:bg-custom-green/90 text-white px-6 py-2 rounded-lg font-medium transition-colors"
                onClick={() => alert("Logout clicked")}
              >
                Logout
              </button>
            </nav>
          </div>
        </div>
      </header>
      <main className="py-8">{renderContent()}</main>
      <PaymentPopup />
    </div>
  )
}