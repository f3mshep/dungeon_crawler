class Dungeon
  attr_accessor :player

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
  attr_accessor :name, :location

  def initialize(player_name)
    @name = player_name
  end

end

class Room
  attr_accessor :reference, :name, :description, :connections

  def full_description
      + ' you are in ' + @description
  end

  def initialize(reference, name, description, connections)
    @reference = reference
    @name = name
    @description = description
    @connections = connections
  end

end
