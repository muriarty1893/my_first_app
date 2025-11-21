import 'package:flutter/material.dart';
import 'package:my_first_app/screens/exercise_list_screen.dart';
import 'package:my_first_app/screens/program_screen.dart';
import 'package:my_first_app/screens/profile_screen.dart';
import 'package:my_first_app/screens/progress_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness AI'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildNavigationCard(
            context: context,
            icon: Icons.person_outline,
            title: 'My Profile',
            subtitle: 'View and edit your personal details.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildNavigationCard(
            context: context,
            icon: Icons.show_chart,
            title: 'My Progress',
            subtitle: 'Visualize your workout history.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProgressScreen()),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildNavigationCard(
            context: context,
            icon: Icons.assignment_outlined,
            title: 'My Program',
            subtitle: 'View and track your weekly workout plan.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProgramScreen()),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildNavigationCard(
            context: context,
            icon: Icons.search_outlined,
            title: 'Browse All Exercises',
            subtitle: 'Find exercises and build your program.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ExerciseListScreen()),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildNavigationCard(
            context: context,
            icon: Icons.auto_awesome_outlined,
            title: 'Create Program with AI',
            subtitle: 'Let our AI generate a custom plan for you.',
            onTap: () {
              // Placeholder for AI feature
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('AI feature coming soon!')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 40.0,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 24.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
