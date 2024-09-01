extends Node3D

@onready var raycast_left: RayCast3D = $RayCastLeft
@onready var raycast_right: RayCast3D = $RayCastRight
var speed: float = 150.0

# Define a signal to notify when the laser hits something
signal laser_hit(collider: Node)

func start_moving() -> void:
	print("start moving")
	#raycast_left.enabled = true
	#raycast_right.enabled = true
	visible = true
	#raycast.cast_to = Vector3(0, 0, 100)

func _physics_process(delta: float) -> void:
	# Move the laser forward along the z-axis
	if visible:
		global_position.z += speed * delta
		var raycast:RayCast3D = raycast_left if raycast_left.is_colliding() else null
		if raycast == null:
			raycast = raycast_right if raycast_right.is_colliding() else raycast_right
		# Check if the raycast is colliding with any object
		if raycast.is_colliding():
			var collider = raycast.get_collider()
			emit_signal("laser_hit", collider)  # Emit the signal with the collider
			
			# Queue free the laser when it hits something
			#queue_free()
			visible = false
			#raycast_left.enabled = false
			#raycast_right.enabled = false

		# Remove the laser if it goes too far
		if global_position.z > 200:
			#queue_free()
			visible = false
			#raycast_left.enabled = false
			#raycast_right.enabled = false
