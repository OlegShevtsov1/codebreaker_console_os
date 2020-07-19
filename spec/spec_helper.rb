# frozen_string_literal: true

require 'simplecov'
puts 'required simplecov'
SimpleCov.start do
  minimum_coverage 0
  enable_coverage :branch
  add_filter 'spec/'
end

require_relative '../load.rb'
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.shared_context_metadata_behavior = :apply_to_host_groups
end
