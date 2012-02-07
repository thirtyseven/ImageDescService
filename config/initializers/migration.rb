module ActiveRecord
  module ConnectionAdapters
    class AbstractAdapter
      #
      # main_table: name of the table to add the FK to
      # fk_name: name of the foreign key
      # main_field: name of the field which points to the foreign key
      # fk_table: name of the table which contains the foreign key
      # fk_field: name of the field which has the foreign key
      def add_constraint main_table, fk_name, main_field, fk_table, fk_field, options={}
        main_field = main_field.join(', ') if main_field.is_a?(Array)
        fk_field = fk_field.join(', ') if fk_field.is_a?(Array)
        execute "alter table #{main_table} add constraint #{fk_name} foreign key (#{main_field}) references #{fk_table}(#{fk_field})" unless adapter_name =~ /SQLite/i || Rails.env.test?
      end
      
      # main_table: name of table you want to remove the FK from
      # fk_name: name of FK you want to remove
      def remove_constraint main_table, fk_name, options={}
        execute "alter table #{main_table} DROP FOREIGN KEY #{fk_name}" unless adapter_name =~ /SQLite/i || Rails.env.test?
      end
      
    end
  end
end