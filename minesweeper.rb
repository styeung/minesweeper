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

  def draw_board

  end

  def reveal_all

  end

end

class Tile
  attr_accessor :board, :row, :column :bombed, :flagged, :revealed, :value

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
    if self.bombed
      self.board.reveal_all
    else
      self.revealed = true
      surrounding_bombs = self.neighbor_bomb_count
      if surrounding_bombs > 0
        self.value = surrounding_bombs.to_s
      else
        self.value = "_"
        self.neighbors.each do |tile|
          tile.reveal
        end
      end
    end
  end

  def neighbors
    neighbor_array = []
    self.board.each do |tile|
      if self.is_neighbor?(tile)
        neighbor_array << tile
      end
    end

    neighbor_array

  end

  def is_neighbor?(tile2)
    deltas = [
      [1,1], [-1, 1], [1, -1], [-1, -1]
    ]

    deltas.each do |x|
      if [tile2.row, tile2.column] == [self.row + x[0], self.column + x[1]]
        return true
      end
    end

    return false
  end

  def neighbor_bomb_count
    bomb_count = 0

    self.neighbors.each do |x|
      if x.bombed
        bomb_count += 1
      end
    end

    bomb_count
  end
end