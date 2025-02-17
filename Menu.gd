extends MenuBar

const SERVER_PORT = 8080
const SERVER_IP = "localhost"
var peers = {}

func become_host():
	print("Hello Host!")
	# Criação do servidor
	#await get_tree().change_scene_to_file("res://lobby.tscn")
	var server_peer = ENetMultiplayerPeer.new()
	server_peer.create_server(SERVER_PORT, 2)
	multiplayer.multiplayer_peer = server_peer
	
	
	add_player_to_the_game(1, $player_name.text) 
	
	multiplayer.peer_connected.connect(
		func(new_peer_id):
			rpc_id(new_peer_id, "add_previously_connected_players", peers)
	)
	multiplayer.peer_disconnected.connect(
		func(disconnected_player_id):
			rpc("remove_player_from_the_game", disconnected_player_id)
	)

func join():
	print("Hello Player!")
	get_children()
	var client_peer = ENetMultiplayerPeer.new()
	client_peer.create_client(SERVER_IP, SERVER_PORT)
	multiplayer.multiplayer_peer = client_peer
	await multiplayer.connected_to_server
	
	#get_tree().change_scene_to_file("res://lobby.tscn")
	rpc("add_player_to_the_game", multiplayer.get_unique_id(), $player_name.text)
	
@rpc("any_peer", "call_local")
func add_player_to_the_game(id, name):
	peers[id] = name
	print("Player %d connected!" %id)
	var player_character = preload("res://player.tscn").instantiate()
	player_character.set_multiplayer_authority(id)
	player_character.get_node("Label").text = name
	
	if id == 1: #player é o host
		player_character.is_host = true
	else:
		player_character.is_host = false
	add_child(player_character,true)

@rpc()
func add_previously_connected_players(remote_peers: Dictionary):
	for id in remote_peers.keys():
		if id != multiplayer.get_unique_id():
			print("Player %s drawn" % id)
			add_player_to_the_game(id, remote_peers[id])

@rpc("call_local")
func remove_player_from_the_game(id: int):
	print("Player %s disconnected!" %id)
	peers.erase(id);
	
	for player in get_children():
		if player.get_multiplayer_authority() == id: # Se o id é daquele jogador
			player.queue_free() # Remove ele da cena
