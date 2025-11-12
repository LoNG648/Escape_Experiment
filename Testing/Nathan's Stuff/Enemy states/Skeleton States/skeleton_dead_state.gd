extends EnemyState

#example of how to set up dropping an item
#make sure you select the scene you want it to drop in the export area thing
@export var health_drop_chance : float = 0.25
@export var health_potion_scene : PackedScene

@export var coin_drop_chance : float = 0.60
@export var coin_item_scene : PackedScene

var dead = false

func enter():
	if dead:
		return
	super.enter()
	sprite.play("death")
	await sprite.animation_finished
	queue_free()
	
	dead = true
	#for dropping an item
	#if randi() % 100 < int(health_drop_chance * 100):
		#var health_poition_instance = health_potion_scene.instantiate()
		#health_potion_instance.global_position = get_parent().get_parent().global_position + Vector2(-15,0)
		#get_parent().get_parent().call_deferred("add_child", health_potion_instance)
