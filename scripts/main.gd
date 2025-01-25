extends Node

@export var mob_scene: PackedScene
@export var coin_scene: PackedScene
@export var special_item_scenes: Array[PackedScene] = []

var score
var num_coins
var num_hearts
const MIN_DISTANCE = 75.0  # Minimum distance between items

var all_groups = ["coins", "special_items", "hearts", "shields", "mobs"]  # List of all relevant groups

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func player_hit() -> void:
	num_hearts -= 1
	if num_hearts < 0:
		game_over()
	else:
		$MobHitSound.play()
		$HUD.update_num_hearts(num_hearts)
		$Player.become_invincible()

func game_over() -> void:
	$Player.hide()
	$Music.stop()
	$DeathSound.play()
	$ScoreTimer.stop()
	$MobTimer.stop()
	$CoinTimer.stop()
	$SpecialItemTimer.stop()
	
	get_tree().call_group("mobs", "queue_free")
	get_tree().call_group("coins", "queue_free")
	get_tree().call_group("shields", "queue_free")
	get_tree().call_group("special_items", "queue_free")
	
	$HUD.show_game_over()
	
func coin_collected(big_coin: bool) -> void:
	$CoinSound.play()
	if big_coin:
		num_coins += 5
	else:
		num_coins += 1
	$HUD.update_num_coins(num_coins)
	
func new_game():
	score = 0
	num_coins = 0
	num_hearts = 0
	$Music.play()
	$Player.start($StartPosition.position)
	$StartTimer.start()
	
	$HUD.update_score(score)
	$HUD.update_num_coins(num_coins)
	$HUD.update_num_hearts(num_hearts)
	$HUD.show_message("Get Ready")
	

func _on_mob_timer_timeout() -> void:
	var mob = mob_scene.instantiate()  # create a new instance of mob scene
	
	var mob_spawn_location = $MobPath/MobSpawnLocation  # choose random location on Path2D
	mob_spawn_location.progress_ratio = randf()
	
	var direction = mob_spawn_location.rotation + PI / 2  # set mob's direction perpendicular to path direction
	
	mob.position = mob_spawn_location.position  # set mob's position to random location
	
	direction += randf_range(-PI / 4, PI / 4)  
	mob.rotation = direction
	
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)
	
	add_child(mob)  # add mob to main scene - spawn it


func _on_score_timer_timeout() -> void:
	score += 1
	$HUD.update_score(score)

func _on_start_timer_timeout() -> void:
	$MobTimer.start()
	$ScoreTimer.start()
	$CoinTimer.start()
	$SpecialItemTimer.start()

func _on_coin_timer_timeout() -> void:
	var coin = coin_scene.instantiate()
	
	# 10% chance to spawn a big coin
	if randf() <= 0.1:
		coin.big_coin = true
		
	add_item(coin, "coins")
	

func _on_special_item_timer_timeout() -> void:
	var random_special_item_scene = special_item_scenes[randi() % special_item_scenes.size()]
	var random_special_item = random_special_item_scene.instantiate()
	
	if random_special_item.name == "Heart":
		random_special_item.add_to_group("hearts")
	elif random_special_item.name == "Shield":
		random_special_item.add_to_group("shields")
	else:
		random_special_item.add_to_group("special_items")
		
	add_item(random_special_item, "special_items")
	
	
func add_item(item: Node, group_name: String) -> void:
	var screen_size = get_viewport().get_visible_rect().size
	var top_buffer = 70
	var buffer = 50  # Distance from the edges
	var attempts = 10
	var position_ok = false
	
	while not position_ok and attempts > 0:
		var random_x = randf_range(buffer, screen_size.x - buffer)
		var random_y = randf_range(top_buffer, screen_size.y - buffer)
		item.position = Vector2(random_x, random_y)
		
		# Check distance to existing items
		position_ok = true
		for group in all_groups:
			if group == "mobs":  # Skip "mobs"
				continue
			for other_item in get_tree().get_nodes_in_group(group_name):
				if item.position.distance_to(other_item.position) < MIN_DISTANCE:
					position_ok = false
					break
				
		attempts -= 1
	
	if not position_ok:
		return
				
	add_child(item)
	

func special_item_collected(item: Area2D) -> void:
	$SpecialItemSound.play()
	if item.is_in_group("hearts"):
		num_hearts += 1
		$HUD.update_num_hearts(num_hearts)
