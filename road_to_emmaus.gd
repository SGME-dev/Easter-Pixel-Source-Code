extends Node3D

class_name road_to_emmaus

@onready var world_environment: WorldEnvironment = $WorldEnvironment

var actual_port: int = 15780
var port: int = 15780
const DEFAULT_SERVER_IP: String = "127.0.0.1" # IPv4 localhost
const MAX_CONNECTIONS: int = 20

static var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
@export var player_scene : PackedScene
var tar = false
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
	
	


func _on_join_pressed(address: String = str($CanvasLayer/LineEdit.text), port: int = int(%LineEdit2.text)) -> void:
	if address.is_empty() or address == "localhost":
		address = DEFAULT_SERVER_IP
	if %LineEdit2.text.is_empty():
		port = actual_port
	peer.create_client(address, port)
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



func set_active_environment(environment: WorldEnvironment):
	# Set the provided environment as the active environment
	get_viewport().world_3d.environment = environment.environment


func _on_next_pressed() -> void:
	$AnimatableBody3D121/speech.show()
	$AnimatableBody3D122/speech.hide()
	$CanvasLayer/Next.hide()
	$CanvasLayer/Next2.show()


func _on_next_2_pressed() -> void:
	$AnimatableBody3D121/speech.hide()
	$AnimatableBody3D122/speech2.show()
	$CanvasLayer/Next2.hide()
	$CanvasLayer/Next3.show()


func _on_next_3_pressed() -> void:
	$AnimatableBody3D122/speech2.hide()
	$AnimatableBody3D121/speech2.show()
	$CanvasLayer/Next3.hide()
	$CanvasLayer/Next4.show()


func _on_next_4_pressed() -> void:
	$AnimatableBody3D123.show()
	$AnimatableBody3D123/AnimationPlayer.play("move")
	$AnimatableBody3D121/speech2.hide()
	$AnimatableBody3D123/speech.show()
	$CanvasLayer/Next4.hide()
	$CanvasLayer/Next5.show()


func _on_next_5_pressed() -> void:
	
	
	$AnimatableBody3D123/speech.hide()
	$AnimatableBody3D122/speech3.show()
	$CanvasLayer/Next5.hide()
	$CanvasLayer/Next6.show()


func _on_next_6_pressed() -> void:
	$AnimatableBody3D122/speech3.hide()
	$AnimatableBody3D123/speech2.show()
	$CanvasLayer/Next6.hide()
	$CanvasLayer/Next7.show()


func _on_next_7_pressed() -> void:
	$AnimatableBody3D123/speech2.hide()
	$AnimatableBody3D121/speech3.show()
	$CanvasLayer/Next7.hide()
	$CanvasLayer/Next8.show()


func _on_next_8_pressed() -> void:
	$AnimatableBody3D121/speech3.hide()
	$AnimatableBody3D122/speech4.show()
	$CanvasLayer/Next8.hide()
	$CanvasLayer/Next9.show()



func _on_next_9_pressed() -> void:
	$AnimatableBody3D122/speech4.hide()
	$AnimatableBody3D121/speech4.show()
	$CanvasLayer/Next9.hide()
	$CanvasLayer/Next10.show()


func _on_next_10_pressed() -> void:
	$AnimatableBody3D121/speech4.hide()
	$AnimatableBody3D122/speech5.show()
	$CanvasLayer/Next10.hide()
	$CanvasLayer/Next11.show()


func _on_next_11_pressed() -> void:
	$AnimatableBody3D122/speech5.hide()
	$AnimatableBody3D121/speech5.show()
	$CanvasLayer/Next11.hide()
	$CanvasLayer/Next12.show()


func _on_next_12_pressed() -> void:
	$AnimatableBody3D121/speech5.hide()
	$AnimatableBody3D123/speech3.show()
	$CanvasLayer/Next12.hide()
	$CanvasLayer/Next13.show()


func _on_next_13_pressed() -> void:
	set_active_environment($WorldEnvironment2)
	$Sprite3D.show()
	$AnimatableBody3D123/speech3.hide()
	$AnimatableBody3D122/speech6.show()
	$CanvasLayer/Next13.hide()
	$CanvasLayer/Next14.show()


func _on_next_14_pressed() -> void:
	
	$AnimatableBody3D122/speech6.hide()
	$AnimatableBody3D121/speech6.show()
	$CanvasLayer/Next14.hide()
	$CanvasLayer/Next15.show()


func _on_next_15_pressed() -> void:
	$AnimatableBody3D121/speech6.hide()
	$AnimatableBody3D123/speech4.show()
	$CanvasLayer/Next15.hide()
	$CanvasLayer/Next16.show()
	$StaticBody3D/CollisionShape3D.set_deferred("disabled", true)
	$StaticBody3D/CollisionShape3D2.set_deferred("disabled", true)
	$StaticBody3D/CollisionShape3D3.set_deferred("disabled", true)
	$StaticBody3D/CollisionShape3D4.set_deferred("disabled", true)
	$StaticBody3D/CollisionShape3D5.set_deferred("disabled", true)
	$StaticBody3D/Sprite3D.show()
	$StaticBody3D/Sprite3D2.show()
	$StaticBody3D/Sprite3D3.show()
	$StaticBody3D/Sprite3D4.show()
	$CanvasLayer/TextEdit.show()


func _on_next_16_pressed() -> void:
	if tar == true:
		$AnimatableBody3D126/AnimationPlayer.play("move")
		$CanvasLayer/Next16.hide()
		$CanvasLayer/Next17.show()


func _on_area_3d_body_entered(body: player) -> void:
	body.global_position = $StaticBody3D61.global_position


func _on_next_17_pressed() -> void:
	Input.action_press("quit")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	$AnimatableBody3D126.hide()
	$AnimatableBody3D125/Sprite3D2.show()
	$AnimatableBody3D125/Sprite3D.hide()
	$AnimatableBody3D124/Sprite3D.hide()
	$AnimatableBody3D124/Sprite3D2.show()


func _on_area_3d_2_body_entered(body: player) -> void:
	tar = true


func _on_button_pressed() -> void:
	$CanvasLayer/TextEdit/Label.text = "Right"
	$CanvasLayer/TextEdit/Timer.start()


func _on_button_2_pressed() -> void:
	$CanvasLayer/TextEdit/Label.text = "WROUNG"
	$CanvasLayer/TextEdit/Timer.start()


func _on_timer_timeout() -> void:
	$CanvasLayer/TextEdit.hide()
