extends CanvasLayer

signal start_game  # notify Main scene that the button has been pressed
var game_started = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("start_game") and not game_started:
		$StartButton.hide()
		start_game.emit()
		game_started = true

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()
	

func show_game_over():
	show_message("Game Over")
	await $MessageTimer.timeout
	
	$Message.text = "Dodge the Creeps!"
	$Message.show()
	
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()
	game_started = false
	

func update_score(score):
	$ScoreLabel.text = str(score)
	
func update_num_coins(num_coins):
	$CoinLabel.text = "x" + str(num_coins)

func _on_start_button_pressed() -> void:
	$StartButton.hide()
	start_game.emit()
	game_started = true

func _on_message_timer_timeout() -> void:
	$Message.hide()
