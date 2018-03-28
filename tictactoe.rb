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
    @whose_turn = 'X'
  end

  def start_game
    system "clear"
    Hashtag.draw(@board)
    until @board.winner
      next_move = get_input
      system "clear"
      do_move(next_move)
      Hashtag.draw(@board)
    end
    puts "Winner: #{@board.winner}"
    puts "Thanks for playing!"
  end

  def get_input
    puts "Current turn: #{@whose_turn}"
    if !@board.possible_to_win?(@whose_turn)
      puts "Sadly, it's no longer possible for #{@whose_turn} to win."
    end
    puts @board.possible_moves.map { |m| format_input(m) }.inspect
    puts format_input(@board.best_move(@whose_turn)).inspect
    puts "Enter move (row, col) or C for computer:"
    user_input = gets.chomp.split(',')
    get_input if !user_input[0]
    if user_input[0].upcase == "C"
      move = @board.best_move(@whose_turn)
      move = format_input(move)
    end
    # if user_input[0].upcase == "Q"
    #   @board.end_game
    # end
    pry if user_input[0].upcase == "P"
    row = user_input[0].to_i
    col = user_input[1].to_i
    move ? move : [row, col]
  end

  def format_input(move)
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

end

Game.new.start_game
