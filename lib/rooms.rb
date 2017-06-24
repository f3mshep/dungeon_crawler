
my_dungeon.add_room(:largecave, "Large Cave", "a large cavernous cave. The entrance is freshly caved in. You see a point of light WEST of you. ", { :west => :smallcave })

my_dungeon.add_room(:smallcave, "Small Cave", "a small, claustrophobic cave. There is an opening to the large cave EAST of you. You can make something out to the NORTH.", { :east => :largecave, :north => :torture_chamber })

my_dungeon.add_room(:torture_chamber, "Torture Chamber", "a dimly lit chamber. People were tortured here. It is vaguely smelly in here. To the SOUTH is the small cave.", {:south => :smallcave} )

my_dungeon.start(:largecave)
