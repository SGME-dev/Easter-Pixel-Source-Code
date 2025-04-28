extends Node3D

class_name easteregghunt

@onready var label_3: TextEdit = $Label3

@export var easter_egg: int = 0
var port: int = 15780
const DEFAULT_SERVER_IP: String = "127.0.0.1" # IPv4 localhost
const MAX_CONNECTIONS: int = 3

static var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
@export var player_scene : PackedScene

func _physics_process(delta: float) -> void:
	if easter_egg == 12:
		$Label.text = "Go to the electricity sound!"
	$Label2.text = str(easter_egg, "/12")

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
	label_3.text += "\nEaster egg 1:\nMatthew 21:9: And the crowds that went before him and that followed him were shouting, “Hosanna to the Son of David! Blessed is he who comes in the name of the Lord! Hosanna in the highest!”\nPoem:\nPalm branches wave, a joyful sound,\n'Hosanna!' echoes all around.\nThe King arrives, on humble beast,\nA blessing comes, from West to East."
	$Area3D.hide()
	$Area3D/CollisionShape3D.set_deferred("disabled", true)
	easter_egg += 1


func _on_area_3d_2_body_entered(body: player) -> void:
	label_3.show()
	label_3.text += "\nEaster egg 2:\nJohn 12:13: so they took branches of palm trees and went out to meet him, crying out, “Hosanna! Blessed is he who comes in the name of the Lord, even the King of Israel!”\nPoem:\nWith verdant fronds, they pave the way,\nFor Israel's King, this glorious day.\n'Hosanna!' rings, a heartfelt plea,\nFor the promised one, for all to see."
	$Area3D2.hide()
	$Area3D2/CollisionShape3D.set_deferred("disabled", true)
	easter_egg += 1


func _on_area_3d_3_body_entered(body: player) -> void:
	label_3.show()
	label_3.text += "\nEaster egg 3:\nMatthew 26:26: Now as they were eating, Jesus took bread, and after blessing it broke it and gave it to the disciples, and said, “Take, eat; this is my body.”\nPoem:\nThe loaf He held, a symbol true,\nMy body broken, given for you.\nA sacred meal, a love profound,\nWhere grace and sacrifice are found."
	$Area3D3.hide()
	$Area3D3/CollisionShape3D.set_deferred("disabled", true)
	easter_egg += 1
	


func _on_area_3d_4_body_entered(body: player) -> void:
	label_3.show()
	label_3.text += "\nEaster egg 4:\nJohn 13:34: A new commandment I give to you, that you love one another: just as I have loved you, you also are to love one another.\nPoem:\nA bond He forged, with gentle plea,\nLove one another, even as Me.\nA testament of heart and hand,\nA love that all may understand."
	$Area3D4.hide()
	$Area3D4/CollisionShape3D.set_deferred("disabled", true)
	easter_egg += 1


func _on_area_3d_5_body_entered(body: player) -> void:
	label_3.show()
	label_3.text += "\nEaster egg 5:\nMatthew 26:39: And going a little farther he fell on his face and prayed, saying, “My Father, if it be possible, let this cup pass from me; nevertheless, not as I will, but as you will.”\nPoem:\nBeneath the olives, sorrow deep,\nA Father's will, His heart to keep.\nThe cup of suffering, bitter cost,\nYet Your will, not mine, though all seems lost."
	$Area3D5.hide()
	$Area3D5/CollisionShape3D.set_deferred("disabled", true)
	easter_egg += 1


func _on_area_3d_6_body_entered(body: player) -> void:
	label_3.show()
	label_3.text += "\nEaster egg 6:\nLuke 22:42: saying, “Father, if you are willing, remove this cup from me. Nevertheless, not my will, but yours, be done.”\nPoem:\nIn fervent prayer, He sought release,\nBut bowed His head to perfect peace.\nA humble spirit, strong and true,\nYour way, O Father, I pursue."
	$Area3D6.hide()
	$Area3D6/CollisionShape3D.set_deferred("disabled", true)
	easter_egg += 1


func _on_area_3d_7_body_entered(body: player) -> void:
	label_3.show()
	label_3.text += "\nEaster egg 7:\nMatthew 27:22: Pilate said to them, “Then what should I do with Jesus who is called Christ?” They all said, “Let him be crucified!”\nPoem:\nA question asked, a choice to make,\nBut cries of anger, hearts that break.\n'Crucify Him!' the voices roar,\nAnd darkness falls, forevermore."
	$Area3D7.hide()
	$Area3D7/CollisionShape3D.set_deferred("disabled", true)
	easter_egg += 1

func _on_area_3d_8_body_entered(body: player) -> void:
	label_3.show()
	label_3.text += "\nEaster egg 8:\nJohn 19:30: When Jesus had received the sour wine, he said, “It is finished,” and he bowed his head and gave up his spirit.\nPoem:\nThe bitter draught, His final taste,\nIt is finished, no time to waste.\nHe yields His breath, His earthly fight,\nAnd darkness claims the fading light."
	$Area3D8.hide()
	$Area3D8/CollisionShape3D.set_deferred("disabled", true)
	easter_egg += 1


func _on_area_3d_9_body_entered(body: player) -> void:
	label_3.show()
	label_3.text += "\nEaster egg 9:\nMatthew 28:5: But the angel said to the women, “Do not be afraid, for I know that you seek Jesus who was crucified.\nPoem:\nWith hearts of sorrow, they draw near,\nBut angel words dispel all fear.\n'He is not here,' the message bright,\nThe crucified, now filled with light."
	$Area3D9.hide()
	$Area3D9/CollisionShape3D.set_deferred("disabled", true)
	easter_egg += 1


func _on_area_3d_10_body_entered(body: player) -> void:
	label_3.show()
	label_3.text += "\nEaster egg 10:\nLuke 24:6: He is not here, but has risen.\nPoem:\nThe tomb is empty, stone aside,\nDeath's power broken, cast aside.\nA simple truth, a glorious claim,\nHe has arisen, praise His name!"
	$Area3D10.hide()
	$Area3D10/CollisionShape3D.set_deferred("disabled", true)
	easter_egg += 1


func _on_area_3d_11_body_entered(body: player) -> void:
	label_3.show()
	label_3.text += "\nEaster egg 11:\nLuke 24:15: As they talked and discussed these things with each other, Jesus himself came up and walked along with them; but they were kept from recognizing him.\nPoem:\nAlong the road, with heavy tread,\nThey spoke of loss, their hopes all dead.\nAnd Jesus walked, though eyes were dim,\nA stranger near, unknown to them."
	$Area3D11.hide()
	$Area3D11/CollisionShape3D.set_deferred("disabled", true)
	easter_egg += 1


func _on_area_3d_12_body_entered(body: player) -> void:
	label_3.show()
	label_3.text += "\nEaster egg 12:\nLuke 24:31: Then their eyes were opened and they recognized him, and he disappeared from their sight.\nPoem:\nThe bread He broke, a familiar sign,\nTheir opened eyes, a truth divine.\nThey knew Him then, their risen Lord,\nBefore He vanished at His word."
	$Area3D12.hide()
	$Area3D12/CollisionShape3D.set_deferred("disabled", true)
	easter_egg += 1


func _on_area_3d_13_body_entered(body: player) -> void:
	if easter_egg == 12:
		Input.action_press("quit")
	else:
		body.label_2.text = "Collect all 12 easter eggs!"
		body.label_2.show()
