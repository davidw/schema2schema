require 'pp'

class SchemaDefinition
  def initialize
    @tables = []
  end

  def create_table(name, info)
    td = TableDefinition.new
    yield(td)
    @tables << [name, td.fields]
  end

  def enable_extension(*args)
  end

  def tables
    @tables
  end
end

class TableDefinition

  def initialize()
    @fields = {}
  end

  [:bigint, :hstore, :json, :integer, :string, :float, :date,
   :decimal, :datetime, :boolean, :text, :serial].each do |m|
    define_method(m) do |name, *options|
      @fields[name] = [m, options]
    end
  end

  def index(*args)
    # FIXME
  end

  def fields
    @fields.to_a.sort
  end

  def print_fields
    puts fields.inspect
  end
end

class ActiveRecord
  class Schema
    def self.define(info, &block)
      sd = SchemaDefinition.new
      sd.instance_eval &block
      return sd.tables
    end
  end
end

def get_keys(array)
  array.map { |a| a[0] }
end

def table_diff(schema1, schema2)
  only_in1 = get_keys(schema1) - get_keys(schema2)
  only_in2 = get_keys(schema2) - get_keys(schema1)
  [only_in1, only_in2]
end

def by_key(key, array)
  array.select do |a|
    a[0] == key
  end[0]
end

schema_file1 = ARGV[0]
schema_file2 = ARGV[1]

schema1 = eval(File.open(schema_file1).read)
schema2 = eval(File.open(schema_file2).read)

only_in1, only_in2 = table_diff(schema1, schema2)

puts "Only in #{schema_file1}: #{only_in1}"
puts "Only in #{schema_file2}: #{only_in2}"

dont_diff = only_in1 + only_in2

schema1.each do |table|
  next if dont_diff.member?(table[0])

  tablename = table[0]
  table2 = by_key(table[0], schema2)
  (table2[1] - table[1]).each do |c|
    colname = c[0]
    coltype = c[1][0]
    coloptions = c[1][1..-1].flatten[0]
    puts "add_column " + [tablename.inspect, colname.inspect, coltype.inspect, coloptions].join(", ")
  end
end
