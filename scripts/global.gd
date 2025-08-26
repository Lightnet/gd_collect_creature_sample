extends Node

const PICKUP = preload("res://item/pickUp/pick_up.tscn")

#================================================
# Player Data Handle
#================================================

#var player_data:PlayerData # current player
#var save_player_data:PlayerData # save state last battle

#func set_player_data(_player_data:PlayerData):
	#player_data = _player_data
	#pass
	
#================================================
# SCENE Handle
#================================================

# battle scene
var next_scene:String = ""

# player scene when go to battle to save.
var open_world_scene_path:String = ""
var open_world_position:Vector3
var is_defeated:bool = false #make sure the player is either win or lose for handle defeat result

#================================================
# RANDOM GEN STR CHARACTERS 16
#================================================

# change the scene handler
var game_controller:GameController

#================================================
# RANDOM GEN STR CHARACTERS 16
#================================================
# Length of the random ID
var id_length: int = 16

# Character set for generating the random ID (alphanumeric)
const CHARACTERS: String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

# Generates a random ID string
func generate_random_id() -> String:
	var rng = RandomNumberGenerator.new()
	rng.randomize() # Ensure different random seed each run
	var result = ""
	for i in range(id_length):
		var index = rng.randi_range(0, CHARACTERS.length() - 1)
		result += CHARACTERS[index]
	return result

#================================================
# MOB
#================================================
var current_mob_id:String # current creature attack player or event ecounter
#var mobs:Array[MapCreatureData] # store current mob defeated

## add mob to map tablet that player encounter
func add_mob(_map_name,_id:String):
	current_mob_id = _id
	#var mob_data = MapCreatureData.new()
	#mob_data.name = _map_name
	#mob_data.id = _id
	#mobs.append(mob_data)
	pass

#TODO need rework and for quest count creature???
func defeat_mob():
	#for mob in mobs:
		#if mob.id == current_mob_id:
			#mob.is_defeat = true
	pass

func show_connection_status()-> void:
	#connectionstatus
	var connectionstatuses = get_tree().get_nodes_in_group("connectionstatus")
	if len(connectionstatuses) == 1:
		connectionstatuses[0].show()
	#pass

func hide_connection_status()-> void:
	#connectionstatus
	var connectionstatuses = get_tree().get_nodes_in_group("connectionstatus")
	if len(connectionstatuses) == 1:
		connectionstatuses[0].hide()
	#pass

#================================================
#
#================================================
var count_player:int = 0
func get_name_player_count()->String:
	count_player+= 1
	return "player_"+str(count_player)
	
var count_projectile:int = 0
func get_name_projectile_count()->String:
	count_projectile+= 1
	return "projectile_"+str(count_projectile)
	

var player
var state_menu:String = "none"
#var res_player_path = "user://player_res.tres"

func set_player(entity):
	player = entity
	if player:
		connect_player()
	else:
		disconnect_player()
		pass
	
func get_player():
	return player

func connect_player():
	#delay due other ui not load for scene...
	await get_tree().create_timer(0.1).timeout
	var inventory_interface = get_tree().get_first_node_in_group("inventoryinterface")
	var hot_bar_inventory = get_tree().get_first_node_in_group("hotbarinventory")
	if player and inventory_interface and hot_bar_inventory:
		#print("player: ", player)
		player.toggle_inventory.connect(toggle_inventory_interface)
		
		#print("player.inventory_data:", player.inventory_data)
		inventory_interface.drop_slot_data.connect(_on_inventory_interface_drop_slot_data)
		inventory_interface.set_player_inventory_data(player.inventory_data)
		# inventory
		inventory_interface.set_equip_inventory_data(player.equip_inventory_data)
		inventory_interface.force_close.connect(toggle_inventory_interface)
		hot_bar_inventory.set_inventory_data(player.inventory_data)
	
	#chest
	#for node in get_tree().get_nodes_in_group("external_inventory"):
		#node.toggle_inventory.connect(toggle_inventory_interface)
	#pass
	
func disconnect_player():
	var inventory_interface = get_tree().get_first_node_in_group("inventoryinterface")
	var hot_bar_inventory = get_tree().get_first_node_in_group("hotbarinventory")
	
	player.toggle_inventory.disconnect(toggle_inventory_interface)
	inventory_interface.force_close.disconnect(toggle_inventory_interface)
	pass

func toggle_inventory_interface(external_inventory_owner = null) -> void:
	var inventory_interface = get_tree().get_first_node_in_group("inventoryinterface")
	
	inventory_interface.visible = not inventory_interface.visible
	print("inventory_interface.visible: ", inventory_interface.visible)
	
	if inventory_interface.visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		#PlayerManager.enable_menu()
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		#PlayerManager.disable_menu()
	
	if external_inventory_owner and inventory_interface.visible:
		print("external_inventory_owner")
		inventory_interface.set_external_inventory(external_inventory_owner)
	else:
		inventory_interface.clear_external_inventory()

func _on_inventory_interface_drop_slot_data(slot_data: SlotData) -> void:
	var pick_up = PICKUP.instantiate()
	pick_up.slot_data = slot_data
	#pick_up.position = Vector3.UP
	pick_up.position = player.get_drop_position()
	get_tree().current_scene.add_child(pick_up)
	#pass

#================================================
# SLOT
#================================================

func use_slot_data(slot_data:SlotData) -> void:
	slot_data.item_data.use(player)
	#pass

func get_global_position() -> Vector3:
	return player.global_position

#================================================
# MENU
#================================================

func disable_menu():
	state_menu = "none"

func enable_menu():
	state_menu = "menu"

func is_enable_controller() -> bool:
	if state_menu == "menu":
		return false
	return true
