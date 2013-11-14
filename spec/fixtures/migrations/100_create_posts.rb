class CreatePosts < CassandraMigrations::Migration
  
  def up
    create_table :posts do |p|
      p.integer :id, :primary_key => true
      p.timestamp :created_at
      p.string :title
      p.text :text
    end
  end

  def down
    drop_table :posts
  end
  
end