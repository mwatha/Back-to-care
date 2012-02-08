namespace :btc do

  def setup_data
    raise "You must specify the RAILS_ENV variable for the database environment you want to use" unless ENV["RAILS_ENV"] 
    require File.join(RAILS_ROOT, 'config', 'environment')
    require 'active_record/fixtures'    
    ActiveRecord::Base.establish_connection(RAILS_ENV.to_sym)
    ActiveRecord::Base.connection.execute("SET FOREIGN_KEY_CHECKS=0")    
  end  

  namespace :bootstrap do
    namespace :load do
      desc "Load a set of Back to care fixtures into the current database"
      task :defaults do
        setup_data
        Dir.glob(File.join(RAILS_ROOT, 'db', 'data', 'defaults', '*.yml')).each do |fixture_file|
          puts 'Loading fixture: ' + fixture_file 
          Fixtures.create_fixtures("db/data/defaults", File.basename(fixture_file, '.*'))
        end
      end
    
    end
  end  
end
