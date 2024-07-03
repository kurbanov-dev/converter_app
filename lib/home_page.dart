import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String fromCurrency = 'USD';
  String toCurrency = 'EUR';
  double rate = 0;
  double total = 0;
  TextEditingController amountController = TextEditingController();
  List<String> currencies = [];

  @override
  void initState() {
    super.initState();
    _getCurrencies();
  }

  // logic
  Future<void> _getCurrencies() async {
    var response = await http
        .get(Uri.parse('https://api.exchangerate-api.com/v4/latest/USD'));

    var data = json.decode(response.body);
    setState(() {
      currencies = (data['rates'] as Map<String, dynamic>).keys.toList();
      rate = data['rates'][toCurrency];
    });
  }

  Future<void> _getRate() async {
    var response = await http.get(
        Uri.parse('https://api.exchangerate-api.com/v4/latest/$fromCurrency'));

    var data = json.decode(response.body);
    setState(() {
      rate = data['rates'][toCurrency];
    });
  }

  void _swapCurrencies() {
    setState(() {
      String temp = fromCurrency;
      fromCurrency = toCurrency;
      toCurrency = temp;
      _getRate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1d2630),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text(
          'Currency Converter',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(40),
                child: Image.asset(
                  'images/currency.png',
                  width: MediaQuery.of(context).size.width / 2,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                child: TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    labelStyle: const TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    if (value != '') {
                      setState(() {
                        double amount = double.parse(value);
                        total = amount * rate;
                      });
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 100,
                      child: DropdownButton<String>(
                        dropdownColor: const Color(0xFF1d2630),
                        value: fromCurrency,
                        isExpanded: true,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                        items: currencies.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            fromCurrency = newValue!;
                            _getRate();
                          });
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: _swapCurrencies,
                      icon: const Icon(
                        Icons.swap_horiz,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: DropdownButton<String>(
                        dropdownColor: const Color(0xFF1d2630),
                        value: toCurrency,
                        isExpanded: true,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 18),
                        items: currencies.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            toCurrency = newValue!;
                            _getRate();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Rate $rate',
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
              const SizedBox(height: 30),
              Text(
                total.toStringAsFixed(3),
                style: const TextStyle(fontSize: 40, color: Colors.greenAccent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
