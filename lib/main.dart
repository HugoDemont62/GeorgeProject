import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'cuddle_storage.dart';

void main() {
  runApp(const CatClickerApp());
}

class CatClickerApp extends StatelessWidget {
  const CatClickerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const CatHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CatHomePage extends StatefulWidget {
  const CatHomePage({super.key});

  @override
  State<CatHomePage> createState() => _CatHomePageState();
}

class _CatHomePageState extends State<CatHomePage>
    with SingleTickerProviderStateMixin {
  int _tapCount = 0;
  int _cuddlesPerClick = 1;
  int _upgradePrice = 10;
  int _clicksPerSecond = 0;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  final ExampleStorage _storage = ExampleStorage();
  Timer? _clickTimer;
  List<_ImageData> _imagesData = [];
  final int _maxImages = 10; // Maximum number of images to display

  final List<String> _images = [
    'assets/images/George.jpg',
    'assets/images/George2.jpg',
    'assets/images/George3.jpg',
    'assets/images/George4.jpg',
    'assets/images/George5.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _loadData();
    _startClickTimer();
  }

  void _startClickTimer() {
    _clickTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_clicksPerSecond > 1) {
          _addRandomImage();
          _controller.forward(from: 0.0);
        }
        _clicksPerSecond = 0;
      });
    });
  }

  void _addRandomImage() {
    final random = Random();
    final image = _images[random.nextInt(_images.length)];
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Define the safe area where images should not appear
    final safeArea = Rect.fromLTWH(
      screenWidth / 2 - 100, // Centered horizontally
      screenHeight / 2 - 200, // Centered vertically with some margin
      200, // Width of the safe area
      400, // Height of the safe area
    );

    double x, y;
    do {
      x = random.nextDouble() * (screenWidth - 100);
      y = random.nextDouble() * (screenHeight - 100);
    } while (safeArea.contains(Offset(x, y)));

    if (_imagesData.length >= _maxImages) {
      _imagesData.removeAt(0); // Remove the oldest image
    }

    final imageData = _ImageData(image, x, y);
    _imagesData.add(imageData);

    // Remove the image after a certain duration
    Timer(const Duration(seconds: 1), () {
      setState(() {
        _imagesData.remove(imageData);
      });
    });
  }

  void _handleTap() {
    setState(() {
      _tapCount += _cuddlesPerClick;
      _clicksPerSecond++;
    });
    _storage.storeData(_tapCount, _cuddlesPerClick, _upgradePrice);
  }

  Future<void> _loadData() async {
    final data = await _storage.loadData();
    setState(() {
      _tapCount = data['tapCount']!;
      _cuddlesPerClick = data['cuddlesPerClick']!;
      _upgradePrice = data['upgradePrice']!;
    });
  }

  void _buyUpgrade() {
    if (_tapCount >= _upgradePrice) {
      setState(() {
        _tapCount -= _upgradePrice;
        _cuddlesPerClick++;
        _upgradePrice = (_upgradePrice * 1.5).toInt();
      });
      _storage.storeData(_tapCount, _cuddlesPerClick, _upgradePrice);
    }
  }

  void _resetGame() {
    setState(() {
      _tapCount = 0;
      _cuddlesPerClick = 1;
      _upgradePrice = 10;
      _imagesData.clear(); // Clear all images when the game is reset
    });
    _storage.resetData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('George Clicker')),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: _handleTap,
                  child: Image.asset('assets/images/George.jpg', width: 200),
                ),
                const SizedBox(height: 30),
                Text('cuddle: $_tapCount', style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 10),
                Text('Carresses par clic: $_cuddlesPerClick', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _buyUpgrade,
                  child: Text('Acheter un upgrade ($_upgradePrice carresses)'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _resetGame,
                  child: const Text('Redémarrer'),
                ),
              ],
            ),
          ),
          ..._imagesData.map((data) {
            return Positioned(
              left: data.x,
              top: data.y,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Transform(
                  transform: Matrix4.identity()
                    ..rotateZ(_rotationAnimation.value)
                    ..scale(_scaleAnimation.value),
                  alignment: Alignment.center,
                  child: Image.asset(data.image, width: 100),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _clickTimer?.cancel();
    super.dispose();
  }
}

class _ImageData {
  final String image;
  final double x;
  final double y;

  _ImageData(this.image, this.x, this.y);
}