import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/widgets/primary_button.dart';
import 'package:southsea_cinema/widgets/nav_drawer.dart';

// Keys the profile is stored under.
const String profileFirstNameKey = 'profile_first_name';
const String profileLastNameKey = 'profile_last_name';
const String profileEmailKey = 'profile_email';
const String profilePhoneKey = 'profile_phone';
const String profileEmailNewsKey = 'profile_email_news';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final _formKey = GlobalKey<FormState>();

  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  final TextEditingController _firstNameController = TextEditingController();

  final TextEditingController _lastNameController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _phoneController = TextEditingController();

  bool _emailNews = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final String? firstName = await _prefs.getString(profileFirstNameKey);
    final String? lastName = await _prefs.getString(profileLastNameKey);
    final String? email = await _prefs.getString(profileEmailKey);
    final String? phone = await _prefs.getString(profilePhoneKey);
    final bool? emailNews = await _prefs.getBool(profileEmailNewsKey);

    if (!mounted) return;

    setState(() {
      _firstNameController.text = firstName ?? '';
      _lastNameController.text = lastName ?? '';
      _emailController.text = email ?? '';
      _phoneController.text = phone ?? '';
      _emailNews = emailNews ?? false;
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await _prefs.setString(profileFirstNameKey, _firstNameController.text);
    await _prefs.setString(profileLastNameKey, _lastNameController.text);
    await _prefs.setString(profileEmailKey, _emailController.text);
    await _prefs.setString(profilePhoneKey, _phoneController.text);
    await _prefs.setBool(profileEmailNewsKey, _emailNews);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Settings'),
      ),
      drawer: const NavDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Customer Profile',
                style: TextStyle(
                  color: cinemaFontWhite,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'First Name',
                style: TextStyle(color: cinemaFontWhite),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  hintText: 'Enter your first name',
                  filled: true,
                  fillColor: cinemaSurface,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Last Name',
                style: TextStyle(color: cinemaFontWhite),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  hintText: 'Enter your last name',
                  filled: true,
                  fillColor: cinemaSurface,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Email Address',
                style: TextStyle(color: cinemaFontWhite),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Enter your email address',
                  filled: true,
                  fillColor: cinemaSurface,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      !RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value.trim())) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Phone Number',
                style: TextStyle(color: cinemaFontWhite),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: 'Enter your phone number',
                  filled: true,
                  fillColor: cinemaSurface,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Email me cinema news',
                  style: TextStyle(color: cinemaFontWhite),
                ),
                value: _emailNews,
                onChanged: (value) {
                  setState(() {
                    _emailNews = value;
                  });
                },
              ),
              const SizedBox(height: 30),
              PrimaryButton(
                label: 'SAVE CHANGES',
                onPressed: _saveProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
