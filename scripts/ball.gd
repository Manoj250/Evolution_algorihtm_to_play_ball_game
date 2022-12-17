extends RigidBody2D

export var move_force = 40
var root
var next_plat = Vector2(0,0)
var jump_count = 0

var x1
var x2

var y1
var y2

var z1
var z2

var start_time
var end_time


func _ready():
	root = get_node("..")
	start_time = OS.get_ticks_msec()

func _physics_process(delta):
	# if Input.is_action_pressed("ui_left"):
	# 	apply_central_impulse(Vector2(-(move_force*delta),0))
	# if Input.is_action_pressed("ui_right"):
	# 	apply_central_impulse(Vector2(move_force*delta,0))

	var action = take_action()
	if action == "left":
		apply_central_impulse(Vector2(-(move_force*delta),0))
	elif action == "right":
		apply_central_impulse(Vector2(move_force*delta,0))
	else:
		pass

func _on_Area2D_area_entered(area:Area2D):
	if area.get_name() == "spike" or "wall" in area.get_name():
		end_time = OS.get_ticks_msec()
		# root.gene_pool.append([[(end_time-start_time)/1000],[x1,x2,x3,x4],[y1,y2,y3,y4],[z1,z2,z3,z4]])
		root.gene_pool.append([[jump_count],[x1,x2],[y1,y2],[z1,z2]])
		queue_free()

func take_action():

	
	var h_distance = (next_plat.x - position.x)/600
	var v_distance = (next_plat.y - position.y)/750

	var f1 = x1*(h_distance) + x2*(v_distance) 
	var f2 = y1*(h_distance) + y2*(v_distance)
	var f3 = z1*(h_distance) + z2*(v_distance)
	
	var softmax = [
		exp(f1)/(exp(f1)+exp(f2)+exp(f3)),
		exp(f2)/(exp(f1)+exp(f2)+exp(f3)),
		exp(f3)/(exp(f1)+exp(f2)+exp(f3))
	]

	if softmax[0] >= softmax[1] and softmax[0] >= softmax[2]:
		return "left"
	elif softmax[1] >= softmax[2]:
		return "right"
	else:
		return "discombombulate"


func _on_ball_body_entered(body:Node):
	if "platform" in body.get_name():
		jump_count += 1
		next_plat = body.next_plat