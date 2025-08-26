extends RigidBody3D

const DUMMY_CAPTURE_EFFECT = preload("res://prefabs/dummy_capture_effect/dummy_capture_effect.tscn")
# solver > contact monitor = true

# Export variables for easy tweaking in the editor
@export var impulse_strength: float = 20.0  # Strength of the impulse (affects speed)
@export var speed: float = 20.0  # Speed of the projectile
@export var lifetime: float = 5.0  # Time before projectile is destroyed (seconds)
@export var damage: float = 10.0  # Damage dealt on hit
@export var is_hit:bool = false

# Internal variables
var timer: float = 0.0  # Tracks lifetime

func _ready() -> void:
	# Ensure the projectile uses physics for movement
	#set_physics_process(true)
	# Connect collision signal to detect hits
	#body_entered.connect(_on_body_entered)
	pass

func _physics_process(delta: float) -> void:
	# Update lifetime timer
	timer += delta
	if timer >= lifetime:
		queue_free()  # Destroy projectile after lifetime expires

#func init_fire(direction: Vector3, spawn_position: Vector3) -> void:
func init_fire() -> void:
	var direction = -global_transform.basis.z
	# Set initial position of the projectile
	#global_position = spawn_position
	# Apply initial velocity in the given direction
	#linear_velocity = direction.normalized() * speed
	
	# Apply an impulse in the given direction
	apply_impulse(direction.normalized() * impulse_strength)

func _on_body_entered(body: Node) -> void:
	if is_hit: return
	# Handle collision with other bodies
	print("found creature!")
	if body.is_in_group("creature"):
		print("found creature!")
		var dummy = DUMMY_CAPTURE_EFFECT.instantiate()
		get_tree().current_scene.add_child(dummy)
		dummy.global_position = global_position
		is_hit = true
		# need to handle store inventory here.
		#pass
		
	#if body.is_in_group("enemies"):
		# Example: Apply damage to an enemy (assumes enemy has a take_damage method)
		#if body.has_method("take_damage"):
			#body.take_damage(damage)
			
	await get_tree().create_timer(0.5).timeout
	if body.is_in_group("creature"):
		body.queue_free()
	# Destroy projectile on collision
	queue_free()

func _on_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	#print("_on_body_shape_entered found creature!")
	pass
