extends Node3D

class_name easteregghunt

var port: int = 15780
const DEFAULT_SERVER_IP: String = "127.0.0.1" # IPv4 localhost
const MAX_CONNECTIONS: int = 3

static var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
@export var player_scene : PackedScene



func _on_host_pressed() -> void:
	
	peer.create_server(port, MAX_CONNECTIONS)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(add_player)
	add_player()
	multiplayer.get_peers()
	
	$CanvasLayer/host.hide()
	$CanvasLayer/join.hide()
	$CanvasLayer/LineEdit.hide()
	%LineEdit2.hide()
	$Sprite3D38.hide()


func _on_join_pressed(address: String = str($CanvasLayer/LineEdit.text)) -> void:
	if address.is_empty() or address == "localhost":
		address = DEFAULT_SERVER_IP
	peer.create_client(address, int(%LineEdit2.text))
	multiplayer.multiplayer_peer = peer
	$CanvasLayer/host.hide()
	$CanvasLayer/join.hide()
	$CanvasLayer/LineEdit.hide()
	%LineEdit2.hide()
	$Sprite3D38.hide()
	

func add_player(id: int = 1) -> void:
	var player: CharacterBody3D = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child", player)
	

func exit_game(id: int) -> void:
	multiplayer.peer_disconnected.connect(del_player)
	del_player(id)


func del_player(id: int) -> void:
	rpc("_del_player" ,id)
	
@rpc("any_peer","call_local")
func  _del_player(id: int) -> void:
	get_node(str(id)).queue_free()
	

func _on_connected_fail() -> void:
	multiplayer.multiplayer_peer = null


func _on_area_3d_body_entered(body: player) -> void:
	body.label_3.show()
	body.label_3.text += "\nEaster egg 1:\nMatthew 21:9: And the crowds that went before him and that followed him were shouting, “Hosanna to the Son of David! Blessed is he who comes in the name of the Lord! Hosanna in the highest!”\nPoem:\nPalm branches wave, a joyful sound,\n'Hosanna!' echoes all around.\nThe King arrives, on humble beast,\nA blessing comes, from West to East."
	$Area3D.hide()
	$Area3D/CollisionShape3D.set_deferred("disabled", true)


func _on_area_3d_2_body_entered(body: player) -> void:
	body.label_3.show()
	body.label_3.text += "\nEaster egg 2:\nJohn 12:13: so they took branches of palm trees and went out to meet him, crying out, “Hosanna! Blessed is he who comes in the name of the Lord, even the King of Israel!”\nPoem:\nWith verdant fronds, they pave the way,\nFor Israel's King, this glorious day.\n'Hosanna!' rings, a heartfelt plea,\nFor the promised one, for all to see."
	$Area3D2.hide()
	$Area3D2/CollisionShape3D.set_deferred("disabled", true)


func _on_area_3d_3_body_entered(body: player) -> void:
	body.label_3.show()
	body.label_3.text += "\nEaster egg 3:\nMatthew 26:26: Now as they were eating, Jesus took bread, and after blessing it broke it and gave it to the disciples, and said, “Take, eat; this is my body.”\nPoem:\nThe loaf He held, a symbol true,\nMy body broken, given for you.\nA sacred meal, a love profound,\nWhere grace and sacrifice are found."
	$Area3D3.hide()
	$Area3D3/CollisionShape3D.set_deferred("disabled", true)
	
