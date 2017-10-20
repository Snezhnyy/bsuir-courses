require 'mechanize'

class KotdBattle
  attr_reader :title, :lyrics, :uri, :winner, :score

  def initialize(page = nil, criteria = nil)
    @title = ''
    @lyrics = ''
    @count = {}
    @winner = ''.to_sym
    @score = 0
    @criteria = criteria
    if page
      @uri = page.uri
      @title = page.title
      @title.gsub!('King of the Dot –', ' ')
      @title.gsub!('Lyrics | Genius Lyrics', ' ')
      @title.strip!
      @lyrics = page.css('.lyrics').text.strip
      # remove [?]
      @lyrics.gsub!(/\[\?\]/, ' ')
      # remove [...]
      @lyrics.gsub!(/\[\.\.\.\]/, ' ')
      @lyrics.gsub!(/\[…\]/, ' ')
      # remove [*text*]
      @lyrics.gsub!(/\[\*.*?\*\]/, ' ')
      battle
      guess_winner
    end
  end

  def to_s
    str = @title.to_s + ' - ' + @uri.to_s
    if @count.size > 1
      str += "\n"
      @count.each { |key, value| str += key.to_s + ' - ' + value.to_s + "\n" }
      str += @winner.to_s + ' WINS!' + "\n"
    end
    str
  end

  private

  def battle
    round = @lyrics.scan(/\[.*?\]/)
    text = @lyrics.split(/\[.*?\]/)
    text.shift
    (0...round.count).each do |i|
      performer = round[i]
      performer.gsub!('[', ' ')
      performer.gsub!(']', ' ')
      performer.strip!
      performer.gsub!(/Round\s\d\s?[:|\-|\u2013]*\s*/, ' ')
      performer.strip!
      key = performer.to_sym
      if text[i]
        if @criteria
          counter = text[i].scan(@criteria).count
        else
          counter = text[i].scan(/[A-Za-z]/).count
        end
      end
      if counter
        @count[key] = @count[key] ? @count[key] + counter : counter
      end
    end
  end

  def guess_winner
    if @count.any?
      @winner = @count.keys.first
      @score = @count.values.first
      @count.each do |key, value|
        if value > @score
          @winner = key
          @score = value
        end
      end
    end
  end
end
