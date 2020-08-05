# frozen_string_literal: true

require 'table_print'
require 'codebreaker_os'
require 'i18n'
require 'pry'

# require_relative 'modules/input'
require_relative 'modules/output'
require_relative 'classes/console'

I18n.load_path << Dir[File.expand_path('config/locales') + '/*.yml']
