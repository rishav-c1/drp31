import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

class WeeklyRecapPage extends StatefulWidget {
  final int goalsCompleted;
  final int totalPoints;

  const WeeklyRecapPage({
    required this.goalsCompleted,
    required this.totalPoints,
  });

  @override
  State<WeeklyRecapPage> createState() => _WeeklyRecapPage();
}
class _WeeklyRecapPage extends State<WeeklyRecapPage> {
  final controller = ConfettiController();

  @override
  void initState() {
    super.initState();
    controller.play();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Congratulations!'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "That's a wrap!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            Center(child: Text(
              'Congrats! This week you have achieved ${widget.goalsCompleted} goals, for a total of ${widget.totalPoints} points.',
              style: TextStyle(fontSize: 18),
            ),
            ),
            const SizedBox(height: 8),
            const SizedBox(height: 32),
            ConfettiWidget(
              confettiController: controller,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.orange,
                Colors.purple,
                Colors.yellow,
              ],
            ),
          ],
        ),
      ),
    );
  }
}