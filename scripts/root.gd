extends Node3D

# Define the number of balls you want to create
const BALL_COUNT: int = 10

# Preload the ball scene
const BALL: PackedScene = preload("res://scenes/ball.tscn")
@onready var spaceship_area: Area3D = $Spaceship/Area3D

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

class BallData:
	var ball: Node3D
	var speed: float
	var hit: bool

var balls: Array[BallData] = []

func create_balls() -> void:
	for i in BALL_COUNT:
		# Instantiate a new ball
		var a_ball: Node3D = BALL.instantiate() as Node3D
		# Set a random position within the defined range
		a_ball.transform.origin = Vector3(
			randf_range(-POSITION_RANGE, POSITION_RANGE),
			0,
			randf_range(0, POSITION_RANGE*2)
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
		mesh_material.emission = random_color
		mesh_material.emission_energy_multiplier = 1.1
		mesh_material.emission_enabled = true
		
		# Assign the new material to the mesh
		mesh.material_override = mesh_material
		
		# Add the ball to the scene
		add_child(a_ball)
		var ba = BallData.new()
		ba.ball = a_ball
		ba.hit = false
		ba.speed = randf_range(2 * 10, 10 * 10) # randomize this!
		balls.append(ba)
		#print("Ball ", i, " created at position: ", a_ball.transform.origin, " with color: ", random_color)

func update_ball(ball:BallData, delta:float, i:int) -> void:
	# Move ball along the Z-axis
	ball.ball.global_position.z -= ball.speed * delta
	var ship_width:float = 3
	# Reset star if it goes beyond a certain point
	if ball.ball.global_position.z < -25.0:
		# randomize other stuff?
		ball.ball.global_position.z = 195
		ball.hit = false
		ball.ball.visible = true

# In your spaceship script
func check_for_collisions() -> void:
	var overlapping_areas = spaceship_area.get_overlapping_areas()
	for area in overlapping_areas:
		if area.name.begins_with("Ball"):
			var index:int = int(area.name.split("_")[1])
			if balls[index].hit == false:
				balls[index].hit = true
				balls[index].ball.visible = false
				# print("Collision with ball index:", index)

func _ready() -> void:
	create_balls()

func _process(delta: float) -> void:
	for i in balls.size():
		var ball:BallData = balls[i]
		update_ball(ball,delta,i)

func _physics_process(delta: float) -> void:
	check_for_collisions()
