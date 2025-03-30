extends Node3D

class_name lobby

@onready var world_environment: WorldEnvironment = $WorldEnvironment


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
	
	$StaticBody3D16/AnimationPlayer.play("move")
	$Narrorator/AudioStreamPlayer.play()
	
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
	$StaticBody3D16/AnimationPlayer.play("move")
	$AudioStreamPlayer.play()
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


func _on_area_3d_body_entered(body: AnimatableBody3D) -> void:
	if body.is_in_group("jesus_donkey"):
		body.hide()


func _on_area_3d2_body_entered(body: player) -> void:
	set_active_environment($WorldEnvironment2)
	$CanvasLayer/TextEdit.text = "Later, on the night, Jesus was having a passover meal with his disiples."
	$Narrorator/AudioStreamPlayer3.play()
	


func _on_area_3d_2_body_entered(body: player) -> void:
	body.global_position = $HTerrain.global_position
	$AnimatableBody3D86/AnimationPlayer.play("move")
	$CanvasLayer/TextEdit.text = "Jesus went to a garden to pray."
	$Narrorator/AudioStreamPlayer5.play()
	


func _on_area_3d_3_body_entered(body: player) -> void:
	body.global_position = $Sprite3D30.global_position
	$CanvasLayer/TextEdit.text = "The pharisies and sadusees asked Jesus alot of questions. They did not care what jesus said, they blamed jesus of blaspymy because he said he was the son of god."
	$Narrorator/AudioStreamPlayer7.play()


func _on_area_3d_4_body_entered(body: player) -> void:
	body.global_position = $StaticBody3D41.global_position
	$AnimatableBody3D105/AnimationPlayer.play("move")
	$CanvasLayer/TextEdit.text = "After that, The pharisies and sadusees sent Jesus to a roman goverer called ponchious pilate. He said 'Jesus did nothing worng', but The pharisies and sadusees kept shouting"
	$Narrorator/AudioStreamPlayer8.play()


func _on_area_3d_5_body_entered(body: player) -> void:
	body.global_position = $HTerrain2.global_position
	crusifiction()
	$CanvasLayer/TextEdit.text = "So Jesus got beaten up and had to carry his cross to the hill. "
	$Narrorator/AudioStreamPlayer10.play()

func crusifiction():
	$AnimatableBody3D111/AnimatableBody3D.play("move")
	$StaticBody3D46/AnimationPlayer.play("move")
	


func _on_area_3d_6_body_entered(body: player) -> void:
	body.global_position = $StaticBody3D47/Marker3D.global_position
	$StaticBody3D53/AnimationPlayer.play("move")
	$AnimatableBody3D113/AnimationPlayer.play("move")
	$AnimatableBody3D112/AnimationPlayer.play("move")
	$AnimatableBody3D114/AnimationPlayer.play("move")
	$AnimatableBody3D117/AnimationPlayer.play("move")
	$CanvasLayer/TextEdit.text = "Joseph loved jesus so much that he gave his tomb to Jesus. Ponchious Pilate put Guards to guard the tomb."
	$Narrorator/AudioStreamPlayer12.play()


func _on_animation_player_animation_finished(anim_name: StringName = "move") -> void:
	$AnimatableBody3D113.hide()


func _on_animation2_player_animation_finished(anim_name: StringName) -> void:
	$AnimatableBody3D112.hide()


func _on_animation3_player_animation_finished(anim_name: StringName) -> void:
	$AnimatableBody3D115.show()
	$AnimatableBody3D116.show()


func _on_area_3d_7_body_entered(body: player) -> void:
	body.global_position = $StaticBody3D54.global_position
	$AnimatableBody3D118/AnimationPlayer2.play("move")
	$AnimatableBody3D119/AnimationPlayer2.play("move")
	set_active_environment($WorldEnvironment)
	$CanvasLayer/TextEdit.text = "The girls was rushing to tell the disiples that Jesus was alive, But then Jesus appered and said 'Dont be afraid.'"
	$Narrorator/AudioStreamPlayer14.play()

func set_active_environment(environment: WorldEnvironment):
	# Set the provided environment as the active environment
	get_viewport().world_3d.environment = environment.environment


func _on_area_3d_8_body_entered(body: AnimatableBody3D) -> void:
	set_active_environment($WorldEnvironment2)
	if body.is_in_group("jesus_emmaus"):
		$AnimatableBody3D121.hide()
		$AnimatableBody3D122.hide()
		$AnimatableBody3D123.hide()
	
	


func _on_area_3d_9_body_entered(body: player) -> void:
	body.global_position = $StaticBody3D56/MeshInstance3D2.global_position
	$AnimatableBody3D122/AnimationPlayer.play("move")
	$AnimatableBody3D123/AnimationPlayer.play("move")
	$AnimatableBody3D121/AnimationPlayer.play("move")
	$CanvasLayer/TextEdit.text = "Later two disiples called simon and cleaopas were walking to a village called emmaus. Jesus came and said 'What are you talking about?', Cleaopas said what happened to Jesus but they did not reconise its Jesus."
	$Narrorator/AudioStreamPlayer15.play()


func _on_area_3d2_8_body_entered(body: player) -> void:
	$AnimatableBody3D126/AnimationPlayer.play("break_bread")
	$CanvasLayer/TextEdit.text = "When Jesus blessed them by breaking the bread in emmaus and giving it to them, they reconised Jesus, then Jesus vanished"
	$Narrorator/AudioStreamPlayer17.play()


func _on_area_3d_10_body_entered(body: Node3D) -> void:
	body.global_position = $StaticBody3D67.global_position
	set_active_environment($WorldEnvironment)
	$AnimatableBody3D137/AnimationPlayer.play("run")
	$AnimatableBody3D138/AnimationPlayer.play("run")
	$CanvasLayer/TextEdit.text = "Then they rushed to the other 10 disiples to tell that Jesus was alive!"
	$Narrorator/AudioStreamPlayer18.play()


func _on_area_3d_11_body_entered(body: player) -> void:
	body.global_position = $StaticBody3D73.global_position
	$AnimatableBody3D150/AnimationPlayer.play("rise_to_heaven")
	$CanvasLayer/TextEdit.text = "Then the disiples saw that Jesus was alive, Jesus went up and up to heaven! THE END"
	$Narrorator/AudioStreamPlayer19.play()


func _on_area_3d_12_body_entered(body: player) -> void:
	Input.action_press("quit")
	


func _on_next_pressed() -> void:
	
	var timer = Timer.new()
	
	if $CanvasLayer/TextEdit.text == "Jesus and his disiples entered jurluselem. ":
		$CanvasLayer/TextEdit.text = "When Jesus entered, people was waving palm branches and said 'Hosanna, Hosanna, Hosanna in the name of the Lord'"
		$Narrorator/AudioStreamPlayer2.play()
		
			
	if $CanvasLayer/TextEdit.text == "Later, on the night, Jesus was having a passover meal with his disiples.":
		$CanvasLayer/TextEdit.text = "Jesus said 'One of you is going to betray me', Jesus' disiples wanted to know who could it be?. Jesus gave the bread to the one who was going to betray him"
		$Narrorator/AudioStreamPlayer4.play()
		
	
	if $CanvasLayer/TextEdit.text == "Jesus went to a garden to pray.":
		$CanvasLayer/TextEdit.text = "After Jesus finished praying , Judas(One of Jesus' disiples) Led the pharisies and sadusees to Jesus. The pharisies and sadusees arrested Jesus."
		$Narrorator/AudioStreamPlayer6.play()
	if $CanvasLayer/TextEdit.text == "After that, The pharisies and sadusees sent Jesus to a roman goverer called ponchious pilate. He said 'Jesus did nothing worng', but The pharisies and sadusees kept shouting":
		$CanvasLayer/TextEdit.text = "So he sent Jesus to be crusified on a cross."
		$Narrorator/AudioStreamPlayer9.play()
	if $CanvasLayer/TextEdit.text == "So Jesus got beaten up and had to carry his cross to the hill. ":
		$CanvasLayer/TextEdit.text = "Jesus went on the cross and they nailed him on the cross. Jesus said 'Please fogive them, they dont know what they are doing'"
		$Narrorator/AudioStreamPlayer11.play()
	if $CanvasLayer/TextEdit.text == "Joseph loved jesus so much that he gave his tomb to Jesus. Ponchious Pilate put Guards to guard the tomb.":
		$CanvasLayer/TextEdit.text = "Two of two Jesus' friends who were girls came to put spices on Jesus, but they saw that Jesus was gone and the Guards were laying down. An angel said 'Dont worry, Jesus has ressurected from the dead.'"
		$Narrorator/AudioStreamPlayer13.play()
	if $CanvasLayer/TextEdit.text == "Later two disiples called simon and cleaopas were walking to a village called emmaus. Jesus came and said 'What are you talking about?', Cleaopas said what happened to Jesus but they did not reconise its Jesus.":
		$CanvasLayer/TextEdit.text = "Jesus said 'You foolish! Havent you heard what the scriptures said,' and when they were nealy there Jesus went another way so they begged him to come because it was nearly night time."
		$Narrorator/AudioStreamPlayer16.play()





func _on_area_3d_13_body_entered(body: player) -> void:
	body.global_position = $StaticBody3D23/Marker3D.global_position
	print(1 + 2 + 3 + 4 + 5 + 6 + 7 + 8 + 9 + 10 + 11 + 12 + 13 + 14 + 15 + 16 + 17 + 18 + 19 + 20 + 21 + 22 + 23 + 24 + 25 + 26 + 27 + 28 + 29 + 30 + 31 + 32 + 33 + 34 + 35 + 36 + 37 + 38 + 39 + 40 + 41 + 42 + 43 + 44 + 45 + 46 + 47 + 48 + 49 + 50)


func _on_area_3d_14_body_entered(body: player) -> void:
	body.global_position = Vector3(0, 0, 0)
