# frozen_string_literal: true

require 'simplecov'

SimpleCov.start do
  enable_coverage :branch
  add_filter 'spec/'
end

SimpleCov.minimum_coverage 95

require_relative '../load'
require_relative 'support/create_game'

RSpec.configure do |config|
  DIFFICULTY_LEVELS = { easy: :easy, medium: :medium, hell: :hell }.freeze

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end
