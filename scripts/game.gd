extends Node2D

const PLATFORM = preload("res://scenes/platform.tscn")
const BALL  = preload("res://scenes/ball.tscn")
var rng = RandomNumberGenerator.new()

var next_plat
var curr_plat = Vector2(240,490)
export var agent_count = 10
export var fittest = 10
export var limit_for_random = 1
var gene_pool = []
var prev_gene_pool = []
var wait = true
var spawn_points = [Vector2(120,640),Vector2(240,640),Vector2(370,640)]
var generation = 1
var best_streak = 0
var dna
var use_trained = false

func _process(_delta):
	if dna["genes"][0][0] > 0:
		$menuholder/Control/Button2.disabled = false

	if not use_trained:
		var ball_alive = get_tree().get_nodes_in_group("ballz")
		if not ball_alive and not wait:
			wait = true
			respawn()
	else:
		var ball_alive = get_tree().get_nodes_in_group("ballz")
		if not ball_alive and not wait:
			wait = true
			respawn_single()
		if ball_alive:
			$scoreholder/Label.text = "streak : %d" % [$ball.jump_count]
		
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		show_menu()

func _ready():
	dna = load_json()
	if dna["genes"][0][0] == 0:
		$menuholder/Control/Button2.disabled = true

func _on_border_area_entered(area:Area2D):
	if area.get_name() == "platform":
		spawn_platform()

func spawn_platform():
	var platform = PLATFORM.instance()
	platform.position = next_plat
	rng.randomize()
	next_plat = Vector2(rng.randf_range(120,370),640)
	platform.next_plat = next_plat
	add_child(platform)

func respawn():
	get_tree().call_group("platforms", "queue_free")
	gene_pool.sort_custom(self,"asc_sort")
	var x1_pool = []
	var x2_pool = []
	
	var y1_pool = []
	var y2_pool = []
	
	var z1_pool = []
	var z2_pool = []

	if gene_pool[0][0][0] < best_streak:
		gene_pool = prev_gene_pool

	for gene in gene_pool.slice(0,fittest):
		x1_pool.append(gene[1][0])
		x2_pool.append(gene[1][1])

		y1_pool.append(gene[2][0])
		y2_pool.append(gene[2][1])

		z1_pool.append(gene[3][0])
		z2_pool.append(gene[3][1])

	for i in range(3):
		var new_ball = BALL.instance()
		new_ball.position = Vector2(240,480)
		new_ball.x1 = x1_pool[i]
		new_ball.x2 = x2_pool[i]

		new_ball.y1 = y1_pool[i]
		new_ball.y2 = y2_pool[i]

		new_ball.z1 = z1_pool[i]
		new_ball.z2 = z2_pool[i]

		add_child(new_ball)

	var platform = PLATFORM.instance()
	platform.position = curr_plat
	rng.randomize()
	next_plat = Vector2(rng.randf_range(120,370),640)
	platform.next_plat = next_plat
	
	add_child(platform)

	for _i in range(3,10):
		rng.randomize()
		var new_ball = BALL.instance()
		new_ball.position = Vector2(240,480)
		new_ball.x1 = x1_pool[rng.randi() % len(x1_pool)]*rng.randf_range(0.96,1.04)
		new_ball.x2 = x2_pool[rng.randi() % len(x2_pool)]*rng.randf_range(0.96,1.04)

		new_ball.y1 = y1_pool[rng.randi() % len(y1_pool)]*rng.randf_range(0.96,1.04)
		new_ball.y2 = y2_pool[rng.randi() % len(y2_pool)]*rng.randf_range(0.96,1.04)

		new_ball.z1 = z1_pool[rng.randi() % len(z1_pool)]*rng.randf_range(0.96,1.04)
		new_ball.z2 = z2_pool[rng.randi() % len(z2_pool)]*rng.randf_range(0.96,1.04)

		add_child(new_ball)
	
	for _i in range(10,agent_count):
		rng.randomize()
		var new_ball = BALL.instance()
		new_ball.position = Vector2(240,480)
		new_ball.x1 = x1_pool[rng.randi() % len(x1_pool)]*rng.randf_range(0.99,1.01)
		new_ball.x2 = x2_pool[rng.randi() % len(x2_pool)]*rng.randf_range(0.99,1.01)

		new_ball.y1 = y1_pool[rng.randi() % len(y1_pool)]*rng.randf_range(0.99,1.01)
		new_ball.y2 = y2_pool[rng.randi() % len(y2_pool)]*rng.randf_range(0.99,1.01)

		new_ball.z1 = z1_pool[rng.randi() % len(z1_pool)]*rng.randf_range(0.99,1.01)
		new_ball.z2 = z2_pool[rng.randi() % len(z2_pool)]*rng.randf_range(0.99,1.01)

		add_child(new_ball)

	wait = false
	prev_gene_pool = gene_pool
	generation += 1
	if gene_pool[0][0][0] > best_streak:
		best_streak = gene_pool[0][0][0]
		
	if best_streak > dna["genes"][0][0]:
		dna["genes"] = gene_pool[0]
		save_json()
	$scoreholder/Label.text = "generation : %d , best streak : %d" % [generation,best_streak]
	gene_pool = []



func asc_sort(a,b):
	if a[0][0] > b[0][0]:
		return true
	return false


func save_json():
	var file = File.new()
	file.open("DNA.json", File.WRITE)
	file.store_string(to_json(dna))
	file.close()

func load_json():
	var file = File.new()
	if file.file_exists("DNA.json"):
		file.open("DNA.json", File.READ)
		var data = parse_json(file.get_as_text())
		file.close()
		return data
	else:
		return {"genes":[[0],[0,0],[0,0],[0,0]]}

func play_trained():
	var new_ball = BALL.instance()
	new_ball.position = Vector2(240,480)

	new_ball.x1 = dna["genes"][1][0]
	new_ball.x2 = dna["genes"][1][1]

	new_ball.y1 = dna["genes"][2][0]
	new_ball.y2 = dna["genes"][2][1]
	
	new_ball.z1 = dna["genes"][3][0]
	new_ball.z2 = dna["genes"][3][1]
	
	add_child(new_ball)
	wait = false

func train_start():
	generation = 0
	best_streak = 0
	$scoreholder/Label.text = "generation : %d , best streak : %d" % [generation,best_streak]
	for _i in range(agent_count):
		rng.randomize()
		var new_ball = BALL.instance()
		new_ball.position = Vector2(240,480)

		new_ball.x1 = rng.randf_range(-limit_for_random,limit_for_random)
		new_ball.x2 = rng.randf_range(-limit_for_random,limit_for_random)

		new_ball.y1 = rng.randf_range(-limit_for_random,limit_for_random)
		new_ball.y2 = rng.randf_range(-limit_for_random,limit_for_random)
		
		new_ball.z1 = rng.randf_range(-limit_for_random,limit_for_random)
		new_ball.z2 = rng.randf_range(-limit_for_random,limit_for_random)
		
		add_child(new_ball)
	wait = false
	
func respawn_single():
	get_tree().call_group("platforms", "queue_free")
	var platform = PLATFORM.instance()
	platform.position = curr_plat
	rng.randomize()
	next_plat =  Vector2(rng.randf_range(120,370),640)
	platform.next_plat = next_plat
	add_child(platform)
	play_trained()
	wait = false

func _on_Button2_pressed():	
	use_trained = true
	$menuholder.visible = false
	var platform = PLATFORM.instance()
	platform.position = curr_plat
	rng.randomize()
	next_plat =  Vector2(rng.randf_range(120,370),640)
	platform.next_plat = next_plat
	add_child(platform)
	play_trained()


func _on_Button_pressed():
	use_trained = false
	$menuholder.visible = false
	var platform = PLATFORM.instance()
	platform.position = curr_plat
	rng.randomize()
	next_plat =  Vector2(rng.randf_range(120,370),640)
	platform.next_plat = next_plat
	add_child(platform)
	train_start()

func show_menu():
	wait = true
	get_tree().call_group("platforms", "queue_free")
	get_tree().call_group("ballz", "queue_free")
	$menuholder.visible = true
