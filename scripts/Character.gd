extends KinematicBody2D

signal activate_selected_character(previously_active_character)

# initialize for level
export(bool) var start_active = false

# tweakable paramters
export(float) var horizontal_speed = 32 * 16
export(float) var jump_height      = 32 * 8
export(float) var active_jump_time = 0.4
export(float) var inactive_jump_time = 10.0
export(float) var grab_distance_sqr = 50 * 50
export(float) var grab_angle = PI * 1/3

# dependent variables
var gravity : float
var initial_jump_speed : float
var inactive_ratio : float

# for internal use
var velocity = Vector2(0, 0)
var is_character_active : bool

func _ready():
	gravity = 2 * jump_height / (active_jump_time * active_jump_time)
	initial_jump_speed = -2 * jump_height / active_jump_time
	inactive_ratio = active_jump_time / inactive_jump_time
	
	set_character_activation(start_active)
	
	connect("activate_selected_character", get_parent(), "_on_Character_activate_selected_character")
	
func set_character_activation(is_active):
	print("set_character_activation on " + str(self))
	is_character_active = is_active
	if is_active:
		modulate.a = 1
	else:
		modulate.a = 0.5
	
func handle_input(player):
	var pressed_leftright = false
	if is_character_active:
		if Input.is_action_pressed(player + "_move_left"):
			velocity.x = -horizontal_speed
			pressed_leftright = true
		if Input.is_action_pressed(player + "_move_right"):
			velocity.x = horizontal_speed
			pressed_leftright = true
		if is_on_floor() and Input.is_action_just_pressed(player + "_jump"):
			velocity.y = initial_jump_speed
		if Input.is_action_just_pressed(player + "_activate_character"):
			emit_signal("activate_selected_character", self)
		if Input.is_action_just_pressed(player + "_drop"):
			velocity.x = 0
			velocity.y = max(velocity.y, 0)
		
	if is_on_floor() and !pressed_leftright:
		velocity.x = 0


func _physics_process(delta):
	# Grab other players
	self.modulate = Color(0,1,0)
	if (is_character_active):
		for c in get_tree().get_nodes_in_group("character"):
			var c_origin = c.transform.origin
			var s_origin = self.transform.origin
			if (c != self):
				if (s_origin.distance_squared_to(c_origin) <= grab_distance_sqr):
					# c.transform.origin = self.transform.origin + Vector2(0, -32)
					c.modulate = Color(1,0,0)
				#if (Vector2.UP.dot((c_origin - s_origin).normalized()) > cos(grab_angle)):
				
	
	
	# Input
	handle_input("p1")
	
	# Handle gravity
	var acceleration_due_to_gravity = gravity * delta
	
	if not is_character_active:
		acceleration_due_to_gravity *= inactive_ratio

	velocity.y += acceleration_due_to_gravity
	
	# Slow inactive
	var movement_velocity = velocity
	
	if not is_character_active:
		movement_velocity *= inactive_ratio

	# Handle movement
	move_and_slide(movement_velocity, Vector2.UP)
