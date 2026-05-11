import 'package:dermatologist_app/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class Changepass extends StatefulWidget {
  const Changepass({super.key});

  @override
  State<Changepass> createState() => _ChangepassState();
}

class _ChangepassState extends State<Changepass> {
  // SAME COLORS AS CART PAGE
  static const Color bgColor = Color(0xFFF5F6FA);
  static const Color primary = Color(0xFF2E7431);

  final TextEditingController _oldPasswordController =
      TextEditingController();

  final TextEditingController _newPasswordController =
      TextEditingController();

  final TextEditingController
      _confirmPasswordController =
      TextEditingController();

  String _storedOldPassword = "";
  bool _isLoading = false;

  bool _showOld = false;
  bool _showNew = false;
  bool _showConfirm = false;

  @override
  void initState() {
    super.initState();
    _fetchCurrentPassword();
  }

  Future<void> _fetchCurrentPassword() async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) return;

      final response = await supabase
          .from('tbl_dermatologist')
          .select('dermatologist_password')
          .eq('dermatologist_id', user.id)
          .maybeSingle();

      if (response != null) {
        setState(() {
          _storedOldPassword =
              response['dermatologist_password'] ?? '';
        });
      }
    } catch (e) {
      debugPrint("Error fetching password: $e");
    }
  }

  Future<void> _handleChangePassword() async {
    final oldInput =
        _oldPasswordController.text.trim();

    final newPassword =
        _newPasswordController.text.trim();

    final confirmPassword =
        _confirmPasswordController.text.trim();

    if (oldInput.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      _showMsg("Please fill all fields");
      return;
    }

    // RED ERROR MESSAGE FOR OLD PASSWORD
    if (oldInput != _storedOldPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          content: Text(
            "The old password you entered is incorrect",
            style: GoogleFonts.poppins(
              color: Colors.white,
            ),
          ),
        ),
      );
      return;
    }

    // RED ERROR MESSAGE FOR PASSWORD MISMATCH
    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          content: Text(
            "New passwords do not match",
            style: GoogleFonts.poppins(
              color: Colors.white,
            ),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = supabase.auth.currentUser;

      if (user == null) return;

      // Update database
      await supabase
          .from('tbl_dermatologist')
          .update({'dermatologist_password': newPassword})
          .eq('dermatologist_id', user.id);

      // Update auth password
      await supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      _showMsg("Password updated successfully!");

      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      _fetchCurrentPassword();
    } catch (e) {
      _showMsg("Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: primary,
        behavior: SnackBarBehavior.floating,
        content: Text(
          msg,
          style: GoogleFonts.poppins(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,

      appBar: AppBar(
        title: Text(
          "Change Password",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),

        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            const SizedBox(height: 10),

            Text(
              "Update your password securely",
              style: GoogleFonts.poppins(
                color: Colors.grey.shade700,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 25),

            // CARD
            Container(
              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(16),

                border: Border.all(
                  color: Colors.grey.shade300,
                ),
              ),

              child: Column(
                children: [
                  _buildPasswordField(
                    "Old Password",
                    _oldPasswordController,
                    _showOld,
                    () {
                      setState(() {
                        _showOld = !_showOld;
                      });
                    },
                  ),

                  const SizedBox(height: 18),

                  _buildPasswordField(
                    "New Password",
                    _newPasswordController,
                    _showNew,
                    () {
                      setState(() {
                        _showNew = !_showNew;
                      });
                    },
                  ),

                  const SizedBox(height: 18),

                  _buildPasswordField(
                    "Confirm Password",
                    _confirmPasswordController,
                    _showConfirm,
                    () {
                      setState(() {
                        _showConfirm =
                            !_showConfirm;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 35),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : _handleChangePassword,

                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,

                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                ),

                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : Text(
                        "Update Password",
                        style:
                            GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight:
                              FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    bool visible,
    VoidCallback onToggle,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),

        const SizedBox(height: 8),

        TextFormField(
          controller: controller,
          obscureText: !visible,

          decoration: InputDecoration(
            hintText: "Enter $label",

            hintStyle: GoogleFonts.poppins(
              color: Colors.grey,
              fontSize: 14,
            ),

            filled: true,
            fillColor: bgColor,

            prefixIcon: const Icon(
              Icons.lock_outline,
              color: primary,
            ),

            suffixIcon: IconButton(
              onPressed: onToggle,
              icon: Icon(
                visible
                    ? Icons.visibility
                    : Icons.visibility_off,
                color: Colors.grey,
              ),
            ),

            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(12),

              borderSide: BorderSide(
                color: Colors.grey.shade300,
              ),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(12),

              borderSide: BorderSide(
                color: Colors.grey.shade300,
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(12),

              borderSide: const BorderSide(
                color: primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}