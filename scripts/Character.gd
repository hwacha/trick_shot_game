extends KinematicBody2D

signal activate_selected_character(previously_active_character)

# initialize for level
export(bool) var start_active = false

# tweakable paramters
export(float) var horizontal_speed = 32 * 16
export(float) var jump_height      = 32 * 8
export(float) var active_jump_time = 0.4
export(float) var inactive_jump_time = 0.4
export(float) var grab_distance = 50
export(float) var grab_angle = PI * 1/3
export(float) var throw_speed = 32 * 24
export(float) var max_speed = 32 * 32

# dependent variables
var gravity : float
var initial_jump_speed : float
var inactive_ratio : float
var grab_norm : float
var adjusted_max_speed : float

# for internal use
var velocity = Vector2(0, 0)
var is_character_active : bool
var index : int
var grab_lock = false

# references
var lifter = null
var liftee = null
var characters_root = null

func _ready():
	gravity = 2 * jump_height / (active_jump_time * active_jump_time)
	initial_jump_speed = -2 * jump_height / active_jump_time
	inactive_ratio = active_jump_time / inactive_jump_time
	grab_norm = grab_distance * grab_distance
#	throw_speed /= inactive_ratio
	adjusted_max_speed = max_speed * sqrt(2)
	
	set_character_activation(start_active)
	
	connect("activate_selected_character", get_parent(), "_on_Character_activate_selected_character")
	
func set_character_activation(is_active):
	is_character_active = is_active
	if is_active:
		self.get_node("ColorRect").self_modulate.a = 1
	else:
		self.get_node("ColorRect").self_modulate.a = 0.5
	
func handle_input(player):
	if is_on_floor():
		velocity.x = 0

	if is_character_active:
		var moving_left  = Input.is_action_pressed(player + "_move_left")
		var moving_right = Input.is_action_pressed(player + "_move_right")
		var moving_up    = Input.is_action_pressed(player + "_move_up")
		var moving_down  = Input.is_action_pressed(player + "_move_down")

		if moving_left:
			velocity.x = -horizontal_speed
		if moving_right:
			velocity.x = horizontal_speed
		if is_on_floor() and Input.is_action_just_pressed(player + "_jump"):
			velocity.y = initial_jump_speed
		if Input.is_action_just_pressed(player + "_activate_character"):
			emit_signal("activate_selected_character", self)
		if Input.is_action_just_pressed(player + "_drop"):
			velocity.x = 0
			velocity.y = max(velocity.y, 0)
		if Input.is_action_just_pressed(player + "_throw"):
			var direction = Vector2(0, 0)
			if moving_left:
				direction.x += -1
			if moving_right:
				direction.x +=  1
			if moving_up:
				direction.y += -1
			if moving_down:
				direction.y +=  1

			throw(direction)

func grab(grabbee):
	if self == grabbee:
		return
	elif liftee == null:
		# set list refs
		self.liftee = grabbee
		grabbee.lifter = self
		# set transforms
		grabbee.get_parent().remove_child(grabbee)
		self.add_child(grabbee)
		grabbee.transform.origin = Vector2(0, -32)
	else:
		liftee.grab(grabbee)

func throw(direction):
	if liftee == null:
		return
	
	# reparent liftee to characters root
	var liftee_global_position = liftee.get_global_position()
	self.remove_child(liftee)
	characters_root.add_child(liftee)
	liftee.set_global_position(liftee_global_position)
	
	# apply impulse for throw
	liftee.velocity = self.velocity + (direction.normalized() * throw_speed)
	liftee.velocity = liftee.velocity.clamped(adjusted_max_speed)

	# split group
	liftee.lifter = null
	self.liftee   = null
	
	grab_lock = true
	$GrabLockTimer.start()

func ground():
	velocity.y = 0
	if liftee != null:
		liftee.ground()

func _physics_process(delta):
	if is_on_floor():
		ground()

	# Input
	handle_input("p1")
	
	if lifter != null:
		return

	# Grab other players
	if is_character_active and not grab_lock:
		for c in get_tree().get_nodes_in_group("character"):
			var c_origin = c.transform.origin
			var s_origin = self.transform.origin
			if (s_origin.distance_squared_to(c_origin) <= grab_norm):
				grab(c)
	
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


func _on_GrabLockTimer_timeout():
	grab_lock = false
