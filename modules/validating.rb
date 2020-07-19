# frozen_string_literal: true

module Validating
  def valid_name?(name = '')
    name.length.between?(4, 20) && name[/^[a-zа-яё]+$/i]
  end
end
