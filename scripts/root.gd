extends Node3D

# Define the number of balls you want to create
const BALL_COUNT: int = 10

# Preload external scenes
const BALL: PackedScene = preload("res://scenes/ball.tscn")
const LASER: PackedScene = preload("res://scenes/laser.tscn")

@onready var spaceship_area: Area3D = $Spaceship/Area3D
@onready var spaceship: Node3D = $Spaceship
@onready var laser_spawner: Node3D = $Spaceship/LaserSpawner

# Define the range for random positions
const POSITION_RANGE: float = 10.0

# Predefined colors array
const COLORS: Array[Color] = [
	Color("#fcaa67"), 
	Color("#C75D59"), 
	Color("#ffffc7"), 
	Color("#8CC5C6"), 
	Color("#A5898C")
]

# Movement and tilt variables
var movement_speed: float = 25.0
var tilt_angle: float = 25.0
var tilt_damping: float = 10.5

class BallData:
	var ball: Node3D
	var speed: float
	var hit: bool

var balls: Array[BallData] = []

var laser_instance: Node3D = null  # Store the laser instance here

func create_balls() -> void:
	for i in BALL_COUNT:
		# Instantiate a new ball
		var a_ball: Node3D = BALL.instantiate() as Node3D
		# Set a random position within the defined range
		a_ball.transform.origin = Vector3(
			randf_range(-POSITION_RANGE, POSITION_RANGE),
			0,
			randf_range(0, POSITION_RANGE*4)
		)
		# name for manual collision check
		a_ball.get_child(1).name = "Ball_%d" % i  
		
		# Access the MeshInstance3D (assuming it's the first child of a_ball)
		var mesh: MeshInstance3D = a_ball.get_child(0)
		
		# Choose a random color from the predefined list
		var rnd = randi_range(0, COLORS.size() - 1)
		var random_color = COLORS[rnd]
		# Check if a material is set, if not create a new one
		var mesh_material: StandardMaterial3D
		mesh_material = StandardMaterial3D.new()
		mesh_material.albedo_color = random_color # Default color if none is set
		
		# Optionally, set a random emission color
		#mesh_material.emission = random_color
		#mesh_material.emission_energy_multiplier = 1.01
		#mesh_material.emission_enabled = true
		
		# Assign the new material to the mesh
		mesh.material_override = mesh_material
		
		# Add the ball to the scene
		add_child(a_ball)
		var ba = BallData.new()
		ba.ball = a_ball
		ba.hit = false
		ba.speed = randf_range(2 * 10, 10 * 10) # randomize this!
		balls.append(ba)

func update_ball(ball: BallData, delta: float, i: int) -> void:
	# Move ball along the Z-axis
	ball.ball.global_position.z -= ball.speed * delta
	var ship_width: float = 3
	# Reset star if it goes beyond a certain point
	if ball.ball.global_position.z < -25.0:
		# randomize other stuff?
		ball.ball.global_position.z = 195
		ball.hit = false
		ball.ball.visible = true

func check_for_collisions() -> void:
	var overlapping_areas = spaceship_area.get_overlapping_areas()
	for area in overlapping_areas:
		if area.name.begins_with("Ball"):
			var index: int = int(area.name.split("_")[1])
			if balls[index].hit == false:
				balls[index].hit = true
				balls[index].ball.visible = false
				explode_at(balls[index].ball.global_transform)

func steer_ship(delta: float) -> void:
	# Handle user input for movement
	var input_direction: float = 0.0
	if Input.is_action_pressed("steer_left"):
		input_direction += 1.0
	if Input.is_action_pressed("steer_right"):
		input_direction -= 1.0

	# Calculate new position
	var new_position = spaceship.global_position
	new_position.x += input_direction * movement_speed * delta

	# Limit spaceship movement to within the viewport bounds
	var viewport = get_viewport().size
	new_position.x = clamp(new_position.x, -viewport.x / 2, viewport.x / 2)

	# Apply the new position
	spaceship.global_position = new_position

	# Tilt the spaceship based on the movement direction with damping
	var target_rotation = -input_direction * tilt_angle
	spaceship.rotation_degrees.z = lerp(spaceship.rotation_degrees.z, target_rotation, tilt_damping * delta)

func shoot_laser() -> void:
	# Check if the laser is already active
	if laser_instance and laser_instance.visible:
		return  # Do nothing if the laser is still active

	#if not laser_instance:
	#	# Instantiate the laser once
	#	laser_instance = LASER.instantiate() as Node3D
	#	add_child(laser_instance)
	#	laser_instance.connect("laser_hit", Callable(self, "_on_laser_hit"))

	# Reset the laser position and visibility
	laser_instance.global_transform = laser_spawner.global_transform
	laser_instance.visible = true
	laser_instance.start_moving()
	Audio.play("audio/Laser.mp3", false)

func _on_laser_hit(collider: Node) -> void:
	print("Laser hit:", collider.name)
	if collider is Area3D and collider.name.begins_with("Ball"):
		var index: int = int(collider.name.split("_")[1])
		if not balls[index].hit:
			balls[index].hit = true
			balls[index].ball.visible = false
			explode_at(balls[index].ball.global_transform)
			
	# Hide the laser when it hits something
	laser_instance.visible = false
	
func explode_at(global_transform:Transform3D) -> void:
	# Load the explosion scene
	var explosion:GPUParticles3D = preload("res://scenes/Explosion.tscn").instantiate()
	# Set the explosion position to the ball's position
	explosion.global_transform = global_transform
	# Add the explosion to the scene
	add_child(explosion)
	# Start the particle effect
	explosion.emitting = true
	Audio.play("audio/Explosion.mp3", true, global_transform)

	# Optionally, you might want to queue_free() the explosion after it has played
	# You can use a timer or a callback from the particles themselves
	#explosion.queue_free()

func _ready() -> void:
	create_balls()
	laser_instance = LASER.instantiate() as Node3D
	laser_instance.visible = false
	add_child(laser_instance)
	laser_instance.connect("laser_hit", Callable(self, "_on_laser_hit"))

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	steer_ship(delta)
	if Input.is_action_just_pressed("shoot"):
		shoot_laser()

	# Update balls
	for i in balls.size():
		var ball: BallData = balls[i]
		update_ball(ball, delta, i)
	check_for_collisions()
