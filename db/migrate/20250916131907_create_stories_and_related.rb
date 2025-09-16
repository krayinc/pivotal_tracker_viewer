class CreateStoriesAndRelated < ActiveRecord::Migration[8.0]
  def change
    create_table :epics do |t|
      t.bigint :tracker_id, null: false
      t.string :name, null: false
      t.string :label
      t.string :state
      t.string :url

      t.timestamps
    end

    add_index :epics, :tracker_id, unique: true

    create_table :stories do |t|
      t.bigint :tracker_id, null: false
      t.references :epic, foreign_key: true
      t.string :title, null: false
      t.string :story_type
      t.integer :estimate
      t.string :priority
      t.string :current_state
      t.string :requested_by
      t.datetime :story_created_at
      t.datetime :story_updated_at
      t.datetime :accepted_at
      t.integer :import_position, null: false, default: 0
      t.text :description
      t.string :url

      t.timestamps
    end

    add_index :stories, :tracker_id, unique: true
    add_index :stories, :story_type
    add_index :stories, :current_state
    add_index :stories, :priority
    add_index :stories, :requested_by
    add_index :stories, :import_position

    create_table :story_ownerships do |t|
      t.references :story, null: false, foreign_key: true
      t.string :owner_name, null: false
      t.integer :position

      t.timestamps
    end

    add_index :story_ownerships, [:story_id, :position]

    create_table :story_labels do |t|
      t.references :story, null: false, foreign_key: true
      t.string :name, null: false

      t.timestamps
    end

    add_index :story_labels, [:story_id, :name], unique: true

    create_table :story_comments do |t|
      t.references :story, null: false, foreign_key: true
      t.string :author_name
      t.text :body, null: false
      t.datetime :commented_at
      t.integer :position

      t.timestamps
    end

    add_index :story_comments, [:story_id, :position]

    create_table :story_tasks do |t|
      t.references :story, null: false, foreign_key: true
      t.text :description, null: false
      t.string :status
      t.integer :position
      t.datetime :completed_at

      t.timestamps
    end

    add_index :story_tasks, [:story_id, :position]

    create_table :story_blockers do |t|
      t.references :story, null: false, foreign_key: true
      t.text :description, null: false
      t.string :status
      t.datetime :reported_at
      t.datetime :resolved_at

      t.timestamps
    end

    add_index :story_blockers, :status

    create_table :story_pull_requests do |t|
      t.references :story, null: false, foreign_key: true
      t.string :title
      t.string :url, null: false
      t.string :status
      t.datetime :submitted_at

      t.timestamps
    end

    add_index :story_pull_requests, :url

    create_table :story_branches do |t|
      t.references :story, null: false, foreign_key: true
      t.string :name, null: false
      t.string :url

      t.timestamps
    end

    add_index :story_branches, [:story_id, :name], unique: true
  end
end
