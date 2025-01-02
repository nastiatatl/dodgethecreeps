extends Area2D

@export var big_coin: bool = false
@onready var big_coin_timer = $BigCoinTimer

func _ready() -> void:
	if big_coin:
		$Sprite2D.texture = preload("res://assets/images/bigCoin.png")
		big_coin_timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func _on_big_coin_timer_timeout() -> void:
	if big_coin:
		queue_free()
