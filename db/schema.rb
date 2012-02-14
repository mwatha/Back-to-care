# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120211154331) do

  create_table "report_types", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reports", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sms", :force => true do |t|
    t.integer  "sms_type_id"
    t.integer  "person_id"
    t.integer  "provider_id"
    t.text     "message"
    t.integer  "number"
    t.boolean  "delivered",    :default => false
    t.datetime "date_created", :default => '2012-02-14 12:51:17'
    t.boolean  "voided",       :default => false
    t.integer  "voided_by"
    t.datetime "date_voided"
  end

  create_table "sms_type", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "date_created",     :default => '2012-02-14 12:51:17'
    t.boolean  "retired",          :default => false
    t.datetime "retired_datetime"
    t.string   "retired_reason"
  end

end
