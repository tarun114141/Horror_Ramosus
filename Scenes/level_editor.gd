extends Node2D

@onready var tile_map: TileMap = $TileMap
@onready var grid_container: GridContainer = $CanvasLayer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/GridContainer
@onready var save_button: Button = $CanvasLayer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/SaveButton
@onready var load_button: Button = $CanvasLayer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/LoadButton
@onready var file_dialog: FileDialog = $CanvasLayer/FileDialog

var current_atlas_coords: Vector2i = Vector2i.ZERO
var current_source_id: int = 1
var is_painting: bool = false
var is_erasing: bool = false
var _is_saving: bool = fals

func _ready() -> void:
	_populate_tile_palette()
	
	save_button.pressed.connect(_on_save_button_pressed)
	load_button.pressed.connect(_on_load_button_pressed)
	file_dialog.file_selected.connect(_on_file_selected)

func _populate_tile_palette() -> void:
	var tile_set: TileSet = tile_map.tile_set
	if not tile_set:
		push_error("No tileset found on TileMap!")
		return
		
	var source = tile_set.get_source(current_source_id) as TileSetAtlasSource
	if not source:
		push_error("No TileSetAtlasSource found with ID ", current_source_id)
		return
		
	for i in range(source.get_tiles_count()):
		var atlas_coords = source.get_tile_id(i)
		var btn = Button.new()
		
		var atlas_tex = AtlasTexture.new()
		atlas_tex.atlas = source.texture
		atlas_tex.region = Rect2(atlas_coords * tile_set.tile_size, tile_set.tile_size)
		
		btn.icon = atlas_tex
		btn.custom_minimum_size = Vector2(40, 40)
		btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn.expand_icon = true
		
		# Set Focus Mode to none so hitting space/arrows doesn't trigger the button or steal focus from camera
		btn.focus_mode = Control.FOCUS_NONE 
		
		btn.pressed.connect(func(): _on_tile_selected(atlas_coords))
		grid_container.add_child(btn)

func _on_tile_selected(coords: Vector2i) -> void:
	current_atlas_coords = coords

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_painting = event.pressed
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			is_erasing = event.pressed
			
	elif event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			is_painting = true
			is_erasing = false
		elif Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			is_erasing = true
			is_painting = false
			
	if is_painting:
		_paint_cell()
		get_viewport().set_input_as_handled()
	elif is_erasing:
		_erase_cell()
		get_viewport().set_input_as_handled()

func _paint_cell() -> void:
	if file_dialog.visible: return
	var map_pos = tile_map.local_to_map(get_global_mouse_position())
	tile_map.set_cell(0, map_pos, current_source_id, current_atlas_coords)

func _erase_cell() -> void:
	if file_dialog.visible: return
	var map_pos = tile_map.local_to_map(get_global_mouse_position())
	tile_map.erase_cell(0, map_pos)

func _on_save_button_pressed() -> void:
	_is_saving = true
	file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	file_dialog.title = "Save Level Scene"
	file_dialog.popup_centered()

func _on_load_button_pressed() -> void:
	_is_saving = false
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.title = "Load Level Scene"
	file_dialog.popup_centered()

func _on_file_selected(path: String) -> void:
	if _is_saving:
		_save_level(path)
	else:
		_load_level(path)

func _save_level(path: String) -> void:
	var map_copy = tile_map.duplicate()
	map_copy.position = Vector2.ZERO
	
	var packed = PackedScene.new()
	var result = packed.pack(map_copy)
	if result == OK:
		ResourceSaver.save(packed, path)
		print("Successfully saved level to: ", path)
	else:
		push_error("Failed to pack scene for saving: ", result)

func _load_level(path: String) -> void:
	var res = ResourceLoader.load(path)
	if res and res is PackedScene:
		var new_map = res.instantiate()
		if new_map is TileMap:
			tile_map.queue_free()
			add_child(new_map)
			move_child(new_map, 0) # Keep it behind camera and UI
			tile_map = new_map
			print("Successfully loaded level from: ", path)
		else:
			push_error("Loaded scene is not a TileMap!")
			new_map.queue_free()
	else:
		push_error("Failed to load scene from: ", path)
