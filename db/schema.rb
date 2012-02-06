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

ActiveRecord::Schema.define(:version => 20120131092731) do

  create_table "sms", :force => true do |t|
    t.integer  "sms_type_id"
    t.integer  "person_id"
    t.integer  "provider_id"
    t.text     "message"
    t.integer  "number"
    t.datetime "date_created"
    t.boolean  "voided"
    t.integer  "voided_by"
    t.datetime "date_voided"
  end

  create_table "sms_type", :force => true do |t|
    t.integer  "name"
    t.text     "description"
    t.datetime "date_created"
    t.boolean  "retired"
    t.datetime "retired_datetime"
    t.text     "retired_reason"
  end

end
