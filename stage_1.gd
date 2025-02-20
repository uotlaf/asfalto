extends Node

var peer_ids = []
@export var mob_scene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if is_multiplayer_authority():
		$MobSpawner.start()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


@rpc
func add_player_to_the_game(id: int):
	peer_ids.append(id)
	print("Player %d connected!" %id)
	var player_character = preload("res://entities/player.tscn").instantiate()
	player_character.set_multiplayer_authority(id)
	
	if id == 1: #player é o host
		player_character.is_host = true
	else:
		player_character.is_host = false
	add_child(player_character,true)

@rpc
func add_previously_connected_players(peers):
	for id in peers:
		if id != multiplayer.get_unique_id() and id not in peer_ids:
			print("Player %s drawn" % id)
			add_player_to_the_game(id)

func remove_player_from_the_game(id: int):
	print("Player %s disconnected!" %id)

@rpc("authority")
func get_new_position():
	var spawn_location = $MobPath/MobSpawnLocation
	spawn_location.progress_ratio = randf()
	rpc("spawn_new_mob", spawn_location.position)

@rpc("any_peer", "call_local", "reliable")
func spawn_new_mob(position):
	var new_mob = mob_scene.instantiate()
	new_mob.position = position
	add_child(new_mob)

func _on_mob_spawner_timeout() -> void:
	rpc("get_new_position")
