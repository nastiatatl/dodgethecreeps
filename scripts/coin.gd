extends Area2D

@export var big_coin: bool = false
@onready var big_coin_timer = $BigCoinTimer
@export var flash_interval: float = 0.1  # Interval for flashing (in seconds)
@export var big_coin_scale: Vector2 = Vector2(1.1, 1.1)  # Scale for big coins


func _ready() -> void:
	if big_coin:
		$Sprite2D.texture = preload("res://assets/images/bigCoin.png")
		scale_big_coin()
		$FlashTimer.start()
		big_coin_timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func _on_big_coin_timer_timeout() -> void:
	if big_coin:
		queue_free()


func _on_flash_timer_timeout() -> void:
	# Toggle visibility at intervals
	$Sprite2D.visible = !$Sprite2D.visible
	
	# Continue flashing if coin is still alive
	if $BigCoinTimer.time_left > 0:
		$FlashTimer.start(flash_interval)
		
func scale_big_coin():
	# Scale the sprite
	$Sprite2D.scale = big_coin_scale
	
	# Scaale Collision shape
	var circle_shape = $CollisionShape2D.shape as CircleShape2D
	circle_shape.radius *= big_coin_scale.x  # Assuming uniform scaling
