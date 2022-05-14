extends Node2D

onready var selector = $Selector

var characters
var selected_character
var lock_switch = false

func _ready():
	characters = get_tree().get_nodes_in_group("character")
	var selector_set = false
	for i in range(len(characters)):
		var character = characters[i]
		character.index = i
		character.characters_root = self
		if not character.name == "Selector" and \
		   not character.start_active and \
		   not selector_set:
			selected_character = character
			self.remove_child(selector)
			selected_character.add_child(selector)
			selector_set = true

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
		var selected_character_index : int = selected_character.index
		var character_index : int = selected_character_index
		character_index = add_and_wrap(character_index, search_direction, len(characters))
		while character_index != selected_character_index:
			var new_selected_character = characters[character_index]
			if not new_selected_character.is_character_active:
				switch_selected_character_to(new_selected_character)
				break
			character_index = add_and_wrap(character_index, search_direction, len(characters))

func _process(_delta):
	lock_switch = false
	handle_input("p1")

func _on_Character_activate_selected_character(previously_active_character):
	if not lock_switch:
		previously_active_character.set_character_activation(false)
		selected_character.set_character_activation(true)
		switch_selected_character_to(previously_active_character)
		lock_switch = true
