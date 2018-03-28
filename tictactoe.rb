require './models.rb'
require './views.rb'
require 'pry'
class Game

  def initialize
    puts 'Enter board size (3 to 8): '
    size = gets.chomp
    if size.upcase == 'R'
      @board = GameBoard.new(rand(3..8))
      @board.random
    else
      @board = GameBoard.new(size.to_i)
    end
    @game_ended = false
    @whose_turn = 'X'
  end

  def start_game
    system "clear"
    Hashtag.draw(@board)
    until @board.winner || @game_ended
      display_info
      next_move = get_input
      system "clear"
      do_move(next_move) if next_move
      Hashtag.draw(@board)
    end
    if @game_ended
      puts "Game ended by user"
    else
      puts "Winner: #{@board.winner}"
    end
    puts "Thanks for playing!"
  end

  def display_info
    puts "Current turn: #{@whose_turn}"
    if !@board.possible_to_win?(@whose_turn)
      puts "Sadly, it's no longer possible for #{@whose_turn} to win."
    end
    # puts @board.possible_moves.map { |m| format_input(m) }.inspect
    puts "Best move: ", format_input(@board.best_move(@whose_turn)).inspect
    puts "Enter move (row, col); C = accept choice; R = random move; Q = quit:"
  end

  def get_input
    user_input = gets.chomp.split(',')
    return false if !user_input[0]
    case user_input[0].upcase
    when "C"
      move = @board.best_move(@whose_turn)
      move = format_input(move)
    when "P"
      pry
    when "Q"
      self.end_game
      return false
    when "R"
      move = @board.possible_moves.sample
      move = format_input(move)
    else
      row = user_input[0].to_i
      col = user_input[1].to_i
      move ? move : [row, col]
    end
  end

  def format_input(move)  #turns 0-indexed coords into 1-indexed coords
    if move
      [move[0] + 1, move[1] + 1]
    end
  end

  def do_move(next_move)
    row = next_move[0]
    col = next_move[1]
    if @board.move(@whose_turn, row, col)
      next_player
    else
      puts "Square (#{row}, #{col}): invalid move"
    end
  end

  def next_player
    @whose_turn == 'X' ? @whose_turn = 'O' : @whose_turn = 'X'
  end

  def end_game
    @game_ended = true
  end

end

Game.new.start_game
