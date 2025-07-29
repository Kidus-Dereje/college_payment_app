# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_07_28_214204) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "bank_accounts", force: :cascade do |t|
    t.bigint "service_id", null: false
    t.string "bank_name", null: false
    t.string "account_number", null: false
    t.string "account_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_number"], name: "index_bank_accounts_on_account_number", unique: true
    t.index ["service_id"], name: "index_bank_accounts_on_service_id"
  end

  create_table "course_departments", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.bigint "department_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_course_departments_on_course_id"
    t.index ["department_id"], name: "index_course_departments_on_department_id"
  end

  create_table "courses", force: :cascade do |t|
    t.string "course_id"
    t.string "course_name"
    t.integer "credits"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_courses_on_course_id", unique: true
  end

  create_table "departments", force: :cascade do |t|
    t.string "department_id"
    t.string "department_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["department_id"], name: "index_departments_on_department_id", unique: true
  end

  create_table "semesters", force: :cascade do |t|
    t.string "name"
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_semesters_on_name", unique: true
  end

  create_table "services", force: :cascade do |t|
    t.string "service_name"
    t.boolean "is_active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["service_name"], name: "index_services_on_service_name", unique: true
  end

  create_table "student_courses", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.bigint "course_id", null: false
    t.bigint "semester_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_student_courses_on_course_id"
    t.index ["semester_id"], name: "index_student_courses_on_semester_id"
    t.index ["student_id"], name: "index_student_courses_on_student_id"
  end

  create_table "students", force: :cascade do |t|
    t.string "student_id"
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.date "enrollment_date"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_students_on_email", unique: true
    t.index ["student_id"], name: "index_students_on_student_id", unique: true
    t.index ["user_id"], name: "index_students_on_user_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "service_id", null: false
    t.bigint "wallet_transaction_id"
    t.bigint "bank_account_id"
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.integer "status", null: false
    t.string "reference_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bank_account_id"], name: "index_transactions_on_bank_account_id"
    t.index ["reference_id"], name: "index_transactions_on_reference_id", unique: true
    t.index ["service_id"], name: "index_transactions_on_service_id"
    t.index ["status"], name: "index_transactions_on_status"
    t.index ["user_id"], name: "index_transactions_on_user_id"
    t.index ["wallet_transaction_id"], name: "index_transactions_on_wallet_transaction_id"
  end

  create_table "tuition_fees", force: :cascade do |t|
    t.decimal "amount_per_credit", precision: 8, scale: 2
    t.date "enrollment_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.integer "role", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "wallet_transactions", force: :cascade do |t|
    t.bigint "wallet_id", null: false
    t.bigint "bank_account_id"
    t.integer "transaction_type", default: 0, null: false
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.integer "direction", default: 0, null: false
    t.string "reference_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bank_account_id"], name: "index_wallet_transactions_on_bank_account_id"
    t.index ["direction"], name: "index_wallet_transactions_on_direction"
    t.index ["reference_id"], name: "index_wallet_transactions_on_reference_id", unique: true
    t.index ["transaction_type"], name: "index_wallet_transactions_on_transaction_type"
    t.index ["wallet_id"], name: "index_wallet_transactions_on_wallet_id"
  end

  create_table "wallets", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.decimal "balance", precision: 12, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_wallets_on_user_id"
  end

  add_foreign_key "bank_accounts", "services"
  add_foreign_key "course_departments", "courses"
  add_foreign_key "course_departments", "departments"
  add_foreign_key "student_courses", "courses"
  add_foreign_key "student_courses", "semesters"
  add_foreign_key "student_courses", "students"
  add_foreign_key "students", "users"
  add_foreign_key "transactions", "bank_accounts"
  add_foreign_key "transactions", "services"
  add_foreign_key "transactions", "users"
  add_foreign_key "transactions", "wallet_transactions"
  add_foreign_key "wallet_transactions", "bank_accounts"
  add_foreign_key "wallet_transactions", "wallets"
  add_foreign_key "wallets", "users"
end
