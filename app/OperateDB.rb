
class OperateDB
  attr_accessor :all_data

  def initialize(dbclass,table_name)
    dbclass.establish_connection(ENV['DATABASE_URL'])
    @con = dbclass.connection
    @query_a = 'select * from '+table_name
    @all_data = @con.select_all(@query_a).to_hash
    @all_data = format_results(symbolize_keys(@all_data))
  end

  def symbolize_keys(hash_a)
    hash_a.map{|hash|hash.map{|k,v|[k.to_sym,v]}.to_h}
  end

  def get_all_data
    @all_data = @con.select_all(@query_a).to_hash
    @all_data = format_results(symbolize_keys(@all_data))
  end

  def reflesh_data(dbclass,data)
    dbclass.delete_all
    dbclass.create(data)
  end
end