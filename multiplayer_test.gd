extends Node2D

const SERVER_PORT = 8080
const SERVER_IP = "localhost"
var peer_ids = []

var new_scene = preload("res://stage1.tscn").instantiate()

func become_host():
	print("Hello Host!")
	# Criação do servidor
	var server_peer = ENetMultiplayerPeer.new()
	server_peer.create_server(SERVER_PORT, 2)
	multiplayer.multiplayer_peer = server_peer
	
	new_scene.add_player_to_the_game(1) 
	
	multiplayer.peer_connected.connect(
		func(new_peer_id):
			peer_ids.append(new_peer_id)
			rpc("add_player_to_the_game", new_peer_id)
			rpc_id(new_peer_id, "add_previously_connected_players", peer_ids)
			new_scene.add_player_to_the_game(new_peer_id)
	)
	multiplayer.peer_disconnected.connect(new_scene.remove_player_from_the_game)
	change_scene()
func join():
	print("Hello Player!")
	
	var client_peer = ENetMultiplayerPeer.new()
	var error = client_peer.create_client(SERVER_IP, SERVER_PORT)
	if error:
		return error
	multiplayer.multiplayer_peer = client_peer
	change_scene()
	
@rpc("call_local", "reliable")
func change_scene():
	get_tree().root.add_child(new_scene)
