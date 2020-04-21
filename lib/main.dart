import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

void main() => runApp(ExerciseHelper());

class ExerciseHelper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MaterialApp(
        title: 'Exercise Helper',
        theme: ThemeData(
            fontFamily: 'FredokaOne',
        ),
        home: HomePage()
      //home: DemoPage('Montserrat')
    );
  }
}

class Workout {
  const Workout(this.name, this.color, this.icon, this.exercises);
  final String name;
  final Color color;
  final Icon icon;
  final List<String> exercises;
}

const List<Workout> workouts = [
  Workout("Workout A", Colors.lightBlue, Icon(MdiIcons.alphaABox, size: 35, color: Colors.white),
    ["Single Leg Box Squats", "1-1/2 Bottomed Out Squats", "Jump Squats",
    "Handstand Pushups", "Rotational Pushups", "Cobra Pushups",
    "Heel Touch Squats", "Sprinter Lunges", "Pylo Sprinter Lunges",
    "Pullups", "Human Pullovers", "Inverted Chin Curls",
    "Reverse Corkscrews", "Black Widow Knee Slides", "Levitation Crunches",
    "Angels and Devils"]
  ),
  Workout("Workout B", Colors.purple, Icon(MdiIcons.alphaBBox, size: 35, color: Colors.white),
    ["Slick Floor Bridge Curls", "Long Leg Marches", "High Hip Bucks",
    "Variable Wall Pushups", "Side Lateral Raises", "Triceps Extensions",
    "Crossover Step Ups", "Reverse Lunges", "Split Squat Jumps",
    "Chinups", "Inverted Rows", "Back Widows",
    "Ab Halos", "V-Up Tucks", "Sit-Up Elbow Thrusts",
    "Reverse Hypers"]
  ),
  Workout("Ab Workout", Colors.red, Icon(FontAwesomeIcons.child, size: 25, color: Colors.white),
    ["Figure 8s", "Windshield Wipers", "Twisting Pistons", "30s Rest / Starfish Crunch",
    "Tuck Planks", "Upper Circle Crunches", "Upper Circle Crunches"]
  )
];


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
          index: _currentIndex,
          children: workouts.map<Widget>((Workout w) {
            return WorkoutView(workout: w);
          }).toList()
      ),
      bottomNavigationBar: SnakeNavigationBar(
        style: SnakeBarStyle.pinned,
        snakeShape: SnakeShape.rectangle,
        snakeColor: Colors.white,
        padding: EdgeInsets.zero,
        selectedItemColor: workouts[_currentIndex].color,
        backgroundColor: workouts[_currentIndex].color,
        currentIndex: _currentIndex,
        onPositionChanged: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: workouts.map((Workout w) {
          return BottomNavigationBarItem(
              icon: w.icon
          );
        }).toList()
      )
    );
  }
}


class WorkoutView extends StatefulWidget {
  WorkoutView({Key key, this.workout}) : super(key: key);
  final Workout workout;

  @override
  _WorkoutViewState createState() => _WorkoutViewState();
}

class _WorkoutViewState extends State<WorkoutView> {
  bool started = false;
  Timer timer;
  int timeCounter = 65;
  int index = 0;

  final audioPlayer = AssetsAudioPlayer();

  @override
  void dispose() {
    if (timer != null) {
      timer.cancel();
    }
    audioPlayer.dispose();
    super.dispose();
  }

  void tapped() {
    setState(() { started = !started; });

    if (timer != null) {
      timer.cancel();
    }

    timer = new Timer.periodic(Duration(seconds: 1), (Timer t) {
        setState(() {
          if (started) {
            if (timeCounter <= 1) {
              audioPlayer.open(
                Audio("assets/audio/finish.ogg"),
              );
              timeCounter = 65;
              started = !started;
              t.cancel();
              if (index == widget.workout.exercises.length - 1)
                index = 0;
              else
                index++;
            }
            else {
              timeCounter = timeCounter - 1;
            }
          }
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workout.name, style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.w700)),
        backgroundColor: widget.workout.color,
        actions: <Widget>[
          PopupMenuButton<String>(
            color: started ? Colors.white : widget.workout.color,
            elevation: 2.0,
            offset: Offset.fromDirection(pi/2, 48.0),
            icon: Icon(Icons.more_vert, color: Colors.white, size: 30),
            onSelected: (value) {
              if (value == 'Timer' || value == 'Workout') {
                setState(() {
                  if (timer != null) {
                    timer.cancel();
                  }
                  if (started) {
                    started = false;
                  }
                  timeCounter = 65;
                  if (value == 'Workout') {
                    index = 0;
                  }
                });
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                  value: 'Timer',
                  child: Text('Reset Timer', style: TextStyle(color: started ? widget.workout.color : Colors.white))
              ),
              PopupMenuItem<String>(
                  value: 'Workout',
                  child: Text('Reset Workout', style: TextStyle(color: started ? widget.workout.color : Colors.white))
              ),
            ],
          )
        ],
      ),
      backgroundColor: started ? widget.workout.color : Colors.white,
      body: InkWell(
        radius: 3500.0,
        onTap: tapped,
        splashColor: started ? Colors.white : widget.workout.color.withAlpha(1000),
        //highlightColor: Colors.lightBlue,
        child: Container(
          //color: Colors.white,
          padding: const EdgeInsets.all(20.0),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("${widget.workout.exercises[index]}", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 56.0, color: started ? Colors.white : widget.workout.color)),
              Text("", style: TextStyle(fontSize: 60.0)),
              Text("$timeCounter", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 52.0, color: started ? Colors.white : widget.workout.color))
            ]
          )
        ),
      )
    );
  }
}