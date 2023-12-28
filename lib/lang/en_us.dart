Map<String, String> get getLang {
	Map<String, String> lang = {};
	lang['title'] = 'Flashpaws';

  // page titles
  lang['settingsPage'] = 'Settings';
  lang['reviewPage'] = 'Review';
  lang['reviewCompletePage'] = 'Review Complete';
  lang['practicePage'] = 'Practice - \${0} Cards Practiced';

  // generic
  lang['confirm'] = 'Confirm';
  lang['cancel'] = 'Cancel';
  lang['close'] = 'Close';

  // btns
  lang['btn_all_cards'] = 'All Cards';
  lang['btn_practice'] = 'Practice';
  lang['btn_review'] = 'Review';
  lang['btn_multitest'] = 'Multi-Choice';
  lang['btn_light_theme'] = 'Light Theme';
  lang['btn_dark_theme'] = 'Dark Theme';
  lang['btn_auto_theme'] = 'System Theme';
  lang['btn_theme_brightness_menu'] = 'Change Theme';
  lang['btn_cycle_theme_color'] = 'Cycle Theme Color';

  // tooltip
  lang['tooltip_create_card'] = 'Create card';

  // heading
  lang['header_create_new_card'] = 'Create New Card';
  lang['header_delete_card'] = 'Delete Flashcard';
  lang['header_exit_app'] = 'Exit ${lang['title']}';

  // msg
  lang['msg_confirm_delete_card'] = 'The card \'\${0}\' will be deleted, continue?';
  lang['msg_confirm_app_exit'] = 'You are about to exit the app, continue?';

  // texts
  lang['txt_review_stats'] = '**STATS:**  \n**Score:** \${0} / \${1}  \n**Percent:** \${2}';

  // hint
  lang['hint_create_new_card_key'] = 'Key';
  lang['hint_create_new_card_deck'] = 'Deck';
  lang['hint_create_new_card_values'] = 'Values (separate by: [new line]+++[newline])';
  lang['hint_create_new_card_tags'] = 'Tags (separated by [space])';

  //intro cards
  lang['introcard_how_to_new_card'] = 'How to create a new card.';
  lang['introcard_how_to_new_card_answer'] = '''
To make a new card, press the '+' button on the bottom right of the screen. Enter the information, and
Tada!!!
'''.trim();
  lang['introcard_how_to_sort_cards'] = 'How to sort cards.';
  lang['introcard_how_to_sort_cards_answer'] = '''
Cards are sorted similar to folders on your computer. These 'folders' are represented by the second
row of buttons. Selecting one of these buttons will update the displayed contents to show the cards
and folders that are nested under the selected folder. To go back a folder, you can simply press the
folder you want to view from. And if you want to clear the filter, you can press the 'All Cards'
button.
'''.trim();
  lang['introcard_how_to_practice'] = 'How to practice flashcards.';
  lang['introcard_how_to_practice_answer'] = '''
The practice mode buttons are viewable at the top of the display. The 'Flashcard' mode will go
through all the cards matched by the current filter. The card will only show the key until flipped
revealing the value. You will also be givin a way to mark how well you remembered the information on
the card. The 'Infinite' mode will continously cycle through the matched cards the same way that
'Flashcards' does, except with no end, and no way to mark the level of understanding. 'Multi-Choice'
provides a multiple choice test for the matched cards.
'''.trim();

	return lang;
}