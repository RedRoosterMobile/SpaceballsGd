extends Node3D

@onready var raycast: RayCast3D = $RayCast3D
var speed: float = 100.0

# Define a signal to notify when the laser hits something
signal laser_hit(collider: Node)



func start_moving() -> void:
	print("start moving")
	raycast.enabled = true
	#raycast.cast_to = Vector3(0, 0, 100)

func _process(delta: float) -> void:
	# Move the laser forward along the z-axis
	global_position.z += speed * delta
	
	# Check if the raycast is colliding with any object
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		emit_signal("laser_hit", collider)  # Emit the signal with the collider
		
		# Queue free the laser when it hits something
		queue_free()

	# Remove the laser if it goes too far
	if global_position.z > 100:
		queue_free()
