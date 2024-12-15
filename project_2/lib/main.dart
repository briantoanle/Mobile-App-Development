import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: "AIzaSyCUjW2ubYA7isWvadSnoS6e0gxnXU4ob5E",
        authDomain: "project-2-mobileappdev.firebaseapp.com",
        projectId: "project-2-mobileappdev",
        storageBucket: "project-2-mobileappdev.firebasestorage.app",
        messagingSenderId: "436564629857",
        appId: "1:436564629857:web:423d293dbe7577671acd20",
        measurementId: "G-R0N2XHRNFJ"),
  );
  debugPrint('Firebase initialized');
  runApp(MyApp());
}

// Models
class Stock {
  final String symbol;
  final String companyName;
  final double currentPrice;
  final double changePercentage;
  final List<double> historicalPrices;
  final Map<String, dynamic> metrics;

  Stock({
    required this.symbol,
    required this.companyName,
    required this.currentPrice,
    required this.changePercentage,
    required this.historicalPrices,
    required this.metrics,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      symbol: json['symbol'] ?? '',
      companyName: json['name'] ?? json['symbol'] ?? '',
      currentPrice: (json['c'] ?? 0).toDouble(),
      changePercentage: (json['dp'] ?? 0).toDouble(),
      historicalPrices: [],
      metrics: json['metric'] ?? {},
    );
  }
}

class NewsArticle {
  final String title;
  final String summary;
  final String url;
  final String datetime;
  final String? thumbnailUrl;

  NewsArticle({
    required this.title,
    required this.summary,
    required this.url,
    required this.datetime,
    this.thumbnailUrl,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['headline'] ?? '',
      summary: json['summary'] ?? '',
      url: json['url'] ?? '',
      datetime: json['datetime'].toString(),
      thumbnailUrl: json['thumbnail'] as String?,
    );
  }
}

// Main App
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      home: AuthWrapper(),
    );
  }
}

// Authentication Wrapper
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return HomeScreen();
        }
        return LoginScreen();
      },
    );
  }
}

// Login Screen
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _signIn,
              child: Text('Sign In'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}

// Register Screen
class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _register() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      Navigator.pop(
          context); // Go back to the previous screen after registration
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _register,
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}

// Stock Service
class StockService {
  static const String apiKey = 'cte9j2hr01qt478ldqjgcte9j2hr01qt478ldqk0';
  static const String baseUrl = 'https://finnhub.io/api/v1';

  static Future<Stock> getStockData(String symbol) async {
    try {
      // Fetch quote data
      final quoteResponse = await http.get(
        Uri.parse('$baseUrl/quote?symbol=$symbol&token=$apiKey'),
      );

      // Fetch company profile
      final profileResponse = await http.get(
        Uri.parse('$baseUrl/stock/profile2?symbol=$symbol&token=$apiKey'),
      );

      // Fetch company metrics
      final metricsResponse = await http.get(
        Uri.parse(
            '$baseUrl/stock/metric?symbol=$symbol&metric=all&token=$apiKey'),
      );

      if (quoteResponse.statusCode == 200) {
        final quoteData = jsonDecode(quoteResponse.body);
        final profileData = jsonDecode(profileResponse.body);
        final metricsData = jsonDecode(metricsResponse.body);

        final fullData = <String, dynamic>{
          ...quoteData,
          ...profileData,
          'metric': metricsData['metric'] ?? {},
        };

        return Stock.fromJson({...fullData, 'symbol': symbol});
      } else {
        throw Exception('Failed to load stock data');
      }
    } catch (e) {
      debugPrint('Error fetching stock data: $e');
      throw Exception('Failed to load stock data');
    }
  }

  static Future<List<double>> getHistoricalData(String symbol,
      {DateTime? fromDate, DateTime? toDate}) async {
    try {
      final now = DateTime.now();
      final from = fromDate ?? now.subtract(Duration(days: 30));
      final to = toDate ?? now;

      final response = await http.get(
        Uri.parse(
            '$baseUrl/stock/candle?symbol=$symbol&resolution=D&from=${from.millisecondsSinceEpoch ~/ 1000}&to=${to.millisecondsSinceEpoch ~/ 1000}&token=$apiKey'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['s'] == 'ok') {
          return List<double>.from(data['c'] ?? []);
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching historical data: $e');
      return [];
    }
  }

  static Future<List<NewsArticle>> getStockNews() async {
    final response = await http.get(
      Uri.parse('$baseUrl/news?category=general&token=$apiKey'),
    );

    if (response.statusCode == 200) {
      List<dynamic> newsJson = jsonDecode(response.body);
      return newsJson.map((article) => NewsArticle.fromJson(article)).toList();
    } else {
      throw Exception('Failed to load news');
    }
  }

  static Future<List<NewsArticle>> getStockNewsForSymbol(String symbol) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/company-news?symbol=$symbol&from=2023-01-01&to=2023-12-31&token=$apiKey'),
    );

    if (response.statusCode == 200) {
      List<dynamic> newsJson = jsonDecode(response.body);
      return newsJson.map((article) => NewsArticle.fromJson(article)).toList();
    } else {
      throw Exception('Failed to load news for $symbol');
    }
  }
}

// Home Screen
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Stock> watchlist = [];
  List<NewsArticle> news = [];
  final TextEditingController _symbolController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _loadNews();
    _loadWatchlist();
  }

  Future<void> _loadWatchlist() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('watchlist')
          .get();
      List<Stock> loadedWatchlist =
          snapshot.docs.map((doc) => Stock.fromJson(doc.data())).toList();

      // Fetch the latest data for each stock
      for (var stock in loadedWatchlist) {
        final latestStock = await StockService.getStockData(stock.symbol);
        setState(() {
          watchlist.add(latestStock);
        });
      }
      debugPrint('Watchlist loaded: ${watchlist.length} items');
    } catch (e) {
      debugPrint('Error loading watchlist: ${e.toString()}');
    }
  }

  Future<void> _loadNews() async {
    try {
      final newsArticles = await StockService.getStockNews();
      setState(() {
        news = newsArticles;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _addToWatchlist(String symbol) async {
    try {
      final stock = await StockService.getStockData(symbol);
      setState(() {
        watchlist.add(stock);
      });
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('watchlist')
          .doc(symbol)
          .set({
        'symbol': stock.symbol,
        'companyName': stock.companyName,
        'currentPrice': stock.currentPrice,
        'changePercentage': stock.changePercentage,
        // Add other fields as necessary
      });
      debugPrint('Stock added to watchlist: $symbol');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding stock: ${e.toString()}')),
      );
      debugPrint('Error adding stock: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Stock Tracker'),
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () => FirebaseAuth.instance.signOut(),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: 'Watchlist'),
              Tab(text: 'Market'),
              Tab(text: 'News'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildWatchlistTab(),
            _buildMarketTab(),
            _buildNewsTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Add Stock'),
                content: TextField(
                  controller: _symbolController,
                  decoration: InputDecoration(labelText: 'Stock Symbol'),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      _addToWatchlist(_symbolController.text.toUpperCase());
                      Navigator.pop(context);
                      _symbolController.clear();
                    },
                    child: Text('Add'),
                  ),
                ],
              ),
            );
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildWatchlistTab() {
    return ListView.builder(
      itemCount: watchlist.length,
      itemBuilder: (context, index) {
        final stock = watchlist[index];
        return ListTile(
          title: Text(stock.symbol),
          subtitle: Text(stock.companyName),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('\$${stock.currentPrice.toStringAsFixed(2)}'),
              Text(
                '${stock.changePercentage >= 0 ? '+' : ''}${stock.changePercentage.toStringAsFixed(2)}%',
                style: TextStyle(
                  color:
                      stock.changePercentage >= 0 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StockDetailScreen(stock: stock),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMarketTab() {
    return Center(
      child: Text('Market Overview - Coming Soon'),
    );
  }

  Widget _buildNewsTab() {
    return ListView.builder(
      itemCount: news.length,
      itemBuilder: (context, index) {
        final article = news[index];
        return Card(
          margin: EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(article.title),
            subtitle: Text(
              article.summary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () async {
              final Uri uri = Uri.parse(article.url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Could not open article')),
                );
              }
            },
          ),
        );
      },
    );
  }
}

class StockDetailScreen extends StatefulWidget {
  final Stock stock;
  StockDetailScreen({required this.stock});

  @override
  _StockDetailScreenState createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  List<NewsArticle> stockNews = [];

  @override
  void initState() {
    super.initState();
    _loadStockNews();
  }

  Future<void> _loadStockNews() async {
    try {
      final newsArticles =
          await StockService.getStockNewsForSymbol(widget.stock.symbol);
      setState(() {
        stockNews = newsArticles.take(20).toList(); // Limit to 20 articles
      });
    } catch (e) {
      debugPrint('Error loading stock news: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.stock.companyName)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.stock.symbol,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
                '10-Day Avg Trading Volume: ${widget.stock.metrics['10DayAverageTradingVolume']?.toStringAsFixed(2) ?? 'N/A'}'),
            Text(
                '52-Week High: \$${widget.stock.metrics['52WeekHigh']?.toStringAsFixed(2) ?? 'N/A'}'),
            Text(
                '52-Week Low: \$${widget.stock.metrics['52WeekLow']?.toStringAsFixed(2) ?? 'N/A'}'),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: stockNews.length,
                itemBuilder: (context, index) {
                  final article = stockNews[index];
                  return Card(
                    margin: EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: article.thumbnailUrl != null
                          ? Image.network(
                              article.thumbnailUrl!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : null,
                      title: Text(article.title),
                      subtitle: Text(
                        article.summary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        // Open news article URL
                        _openArticleUrl(article.url);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openArticleUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
}
