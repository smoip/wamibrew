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

ActiveRecord::Schema.define(version: 20140914211859) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "hops", force: true do |t|
    t.string   "name"
    t.float    "alpha"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "malts", force: true do |t|
    t.string   "name"
    t.float    "potential"
    t.float    "malt_yield"
    t.float    "srm"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "base_malt?", default: false
  end

  create_table "recipes", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "styles", force: true do |t|
    t.string   "name"
    t.string   "yeast_family"
    t.boolean  "aroma_required?"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.hstore   "calc_attributes"
    t.hstore   "ingredients"
    t.string   "required_malts",  array: true
    t.string   "required_hops",   array: true
    t.string   "common_malts",    array: true
    t.string   "common_hops",     array: true
    t.float    "abv_upper"
    t.float    "abv_lower"
    t.float    "ibu_upper"
    t.float    "ibu_lower"
    t.float    "srm_upper"
    t.float    "srm_lower"
  end

  create_table "yeasts", force: true do |t|
    t.string   "name"
    t.integer  "attenuation"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "family",      default: "ale"
  end

end
