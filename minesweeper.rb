require 'set'

class Minesweeper



end

class Board
  attr_accessor :board

  def self.create_with_random(row_size, column_size, num_bombs)
    overall_board = Array.new(row_size) { Array.new(column_size)}

    i = 0
    bomb_places = Set.new
    while i < num_bombs
      random_row = (0...row_size).to_a.sample
      random_column = (0...column_size).to_a.sample

      unless bomb_places.include?([random_row, random_column])
        bomb_places.add( [random_row, random_column] )
        i += 1
      end

    end

    (0...row).each do |row|
      (0...column).each do |column|
        if bomb_places.include?([row, column])
          new_tile = Tile.new(self, row, column, true)
          overall_board[row][column] = new_tile
        else
          new_tile = Tile.new(self, row, column, false)
          overall_board[row][column] = new_tile
        end
      end
    end

    overall_board

  end

  def initialize(row_size, column_size, num_bombs)
    @board = self.create_with_random(row_size, column_size, num_bombs)

  end

end

class Tile
  attr_accessor :row, :column :bombed, :flagged, :revealed

  def initialize(board, row, column, bombed_status = false)
    @board = board
    @row = row
    @column = column
    @bombed = bombed_status
    @flagged = false
    @revealed = false
    @value = "*"
  end

  def reveal

  end

  def neighbors

  end

  def neighbor_bomb_count

  end
end