extends ItemData
class_name CreatureData

#@export var name:String = "Dummy Creature"

#@export var health:float = 100.0
#@export var health_max:float = 100.0
#@export var attack:float = 100.0
#@export var defense:float = 100.0
#@export var is_own:bool = false
@export var is_empty:bool = true
@export var is_summon:bool = false
#@export var team_id:int = 0
@export var pack_scene:PackedScene # creature
@export var creature_data_info:CreatureDataInfo #stats
