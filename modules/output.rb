# frozen_string_literal: true

module View
  include CommandLineReporter

  def template(result)
    tpl = { '+' => RESULT_PLUS, '-' => RESULT_MINUS }
    result.chars.map { |char| tpl.key?(char) ? tpl[char] : char }.join
  end

  def rules
    message(:Rules)
  end

  def stats(sorted_stats = Statistic.sort_stats)
    table(border: true) do
      table_titles
      table_values(sorted_stats)
    end
  end

  def table_titles
    row do
      column('Rating', width: 10)
      column('Name', width: 20)
      column('Difficulty', width: 10)
      column('Attempts total', width: 14)
      column('Attempts used', width: 13)
      column('Hints total', width: 12)
      column('Hints used', width: 12)
    end
  end

  def table_values(sorted_stats)
    rating = 1
    sorted_stats.each do |player|
      row_columns(player, rating)
      rating += 1
    end
  end

  def row_columns(player, rating)
    row do
      column rating
      column player[:name]
      column player[:difficulty]
      column player[:total_attempts]
      column player[:used_attempts]
      column player[:total_hints]
      column player[:used_hints]
    end
  end

  def message(type)
    puts I18n.t(type)
  end
end
