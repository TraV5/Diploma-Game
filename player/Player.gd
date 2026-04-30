extends CharacterBody2D

signal hp_changed

var gravity = 400
const IMMORTAL_TIME = 2

var SPEED = 120
const jump_speed = -180
var hp = 8
var immortal_time = 0.0
var chase = false

@onready var animated_sprite := $AnimatedSprite2D
@onready var ray_cast_down := $RayCastDown
@onready var animation_player = $AnimationPlayer

func _ready() -> void:
	call_deferred("change_hp", 0)
	_play_animation("idle")

func _physics_process(delta: float):
	if not is_on_floor():
		velocity.y += gravity * delta
	var land = Input.is_action_pressed("land")
	if Input.is_action_just_pressed('jump') and is_on_floor():
		velocity.y = jump_speed
	var direction = Input.get_axis('move_left', 'move_right')
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if direction == -1:
		$AnimatedSprite2D.flip_h = true
	elif direction == 1:
		$AnimatedSprite2D.flip_h = false
	if not is_on_floor() and velocity.y > 0 and ray_cast_down.is_colliding():
		var enemy = ray_cast_down.get_collider()
		hit_enemy(enemy)
	
	_play_move_animation(velocity)
	move_and_slide()
	
	if immortal_time >= 0:
		immortal_time -= delta
		animation_player.play("Immortal")
	else:
		animation_player.stop()
	
func _play_move_animation(velocity: Vector2):
	if velocity.x != 0 and is_on_floor():
		animated_sprite.play("run")
	elif velocity.x == 0 and is_on_floor():
		animated_sprite.play("idle")
	elif velocity.y <= 0:
		animated_sprite.play("jump")
	elif velocity.y > 0:
		animated_sprite.play("fall")
		
func _play_animation(animation: String):
	if animated_sprite.animation != animation:
		animated_sprite.play(animation)

func hit_enemy(enemy: Node2D):
	if enemy.has_method("die"):
		enemy.die()
	velocity.y = jump_speed / 2.0

func take_damage(damage: int, attack_direction: Vector2):
	change_hp(-damage)
	immortal_time = IMMORTAL_TIME
	
func change_hp(diff: int):
	hp += diff
	emit_signal("hp_changed", hp)
