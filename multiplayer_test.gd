extends Node2D

const SERVER_PORT = 8080
const SERVER_IP = "localhost"
var peer_ids = []

func become_host():
	print("Hello Host!")
	# Criação do servidor
	var server_peer = ENetMultiplayerPeer.new()
	server_peer.create_server(SERVER_PORT, 2)
	multiplayer.multiplayer_peer = server_peer
	
	add_player_to_the_game(1) 
	
	multiplayer.peer_connected.connect(
		func(new_peer_id):
			peer_ids.append(new_peer_id)
			rpc("add_player_to_the_game", new_peer_id)
			rpc_id(new_peer_id, "add_previously_connected_players", peer_ids)
			add_player_to_the_game(new_peer_id)
	)
	multiplayer.peer_disconnected.connect(remove_player_from_the_game)

func join():
	print("Hello Player!")
	
	var client_peer = ENetMultiplayerPeer.new()
	client_peer.create_client(SERVER_IP, SERVER_PORT)
	multiplayer.multiplayer_peer = client_peer
	
@rpc
func add_player_to_the_game(id: int):
	peer_ids.append(id)
	print("Player %d connected!" %id)
	var player_character = preload("res://player.tscn").instantiate()
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
