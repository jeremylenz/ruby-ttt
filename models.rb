# require 'pry'

class GameBoard

  attr_reader :rows, :cols

  def initialize(num_rows_cols, rows = [])
    num_rows_cols = 3 unless validation_passed?(num_rows_cols)

    @rows = Array.new(rows)
    @num_rows_cols = num_rows_cols
    set_diag_coordinates

    if @rows.length == 0
      num_rows_cols.times do
        @rows << Array.new(num_rows_cols)  # create a new array filled with the specified number of nils
      end
    end

    @rows.each_with_index do |row, idx|
      @rows[idx] = Array.new(@rows[idx])
    end
  end

  def set_diag_coordinates
    row = 0
    col = 0
    last = @num_rows_cols - 1
    diag_0 = []
    diag_1 = []
    while row <= last
      diag_0 << [row, col]
      diag_1 << [last - row, col]
      row += 1
      col += 1
    end
    @diag_0_coords = diag_0
    @diag_1_coords = diag_1
  end

  # Orientation / describing the board

  def diag_num(row, col)
    coords = [row, col]
    if @diag_0_coords.include?(coords)
      0
    elsif @diag_1_coords.include?(coords)
      1
    else
      nil
    end
  end

  def center_square?(row, col)
    coords = [row, col]
    cs = @diag_0_coords.include?(coords) && @diag_1_coords.include?(coords)
    cs
  end

  def cols
    cols = []
    @num_rows_cols.times do |idx|
      cols << @rows.map do |row|
        row[idx]
      end
    end
    cols
  end

  def diagonals
    diags = []
    # get (1,1) diagonal
    diags << @rows.map.with_index do |row, idx|
      row[idx]
    end
    # get (x, 1) diagonal
    diags << @rows.map.with_index do |row, idx|
      row[@num_rows_cols - 1 - idx]
    end
    diags
  end

  def winner
    x_win = false
    o_win = false
    winning_x_row = Array.new(@num_rows_cols){'X'}
    winning_o_row = Array.new(@num_rows_cols){'O'}
    # check horizontal
    @rows.each do |row|
      x_win = true if row == winning_x_row
      o_win = true if row == winning_o_row
    end
    # check vertical
    self.cols.each do |col|
      x_win = true if col == winning_x_row
      o_win = true if col == winning_o_row
    end
    # check diagonals
    self.diagonals.each do |diag|
      x_win = true if diag == winning_x_row
      o_win = true if diag == winning_o_row
    end
    # return winner
    if x_win
      "X"
    elsif o_win
      "O"
    elsif board_full
      "None"
    else
      false
    end
  end

  # Altering the board

  def move (mark, row, col)
    # mark = 'X' or 'O'
    return false if row > @num_rows_cols || col > @num_rows_cols
    mark = format_mark(mark)
    if !square_is_occupied(row, col)
      self.rows[row-1][col-1] = mark
      true
    else
      false
    end
    # display_board(self)
  end

  # Strategy / logic

  def best_move(player)
    moves = possible_moves
    ratings = moves.map do |move|
      move_rating(move, player)
    end
    # puts ratings.inspect
    # rc_scores =  moves.map do |move|
    #   {
    #     move: [move[0] + 1, move[1] + 1],
    #     row: row_score(move[0], player),
    #     col: col_score(move[1], player),
    #     diag: diag_score(diag_num(move[0], move[1]), player),
    #     prevent: would_prevent_other_player_win?(move[0], move[1], player),
    #     foil: foil_opponent_plans_score(move[0], move[1], player)
    #   }
    # end
    # puts rc_scores.inspect
    idx = ratings.find_index(ratings.max)
    moves[idx]
  end

  def possible_moves  # in other words, a list of unoccupied (nil) squares
    possible_moves = []
    @rows.each_with_index do |squares, row_num|
      possible_moves << squares.map.with_index { |e, col_num| e == nil ? [row_num, col_num] : nil }.compact
    end
    possible_moves.compact.flatten(1)
  end

  def possible_to_win?(player)
    # fill in entire board with X's or O's
    # see if the board is winning
    new_rows = Array.new(@rows)
    mock_board = GameBoard.new(@num_rows_cols, new_rows)
    mock_board.possible_moves.each do |move|
      mock_board.move(player, move[0] + 1, move[1] + 1)
    end
    mock_board.winner == player
  end

  def move_rating(row_col, player)
    # 0: worst
    # 1: move toward i win
    # 2: i prevent you from winning
    # 3: i do 1 and 2

    row = row_col[0]
    col = row_col[1]
    diag = diag_num(row, col)
    weight = @num_rows_cols * 3

    rating = 0
    rating += row_score(row, player)
    rating += col_score(col, player)
    rating += diag_score(diag, player)
    rating += foil_opponent_plans_score(row, col, player)
    if center_square?(row, col)
      rating += diag_score(1, player)  # the center square will only register as being in the 0 diagonal; we must manually account for the second diagonal
      # puts 'center square'
    end
    rating += weight if would_prevent_other_player_win?(row, col, player)
    rating += 98 if would_win?(row, col, player)
    rating
  end

  def row_win_possible?(row_num, player)
    row_score(row_num, other_player(player)) <= 1
  end

  def col_win_possible?(col_num, player)
    col_score(col_num, other_player(player)) <= 1
  end

  def diagonal_win_possible?(diag_num, player)
    return false if !diag_num
    diag_score(diag_num, other_player(player)) <= 1
  end

  def line_score(line, player)
    score = line.count(player) + 1  # start with a score of 1 + however many X's or O's are already there
    score = 0 if line.count(other_player(player)) > 0  # not a good idea to play in the row if you can't win
    score
  end

  def row_score(row_num, player)
    line_score(@rows[row_num], player)
  end

  def col_score(col_num, player)
    line_score(self.cols[col_num], player)
  end

  def diag_score(diag_num, player)
    return 0 if !diag_num
    line_score(self.diagonals[diag_num], player)
  end

  def would_win?(row, col, player)
    mock_board = GameBoard.new(@num_rows_cols, @rows)
    mock_board.move(player, row+1, col+1)
    mock_board.winner == player
  end

  def foil_opponent_plans_score(row, col, player)
    opponent = other_player(player)
    coord_diag_num = diag_num(row, col)
    score = 1 # slight weight in favor of defense as opposed to offense
    score += row_score(row, opponent) if row_win_possible?(row, opponent)
    score += col_score(col, opponent) if col_win_possible?(col, opponent)
    score += diag_score(coord_diag_num, opponent) if diagonal_win_possible?(coord_diag_num, opponent)
    score
  end

  def would_prevent_other_player_win?(row, col, player)
    opponent = other_player(player)
    would_win?(row, col, opponent)
  end

  private

  def other_player(player)
    player == "X" ? "O" : "X"
  end

  def square_is_occupied(row, col)
    !!@rows[row-1][col-1]
  end

  def validation_passed?(num)
    num = num.to_i
    unless num >= 3 && num <= 8
      puts "didn't understand that size; setting to 3"
      gets
      return false
    else
      return true
    end
  end

  def board_full
    free_space = false
    @rows.each do |row|
      free_space = true unless row == row.compact  # if there are no nil elements to remove, the row is full.
    end
    !free_space
  end

  def format_mark(mark)
    if mark.upcase == 'X'
      'X'
    elsif mark.upcase == 'O'
      'O'
    else
      nil
    end
  end

end # of class
