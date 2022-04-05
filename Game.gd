extends Control

const card = preload("res://Card.tscn")
const effect = preload("res://Effect.tscn")

var can_pick = true

onready var suits = ['C','D','H','S']
onready var face_cards = ['J','Q','K','A']
onready var deck_db = []
onready var hand_db = []
onready var stack_db = []
onready var discard_db = []

export (NodePath) onready var deck = get_node(deck) as VBoxContainer
export (NodePath) onready var hand = get_node(hand) as HBoxContainer
export (NodePath) onready var hand_stack = get_node(hand_stack) as HBoxContainer
export (NodePath) onready var discard = get_node(discard) as VBoxContainer

onready var tween = $Tween
onready var menu = $Menu
onready var world = $World


func create_deck():
	for suit in suits:
		for i in range(9):
			instance_card(str(i+2), suit)
		for face_card in face_cards:
			instance_card(face_card, suit)


func instance_card(rank, suit):
	var c = card.instance()
	c.initialize(rank, suit)
	c.add_to_group('cards')
	deck_db.append(c)


func _ready() -> void:
#	start_new_game()
	randomize()
	pass


func start_new_game():
	clear_board()
	if menu.visible == true:
		menu.visible = false
	create_deck()
	shuffle_deck()
	populate_deck()


func clear_board():
	for i in get_tree().get_nodes_in_group('cards'):
		i.queue_free()
#	for i in hand.get_children():
#		i.queue_free()
#	for i in discard.get_children():
#		i.queue_free()


func shuffle_deck():
	deck_db.shuffle()


func populate_deck():
	for i in deck_db:
		deck.add_child(i)


func pick_card():
	if deck.get_child_count() <= 0:
		show_menu()
		return
	var top_card = deck_db.pop_back()
	reparent(top_card, deck, self)
	yield(get_tree(), "idle_frame")
	move_to_hand(top_card)
	top_card.anim_player.play("Flip")
	yield(tween,"tween_all_completed")
	yield(top_card.anim_player,'animation_finished')
	reparent(top_card, top_card.get_parent(), hand)

	# TODO: handle card moving through arrays instead of reparenting.
	# hand_db.append(card)
	# hand_db.append(card)

func move_to_hand(card:Node):
# handles stacking hand > 4 cards in pile & spreading them again
func handle_stack():
#	if hand has more than 4 cards, first card reparents to top of stack
	if hand.get_child_count() < 4 and hand_stack.get_child_count() <= 0:
		return
	if hand.get_child_count() >= 4:
		var bottom = hand_db.pop_front()
		stack_db.append(bottom)
		reparent(bottom, hand, hand_stack)
#	if hand has fewer than 4 cards and stack is not empty, top of stack reparents to hand
#	print( hand.get_child_count() < 4 and hand_stack.get_child_count() > 0 )
	if hand.get_child_count() < 4 and hand_stack.get_child_count() > 0:
		var top = stack_db.pop_back()
		hand_db.push_front(top)
		reparent(top, hand_stack, hand)



#	if hand has fewer than 4 cards and stack is not empty, top of stack reparents to hand
	tween.interpolate_property(card, "rect_position", deck.rect_global_position, hand.rect_global_position,0.15,Tween.TRANS_CIRC,Tween.EASE_IN_OUT)
	tween.start()


func discard():
	if rank_match_check():
		instance_effect(effect, hand.rect_global_position,'Matched RanK!')
		var last_card_rank = hand.get_children()[-1].rank
		instance_effect(effect, hand.rect_global_position, last_card_rank+"'s")
		for i in range(4):
			if not hand.get_child_count():
				continue
			var last_card = hand.get_children()[-1]  # Bug TODO: if suit then rank match makes 0 cards left, index error
			reparent(last_card, last_card.get_parent(), world)
			yield(get_tree(), "idle_frame")
#			yield(tween,"tween_all_completed")
			move_to_discard(last_card)
			yield(tween,"tween_all_completed")
			reparent(last_card, last_card.get_parent(), discard)
	elif suit_match_check():
		instance_effect(effect, hand.rect_global_position,'Matched Suit!')
		var last_card_suit = hand.get_children()[-1].suit
		instance_effect(effect, hand.rect_global_position, last_card_suit+"'s")
		for i in range(2):
#			bug if clicking too fast for tween, goes out of range
			if hand.get_child_count() < 2:
				continue
			var next_last_card = hand.get_children()[-2]
			reparent(next_last_card, next_last_card.get_parent(), world)
			yield(get_tree(),"idle_frame")
#			yield(tween,"tween_all_completed")
			move_to_discard(next_last_card)
			yield(tween,"tween_all_completed")
			reparent(next_last_card, next_last_card.get_parent(), discard)


func move_to_discard(card:Node):
	tween.interpolate_property(card, "rect_position", hand.rect_global_position, discard.rect_global_position, 0.15,Tween.TRANS_SINE, Tween.EASE_OUT)
	tween.start()


func _process(delta: float) -> void:
	if !menu.visible:
		if Input.is_action_just_pressed("lmb") and can_pick:
			pick_card()
			can_pick = false
		discard()


func _on_DeckPlaceholder_mouse_entered() -> void:
	pass


func _on_DeckPlaceholder_mouse_exited() -> void:
	pass


func reparent(child:Node, old_parent:Node, new_parent:Node):
	old_parent.remove_child(child)
	new_parent.add_child(child)


func rank_match_check():
	if hand.get_child_count() >= 4:
		return hand.get_children()[-4].rank == hand.get_children()[-1].rank
	return false


func suit_match_check():
	if hand.get_child_count() >= 4:
		return hand.get_children()[-4].suit == hand.get_children()[-1].suit
	return false


func _on_Hand_resized() -> void:
	can_pick = true


func _on_NewGame_pressed() -> void:
	start_new_game()


func show_menu():
	if menu.visible == false:
		menu.visible = true


func instance_effect(scene:PackedScene, _position:Vector2, text:String):
	var s = scene.instance()
	s.global_position = _position
	var label:Label = s.get_node('Label')
	label.set_text(text)
	label.rect_position.x = rand_range(-100, 100)
	label.rect_position.y = rand_range(-75, 100)
	world.add_child(s)
