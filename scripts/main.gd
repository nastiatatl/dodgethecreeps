extends Node

@export var mob_scene: PackedScene
@export var coin_scene: PackedScene
var score
var num_coins


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
	
func coin_collected() -> void:
	$CoinSound.play()
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
	
	var screen_size = get_viewport().get_visible_rect().size
	var buffer = 50  # Distance from the edges
	
	var random_x = randf_range(buffer, screen_size.x - buffer)
	var random_y = randf_range(buffer, screen_size.y - buffer)
	coin.position = Vector2(random_x, random_y)
	
	add_child(coin)
	
