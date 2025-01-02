extends Node

@export var mob_scene: PackedScene
@export var coin_scene: PackedScene
var score
var num_coins
const MIN_COIN_DISTANCE = 75.0  # Minimum distance between coins


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func game_over() -> void:
	$Music.stop()
	$DeathSound.play()
	$ScoreTimer.stop()
	$MobTimer.stop()
	$CoinTimer.stop()
	
	get_tree().call_group("mobs", "queue_free")
	get_tree().call_group("coins", "queue_free")
	
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
	$Music.play()
	$Player.start($StartPosition.position)
	$StartTimer.start()
	
	$HUD.update_score(score)
	$HUD.update_num_coins(num_coins)
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

func _on_coin_timer_timeout() -> void:
	var coin = coin_scene.instantiate()
	
	# 10% chance to spawn a big coin
	if randf() <= 0.1:
		coin.big_coin = true
	
	var screen_size = get_viewport().get_visible_rect().size
	var buffer = 50  # Distance from the edges
	var attempts = 10
	var position_ok = false
	
	while not position_ok and attempts > 0:
		var random_x = randf_range(buffer, screen_size.x - buffer)
		var random_y = randf_range(buffer, screen_size.y - buffer)
		coin.position = Vector2(random_x, random_y)
		
		# Check distance to existing coins
		position_ok = true
		for other_coin in get_tree().get_nodes_in_group("coins"):
			if coin.position.distance_to(other_coin.position) < MIN_COIN_DISTANCE:
				position_ok = false
				break
	
	add_child(coin)
	
