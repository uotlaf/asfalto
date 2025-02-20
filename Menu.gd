extends MenuBar

const SERVER_PORT = 8080
const SERVER_IP = "localhost"
const SERVER_ID = 1;
var peers = {}
var my_character: Area2D

func become_host() -> void:
	$host.hide()
	$join.hide()
	$server_ip.hide()
	$player_name.hide()
	$chat.visible = true
	
	print("Hello Host!")
	# Criação do servidor
	var server_peer = ENetMultiplayerPeer.new()
	server_peer.create_server(SERVER_PORT, 2)
	multiplayer.multiplayer_peer = server_peer
	var server_name = $player_name.text
	# Criando o jogador do host
	add_player_to_the_game(SERVER_ID, server_name) 
	# sinais de conexão e desconexão
	multiplayer.peer_connected.connect(  
		func(new_peer_id):
			add_previously_connected_players.rpc_id(new_peer_id, peers)
	)
	multiplayer.peer_disconnected.connect(
		func(disconnected_player_id):
			remove_player_from_the_game.rpc(disconnected_player_id)
	)

func join() -> void:
	$host.hide()
	$join.hide()
	$server_ip.hide()
	$player_name.hide()
	$chat.visible = true
	
	print("Hello Player!")
	# Criação do cliente
	var client_peer = ENetMultiplayerPeer.new()
	client_peer.create_client(SERVER_IP, SERVER_PORT)
	multiplayer.multiplayer_peer = client_peer
	await multiplayer.connected_to_server
	# Criando jogador pro novo player e pros players já online
	var my_id = multiplayer.get_unique_id()
	var my_name = $player_name.text
	rpc("add_player_to_the_game", my_id, my_name)
	
@rpc("any_peer", "call_local")
func add_player_to_the_game(id, name) -> void:
	peers[id] = name
	print("Player %d connected!" %id)
	var player_character = preload("res://entities/player.tscn").instantiate()
	player_character.set_multiplayer_authority(id)
	player_character.set_Label(name)
	
	if id == multiplayer.get_unique_id(): # É o próprio player que foi adicionado
		my_character = player_character

	add_child(player_character,true)

@rpc()
func add_previously_connected_players(remote_peers: Dictionary) -> void:
	for id in remote_peers.keys():
		if id != multiplayer.get_unique_id():
			print("Player %s drawn " % id)
			add_player_to_the_game(id, remote_peers[id])

@rpc("call_local")
func remove_player_from_the_game(id: int) -> void:
	print("Player %s disconnected!" %id)
	peers.erase(id);
	var player = get_player_by_id(id)
	if (player != null):
		player.queue_free()

func get_player_by_id(id: int) -> Area2D:
	for player in get_children():
		if player.get_multiplayer_authority() == id: # Se o id é daquele jogador
			return player
	return null

func _on_chat_text_submitted(msg: String) -> void:
	my_character.rpc("display_message", msg)
	$chat.text = ""
