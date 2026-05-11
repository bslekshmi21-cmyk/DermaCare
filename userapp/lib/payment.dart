import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:userapp/editprof.dart';
import 'package:userapp/success.dart';

class PaymentGatewayScreen extends StatefulWidget {
  final int id;
  final int amt;

  const PaymentGatewayScreen({super.key, required this.id, required this.amt});

  @override
  State<PaymentGatewayScreen> createState() => _PaymentGatewayScreenState();
}

class _PaymentGatewayScreenState extends State<PaymentGatewayScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;

  final TextEditingController cardNumber = TextEditingController();
  final TextEditingController cardName = TextEditingController();
  final TextEditingController expiry = TextEditingController();
  final TextEditingController cvv = TextEditingController();

  Future<void> checkout() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    try {
      await supabase
          .from('tbl_cart')
          .update({'cart_status': 1}).eq('booking_id', widget.id);

      await supabase.from('tbl_booking').update({
        'booking_status': 2,
        'booking_amount': widget.amt
      }).eq('booking_id', widget.id);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PaymentSuccessPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment Failed")),
      );
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),

      appBar: AppBar(
        title: const Text("Secure Payment"),
        backgroundColor: const Color(0xFFF4F7FB),
        foregroundColor: const Color(0xFF0A6C74),
        elevation: 0,
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [

              /// 💳 CARD PREVIEW (RESTORED)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Icon(
                      Icons.credit_card,
                      size: 40,
                      color: Color(0xFF0A6C74),
                    ),

                    const SizedBox(height: 25),

                    Text(
                      cardNumber.text.isEmpty
                          ? "XXXX XXXX XXXX XXXX"
                          : cardNumber.text,
                      style: const TextStyle(
                        fontSize: 20,
                        letterSpacing: 2,
                        color: Color(0xFF0A6C74),
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        Text(
                          cardName.text.isEmpty
                              ? "CARD HOLDER"
                              : cardName.text.toUpperCase(),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),

                        Text(
                          expiry.text.isEmpty ? "MM/YY" : expiry.text,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// FORM
              Form(
                key: _formKey,
                child: Column(
                  children: [

                    /// CARD NUMBER
                    TextFormField(
                      controller: cardNumber,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(16),
                        CardFormatter()
                      ],
                      decoration: inputDecoration("Card Number"),
                      onChanged: (_) => setState(() {}),
                      validator: (value) {
                        if (value == null ||
                            value.replaceAll(" ", "").length != 16) {
                          return "Enter valid card number";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    /// NAME
                    TextFormField(
                      controller: cardName,
                      decoration: inputDecoration("Card Holder Name"),
                      onChanged: (_) => setState(() {}),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Enter name";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [

                        /// EXPIRY (FIXED)
                        Expanded(
                          child: TextFormField(
                            controller: expiry,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                              ExpiryFormatter()
                            ],
                            decoration: inputDecoration("Expiry MM/YY"),
                            onChanged: (_) => setState(() {}),
                            validator: (value) {
                              if (value == null ||
                                  value.length != 5 ||
                                  !value.contains('/')) {
                                return "Invalid";
                              }

                              final parts = value.split('/');
                              final month = int.tryParse(parts[0]);
                              final year = int.tryParse(parts[1]);

                              if (month == null || year == null) {
                                return "Invalid";
                              }

                              if (month < 1 || month > 12) {
                                return "Invalid";
                              }

                              final now = DateTime.now();
                              int currentYear = now.year % 100;
                              int currentMonth = now.month;

                              if (year < currentYear) {
                                return "Expired";
                              }

                              if (year == currentYear &&
                                  month < currentMonth) {
                                return "Expired";
                              }

                              return null;
                            },
                          ),
                        ),

                        const SizedBox(width: 10),

                        /// CVV
                        Expanded(
                          child: TextFormField(
                            controller: cvv,
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(3)
                            ],
                            decoration: inputDecoration("CVV"),
                            validator: (value) {
                              if (value == null || value.length != 3) {
                                return "Invalid";
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    /// PAY BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isProcessing ? null : checkout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A6C74),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isProcessing
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                "Pay ₹${widget.amt}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,color: Colors.white),
                              ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    Text(
                      "Secure payment powered by FragranceHub",
                      style: TextStyle(color: Colors.grey.shade600),
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

  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF0A6C74)),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0A6C74)),
      ),
    );
  }
}

/// CARD FORMATTER
class CardFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue) {
    var text = newValue.text.replaceAll(" ", "");

    if (text.length > 16) return oldValue;

    var newText = "";
    for (int i = 0; i < text.length; i++) {
      if (i % 4 == 0 && i != 0) newText += " ";
      newText += text[i];
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

/// EXPIRY FORMATTER
class ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue) {
    String text = newValue.text.replaceAll("/", "");

    if (text.length > 4) return oldValue;

    if (text.length >= 3) {
      text = "${text.substring(0, 2)}/${text.substring(2)}";
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}