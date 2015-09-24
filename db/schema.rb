# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150924040944) do

  create_table "steps", force: :cascade do |t|
    t.string   "title"
    t.datetime "due"
    t.boolean  "completed",  default: false
    t.integer  "task_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "steps", ["task_id"], name: "index_steps_on_task_id"

  create_table "tasks", force: :cascade do |t|
    t.string   "title"
    t.datetime "due"
    t.boolean  "completed",  default: false
    t.boolean  "archived",   default: false
    t.datetime "schedule"
    t.integer  "user_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "tasks", ["user_id"], name: "index_tasks_on_user_id"

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "provider"
    t.string   "uid"
    t.string   "api_key"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "access_token"
    t.datetime "expires_at"
    t.string   "refresh_token"
  end

end
