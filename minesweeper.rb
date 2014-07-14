require 'set'
require 'debugger'

class Minesweeper
  attr_accessor :board_object

  def initialize(row_size, column_size, num_bombs)
    @board_object = Board.new(row_size, column_size, num_bombs)
  end

  def play

    until self.over?
      self.board_object.draw_board
      puts "What do you want to do? Enter 'r' for reveal or 'f' for flag. "
      action = gets.chomp

      puts "Enter the row of the tile you want to act on: "
      row = gets.chomp.to_i
      puts "Enter the column of the tile you want to act on: "
      column = gets.chomp.to_i

      selected_tile = self.board_object.grid[row][column]

      if action != "r" && action != "f"
        puts "Invalid action. Please try again"
      elsif selected_tile.revealed
        puts puts "This tile was already revealed or flagged. Please try again."
      else
        if action == "r"
          selected_tile.reveal
        elsif action == "f"
          selected_tile.place_flag
        end
      end

    end

    self.print_result
  end

  def over?
    self.board_object.grid.each do |row|
      return true if row.any? {|tile| tile.value == "B" || tile.value == "b"}
      return false if row.any? {|tile| tile.revealed == false}
    end
  end

  def win?
    if self.over?
      self.board_object.grid.each do |row|
        return false if row.any? {|tile| tile.value == "B" || tile.value == "b"}
      end
    end

    return true
  end

  def print_result
    if self.win?
      "You win!"
    else
      "You lose!"
    end
    self.board_object.draw_board
  end

end

class Board
  attr_accessor :grid

  def initialize(row_size, column_size, num_bombs)
    @grid = self.create_with_random(row_size, column_size, num_bombs)

  end

  #factory method to randomly place bombs on a grid
  def create_with_random(row_size, column_size, num_bombs)
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

    (0...row_size).each do |row|
      (0...column_size).each do |column|
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

  def draw_board
    self.grid.each do |row|
      row.each do |column|
        print "#{column.value} "
      end
      puts
    end

    nil
  end

  def reveal_all
    self.grid.each do |row|
      row.each do |tile|
        unless tile.revealed
          tile.revealed = true
          if tile.bombed
            tile.value = "b"
          end
        end
      end
    end
  end

end

class Tile
  attr_accessor :board_object, :row, :column, :bombed, :flagged, :revealed, :value

  def initialize(my_board, row, column, bombed_status = false)
    @board_object = my_board
    @row = row
    @column = column
    @bombed = bombed_status
    @flagged = false
    @revealed = false
    @value = "*"
  end

  def reveal
    unless self.revealed
      if self.bombed
        self.revealed = true
        self.value = "B"
        self.board_object.reveal_all
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
  end

  def place_flag
    unless self.revealed
      self.revealed = true
      self.value = "F"
    end

  end

  def neighbors
    neighbor_array = []

    self.board_object.grid.each do |row|
      row.each do |tile|
        if self.is_neighbor?(tile)
          neighbor_array << tile
        end
      end
    end

    neighbor_array

  end

  def is_neighbor?(tile2)
    deltas = [
      [1,1], [-1, 1], [1, -1], [-1, -1], [1,0], [-1,0], [0, -1], [0,1]
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