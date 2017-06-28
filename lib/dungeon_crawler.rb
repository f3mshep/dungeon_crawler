

class Dungeon
  attr_accessor :player

  DIRECTIONS = [:north, :south, :east, :west]
  PLAYER_ACTIONS = [DIRECTIONS, :take, :help, :use, :fight, :status, :look, :inventory, :drop]



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
      if valid_move?(input)
        go(input)
      end
    when :help
      puts PLAYER_ACTIONS
    when :take
      take_item
    when :inventory
      show_inventory
    when :drop
      drop_item
    when :use
      puts "not working yet"
    when :fight
      puts "oh yeah?"
    when :quit, :exit
      puts "Exiting game"
      exit
    when :status
      puts "You are at a healthy #{@player.healh} hitpoints"
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

  def room_contents
    find_room_in_dungeon(@player.location).contents
  end

  def show_current_description
    puts find_room_in_dungeon(@player.location).full_description
    unless room_contents.empty?
      room_contents.each {|item| puts find_item_in_dungeon(item).view_description }
    end
  end

  def find_room_in_dungeon(reference)
    @rooms[reference]
  end

  def find_item_in_dungeon(reference)
    @items[reference]
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
    @items = Hash.new
  end

  def take_item
    puts "What item do you want to take?"
    room_contents.each {|item| puts find_item_in_dungeon(item).name}
    input = gets.chomp.downcase.tr(" ", "_").to_sym
    chosen_item = room_contents.select { |e| e == input  }
    if chosen_item.empty?
      puts "There are none of those in here"
    else
      puts "You grabbed the #{find_item_in_dungeon(chosen_item[0]).name}"
      @player.inventory << chosen_item[0]
      room_contents.delete(chosen_item[0])
    end
  end

  def show_inventory
    @player.inventory.each {|item| puts find_item_in_dungeon(item).name}
  end

  def drop_item
    puts "What item do you want to drop?"
    show_inventory
    input = gets.chomp.downcase.tr(" ", "_").to_sym
    chosen_item = @player.inventory.select {|item| item == input}
    if chosen_item.empty?
      puts "You don't have any of that!"
    else
      puts "Dropped #{find_item_in_dungeon(chosen_item[0]).name}"
      @player.inventory.delete(chosen_item[0])
      find_room_in_dungeon(@player.location).contents << chosen_item[0]
    end
  end

  def add_item(reference, name, description, location)
    @items[reference] = Item.new(reference, name, description)
    find_room_in_dungeon(location).contents << reference
  end

  def add_room(reference, name, description, connections)
    @rooms[reference] = Room.new(reference, name, description, connections)
  end

end

class Item
  attr_accessor :name, :location, :reference

  def initialize(reference, name, description)
    @reference = reference
    @name = name
    @description = description
  end

  def view_description
    puts @description
  end

end

class Player
  attr_accessor :name, :location, :health, :inventory
  max_health = 100

  def alive?
    return true if health > 0
  end



  def initialize(player_name)
    @name = player_name
    @health = 100
    @inventory = []
  end

end

class Event

  def initialize(name, location, description)
  end

end

class Flag



end

class Room
  attr_accessor :reference, :name, :description, :connections, :contents

  def full_description
      @name + "\nYou are in " + @description
  end

  def initialize(reference, name, description, connections)
    @reference = reference
    @name = name
    @description = description
    @connections = connections
    @contents = []
  end

end
