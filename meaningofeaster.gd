extends Node3D

class_name easteregghunt_resurect

@onready var label_3: TextEdit = $Label3

@export var easter_egg: int = 0
var port: int = 15780
const DEFAULT_SERVER_IP: String = "127.0.0.1" # IPv4 localhost
const MAX_CONNECTIONS: int = 20

static var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
@export var player_scene : PackedScene

func is_dedicated_server():
	var args = OS.get_cmdline_args()
	for arg in args:
		if arg == "--headless":
			return true
	return false

func _ready() -> void:
	if OS.has_feature("dedicated_server"):
		print("Started the server...")
		_on_host_pressed()
		$CanvasLayer/host.hide()
		$CanvasLayer/join.hide()
		$CanvasLayer/LineEdit.hide()
		%LineEdit2.hide()
		$Sprite3D38.hide()

func _physics_process(delta: float) -> void:
	if easter_egg >= 5:
		easter_egg = 5
	if easter_egg == 5:
		$Label.text = "Go to the top of the highest mountain"
		label_3.text = "Jesus died, rose, gave life."
	$Label2.text = str(easter_egg, "/5")
	if easter_egg == 1:
		label_3.text = "Jesus"
	if easter_egg == 2:
		label_3.text = "Jesus died"
	if easter_egg == 3:
		label_3.text = "Jesus died, rose "
	if easter_egg == 4:
		label_3.text = "Jesus died, rose, gave"
	

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
	label_3.show()
	$Area3D.hide()
	$Area3D/CollisionShape3D.set_deferred("disabled", true)
	easter_egg += 1


func _on_area_3d_2_body_entered(body: player) -> void:
	label_3.show()
	$Area3D2.hide()
	$Area3D2/CollisionShape3D.set_deferred("disabled", true)
	easter_egg += 1


func _on_area_3d_3_body_entered(body: player) -> void:
	label_3.show()
	$Area3D3.hide()
	$Area3D3/CollisionShape3D.set_deferred("disabled", true)
	easter_egg += 1
	


func _on_area_3d_4_body_entered(body: player) -> void:
	label_3.show()
	$Area3D4.hide()
	$Area3D4/CollisionShape3D.set_deferred("disabled", true)
	easter_egg += 1


func _on_area_3d_5_body_entered(body: player) -> void:
	label_3.show()
	$Area3D5.hide()
	$Area3D5/CollisionShape3D.set_deferred("disabled", true)
	easter_egg += 1


func _on_area_3d_6_body_entered(body: Node3D) -> void:
	if easter_egg == 5 or easter_egg >= 5:
		Input.action_press("quit")
