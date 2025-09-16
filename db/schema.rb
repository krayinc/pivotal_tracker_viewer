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

ActiveRecord::Schema[8.0].define(version: 2025_09_16_131907) do
  create_table "epics", force: :cascade do |t|
    t.bigint "tracker_id", null: false
    t.string "name", null: false
    t.string "label"
    t.string "state"
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tracker_id"], name: "index_epics_on_tracker_id", unique: true
  end

  create_table "stories", force: :cascade do |t|
    t.bigint "tracker_id", null: false
    t.integer "epic_id"
    t.string "title", null: false
    t.string "story_type"
    t.integer "estimate"
    t.string "priority"
    t.string "current_state"
    t.string "requested_by"
    t.datetime "story_created_at"
    t.datetime "story_updated_at"
    t.datetime "accepted_at"
    t.integer "import_position", default: 0, null: false
    t.text "description"
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["current_state"], name: "index_stories_on_current_state"
    t.index ["epic_id"], name: "index_stories_on_epic_id"
    t.index ["import_position"], name: "index_stories_on_import_position"
    t.index ["priority"], name: "index_stories_on_priority"
    t.index ["requested_by"], name: "index_stories_on_requested_by"
    t.index ["story_type"], name: "index_stories_on_story_type"
    t.index ["tracker_id"], name: "index_stories_on_tracker_id", unique: true
  end

  create_table "story_blockers", force: :cascade do |t|
    t.integer "story_id", null: false
    t.text "description", null: false
    t.string "status"
    t.datetime "reported_at"
    t.datetime "resolved_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_story_blockers_on_status"
    t.index ["story_id"], name: "index_story_blockers_on_story_id"
  end

  create_table "story_branches", force: :cascade do |t|
    t.integer "story_id", null: false
    t.string "name", null: false
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["story_id", "name"], name: "index_story_branches_on_story_id_and_name", unique: true
    t.index ["story_id"], name: "index_story_branches_on_story_id"
  end

  create_table "story_comments", force: :cascade do |t|
    t.integer "story_id", null: false
    t.string "author_name"
    t.text "body", null: false
    t.datetime "commented_at"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["story_id", "position"], name: "index_story_comments_on_story_id_and_position"
    t.index ["story_id"], name: "index_story_comments_on_story_id"
  end

  create_table "story_labels", force: :cascade do |t|
    t.integer "story_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["story_id", "name"], name: "index_story_labels_on_story_id_and_name", unique: true
    t.index ["story_id"], name: "index_story_labels_on_story_id"
  end

  create_table "story_ownerships", force: :cascade do |t|
    t.integer "story_id", null: false
    t.string "owner_name", null: false
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["story_id", "position"], name: "index_story_ownerships_on_story_id_and_position"
    t.index ["story_id"], name: "index_story_ownerships_on_story_id"
  end

  create_table "story_pull_requests", force: :cascade do |t|
    t.integer "story_id", null: false
    t.string "title"
    t.string "url", null: false
    t.string "status"
    t.datetime "submitted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["story_id"], name: "index_story_pull_requests_on_story_id"
    t.index ["url"], name: "index_story_pull_requests_on_url"
  end

  create_table "story_tasks", force: :cascade do |t|
    t.integer "story_id", null: false
    t.text "description", null: false
    t.string "status"
    t.integer "position"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["story_id", "position"], name: "index_story_tasks_on_story_id_and_position"
    t.index ["story_id"], name: "index_story_tasks_on_story_id"
  end

  add_foreign_key "stories", "epics"
  add_foreign_key "story_blockers", "stories"
  add_foreign_key "story_branches", "stories"
  add_foreign_key "story_comments", "stories"
  add_foreign_key "story_labels", "stories"
  add_foreign_key "story_ownerships", "stories"
  add_foreign_key "story_pull_requests", "stories"
  add_foreign_key "story_tasks", "stories"
end
