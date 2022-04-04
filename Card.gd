extends PanelContainer

var red = Color('#a34644')
var rank = ''
var suit = ''
onready var rank_icon = $Front/CenterPanel/DecalMargin/IconMargin/Icon/Rank
onready var rank_id = $Front/CenterPanel/DecalMargin/ID/Rank
onready var suit_id = $Front/CenterPanel/DecalMargin/ID/Suit
onready var anim_player = $AnimationPlayer

func initialize(_rank, _suit):
	rank = _rank
	suit = _suit
	set_name(rank + ' of ' + suit)

func _ready() -> void:
	rank_icon.set_text(rank)
	rank_id.set_text(rank)
	suit_id.set_text(suit)
	set_colors()

func set_colors():
	if suit in ['H','D']:
#		prints('rank icon color', get('custom_colors/font_outline_modulate'))
		rank_icon.set('custom_colors/font_outline_modulate', red)
		rank_id.set('custom_colors/font_color_shadow', red)
		suit_id.set('custom_colors/font_color', red)
