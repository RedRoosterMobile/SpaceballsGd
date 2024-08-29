extends Node3D

@onready var school: MultiMeshInstance3D = $School
@onready var stripe: MeshInstance3D = $Stripe
const COLORS = [Color("#fcaa67"), Color("#C75D59"), Color("#ffffc7"), Color("#8CC5C6"), Color("#A5898C")]
@onready var shader_material: ShaderMaterial = preload("res://materials/stripes.tres")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	school.multimesh.instance_count = 0
	school.multimesh.use_colors = true
	# Apply the ShaderMaterial to the mesh # no-op
	#stripe.mesh.surface_set_material(0, shader_material)
	school.multimesh.mesh = stripe.mesh
	school.multimesh.instance_count = 200
	
	for i in range(school.multimesh.instance_count):
		var position = Transform3D()
		position = position.scaled(Vector3(0.5,1,10))
		position = position.translated(Vector3(randf() * 100 - 50, randf() * 50 - 25, randf() * 50 - 25))
		
		school.multimesh.set_instance_transform(i, position)
		
		var rnd = randi_range(0, COLORS.size()-1)
		school.multimesh.set_instance_color(i, COLORS[rnd])
		
		
		# how to set the emission color to the same color???
		# shader does it!
