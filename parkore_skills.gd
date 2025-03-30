extends Node3D

class_name lobby_bible_verses

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
	body.label.text += "\nMatthew 21:9: 'And the crowds that went before him and that followed him were shouting, 'Hosanna to the Son of David! Blessed is he who comes in the name of the Lord! Hosanna in the highest!''"
	body.label.show()
	$Area3D/CollisionShape3D.set_deferred("disabled", true)
	$Area3D.hide()
	body.Area3d = $Area3D


func _on_area_3d_2_body_entered(body: player) -> void:
	body.label.text += "\nMark 11:9: And those who went before and those who followed were shouting, 'Hosanna! Blessed is he who comes in the name of the Lord!'"
	$Area3D2/CollisionShape3D.set_deferred("disabled", true)
	$Area3D2.hide()
	body.Area3d = $Area3D2

func _on_area_3d_3_body_entered(body: Node3D) -> void:
	body.label.text += "\nMark 11:10: 'Blessed is the kingdom of our father David that is coming! Hosanna in the highest!'"
	$Area3D3/CollisionShape3D.set_deferred("disabled", true)
	$Area3D3.hide()
	body.Area3d = $Area3D3

func _on_area_3d_4_body_entered(body: Node3D) -> void:
	body.label.text += "\nLuke 19:38: saying, “Blessed is the King who comes in the name of the Lord! Peace in heaven and glory in the highest!”"
	$Area3D4/CollisionShape3D.set_deferred("disabled", true)
	$Area3D4.hide()
	body.Area3d = $Area3D4

func _on_area_3d_5_body_entered(body: Node3D) -> void:
	body.label.text += "\nJohn 12:13: so they took branches of palm trees and went out to meet him, crying out, “Hosanna! Blessed is he who comes in the name of the Lord, even the King of Israel!”"
	$Area3D5/CollisionShape3D.set_deferred("disabled", true)
	$Area3D5.hide()
	body.Area3d = $Area3D5

func _on_area_3d_6_body_entered(body: Node3D) -> void:
	body.label.text += "\nMatthew 26:26: Now as they were eating, Jesus took bread, and after blessing it broke it and gave it to the disciples, and said, “Take, eat; this is my body.”"
	$Area3D6/CollisionShape3D.set_deferred("disabled", true)
	$Area3D6.hide()
	body.Area3d = $Area3D6

func _on_area_3d_7_body_entered(body: Node3D) -> void:
	body.label.text += "\nMatthew 26:27: And he took a cup, and when he had given thanks he gave it to them, saying, “Drink of it, all of you,"
	$Area3D7/CollisionShape3D.set_deferred("disabled", true)
	$Area3D7.hide()
	body.Area3d = $Area3D7

func _on_area_3d_8_body_entered(body: Node3D) -> void:
	body.label.text += "\nMatthew 26:28: for this is my blood of the covenant, which is poured out for many for the forgiveness of sins.”"
	$Area3D8/CollisionShape3D.set_deferred("disabled", true)
	$Area3D8.hide()
	body.Area3d = $Area3D8

func _on_area_3d_9_body_entered(body: Node3D) -> void:
	body.label.text += "\nLuke 22:19: And he took bread, and when he had given thanks, he broke it and gave it to them, saying, “This is my body, which is given for you. Do this in remembrance of me.”"  
	$Area3D9/CollisionShape3D.set_deferred("disabled", true)
	$Area3D9.hide()
	body.Area3d = $Area3D9

func _on_area_3d_10_body_entered(body: Node3D) -> void:
	body.label.text += "\nLuke 22:20: And likewise the cup after they had eaten, saying, “This cup that is poured out for you is the new covenant in my blood, which is poured out for you."
	$Area3D10/CollisionShape3D.set_deferred("disabled", true)
	$Area3D10.hide()
	body.Area3d = $Area3D10

func _on_area_3d_11_body_entered(body: Node3D) -> void:
	body.label.text += "\nJohn 13:34: A new commandment I give to you, that you love one another: just as I have loved you, you also are to love one another." 
	$Area3D11/CollisionShape3D.set_deferred("disabled", true)
	$Area3D11.hide()
	body.Area3d = $Area3D11

func _on_area_3d_12_body_entered(body: Node3D) -> void:
	body.label.text += "\nJohn 13:35: By this all people will know that you are my disciples, if you have love for one another.”"
	$Area3D12/CollisionShape3D.set_deferred("disabled", true)
	$Area3D12.hide()
	body.Area3d = $Area3D12

func _on_laser_3d_body_entered(body: player) -> void:
	body.global_position = Vector3(0, 0, 0)


func _on_area_3d_13_body_entered(body: Node3D) -> void:
	body.label.text += "\n Matthew 26:39: And going a little farther he fell on his face and prayed, saying, “My Father, if it be possible, let this cup pass from me; nevertheless, not as I will, but as you will.”"  
	$Area3D13/CollisionShape3D.set_deferred("disabled", true)
	$Area3D13.hide()
	body.Area3d = $Area3D13

func _on_area_3d_14_body_entered(body: Node3D) -> void:
	body.label.text += "\nMark 14:36: And he said, “Abba, Father, all things are possible for you. Remove this cup from me. Yet not what I will, but what you will.”"  
	$Area3D14/CollisionShape3D.set_deferred("disabled", true)
	$Area3D14.hide()
	body.Area3d = $Area3D14

func _on_area_3d_15_body_entered(body: Node3D) -> void:
	body.label.text += "\nLuke 22:42: saying, “Father, if you are willing, remove this cup from me. Nevertheless, not my will, but yours, be done.”"
	$Area3D15/CollisionShape3D.set_deferred("disabled", true)
	$Area3D15.hide()
	body.Area3d = $Area3D15

func _on_area_3d_16_body_entered(body: Node3D) -> void:
	body.label.text += "\nJohn 18:11: So Jesus said to Peter, “Put your sword into its sheath; shall I not drink the cup that the Father has given me?”"  
	$Area3D16/CollisionShape3D.set_deferred("disabled", true)
	$Area3D16.hide()
	body.Area3d = $Area3D16

func _on_area_3d_17_body_entered(body: Node3D) -> void:
	body.label.text += "\nMatthew 27:22: Pilate said to them, “Then what should I do with Jesus who is called Christ?” They all said, “Let him be crucified!”"
	$Area3D17/CollisionShape3D.set_deferred("disabled", true)
	$Area3D17.hide()
	body.Area3d = $Area3D17

func _on_area_3d_18_body_entered(body: Node3D) -> void:
	body.label.text += "\nMatthew 27:23: And he said, “Why? What evil has he done?” But they shouted all the more, “Let him be crucified!”"
	$Area3D18/CollisionShape3D.set_deferred("disabled", true)
	$Area3D18.hide()
	body.Area3d = $Area3D18

func _on_area_3d_19_body_entered(body: Node3D) -> void:
	body.label.text += "\nMark 15:25: And it was the third hour when they crucified him."
	$Area3D19/CollisionShape3D.set_deferred("disabled", true)
	$Area3D19.hide()
	body.Area3d = $Area3D19


func _on_area_3d_20_body_entered(body: Node3D) -> void:
	body.label.text += "\nLuke 23:34: And Jesus said, “Father, forgive them, for they know not what they do.” And they cast lots to divide his garments." 
	$Area3D20/CollisionShape3D.set_deferred("disabled", true)
	$Area3D20.hide()
	body.Area3d = $Area3D20

func _on_area_3d_21_body_entered(body: Node3D) -> void:
	body.label.text += "\nJohn 19:30: When Jesus had received the sour wine, he said, “It is finished,” and he bowed his head and gave up his spirit."  
	$Area3D21/CollisionShape3D.set_deferred("disabled", true)
	$Area3D21.hide()
	body.Area3d = $Area3D21

func _on_area_3d_22_body_entered(body: Node3D) -> void:
	body.label.text += "\nMatthew 28:5: But the angel said to the women, Do not be afraid, for I know that you seek Jesus who was crucified.\nMatthew 28:6: He is not here, for he has risen, as he said. Come, see the place where he lay.\nMark 16:6: And he said to them, Do not be alarmed. You seek Jesus of Nazareth, who was crucified. He has risen; he is not here. See the place where they laid him.\nLuke 24:6: He is not here, but has risen.\nLuke 24:7: Remember how he told you, while he was still in Galilee, that the Son of Man must be delivered into the hands of sinful men and be crucified and on the third day rise.\nJohn 20:17: Jesus said to her, Do not cling to me, for I have not yet ascended to the Father; but go to my brothers and say to them, ‘I am ascending to my Father and your Father, to my God and your God.’\nLuke 24:13: Now that same day two of them were going to a village called Emmaus, about seven miles from Jerusalem.\nLuke 24:14: They were talking with each other about everything that had happened.\nLuke 24:15: As they talked and discussed these things with each other, Jesus himself came up and walked along with them; but they were kept from recognizing him.\nLuke 24:16: He asked them, “What are you discussing together as you walk along?”\nLuke 24:17: They stood still, their faces downcast. One of them, named Cleopas, asked him, “Are you the only one visiting Jerusalem who does not know the things that have happened there in these days?”\nLuke 24:18: “What things?” he asked.\nLuke 24:19: “About Jesus of Nazareth,” they replied. “He was a powerful prophet, powerful in word and deed before God and all the people. The chief priests and our rulers handed him over to be sentenced to death, and they crucified him;\nLuke 24:20: but we had hoped that he was the one who was going to redeem Israel. And what is more, it is now the third day since all this took place.\nLuke 24:21: In addition, some of our women amazed us. They went to the tomb early this morning but didn’t find his body. They came and told us that they had seen a vision of angels, who said he was alive.\nLuke 24:22: Then some of our companions went to the tomb and found it just as the women had said, but they did not see Jesus.”\nLuke 24:23: He said to them, “How foolish you are, and how slow to believe all that the prophets have spoken! Did not the Messiah have to suffer these things and then enter his glory?”\nLuke 24:24: And beginning with Moses and all the Prophets, he explained to them what was said in all the Scriptures concerning himself.\nLuke 24:25: As they approached the village to which they were going, Jesus continued on as if he were going farther.\nLuke 24:26: But they urged him strongly, “Stay with us, for it is nearly evening; the day is almost over.” So he went in to stay with them.\nLuke 24:27: When he was at the table with them, he took bread, gave thanks, broke it and began to give it to them.\nLuke 24:28: Then their eyes were opened and they recognized him, and he disappeared from their sight.\nLuke 24:29: They asked each other, “Were not our hearts burning within us while he talked with us on the road and opened the Scriptures to us?”\nLuke 24:30: They got up and returned at once to Jerusalem.\nLuke 24:31: Then they found the Eleven and those with them, assembled together and saying, “It is true! The Lord has risen and has appeared to Simon.”\nLuke 24:32: Then the two told what had happened on the way, and how Jesus was recognized by them when he broke the bread.\nLuke 24:33: They got up and returned at once to Jerusalem. Then they found the Eleven and those with them, assembled together and saying, “It is true! The Lord has risen and has appeared to Simon.”\nLuke 24:34: and saying, “It is true! The Lord has risen and has appeared to Simon.”\nLuke 24:35: Then the two told what had happened on the way, and how Jesus was recognized by them when he broke the bread.";
	$Area3D22/CollisionShape3D.set_deferred("disabled", true)
	$Area3D22.hide()
	body.Area3d = $Area3D22

func _on_area_3d_23_body_entered(body: player) -> void:
	 
	if body.label.get_line_count() == 51:
		$RichTextLabel.show()
		body.label.hide()
	else:
		body.label_2.text = "COLLECT ALL 50 BIBLE VERSES"
		body.global_position = Vector3(0, 0, 0)


func _on_area_3d_24_body_entered(body: player) -> void:
	if body.Area3d == null:
		body.global_position = Vector3(0, 0, 0)
	else:
		body.global_position = body.Area3d.global_position


func _on_button_pressed() -> void:
	Input.action_press("quit")
