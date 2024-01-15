part of '../widgets.dart';

/// A widget which is used as the button for answers in multi choice tests.
/// 
/// The [AnswerButton] widget is a button which displays an answer to a question in a multi choice
/// test. The [text] is the answer this button will display. [onPressed] is the function which will
/// be run when the button is pressed. [onLongPress] is the function which will be run when the
/// button is long pressed. If [backgroundColor] is set, the button will use that color as its
/// background. If [backgroundColor] is NOT set, but [isSelectedAnswer] is, then the button will use
/// the theme's primary color as its background, representing that the user has selected this
/// answer. If neither [backgroundColor] or [isSelectedAnswer] is set, then the button will be its
/// default color. 
class AnswerButton extends StatelessWidget {

  /// Text to be displayed on the button.
  final String text;
  /// Whether the button is the selected answer, default is false.
  final bool isSelectedAnswer;
  /// The background color to use, optional.
  final Color? backgroundColor;
  /// What to run when the button is pressed. Usually, set this as the selected answer.
  final void Function() onPressed;
  /// What to run when the button is long pressed. Usually, clear the selected answer.
  final void Function()? onLongPress;

  /// Create an AnswerButton.
  const AnswerButton({
    super.key, 
    required this.text,
    required this.onPressed,
    this.onLongPress,
    this.isSelectedAnswer = false,
    this.backgroundColor
  });

  @override
  Widget build(BuildContext context) {
    late Color bgColor;

    // If backgroundColor is set, use it, else if isSelectedAnswer is true, use primary color,
    // else use the surface color for the button.
    if (backgroundColor != null) {
      bgColor = backgroundColor!;
    } else if (isSelectedAnswer) {
      bgColor = getTheme(context).colorScheme.primary;
    } else {
      bgColor = getTheme(context).colorScheme.surface;
    }//e if elif else

    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      child: expand(ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(15),
          backgroundColor: bgColor,
          shape: const BeveledRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(0))),
        ),
        onPressed: onPressed,
        onLongPress: onLongPress,
        child: Markd(text))
    ));
  }//e build()

}//e AnswerButton

/// A StatefulWidget page for the multi choice test mode.
/// 
/// The [MultiChoicePage] is a stateful widget designed to be a page for the multi choice test mode.
/// This page will display the current flashcard's term/question followed by what deck the card
/// belongs to. Separated by a diveder, [AnswerButton]s will be displayed representing the answers
/// for this particular term/question. The app bar displays the current mode, and the buttom app bar
/// displays the left and right navigation buttons. In the middle of these buttons is a timer
/// showing the elapsed time since starting.
class MultiChoicePage extends StatefulWidget {

  const MultiChoicePage({super.key, required this.title});

  final String title;

  @override
  State<MultiChoicePage> createState() => _MultiChoicePageState();
}//e MultiChoicePage

/// The state for [MultiChoicePage].
class _MultiChoicePageState extends State<MultiChoicePage> {

  /// The test for which the user is being tested.
  MultiChoice test = MultiChoice();

  /// The duration since starting the test.
  Duration timeElapsed = const Duration();
  /// A string representation of [timeElapsed] displaying down to the second.
  String get timeElapsedStr {
    return timeElapsed.toString().substring(0, timeElapsed.toString().length - 7);
  }//e timeElapsedStr

  /// A stopwatch which tracks the duration since starting.
  Stopwatch stopwatch = Stopwatch()..start();

  /// A timer which is used to update [timeElapsed] using [stopwatch] as the reference.
  Timer? timer;

  /// Start [timer] to run a function every second which will update [timeElapsed] to match
  /// [stopwatch]. Then call [super.initState()].
  @override
  void initState() {
    // Start the timer counting every second. On every second, update the [timeElapsed] variable to
    // match the [stopwatch].
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => timeElapsed = stopwatch.elapsed);
    });
    super.initState();
  }//e initState()

  /// When called, cancel the [timer], stop the [stopwatch], and call [super.dispose()].
  @override
  void dispose() {
    timer?.cancel();
    stopwatch.stop();
    super.dispose();
  }//e dispose()

  @override
  Widget build(BuildContext context) {

    // The data from the current flashcard.
    Map<String, dynamic> cardData = test.getCard();

    // The cards deck.
    String deck = cardData['deck']!;
    // The current cards term/question.
    String key = cardData['key']!;
    // The current cards possible definitions/answers, in randomized list. One of them is correct,
    // but there is no way to determin that from here.
    List<String> values = cardData['values'];

    // A Text widget which is padded on the left and right, where the data is the term/question of
    // the flashcard.
    Padding txtKey = padLeftRight(HeaderMarkd(key), 15);
    // A Text widget which is padded on the left and right, where the data is the deck of the
    // flashcard.
    Padding txtDeck = padLeftRight(TextItalic(deck), 15);

    // A list of [Widget]s which will hold all the [AnswerButton]s for the cards [values].
    List<Widget> answerBtnList = [];

    // For every value in [values] make and add an [AnswerButton] the [answerBtnList].
    for (String v in values) {
      // If this answer is selected.
      bool isSelectedAnswer = test.getEnteredAnswer() == v;
      // Add the button.
      answerBtnList.add(
        AnswerButton(
          text: v,
          isSelectedAnswer: isSelectedAnswer,
          onPressed: () => setState(() => test.answerCard(v)),
          onLongPress: () => isSelectedAnswer? setState(() => test.answerCard(null)) : null)
      );//e answerBtnList.add()
    }//e for

    // A column containing all the [AnswerButton]s for this card
    Column answerBtns = Column(mainAxisSize: MainAxisSize.min, children: answerBtnList);

    // A column holding all the data for this card to be on the test. The cards term/question, the
    // cards deck, and the possible [AnswerButton]s for this card.
    Column cardColumn = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        txtKey,
        txtDeck,
        const ThickDivider(),
        answerBtns
      ],
    );

    // A row containing the navigation buttons and the time elapsed timer.
    var navBtns = Row(children: [
      // The left navigation button.
      Expanded(
        flex: 1,
        child: IconButton(
          onPressed: () => test.hasPrevCard() ? setState(() => test.prevCard()) : null,
          icon: test.hasPrevCard() ?
            const Icon(Icons.chevron_left) : const Icon(Icons.circle_outlined)
        )
      ),
      // The time elapsed timer.
      Expanded(flex: 2, child: Center(child: Markd(timeElapsedStr, scale: 1.5,))),
      // The right navigation button.
      Expanded(
        flex: 1,
        child: IconButton(
          onPressed: () => test.hasNextCard() ?
            setState(() => test.nextCard()) :
            confirmPopup(
              context,
              getString('header_finish_test'),
              getString('msg_finish_test'),
              () {
                test.endTime = DateTime.now();
                MultiChoice.test = test;
                // Navigator.of(context).pop();
                Navigator.of(context).popAndPushNamed(
                  getRoute('multichoiceResult'));
              }),
          icon: test.hasNextCard() ?
            const Icon(Icons.chevron_right) : const Icon(Icons.check)
        )
      ),
    ]);

    return Scaffold(
      appBar: AppBar(
        // TODO make back button require confirmation.
        // TODO update the page title.
        title: TextBold(widget.title),
        centerTitle: true,
      ),
      body: Aspect(child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Align(alignment: Alignment.center, child:
          SingleChildScrollView(child: cardColumn))
        )),
      bottomNavigationBar: BottomAppBar(child: navBtns),
    );
  }//e build
}//e  _MultiChoicePageState


// TODO add doc comment
class MultiChoiceResultPage extends StatelessWidget {
  MultiChoiceResultPage({super.key, required this.title});

  final String title;

  final List<Flashcard> deck = Flashcard.filteredCards;

  @override
  Widget build(BuildContext context) {

    MultiChoice test = MultiChoice.test!;

    List<Widget> answeredCards = [];

    Map<String, dynamic> results = test.getResults();
    num points = results['points']!;
    num total = results['total']!;
    num percent = (results['percent']!*100).round();

    answeredCards.add(
      Markd(getString('txt_multichoice_stats', [points, total, percent]))
    );

    answeredCards.add(const Text(""));

    for (Flashcard card in test.deck) {
      List<Widget> cardList = [];
      cardList.add(padLeftRight(HeaderMarkd(card.key), 15));
      cardList.add(padLeftRight(TextItalic(card.deck), 15));
      cardList.add(const ThickDivider());

      List<Widget> answers = [];
      
      for (String ans in test.values[card.id]!) {
        String icon = "";
        Color buttonColor = getTheme(context).colorScheme.surface;
        if (ans == test.userAnswers[card.id]) {
          if (ans == card.values[0]) {
            icon = getString('ico_check');
            buttonColor = getTheme(context).colorScheme.primary;
          } else {
            icon = getString('ico_cross');
            buttonColor = getTheme(context).colorScheme.error;
          }
        } else {
          if (ans == card.values[0]) {
            icon = getString('ico_check');
            buttonColor = getTheme(context).colorScheme.error;
          }
        }
        answers.add(
          AnswerButton(
            text: "$icon $ans",
            onPressed: () {},
            backgroundColor: buttonColor)
        );//e add
      }//e for
      cardList.addAll(answers);
      cardList.add(const Text(""));
      answeredCards.add(Column(mainAxisSize: MainAxisSize.min, children: cardList));
    }//e for

    return Scaffold(
      appBar: AppBar(
        title: TextBold(title),
        centerTitle: true,
      ),
      body: Aspect(child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Align(alignment: Alignment.center, child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: answeredCards)
      )))),
      bottomNavigationBar: BottomAppBar(child: Center(
        child: Markd(
          results['duration']!.toString().substring(0, results['duration']!.toString().length - 7),
          scale: 1.5,))),
    );
  }//e build()
}//e MultiChoiceResultPage
