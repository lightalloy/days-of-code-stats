require './parser/parser'
require './tags/counter'
require './progress/counter'
require './progress/view'
require './stats/view'

DELIMITER = '-------------------------------------------'

def delimiter
  puts DELIMITER
end

def p_delimiter
  delimiter
end

def p_title(title)
  p_delimiter
  puts title
  p_delimiter
end

def parser
  filename = ENV.fetch('FILE', 'input.csv')
  DaysOfCode::Parser.new(filename)
end

namespace :tags do
  # most popular tags planned to be learned
  task :initial_popular do
    cnt = ENV.fetch('COUNT', 15)
    # parser = Parser.new('input.csv')
    p_title("#{cnt} most popular tags (initial):")
    counts = DaysOfCode::Tags::Counter.new(parser.initial_tags).sorted_counts
    DaysOfCode::Stats::View.new(counts, symbol: '===').display(cnt)
  end

  # most popular tags overall
  task :popular do
    cnt = ENV.fetch('COUNT', 15)
    p_title("#{cnt} most popular tags:")
    # parser = Parser.new('input.csv')
    counts = DaysOfCode::Tags::Counter.new(parser.tags).sorted_counts
    DaysOfCode::Stats::View.new(counts, symbol: '=').display(cnt)
  end

  # individual progress for each user
  # TODO: refactor
  task :for_users do
    # parser = Parser.new('input.csv')
    progress = parser.users_progress
    counts = DaysOfCode::Progress::Counter.new(progress).counts
    progress.each do |name, tags|
      p_title("#{name} #{'👑' if counts[name] == 30}")
      user_tags = tags.map do |t|
        DaysOfCode::Parser::TagParser.new(t.to_s).to_a
      end.flatten
      user_tags_counts = DaysOfCode::Tags::Counter.new(user_tags).counts
      # sum = user_tags_counts.values.inject(&:+)
      DaysOfCode::Stats::View.new(user_tags_counts, symbol: '*').display
      p_delimiter
      puts ''
    end
  end
end

task :progress do
  # parser = Parser.new('input.csv')
  p_title('Users progress:')
  DaysOfCode::Progress::View.new(parser).display
end
