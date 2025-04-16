import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: VerticalPageView());
  }
}

class VerticalPageView extends StatefulWidget {
  @override
  _VerticalPageViewState createState() => _VerticalPageViewState();
}

class _VerticalPageViewState extends State<VerticalPageView> {
  final PageController _pageController = PageController();
  final ScrollController _listViewController = ScrollController();

  bool _isAtBottom = false;
  bool _isAtTop = true;

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();

    _listViewController.addListener(_handleScrollPosition);

    _pageController.addListener(() {
      final newPage = _pageController.page?.round() ?? 0;

      if (newPage != _currentPage) {
        if (_currentPage == 2 && newPage == 1 && _isAtBottom) {
          // Coming back from Page 3 to Page 2 and was previously at bottom
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _listViewController.jumpTo(_listViewController.position.maxScrollExtent);
          });
        }

        _currentPage = newPage;
      }
    });
  }

  void _handleScrollPosition() {
    final pos = _listViewController.position;
    setState(() {
      _isAtBottom = pos.pixels >= pos.maxScrollExtent;
      _isAtTop = pos.pixels <= pos.minScrollExtent;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _listViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        scrollDirection: Axis.vertical,
        controller: _pageController,
        children: [
          _buildPage("Page 1", Colors.teal),
          _buildListPage(),
          _buildPage("Page 3", Colors.deepPurple),
        ],
      ),
    );
  }

  Widget _buildPage(String title, Color color) {
    return Container(
      color: color,
      child: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 32, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildListPage() {
    return Listener(
      onPointerMove: (event) {
        final dy = event.delta.dy;

        if (_isAtBottom && dy < -10) {
          _pageController.nextPage(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } else if (_isAtTop && dy > 10) {
          _pageController.previousPage(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      },
      child: ListView.builder(
        controller: _listViewController,
        physics: const ClampingScrollPhysics(),
        itemCount: 50,
        itemBuilder: (context, index) => ListTile(title: Text("Item $index")),
      ),
    );
  }
}
