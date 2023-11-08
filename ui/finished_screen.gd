extends PanelContainer

func init_state(level_id, time, current_user_level, finished_level_index, star_level_reached, is_dead):
	%TimeLabel.text = "Your time: %s" % Utils.get_time_label(time)
	%ScoreBoard.show_scores(ProfileManager.get_level_times(ProfileManager.get_current_profile_id(), level_id), is_dead)

	var star_requirements = Levels.get_star_requirements(level_id)
	
	%StarSectionContainer.set_star_level_requirements(star_requirements)
	%StarSectionContainer.set_star_level_reached(star_level_reached)

	var player_on_last_level = current_user_level <= finished_level_index
	var next_level = Levels.get_next_level(level_id)
	
	%NextLevelButton.visible = false
	
	if player_on_last_level and not is_dead:
		%NextLevelTipContainer.visible = true
		if star_level_reached != null:
			if next_level != null:
				%NextLevelTipContainer.get_node("Label").text = "Congratulations, you unlocked the next level!"
				%NextLevelButton.visible = true
			else:
				%NextLevelTipContainer.get_node("Label").text = "Congratulations, you beat the game!! You are a winner!"
		else:
			%NextLevelTipContainer.get_node("Label").text = "Beat the bronze time limit (%ss) to advance to the next level!" % star_requirements[0]
	elif not is_dead:
		%NextLevelTipContainer.visible = false
	else:
		%NextLevelTipContainer.get_node("Label").text = "You made it but also... you're already dead"
	
func _on_try_again_button_pressed():
	Events.try_again_pressed.emit()


func _on_leve_l_selection_button_pressed():
	Events.new_game_pressed.emit()

func _on_next_level_button_pressed():
	Events.next_level_pressed.emit()
