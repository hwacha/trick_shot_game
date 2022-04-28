extends Node2D

onready var selector = $Selector

var selected_character
var lock_switch = false

func _ready():
	for character in get_children():
		if not character.name == "Selector" and not character.start_active:
			selected_character = character
			self.remove_child(selector)
			selected_character.add_child(selector)
			break

func switch_selected_character_to(new_selected_character):
	selected_character.remove_child(selector)
	selected_character = new_selected_character
	selected_character.add_child(selector)
	
func add_and_wrap(n, offset, maximum):
	return (n + maximum + offset) % maximum

func handle_input(player):
	var search_direction : int = 0
	if Input.is_action_just_pressed(player + "_select_next_character"):
		search_direction += 1
	if Input.is_action_just_pressed(player + "_select_prev_character"):
		search_direction -= 1
	
	if search_direction != 0:
		var selected_character_index : int = selected_character.get_index()
		var character_index : int = selected_character_index
		character_index = add_and_wrap(character_index, search_direction, get_child_count())
		
		while character_index != selected_character_index:
			var new_selected_character = get_child(character_index)
			if not new_selected_character.is_character_active:
				switch_selected_character_to(new_selected_character)
				break
			
			character_index = add_and_wrap(character_index, search_direction, get_child_count())

func _process(_delta):
	lock_switch = false
	handle_input("p1")

func _on_Character_activate_selected_character(previously_active_character):
	if not lock_switch:
		previously_active_character.set_character_activation(false)
		selected_character.set_character_activation(true)
		switch_selected_character_to(previously_active_character)
		lock_switch = true
