require 'yaml'

# class hangman
class Hangman
  def initialize(secret_word = nil, _count = 6, _chars = [])
    secret_word ||= pick_secret_word('word_list')
    @secret_word = secret_word
    @guess_count = _count
    @characters_guessed_correctly = _chars
    @word_guessed = '_' * @secret_word.size
  end

  # load file and pick secret word
  def pick_secret_word(filename = 'word_list')
    secret_word = nil
    if File.exist? filename
      words = File.readlines filename
      suitable_words = words.select { |word| word.size.between?(5, 12) }
      secret_word = suitable_words.sample.downcase.chomp
    else
      puts 'file does not exist'
    end
    secret_word
  end

  # get users to guess the letters
  def guess_letters
    while @guess_count > 0 && @word_guessed.include?('_')
      print 'Guess a letter to play or type save to save game: '
      letter_guessed = gets.chomp.downcase
      if letter_guessed == 'save'
        save_game
        return
      else
        check_letters letter_guessed
      end
    end
    puts "The secret word was #{@secret_word}"
  end

  # replaced correctly guessed letters
  def replace_correct_letters
    result = @secret_word
    @secret_word.split('').each do |letter|
      unless @characters_guessed_correctly.include? letter
        result = result.gsub(letter, '_')
      end
    end
    @word_guessed = result
    result
  end

  # check if letter exists in secret word
  def check_letters(letter_guessed)
    if @secret_word.include?(letter_guessed)
      @characters_guessed_correctly << letter_guessed
      puts 'you guessed correctly'
      puts replace_correct_letters
    else
      puts 'you guessed wrong'
      @guess_count -= 1
    end
  end

  # save the current game
  def save_game
    store = YAML.dump(self)
    File.open('saved_game.yml', 'w') do |file|
      file.puts(store)
    end
    puts 'your game has been saved!'
  end
end

# class game
class Game
  # load game
  def load_game(option)
    if option == 'start'
      hangman = Hangman.new
    else
      store = YAML.load(File.read('saved_game.yml'))
      characters = store.instance_variable_get('@characters_guessed_correctly')
      guess_count = store.instance_variable_get('@guess_count')
      secret_word = store.instance_variable_get('@secret_word')
      hangman = Hangman.new(secret_word, guess_count, characters)
    end
    hangman.guess_letters
  end
end

puts 'Enter start to start new game and continue to proceed'
option = gets.chomp.downcase
game = Game.new
game.load_game option
