extends Control

#On ready variables
@onready var abilities: PanelContainer = $Abilities
@onready var controls: PanelContainer = $Controls
@onready var player: Player = $"../.."
@onready var attack_list: MenuButton = $Abilities/VBoxContainer/AttackList
@onready var special_list: MenuButton = $Abilities/VBoxContainer/SpecialList
@onready var counter_list: MenuButton = $Abilities/VBoxContainer/CounterList
@onready var block_list: MenuButton = $Abilities/VBoxContainer/BlockList
@onready var passive_list: MenuButton = $Abilities/VBoxContainer/PassiveList

#Regular Variables
var paused: bool = false
var attackOptions: Object
var specialOptions: Object
var counterOptions: Object
var blockOptions: Object
var passiveOptions: Object

func _ready() -> void:
		attackOptions = attack_list.get_popup()
		specialOptions = special_list.get_popup()
		counterOptions = counter_list.get_popup()
		blockOptions = block_list.get_popup()
		passiveOptions = passive_list.get_popup()
		attackOptions.id_pressed.connect(AbilityChanged.bind(attackOptions))
		specialOptions.id_pressed.connect(AbilityChanged.bind(specialOptions))
		counterOptions.id_pressed.connect(AbilityChanged.bind(counterOptions))
		blockOptions.id_pressed.connect(AbilityChanged.bind(blockOptions))
		passiveOptions.id_pressed.connect(AbilityChanged.bind(passiveOptions))

func resume():
	paused = false
	get_tree().paused = false

func pause():
	paused = true
	get_tree().paused = true

func test_escape():
	if Input.is_action_just_pressed("Pause") and get_tree().paused == false:
		pause()
	elif Input.is_action_just_pressed("Pause") and get_tree().paused == true:
		resume()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_resume_pressed() -> void:
	resume()

func _on_restart_pressed() -> void:
	resume()
	get_tree().reload_current_scene()

func _process(_delta):
	if paused == true:
		$".".show()
	elif paused == false:
		$".".hide()
	test_escape()

func _on_controls_pressed() -> void:
	if controls.visible == false:
		controls.show()
		abilities.show()
	elif controls.visible == true:
		controls.hide()
		abilities.hide()

func addBossMoveset() -> void:
	attack_list.get_popup().add_item("The Tank", 1)
	special_list.get_popup().add_item("The Tank", 1)
	counter_list.get_popup().add_item("The Tank", 1)
	block_list.get_popup().add_item("The Tank", 1)
	passive_list.get_popup().add_item("The Tank", 1)
	
func addBasicEnemyPassive() -> void:
	passive_list.get_popup().add_item("Basic Enemy", 2)

func addComplexEnemyPassive() -> void:
	passive_list.get_popup().add_item("Complex Enemy", 3)

func AbilityChanged(id, PopUpMenu) -> void:
	if PopUpMenu == passiveOptions:
		if id == 0:
			passive_list.text = "Passive: The Collector"
			player.passive = player.passiveSet[0]
		elif id == 1:
			passive_list.text = "Passive: The Tank"
			player.passive = player.passiveSet[1]
		elif id == 2:
			passive_list.text = "Passive: Basic Enemy"
			player.passive = player.passiveSet[2]
		elif id == 3:
			passive_list.text = "Passive: Complex Enemy"
			player.passive = player.passiveSet[3]
	elif PopUpMenu == attackOptions:
		if id == 0:
			attack_list.text = "Basic Attack: The Collector"
			player.basicAttack = player.attackMoveset[0]
		elif id == 1:
			attack_list.text = "Basic Attack: The Tank"
			player.basicAttack = player.attackMoveset[1]
	elif PopUpMenu == specialOptions:
		if id == 0:
			special_list.text = "Special Attack: The Collector"
			player.specialAttack = player.specialMoveset[0]
		elif id == 1:
			special_list.text = "Special Attack: The Tank"
			player.specialAttack = player.specialMoveset[1]
	elif PopUpMenu == counterOptions:
		if id == 0:
			counter_list.text = "Counter Attack: The Collector"
			player.counterAttack = player.counterMoveset[0]
		elif id == 1:
			counter_list.text = "Counter Attack: The Tank"
			player.counterAttack = player.counterMoveset[1]
	elif PopUpMenu == blockOptions:
		if id == 0:
			block_list.text = "Block: The Collector"
			player.block = player.blockMoveset[0]
		elif id == 1:
			block_list.text = "Block: The Tank"
			player.block = player.blockMoveset[1]
