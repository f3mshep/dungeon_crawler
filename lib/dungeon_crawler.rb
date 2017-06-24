

class Dungeon
  attr_accessor :player

  DIRECTIONS = [:north, :south, :east, :west]
  PLAYER_ACTIONS = [DIRECTIONS, :take, :help, :use, :fight, :status, :look]



  def game_over
    puts "Game over"
    exit
  end

  def play
    game_over unless @player.alive?
    puts "Please enter a command"
    input = gets.chomp.downcase.to_sym
    actions(input)
    play
  end

  def actions(input)
    case input
    when :north, :south, :east, :west
      go(input)
    when :help
      puts PLAYER_ACTIONS
    when :take
      puts "this feature isn't implemented yet, buttmunch"
    when :use
      puts "not working yet"
    when :fight
      puts "oh yeah?"
    when :quit, :exit
      puts "Exiting game"
      exit
    when :status
      puts "You are at a healthy #{@player.health}"
    when :look
      show_current_description
    else
      puts "I did not understand that. Please enter a valid command"
    end
  end

  def valid_move?(input)
    if self.find_room_in_direction(input) == nil
      puts "You cannot go that way"
      return false
    end
    true
  end


  def start(location)
    @player.location = location
    show_current_description
  end

  def show_current_description
    puts find_room_in_dungeon(@player.location).full_description
  end

  def find_room_in_dungeon(reference)
    @rooms[reference]
  end

  def find_room_in_direction(direction)
    find_room_in_dungeon(@player.location).connections[direction]
  end

  def go(direction)
    puts "You go " + direction.to_s
    @player.location = find_room_in_direction(direction)
    show_current_description
    if @player.location == :doom_room
      @player.health -= 100
    end
  end

  def initialize(player)
    @player = player
    @rooms = Hash.new
  end

  def add_room(reference, name, description, connections)
    @rooms[reference] = Room.new(reference, name, description, connections)
  end

end

class Player
  attr_accessor :name, :location, :health
  max_health = 100

  def alive?
    return true if health > 0
  end

  @inventory = []

  def initialize(player_name)
    @name = player_name
    @health = 100
  end

end

class Room
  attr_accessor :reference, :name, :description, :connections

  def full_description
      @name + "\nYou are in " + @description
  end

  def initialize(reference, name, description, connections)
    @reference = reference
    @name = name
    @description = description
    @connections = connections
  end

end
