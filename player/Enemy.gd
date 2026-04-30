extends CharacterBody2D

var SPEED = 120.0

@export var damage := 1
var gravity = 100

var chase = false

@onready var animated_sprite := $AnimatedSprite2D

func _ready() ->void:
	_play_animation("idle")
	pass	

func _play_animation(animation: String):
	if animated_sprite.animation != animation:
		animated_sprite.play(animation)
	
func die():
	_play_animation("death")
	$CollisionShape2D.set_deferred("disabled", true)
	$Area2D/CollisionShapeDamage.set_deferred("disabled", true)
	
func attack(player: CharacterBody2D):
	player.take_damage(damage, global_position.direction_to(player.global_position))
	
func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	var player = $"../../Player/Player"
	var direction = (player.position - self.position).normalized()
	if chase == true:
		velocity.x = direction.x * SPEED
	else: 
		velocity.x = 0
	move_and_slide()

func _on_detector_body_entered(body):
	if body.name == "Player":
		chase = true


func _on_detector_body_exited(body):
	if body.name == "Player":
		chase = false
