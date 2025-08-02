"use client"

import { useState } from "react"
import axios from "axios"
import { useNavigate } from "react-router-dom"

export default function Login() {
  const [email, setEmail] = useState("")
  const [password, setPassword] = useState("")
  const [error, setError] = useState("")
  const navigate = useNavigate()

  const handleSubmit = async (e) => {
    e.preventDefault()
    setError("")

    try {
      const response = await axios.post("http://localhost:3000/api/login", {
        email,
        password,
      })

      const { role, user_id, token } = response.data

      // Store both user_id and auth token
      if (user_id) localStorage.setItem("user_id", user_id)
      if (token) localStorage.setItem("authToken", token)

      console.log("Login successful, role:", role) // Debug log

      if (role === "admin") {
        console.log("Navigating to admin...") // Debug log
        navigate("/admin")
      } else if (role === "student") {
        navigate("/wallet")
      } else {
        setError("Unknown user role.")
      }
    } catch (err) {
      console.log("Login error:", err)
      if (err.response && err.response.data && err.response.data.error) {
        setError(err.response.data.error)
      } else {
        setError("An unexpected error occurred.")
      }
    }
  }

  return (
    <div className="min-h-screen bg-green-50 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
      {/* Header with Logo - Centered at top */}
      <div className="sm:mx-auto sm:w-full sm:max-w-md">
        <div className="flex justify-center">
          <span className="text-3xl font-bold">
            <span className="text-custom-green">Bits</span>
            <span className="text-gray-800">Pay</span>
          </span>
        </div>
      </div>

      {/* Main Content */}
      <div className="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
        <div className="bg-white py-8 px-6 shadow rounded-lg sm:px-10">
          {/* Title */}
          <div className="text-center mb-8">
            <h1 className="text-2xl font-semibold text-gray-700">Get started with BITS-PAY</h1>
          </div>

          {/* Login Form */}
          <form className="space-y-6" onSubmit={handleSubmit}>
            <div className="space-y-4">
              <div>
                <input
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="Email"
                  className="w-full px-4 py-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent"
                  required
                />
              </div>
              <div>
                <input
                  type="password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="Password"
                  className="w-full px-4 py-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent"
                  required
                />
              </div>
            </div>

            {error && <div className="text-red-600 text-center text-sm">{error}</div>}

            <div>
              <button
                type="submit"
                className="w-full flex justify-center py-3 px-4 border border-transparent rounded-md shadow-sm text-lg font-medium text-white bg-custom-green hover:bg-green-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-custom-green transition-colors"
              >
                Login
              </button>
            </div>
          </form>

          {/* Footer Text */}
          <div className="mt-6 text-center text-sm text-gray-500">
            By continuing, you agree to our{" "}
            <a href="/terms" className="font-medium text-gray-600 hover:text-green-500">
              Terms of Service
            </a>{" "}
            and{" "}
            <a href="/privacy" className="font-medium text-gray-600 hover:text-green-500">
              Privacy Policy
            </a>
          </div>
        </div>
      </div>
    </div>
  )
}