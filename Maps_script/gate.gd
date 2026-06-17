

extends StaticBody2D


@onready var gate: AnimatedSprite2D = $AnimatedSprite2D

var player_inside= false

@export var data : door_data





# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("open") and player_inside:
		gate.play()
		get_tree().change_scene_to_packed(data.next_scene)
	pass


func _on_gate_open_body_entered(body: Node2D) -> void:
	player_inside=true
	
		



func _on_gate_open_body_exited(body: Node2D) -> void:
	player_inside=false
	
