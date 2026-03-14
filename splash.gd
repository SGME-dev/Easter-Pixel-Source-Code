extends Node2D


func _on_sprite_2d_animation_finished() -> void:
	$AnimationPlayer.play("fade")



func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	get_tree().change_scene_to_file("res://signin.tscn")
