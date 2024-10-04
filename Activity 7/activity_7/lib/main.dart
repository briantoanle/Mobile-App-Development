import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({Key? key}) : super(key: key);

  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _output = '0';
  String _currentNumber = '';
  String _operation = '';
  double _firstNumber = 0;
  bool _isDecimal = false;

  void _onButtonPressed(String buttonText) {
    setState(() {
      if (buttonText == 'C') {
        _clear();
      } else if (buttonText == '+' ||
          buttonText == '-' ||
          buttonText == '*' ||
          buttonText == '/') {
        _setOperation(buttonText);
      } else if (buttonText == '=') {
        _calculateResult();
      } else if (buttonText == '.') {
        _addDecimalPoint();
      } else {
        _appendNumber(buttonText);
      }
    });
  }

  void _clear() {
    _output = '0';
    _currentNumber = '';
    _operation = '';
    _firstNumber = 0;
    _isDecimal = false;
  }

  void _setOperation(String op) {
    if (_currentNumber.isNotEmpty) {
      _firstNumber = double.parse(_currentNumber);
      _currentNumber = '';
      _operation = op;
      _isDecimal = false;
    } else if (_output != '0') {
      // Allow chaining operations
      _firstNumber = double.parse(_output);
      _operation = op;
      _isDecimal = false;
    }
  }

  void _calculateResult() {
    if (_operation.isNotEmpty) {
      double secondNumber = _currentNumber.isNotEmpty
          ? double.parse(_currentNumber)
          : _firstNumber;
      double result;
      switch (_operation) {
        case '+':
          result = _firstNumber + secondNumber;
          break;
        case '-':
          result = _firstNumber - secondNumber;
          break;
        case '*':
          result = _firstNumber * secondNumber;
          break;
        case '/':
          if (secondNumber != 0) {
            result = _firstNumber / secondNumber;
          } else {
            _output = 'Error';
            return;
          }
          break;
        default:
          return;
      }
      _output =
          result.toStringAsFixed(8).replaceAll(RegExp(r'([.]*0+)(?!.*\d)'), '');
      _currentNumber = _output;
      _operation = '';
      _isDecimal = _output.contains('.');
    }
  }

  void _addDecimalPoint() {
    if (!_isDecimal) {
      if (_currentNumber.isEmpty) {
        _currentNumber = '0';
      }
      _currentNumber += '.';
      _isDecimal = true;
      _output = _currentNumber;
    }
  }

  void _appendNumber(String number) {
    if (_currentNumber == '0' && number != '0' && !_isDecimal) {
      _currentNumber = number;
    } else {
      _currentNumber += number;
    }
    _output = _currentNumber;
  }

  Widget _buildButton(String buttonText, {Color color = Colors.blueGrey}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.all(24.0),
          ),
          child: Text(
            buttonText,
            style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          onPressed: () => _onButtonPressed(buttonText),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
      ),
      body: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.centerRight,
            padding:
                const EdgeInsets.symmetric(vertical: 24.0, horizontal: 12.0),
            child: Text(
              _output,
              style:
                  const TextStyle(fontSize: 48.0, fontWeight: FontWeight.bold),
            ),
          ),
          const Expanded(child: Divider()),
          Column(
            children: [
              Row(
                children: [
                  _buildButton('7'),
                  _buildButton('8'),
                  _buildButton('9'),
                  _buildButton('/', color: Colors.orange),
                ],
              ),
              Row(
                children: [
                  _buildButton('4'),
                  _buildButton('5'),
                  _buildButton('6'),
                  _buildButton('*', color: Colors.orange),
                ],
              ),
              Row(
                children: [
                  _buildButton('1'),
                  _buildButton('2'),
                  _buildButton('3'),
                  _buildButton('-', color: Colors.orange),
                ],
              ),
              Row(
                children: [
                  _buildButton('.'),
                  _buildButton('0'),
                  _buildButton('C', color: Colors.red),
                  _buildButton('+', color: Colors.orange),
                ],
              ),
              Row(
                children: [
                  _buildButton('=', color: Colors.green),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
