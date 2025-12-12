import 'package:flutter/material.dart';
import '../widgets/neumorphic_container.dart';
import '../widgets/neumorphic_button.dart';
import '../widgets/neumorphic_slider.dart';

/// Demo screen to showcase neumorphic components in both light and dark themes
class NeumorphicDemoScreen extends StatefulWidget {
  const NeumorphicDemoScreen({super.key});

  @override
  State<NeumorphicDemoScreen> createState() => _NeumorphicDemoScreenState();
}

class _NeumorphicDemoScreenState extends State<NeumorphicDemoScreen> {
  bool _isPressed = false;
  double _sliderValue = 0.5;
  bool _useDarkTheme = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _useDarkTheme ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: const Text('Neumorphic Components Demo'),
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Theme toggle section
              Text(
                'Theme',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              NeumorphicContainer(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(Icons.light_mode),
                    const SizedBox(width: 20),
                    Expanded(
                      child: NeumorphicSlider(
                        value: _useDarkTheme ? 1.0 : 0.0,
                        divisions: 1,
                        onChanged: (value) {
                          setState(() {
                            _useDarkTheme = value > 0.5;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Icon(Icons.dark_mode),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Neumorphic Container examples
              Text(
                'Neumorphic Container',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Expanded(
                    child: NeumorphicContainer(
                      child: SizedBox(
                        height: 100,
                        child: Center(
                          child: Text('Normal'),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isPressed = !_isPressed;
                        });
                      },
                      child: NeumorphicContainer(
                        isPressed: _isPressed,
                        child: SizedBox(
                          height: 100,
                          child: Center(
                            child: Text(_isPressed ? 'Pressed' : 'Tap Me'),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Neumorphic Button examples
              Text(
                'Neumorphic Button',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 20,
                children: [
                  NeumorphicButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Button pressed!')),
                      );
                    },
                    child: const Text('Press Me'),
                  ),
                  NeumorphicButton(
                    onPressed: () {},
                    disabled: true,
                    child: const Text('Disabled'),
                  ),
                  NeumorphicButton(
                    onPressed: () {},
                    width: 150,
                    height: 60,
                    borderRadius: 30,
                    child: const Text('Custom Size'),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Neumorphic Slider examples
              Text(
                'Neumorphic Slider',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              Column(
                children: [
                  Text('Value: ${_sliderValue.toStringAsFixed(2)}'),
                  const SizedBox(height: 10),
                  NeumorphicSlider(
                    value: _sliderValue,
                    onChanged: (value) {
                      setState(() {
                        _sliderValue = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  NeumorphicSlider(
                    value: 0.75,
                    divisions: 4,
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 20),
                  NeumorphicSlider(
                    value: 30,
                    min: 0,
                    max: 100,
                    onChanged: (value) {},
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Custom styled examples
              Text(
                'Custom Styled Examples',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              NeumorphicContainer(
                borderRadius: 15,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.favorite,
                      size: 40,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Neumorphic Design',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Soft shadows with smooth animations',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}