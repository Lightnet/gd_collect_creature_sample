extends CharacterBody3D

# Signals
signal toggle_inventory()

@export var inventory_data:InventoryData
@export var equip_inventory_data:InventoryDataEquip

#var face_direction:Vector3 = Vector3.ZERO

const DUMMY_CAPTURE = preload("res://prefabs/dummy_capture/dummy_capture.tscn")
const DUMMY_SUMMON_CREATURE = preload("res://prefabs/dummy_summon_creature/dummy_summon_creature.tscn")

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var neck: Node3D = $Neck
@onready var camera: Camera3D = $Neck/Camera3D
@onready var spring_arm = $Neck
@onready var right_hand: Node3D = $Neck/Camera3D/RightHand

@export var speed = 15.0
@export var acceleration = 5.0
@export var JUMP_VELOCITY = 4.5
var mouse_captured: bool = false
var jumping = false

@export_range(0.1, 3.0, 0.1) var jump_height: float = 1 # m
@export_range(0.1, 3.0, 0.1, "or_greater") var camera_sens: float = 1

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var move_dir: Vector2 # Input direction for movement
var look_dir: Vector2 # Input direction for look/aim
var walk_vel: Vector3 # Walking velocity 
var grav_vel: Vector3 # Gravity velocity 
var jump_vel: Vector3 # Jumping velocity
@export var slot_index:int = 1

func _ready() -> void:
	if not is_multiplayer_authority():return
	camera.make_current()
	Global.set_player(self)
	pass

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("jump"): jumping = true
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			mouse_captured = true
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			mouse_captured = false
			
	if event.is_action_pressed("inventory"):
		toggle_inventory.emit()
	# if mouse VISIBLE return do nothing.
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		return
		
	input_key_slot()
	#if event.is_action_pressed("slot1"):
		#slot_index = 1
	#if event.is_action_pressed("slot2"):
		#slot_index = 2
	#if event.is_action_pressed("throw") and slot_index == 1:
		#throw_capture()
	#if event.is_action_pressed("summon") and slot_index == 2:
		#throw_summon()
		#pass
		
	if event is InputEventMouseMotion:
		#print("mo?")
		look_dir = event.relative * 0.001
		if mouse_captured: _rotate_camera()
	#pass

func _physics_process(delta: float) -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		return
	#global_position = spawn_position
	if mouse_captured: _handle_joypad_camera_rotation(delta)
	velocity = _walk(delta) + _gravity(delta) + _jump(delta)
	#velocity.y += -gravity * delta
	#get_move_input(delta)
	move_and_slide()
	
func get_move_input(delta):
	var vy = velocity.y
	velocity.y = 0
	var input = Input.get_vector("left", "right", "forward", "backward")
	var dir = Vector3(input.x, 0, input.y).rotated(Vector3.UP, spring_arm.rotation.y)
	velocity = lerp(velocity, dir * speed, acceleration * delta)
	velocity.y = vy
	
func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true
	
func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false
	
func _rotate_camera(sens_mod: float = 1.0) -> void:
	#print("rotate camera?")
	#camera.rotation.y -= look_dir.x * camera_sens * sens_mod
	#camera.rotation.x = clamp(camera.rotation.x - look_dir.y * camera_sens * sens_mod, -1.5, 1.5)
	
	rotation.y -= look_dir.x * camera_sens * sens_mod
	camera.rotation.x = clamp(camera.rotation.x - look_dir.y * camera_sens * sens_mod, -1.5, 1.5)

func _handle_joypad_camera_rotation(delta: float, sens_mod: float = 1.0) -> void:
	var joypad_dir: Vector2 = Input.get_vector("look_left","look_right","look_up","look_down")
	if joypad_dir.length() > 0:
		look_dir += joypad_dir * delta
		_rotate_camera(sens_mod)
		look_dir = Vector2.ZERO

func _walk(delta: float) -> Vector3:
	move_dir = Input.get_vector("left", "right", "forward", "backward")
	var _forward: Vector3 = camera.global_transform.basis * Vector3(move_dir.x, 0, move_dir.y)
	var walk_dir: Vector3 = Vector3(_forward.x, 0, _forward.z).normalized()
	#this for lerp movement which we do not want when start walk to speed up 
	#walk_vel = walk_vel.move_toward(walk_dir * speed * move_dir.length(), acceleration * delta)
	#return walk_vel
	#this should more easy to move
	walk_vel = (walk_dir * speed * move_dir.length()) * delta * 20
	return walk_vel
	
func _gravity(delta: float) -> Vector3:
	grav_vel = Vector3.ZERO if is_on_floor() else grav_vel.move_toward(Vector3(0, velocity.y - gravity, 0), gravity * delta)
	return grav_vel

func _jump(delta: float) -> Vector3:
	if jumping:
		if is_on_floor(): jump_vel = Vector3(0, sqrt(4 * jump_height * gravity), 0)
		jumping = false
		return jump_vel
	jump_vel = Vector3.ZERO if is_on_floor() else jump_vel.move_toward(Vector3.ZERO, gravity * delta)
	return jump_vel
	
func throw_capture():
	#right_hand.global_transform
	var dummy = DUMMY_CAPTURE.instantiate()
	
	get_tree().current_scene.add_child(dummy)
	dummy.global_transform = right_hand.global_transform
	dummy.init_fire()
	pass
	
func throw_summon():
	
	var dummy = DUMMY_SUMMON_CREATURE.instantiate()
	
	get_tree().current_scene.add_child(dummy)
	dummy.global_transform = right_hand.global_transform
	dummy.init_fire()
	pass

# drop item forward position
func get_drop_position() -> Vector3:
	
	# camera 
	var direction  = -(camera.global_transform.basis.z * 1.5)
	return camera.global_position + direction
	
	# player position and input face direction
	#face_direction.x = (face_direction.x * 1.1 )
	#face_direction.y = face_direction.y + 0.5
	#face_direction.z = (face_direction.z * 1.1 )
	#
	#return global_position + face_direction
	
func input_key_slot():
	
	if Input.is_action_just_pressed("slot1"):
		print("INPUT 1")
		check_slot(0)
	if Input.is_action_just_pressed("slot2"):
		check_slot(1)
	if Input.is_action_just_pressed("slot3"):
		check_slot(2)
	if Input.is_action_just_pressed("slot4"):
		check_slot(3)
	if Input.is_action_just_pressed("slot5"):
		check_slot(4)
	if Input.is_action_just_pressed("slot6"):
		check_slot(5)
	if Input.is_action_just_pressed("slot7"):
		check_slot(6)
	if Input.is_action_just_pressed("slot8"):
		check_slot(7)
	if Input.is_action_just_pressed("slot9"):
		check_slot(8)
	if Input.is_action_just_pressed("slot0"):
		check_slot(9)
	#if event.is_action_pressed("slot1"):
		#slot_index = 1
	#if event.is_action_pressed("slot2"):
		#slot_index = 2
	#if event.is_action_pressed("throw") and slot_index == 1:
		#throw_capture()
	#if event.is_action_pressed("summon") and slot_index == 2:
		#throw_summon()
		#pass
	pass

func check_slot(_index:int):
	print("#=====================================================")
	print("check_slot _index:", _index)
	
	if inventory_data.slot_datas[_index]:
		if inventory_data.slot_datas[_index].item_data:
			print("item_data:", inventory_data.slot_datas[_index].item_data)
	
	if inventory_data.slot_datas[_index]:
		if inventory_data.slot_datas[_index].item_data:
			#if inventory_data.slot_datas[_index].item_data as ItemData:
				#print("FOUND ItemData")
				#pass
			if inventory_data.slot_datas[_index].item_data is CreatureData:
				var creature_data = inventory_data.slot_datas[_index].item_data as CreatureData
				if creature_data.is_empty:
					throw_capture()
				if not creature_data.is_empty:
					throw_summon()
				print("FOUND CREATURE")
				#pass
		pass
	pass
