class AddForeignKeyConstraints < ActiveRecord::Migration
  def self.up
    add_constraint 'books', 'books_library_id', 'library_id', 'libraries', 'id'
    add_constraint 'book_stats', 'book_stats_book_id', 'book_id', 'books', 'id'
    add_constraint 'user_libraries', 'user_libraries_library_id', 'library_id', 'libraries', 'id'
    add_constraint 'user_libraries', 'user_libraries_user_id', 'user_id', 'users', 'id'
    add_constraint 'user_roles', 'user_roles_role_id', 'role_id', 'roles', 'id'
    add_constraint 'user_roles', 'user_roles_user_id', 'user_id', 'users', 'id'
    add_constraint 'user_subject_expertises', 'user_subject_expertises_user_id', 'user_id', 'users', 'id'
    add_constraint 'user_subject_expertises', 'user_subject_expertises_subject_expertise_id', 'subject_expertise_id', 'subject_expertises', 'id'
    #description dynamic_description dynamic_images constraints
  end

  def self.down
  end
end
