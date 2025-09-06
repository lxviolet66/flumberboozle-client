extends Node
## Named "server" to match up with RPCs on server, more accurate name would be
## something more like "network" or "client"


@export_group("Scenes")
@export var PlayerScene: PackedScene

@export_group("Nodes")
@export var Playerlist: Node

var this_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()

var server_ip = "127.0.0.1"
var server_port = 24727

var MainMenu: Control
var IpEntry: LineEdit
var PortEntry: LineEdit
var ConnectButton: Button

var Player: RigidBody3D


func _ready() -> void:
	SignalBus.menu_loaded.connect(_on_menu_loaded)


func connect_to_server() -> void:
	# I have no idea why this is needed, but for some reason it seems that the
	# multiplayer signals get connected twice without checking if we're the
	# multiplayer authorityq
	if not is_multiplayer_authority():
		return
		
	var error: Error = this_peer.create_client(server_ip, server_port)
	if error != OK:
		push_error("Failed to create client with error code %s" % error)
	
	multiplayer.multiplayer_peer = this_peer
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)


func disconnect_from_server() -> void:
	pass
	# TODO: Implement functionality to disconnect, such that you can leave a
	# game then rejoin another without having to reopen the application


@rpc("authority", "call_remote", "reliable")
func add_player(peer_id) -> void:
	var ThisPlayer: CharacterBody3D = PlayerScene.instantiate()
	ThisPlayer.name = str(peer_id)
	ThisPlayer.set_multiplayer_authority(peer_id)
	Playerlist.add_child(ThisPlayer)


@rpc("authority", "call_remote", "reliable")
func add_existing_players(peer_ids: Array[int]) -> void:
	for id in peer_ids:
		add_player(id)


## Called on each peer once when they connect
@rpc("authority", "call_remote", "reliable")
func once_per_peer() -> void:
	print("Welcome to purgatory!\n")
	SignalBus.game_started.emit()


func _on_menu_loaded() -> void:
	MainMenu = Utils.find_node("MainMenu")
	IpEntry = Utils.find_node("IpEntry")
	PortEntry = Utils.find_node("PortEntry")
	ConnectButton = Utils.find_node("ConnectButton")
	ConnectButton.pressed.connect(_on_connect_button_pressed)


func _on_connect_button_pressed() -> void:
	if IpEntry.text != "":
		server_ip = IpEntry.text
	if PortEntry.text != "":
		server_port = PortEntry.text.to_int()
			
	connect_to_server()


func _on_connected_to_server() -> void:
	print("Reached server...\n")


func _on_connection_failed() -> void:
	print("Connection to server failed!\n")
