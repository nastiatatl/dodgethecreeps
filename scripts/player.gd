extends Area2D
signal hit
signal coin_collected(big_coin: bool)
signal special_item_collected

@export var speed = 400
@export var invincibility_duration: float = 2.0
@export var flash_interval: float = 0.2 
var screen_size
var is_invincible = false
var shield_duration: float = 5.0
var shield_flash_delay: float = 2.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var velocity = Vector2.ZERO  # player's movemenet vector
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
		
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	
	if velocity.x != 0: # horizontal move
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.flip_v = velocity.y > 0

func _on_body_entered(body: RigidBody2D) -> void:
	if is_invincible:
		return
	hit.emit()
	$CollisionShape2D.set_deferred("disabled", true)
		
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("coins"):
		coin_collected.emit(area.big_coin)
	elif area.is_in_group("shields"):
		special_item_collected.emit(area)
		gain_shield_protection()
	else:
		special_item_collected.emit(area)
	area.queue_free()
	
func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false

func become_invincible() -> void:
	hide()
	is_invincible = true
	flash(invincibility_duration)
	await get_tree().create_timer(invincibility_duration).timeout
	
	is_invincible = false
	$CollisionShape2D.disabled = false
	show()
	
func flash(duration: float) -> void:
	var flashes = int(duration / flash_interval)
	var visible = false
	for i in range(flashes):
		await get_tree().create_timer(flash_interval).timeout
		visible = !visible
		show() if visible else hide()
	show()
	
func gain_shield_protection():
	$ProtectionBubble.show()  # Show the bubble
	$ProtectionBubble/ProtectionBubbleTimer.start()
	$ProtectionBubble/FlashTimer.start(shield_flash_delay)
	is_invincible = true


func _on_protection_bubble_timer_timeout() -> void:
	$ProtectionBubble.hide()
	is_invincible = false
	$ProtectionBubble/FlashTimer.stop()


func _on_flash_timer_timeout() -> void:
	# Toggle visibility at intervals
	$ProtectionBubble.visible = !$ProtectionBubble.visible
	
	# Continue flashing if coin is still alive
	if $ProtectionBubble/ProtectionBubbleTimer.time_left > 0:
		$ProtectionBubble/FlashTimer.start(flash_interval)
	else:
		$ProtectionBubble/FlashTimer.stop()
