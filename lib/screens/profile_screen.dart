import 'package:flutter/material.dart';
import 'package:my_first_app/data/database_helper.dart';
import 'package:my_first_app/models/user_profile.dart';
import 'package:my_first_app/screens/workout_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late UserProfile _profile;
  bool _isLoading = true;

  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _goalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });
    _profile = await DatabaseHelper.instance.getProfile();
    _nameController.text = _profile.name;
    _weightController.text = _profile.weight.toString();
    _heightController.text = _profile.height.toString();
    _goalController.text = _profile.goal;
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final updatedProfile = UserProfile(
        id: _profile.id,
        name: _nameController.text,
        weight: double.tryParse(_weightController.text) ?? _profile.weight,
        height: double.tryParse(_heightController.text) ?? _profile.height,
        goal: _goalController.text,
      );
      await DatabaseHelper.instance.saveProfile(updatedProfile);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _weightController,
                      decoration: const InputDecoration(
                        labelText: 'Weight (kg)',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _heightController,
                      decoration: const InputDecoration(
                        labelText: 'Height (cm)',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _goalController,
                      decoration: const InputDecoration(
                        labelText: 'Fitness Goal',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveProfile,
                      child: const Text('Save Profile'),
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const WorkoutHistoryScreen()),
                        );
                      },
                      icon: const Icon(Icons.history_edu_outlined),
                      label: const Text('View Workout History'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        side: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
