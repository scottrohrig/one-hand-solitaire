extends PanelContainer

var red_outline = Color('#a34644')
var red_font = Color('#faa')
var blue_outline = Color('#215e99')
var blue_font = Color('#6eb4f8')
var rank = ''
var suit = ''

onready var rank_icon = $Front/CenterPanel/DecalMargin/IconMargin/Icon/Rank
onready var rank_id = $Front/CenterPanel/DecalMargin/ID/Rank
onready var rank_id2 = $Front/CenterPanel/DecalMargin/ID2/Rank
onready var suit_id = $Front/CenterPanel/DecalMargin/ID/Suit
onready var suit_id2 = $Front/CenterPanel/DecalMargin/ID2/Suit
onready var anim_player = $AnimationPlayer

func initialize(_rank, _suit):
	rank = _rank
	suit = _suit
	set_name(rank + ' of ' + suit)

func _ready() -> void:
	rank_icon.set_text(rank)
	
	rank_id.set_text(rank)
	suit_id.set_text(suit)
	
	rank_id2.set_text(rank)
	suit_id2.set_text(suit)
	
	set_colors()

func set_colors():
	if suit in ['H','D']:
		rank_icon.set('custom_colors/font_outline_modulate', red_outline)
		rank_icon.set('custom_colors/font_color', red_font)
		
		rank_id.set('custom_colors/font_color_shadow', red_outline)
		suit_id.set('custom_colors/font_color', red_outline)
		
		rank_id2.set('custom_colors/font_color_shadow', red_outline)
		suit_id2.set('custom_colors/font_color', red_outline)
