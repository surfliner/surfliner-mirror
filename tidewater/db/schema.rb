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

ActiveRecord::Schema[7.0].define(version: 2022_02_02_233451) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "oai_items", force: :cascade do |t|
    t.text "title"
    t.text "creator"
    t.text "description"
    t.text "publisher"
    t.text "contributor"
    t.text "date"
    t.text "type"
    t.text "format"
    t.text "identifier"
    t.text "source"
    t.text "subject"
    t.text "language"
    t.text "relation"
    t.text "coverage"
    t.text "rights"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "source_iri", null: false
    t.index ["source_iri"], name: "index_oai_items_on_source_iri"
  end

end
