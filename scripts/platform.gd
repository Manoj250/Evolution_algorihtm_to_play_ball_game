extends StaticBody2D

export var up_speed = 20

var next_plat = Vector2(0,0)

func _ready():
	pass

func _physics_process(delta):
	position.y -= up_speed*delta

func _on_platform_area_entered(area:Area2D):
	if area.get_name() == "spike":
		queue_free()


