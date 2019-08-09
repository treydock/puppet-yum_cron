dir = File.expand_path(File.dirname(__FILE__))
Dir["#{dir}/shared_examples/*.rb"].sort.each { |f| require f }
