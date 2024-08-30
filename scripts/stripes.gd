extends Node3D

@onready var school: MultiMeshInstance3D = $School
@onready var stripe: MeshInstance3D = $Stripe
const COLORS: Array[Color] = [Color("#fcaa67"), Color("#C75D59"), Color("#ffffc7"), Color("#8CC5C6"), Color("#A5898C")]
@onready var shader_material: ShaderMaterial = preload("res://materials/stripes.tres")
const AMOUNT: float = 200
const SPEED: float = 2
# Define a struct to hold the star's data
class StarData:
	var position: Transform3D
	var speed: float

var stars_data: Array[StarData] = []

func reset_star(i: int) -> void:
	var star_data = stars_data[i]
	star_data.position = Transform3D()
	var length: float = randf_range(2.5, 20.0)
	star_data.position = star_data.position.scaled(Vector3(0.25, 1, length))

	# Set random position
	var straight: float = randf_range(15, 195) # (15, 45 + 150)
	var sideways: float = randf_range(-45, 45) # (-45, 30)
	var upwards: float = randf_range(-10.5, 0)
	var random_position = Vector3(sideways, upwards, straight)
	star_data.position = star_data.position.translated(random_position)
	school.multimesh.set_instance_transform(i, star_data.position)

	# Set random color
	var rnd = randi_range(0, COLORS.size() - 1)
	school.multimesh.set_instance_color(i, COLORS[rnd])

func initialize_star_data(i: int) -> void:
	var star_data = StarData.new()
	star_data.speed = randf_range(19.5, 42.0)
	stars_data.append(star_data)
	reset_star(i)

func _ready() -> void:
	school.multimesh.instance_count = AMOUNT
	school.multimesh.use_colors = true
	school.multimesh.mesh = stripe.mesh

	# Initialize stars data
	for i in range(school.multimesh.instance_count):
		initialize_star_data(i)

func _process(delta: float) -> void:
	for i in range(school.multimesh.instance_count):
		var star_data = stars_data[i]

		# Move star along the Z-axis
		star_data.position.origin.z -= star_data.speed * delta * SPEED
		school.multimesh.set_instance_transform(i, star_data.position)

		# Reset star if it goes beyond a certain point
		if star_data.position.origin.z < -50.0:
			reset_star(i)
