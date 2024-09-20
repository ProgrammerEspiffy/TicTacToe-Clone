extends Node2D

@export var circle_scene: PackedScene
@export var cross_scene: PackedScene

#Board Grid
var grid_data: Array
var grid_pos: Vector2i
var board_size: int
var cell_size: int
#BoardSizeWidthX & BoardSizeScaleX
var bswx: int
var bssx: float

var player: int
var moves: int
var winner : int
var temp_marker
var player_panel_pos: Vector2i


#Check_win
var row_sum: int
var col_sum: int
var diagonal1_sum: int
var diagonal2_sum: int

func _ready():
	bswx = $Tabuleiro.texture.get_width()
	bssx = $Tabuleiro.scale.x
	board_size = bswx * bssx
	print(board_size)
	
	cell_size = board_size / 3
	
	#Pegar as Cordenadas do pequeno painel a canto direito da tela
	player_panel_pos = $PlayerPanel.get_position()
	
	new_game()

func _process(delta):
	pass

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if event.position.x < board_size and event.position.y < board_size:
				grid_pos = Vector2i(event.position / cell_size)
				if grid_data[grid_pos.x][grid_pos.y] == 0:
					moves += 1
					grid_data[grid_pos.x][grid_pos.y] = player
					create_marker(player, grid_pos * cell_size + Vector2i(cell_size / 2, cell_size / 2))
					if check_win() != 0:
						get_tree().paused = true	
						$GameOverMenu.show()
						if winner == 1:
							$GameOverMenu.get_node("ResultLabel").text = "Player1 Wins!"
						elif winner == -1:	
							$GameOverMenu.get_node("ResultLabel").text = "Player2 Wins!"
						
						# Checa se o Tabuleiro está cheio
					elif moves == 9:
						get_tree().paused = true	
						$GameOverMenu.show()
						$GameOverMenu.get_node("ResultLabel").text = "It's a Tie"
					player *= -1
					# Atualizar o painel do marcador
					temp_marker.queue_free()
					create_marker(player, player_panel_pos + Vector2i(cell_size / 2, cell_size / 2), true)
					print(grid_data)

func new_game():
	player = 1
	moves = 0
	winner = 0
	grid_data = [
		[0, 0, 0],
		[0, 0, 0],
		[0, 0, 0]
	]
	row_sum = 0
	col_sum = 0
	diagonal1_sum = 0
	diagonal2_sum = 0
	# Limpar os Marcadores existentes
	get_tree().call_group("Circles", "queue_free")
	get_tree().call_group("Crosses", "queue_free")
	#Criar o marcador para mostrar qual é a vez do Jogador
	create_marker(player, player_panel_pos + Vector2i(cell_size / 2, cell_size / 2), true)
	$GameOverMenu.hide()
	get_tree().paused = false

func create_marker(player, position, temp=false):
	if player == 1:
		var circle = circle_scene.instantiate()
		circle.position = position
		add_child(circle)
		if temp: temp_marker = circle
	else:
		var cross = cross_scene.instantiate()
		cross.position = position
		add_child(cross)
		if temp: temp_marker = cross

func check_win():
	#Somar os marcadores em cada linha, coluna e diagonal
	for i in len(grid_data):
		row_sum = grid_data[i][0] + grid_data[i][1] + grid_data[i][2]
		col_sum = grid_data[0][i] + grid_data[1][i] + grid_data[2][i]
		diagonal1_sum = grid_data[0][0] + grid_data[1][1] + grid_data[2][2]
		diagonal2_sum = grid_data[0][2] + grid_data[1][1] + grid_data[2][0]
	
		#check if either player has all of the markers in one line
		if row_sum == 3 or col_sum == 3 or diagonal1_sum == 3 or diagonal2_sum == 3:
			winner = 1
		elif row_sum == -3 or col_sum == -3 or diagonal1_sum == -3 or diagonal2_sum == -3:
			winner = -1
	return winner

func _on_game_over_menu_restart():
	new_game()
