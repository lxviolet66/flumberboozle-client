extends Node


var network: ENetMultiplayerPeer = ENetMultiplayerPeer.new()

var server_ip = "127.0.0.1"
var server_port = 24727

@onready var IpEntry: LineEdit = Global.find_node("IpEntry")
@onready var PortEntry: LineEdit = Global.find_node("PortEntry")
@onready var ConnectButton: Button = Global.find_node("ConnectButton")
@onready var Players: Node = Global.find_node("Players")
@onready var PlayerScene: PackedScene = preload("res://scenes/test_player.tscn")


func _ready() -> void:
	ConnectButton.pressed.connect(_on_connect_button_pressed)
	
	
func connect_to_server() -> void:
	var error: Error = network.create_client(server_ip, server_port)
	if error != OK:
		push_error("Failed to create client with error code %s" % error)
	
	multiplayer.multiplayer_peer = network
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)


func disconnect_from_server() -> void:
	pass
	# TODO: Implement functionality to disconnect, such that you can leave a
	# game then rejoin another without having to reopen the application


func add_player(peer_id: int):
	var new_player = PlayerScene.instantiate()
	new_player.name = str(peer_id)
	Players.add_child(new_player, true)
	
	
func remove_player(peer_id: int):
	if not Players.has_node(str(peer_id)):
		return
		
	Players.get_node(str(peer_id)).queue_free()


@rpc("authority", "call_remote", "reliable")
func populate_players(peer_ids: Array[int]) -> void:
	for peer_id in peer_ids:
		add_player(peer_id)


@rpc("authority", "call_remote", "reliable")
func once_per_peer() -> void:
	print("Welcome to Purgatory!")


func _on_connect_button_pressed() -> void:
	if IpEntry.text != "":
		server_ip = IpEntry.text
	if PortEntry.text != "":
		server_port = PortEntry.text.to_int()
			
	connect_to_server()


func _on_connected_to_server() -> void:
	print("Connected to server")


func _on_connection_failed() -> void:
	print("Connection to server failed")
