

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
      use_item
    when :fight
      puts "oh yeah?"
    when :quit, :exit
      puts "Exiting game"
      exit
    when :status
      puts "You are at a healthy #{@player.health} hitpoints"
    when :look
      show_current_description
    else
      puts "I did not understand that. Please enter a valid command"
    end
  end

  def player_has?(item)
    @player.inventory.include?(item)
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
      room_contents.each do |element|
        element.each do |object, type|
          if type == :item
            puts find_item_in_dungeon(object).view_description
          end
          if type == :room_object
            puts find_room_object_in_dungeon(object).view_description
          end
        end
      end
    end
  end

  def room_events
    room_contents.each do |element|
      element.each do |object, type|
        if type == :event
          trigger(object)
        end
      end
    end
  end



  def trigger(event)
    puts find_event_in_dungeon(event).view_description
    find_event_in_dungeon(event).block.call
  end

  def change_health(int)
    @player.health += int
  end

  def find_room_in_dungeon(reference)
    @rooms[reference]
  end

  def find_event_in_dungeon(name)
    @events[name]
  end

  def find_item_in_dungeon(reference)
    @items[reference]
  end

  def find_room_object_in_dungeon(reference)
    @room_objects[reference]
  end

  def find_room_in_direction(direction)
    find_room_in_dungeon(@player.location).connections[direction]
  end

  def go(direction)
    puts "You go " + direction.to_s
    @player.location = find_room_in_direction(direction)
    show_current_description
    room_events
  end

  def initialize(player)
    @player = player
    @rooms = Hash.new
    @items = Hash.new
    @events = Hash.new
    @flags = Hash.new
    @room_objects = Hash.new
  end

  def take_item
    room_items = []
    room_contents.each do |element|
      element.each do |object, type|
        if type == :item
          room_items << object
        end
      end
    end
    if room_items.empty?
      puts "There are no items you can take in here"
      return
    end
    puts "What item do you want to take?"
    room_items.each {|item| puts find_item_in_dungeon(item).name}
    input = gets.chomp.downcase.tr(" ", "_").to_sym
    chosen_item = room_items.select { |e| e == input  }
    if chosen_item.empty?
      puts "There are none of those in here"
    else
      puts "You grabbed the #{find_item_in_dungeon(chosen_item[0]).name}"
      @player.inventory << chosen_item[0]
      room_contents.each do |element|
        element.each do |object, type|
          if object == chosen_item[0]
            element.delete(chosen_item[0])
          end
        end
      end
    end
  end

  def show_inventory
    @player.inventory.each {|item| puts find_item_in_dungeon(item).name}
  end

  def use_item
    contents = []
    room_contents.each do |element|
      element.each do |object, type|
        contents << object if type == :room_object
      end
    end
    if contents.empty?
      puts "There are no usuable items in here"
      return
    end
    puts "What do you want to use?"
    contents.each {|object| puts find_room_object_in_dungeon(object).name }
    input = gets.chomp.downcase.tr(" ", "_").to_sym
    chosen_item = contents.select { |object| object == input  }
    if chosen_item.empty?
      puts "There are none of those in here"
    else
      trigger(find_room_object_in_dungeon(chosen_item[0]).actions)
    end
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
      find_room_in_dungeon(@player.location).contents << {chosen_item[0] => :item}
    end
  end

  def add_item(reference, name, description, location)
    @items[reference] = Item.new(reference, name, description)
    find_room_in_dungeon(location).contents << {reference => :item}
  end

  def add_room(reference, name, description, connections)
    @rooms[reference] = Room.new(reference, name, description, connections)
  end

  def add_room_object(reference, name, description, location, actions)
    @room_objects[reference] = RoomObject.new(reference, name, description, location, actions)
    find_room_in_dungeon(location).contents << {reference => :room_object}
  end

  def add_event(name, location, description, block)
    @events[name] = Event.new(name, location, description, block)
    if find_room_in_dungeon(location)
      find_room_in_dungeon(location).contents << {name => :event}
    end
  end

  def delete_room_object(reference, location)
    @room_objects[reference]
    find_room_in_dungeon(location).contents.each do |element|
      element.each do |object, type|
        element.delete(object)
      end
    end  
  end

  def add_flag(name, value)
    @name = name
    @value = value
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
  attr_accessor :name, :location, :description
  attr_reader :block

  def view_description
    puts @description
  end

  def initialize(name, location, description, block)
    @name = name
    @location = location
    @description = description
    @block = block
  end

end

class Flag
  attr_accessor :name, :value

  def initialize(name, value)
    @name = name
    @value = value
  end

end

class RoomObject < Item
  attr_accessor :name, :location, :reference, :actions

  def initialize(reference, name, description, location, actions)
    @reference = reference
    @name = name
    @description = description
    @location = location
    @actions = actions
  end
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
