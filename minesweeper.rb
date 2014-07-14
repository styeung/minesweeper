require 'set'
require 'debugger'

class Minesweeper
  attr_accessor :board

  def initialize(row_size, column_size, num_bombs)
    @board = Board.new(row_size, column_size, num_bombs)
  end

  def play

    until self.board.over?
      self.board.draw_board
      puts "What do you want to do? Enter 'r' for reveal or 'f' for flag. "
      action = gets.chomp

      puts "Enter the row of the tile you want to act on: "
      row = gets.chomp.to_i
      puts "Enter the column of the tile you want to act on: "
      column = gets.chomp.to_i

      pos = [row, column]
      selected_tile = self.board[pos]

      if action != "r" && action != "f"
        puts "Invalid action. Please try again"
      elsif selected_tile.revealed?
        puts "This tile was already revealed or flagged. Please try again."
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


  def print_result

    if self.board.win?
      puts "You win!"
    else
      puts "You lose!"
    end
    self.board.draw_board

  end

end

class Board
  attr_accessor :grid

  def initialize(row_size, column_size, num_bombs)
    @grid = self.create_with_random(row_size, column_size, num_bombs)
  end

  def [](pos)
    row, column = pos[0], pos[1]
    return self.grid[row][column]
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
        pos = [row, column]
        new_tile = Tile.new(self, row, column, bomb_places.include?(pos))
        overall_board[row][column] = new_tile
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
        unless tile.revealed?
          tile.revealed = true
          if tile.bombed?
            tile.value = "b"
          end
        end
      end
    end
  end

  def over?
    self.grid.each do |row|
      return true if row.any? {|tile| tile.value == "B" || tile.value == "b"}
      return false if row.any? {|tile| !tile.revealed? }
    end
  end

  def win?
    if self.over?
      self.grid.each do |row|
        return false if row.any? {|tile| tile.value == "B" || tile.value == "b"}
      end
    end

    return true
  end

end

class Tile
  attr_accessor :board, :row, :column, :bombed, :flagged, :revealed, :value

  def initialize(my_board, row, column, bombed_status = false)
    @board = my_board
    @row = row
    @column = column
    @bombed = bombed_status
    @flagged = false
    @revealed = false
    @value = "*"
  end

  def bombed?
    self.bombed
  end

  def flagged?
    self.flagged
  end

  def revealed?
    self.revealed
  end

  def reveal
    unless self.revealed?
      if self.bombed?
        self.revealed = true
        self.value = "B"
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
  end

  def place_flag
    unless self.revealed?
      self.revealed = true
      self.value = "F"
    end
  end

  def neighbors
    neighbor_array = []
    deltas = [
      [1,1], [-1, 1], [1, -1], [-1, -1], [1,0], [-1,0], [0, -1], [0,1]
    ]
    cur_row = self.row
    cur_column = self.column

    deltas.each do |x|
      new_row = cur_row + x[0]
      new_column = cur_column + x[1]

      if (0...self.board.grid.length).to_a.include?(new_row)
        if (0...self.board.grid[0].length).to_a.include?(new_column)
          neighbor_array << self.board.grid[cur_row + x[0]][cur_column + x[1]]
        end
      end
    end

    neighbor_array
  end

  def neighbor_bomb_count
    bomb_count = 0

    self.neighbors.each do |x|
      if x.bombed?
        bomb_count += 1
      end
    end

    bomb_count
  end

end