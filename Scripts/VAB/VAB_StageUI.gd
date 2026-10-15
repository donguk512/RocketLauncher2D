# VAB_StageUI.gd
extends MarginContainer
class_name StageUI

@onready var v_box_container: VBoxContainer = $ScrollContainer/VBoxContainer
@onready var plus_button: Button = $ScrollContainer/VBoxContainer/PlusButton

const STAGE_UI = preload("uid://dm0862qatkjs8")

# 몇 번째 스테이지가 선택되었는지 Builder 쪽에 알려주는 시그널 (-1이면 선택 해제)
signal stage_selected(stage_index: int)

var stage_nodes: Array[Control] = []
var active_stage_index: int = -1

func _ready() -> void:
	pass

func _on_plus_button_pressed() -> void:
	make_stage()
	
func make_stage():
	var stage_ui := STAGE_UI.instantiate()
	var button: Button = stage_ui.get_node("Button")
	var icon_container: VBoxContainer = stage_ui.get_node("VBoxContainer")
	
	# 아이콘 컨테이너가 버튼 클릭을 가리지 않도록 마우스 무시 설정
	icon_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	v_box_container.add_child(stage_ui)
	stage_nodes.append(stage_ui)
	
	# ⭐️ 핵심: + 버튼을 항상 맨 위(0) 또는 맨 아래(-1)로 안전하게 이동!
	v_box_container.move_child(stage_ui, 0)
	v_box_container.move_child(plus_button, -1)
	
	# 버튼 클릭 시 자신의 현재 인덱스를 찾아 선택 토글
	button.pressed.connect(func():
		var my_idx = stage_nodes.find(stage_ui)
		_on_stage_button_clicked(my_idx)
	)

func _on_stage_button_clicked(idx: int) -> void:
	# 이미 선택된 스테이지를 다시 누르면 선택 해제 (일반 조립 모드로 복귀)
	if active_stage_index == idx:
		active_stage_index = -1
	else:
		active_stage_index = idx
		
	_update_button_visuals()
	stage_selected.emit(active_stage_index)

func _update_button_visuals() -> void:
	for i in range(stage_nodes.size()):
		var btn: Button = stage_nodes[i].get_node("Button")
		btn.text = str(i + 1) # 스테이지 번호 표시 (1, 2, 3...)
		# 선택된 스테이지 탭은 초록빛으로 강조
		btn.modulate = Color(0.5, 1.0, 0.5) if i == active_stage_index else Color(1, 1, 1)

# 파트를 클릭해서 스테이지가 바뀔 때마다 호출하여 우측 UI 아이콘들을 새로고침
func refresh_stage_icons(all_parts: Array) -> void:
	for i in range(stage_nodes.size()):
		var icon_container: VBoxContainer = stage_nodes[i].get_node("VBoxContainer")
		for child in icon_container.get_children():
			child.queue_free()
		
		for part in all_parts:
			if part is PartBase and part.stage_index == i:
				var tex_rect := TextureRect.new()
				tex_rect.texture = part.icon
				tex_rect.custom_minimum_size = Vector2(60, 60)
				tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				tex_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
				icon_container.add_child(tex_rect)

func scan_parts(parts):
	for part: PartBase in parts:
		if part.stage_index == -1:
			continue
			
		while not stage_nodes.get(part.stage_index):
			make_stage()
