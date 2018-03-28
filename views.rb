module Hashtag
  def self.draw(board)
    board.rows.each do |row|
      puts row.map { |sq| sq ? "|" + sq : "| " }.join('') + "|"
    end
  end

end
