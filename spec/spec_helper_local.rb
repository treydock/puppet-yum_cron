# frozen_string_literal: true

dir = __dir__
Dir["#{dir}/shared_examples/*.rb"].sort.each { |f| require f }
