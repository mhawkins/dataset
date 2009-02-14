module Dataset
  module Record # :nodoc:
    
    # A mechanism to cache information about an ActiveRecord class to speed
    # things up a bit for insertions, finds, and method generation.
    class Meta # :nodoc:
      attr_reader :class_name, :columns, :record_class, :table_name
      
      # Provides information necessary to insert STI classes correctly for
      # later reading.
      delegate :name, :inheritance_column, :sti_name, :to => :record_class
      
      def initialize(record_class)
        @record_class     = record_class
        @class_name       = record_class.name
        @table_name       = record_class.table_name
        @columns          = record_class.columns
      end
      
      def id_cache_key
        @id_cache_key ||= table_name
      end
      
      def inheriting_record?
        !record_class.descends_from_active_record?
      end
      
      def timestamp_columns
        @timestamp_columns ||= begin
          timestamps = %w(created_at created_on updated_at updated_on)
          columns.select do |column|
            timestamps.include?(column.name)
          end
        end
      end
      
      def id_finder_names
        @id_finder_names ||= begin
          names = [class_name.underscore]
          names << ActiveRecord::Base.pluralize_table_names ? table_name.singularize : table_name
          names.uniq.collect {|n| "#{n}_id".to_sym}
        end
      end
      
      def model_finder_names
        @record_finder_names ||= [table_name.to_sym, class_name.underscore.pluralize.to_sym].uniq
      end
      
      def to_s
        "#<RecordMeta: #{table_name}>"
      end
    end
    
  end
end