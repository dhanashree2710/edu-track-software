import 'package:edutrack_application/modules/Batch/presentation/widgets/manage_batch.dart';
import 'package:edutrack_application/modules/Trainer/presentation/widgets/manage_trainer_assessment.dart';
import 'package:edutrack_application/modules/Trainer/presentation/widgets/view_trainer_batch.dart';

import 'package:edutrack_application/utils/common/appbar_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TrainerDashboard extends StatefulWidget {
  final String currentUserId;
  final String currentUserRole;

  const TrainerDashboard({
    super.key,
    required this.currentUserId,
    required this.currentUserRole,
  });

  @override
  State<TrainerDashboard> createState() => _TrainerDashboardState();
}

class _TrainerDashboardState extends State<TrainerDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();

    // Wave emoji animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _waveAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Fetch trainer name safely
  Future<String> getTrainerName() async {
    try {
      // Try fetching from trainer collection by trainer_id
      final doc = await FirebaseFirestore.instance
          .collection('trainer')
          .doc(widget.currentUserId)
          .get();

      if (doc.exists) {
        return doc.data()?['name'] ?? 'Trainer'; // <-- Use 'name' here
      }

      // If the document ID is not trainer_id, fallback query by trainer_id field
      final query = await FirebaseFirestore.instance
          .collection('trainer')
          .where('trainer_id', isEqualTo: widget.currentUserId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return query.docs.first.data()['name'] ?? 'Trainer';
      }

      // If you want, fallback to users collection
      final userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('user_id', isEqualTo: widget.currentUserId)
          .limit(1)
          .get();

      if (userQuery.docs.isNotEmpty) {
        return userQuery.docs.first.data()['user_name'] ?? 'Trainer';
      }

      return 'Trainer';
    } catch (e) {
      print("Error fetching trainer name: $e");
      return 'Trainer';
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: "",
      role: widget.currentUserRole,
      body: Column(
        children: [
          // Curved Gradient Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: FutureBuilder<String>(
              future: getTrainerName(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text(
                    'Loading...',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  print("FutureBuilder error: ${snapshot.error}");
                  return const Text(
                    'Trainer',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  );
                }

                String name = snapshot.data ?? 'Trainer';
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ShaderMask(
                        shaderCallback: (bounds) =>
                            const LinearGradient(
                              colors: [Color(0xff3f5efb), Color(0xfffc466b)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(
                              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                            ),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Welcome, ',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                  color: Colors
                                      .white, // This color is masked by the gradient
                                ),
                              ),
                              TextSpan(
                                text: name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Colors.white, // This color is masked too
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Animated Wave Emoji
                    AnimatedBuilder(
                      animation: _waveAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, -_waveAnimation.value),
                          child: const Text(
                            '👋',
                            style: TextStyle(fontSize: 28),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Dashboard Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  dashboardCard(
                    title: "Batches",
                    icon: Icons.groups,
                    colors: [Colors.orange, Colors.deepOrange],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) =>TrainerCollegesScreen(currentUserId: widget.currentUserId,)),
                      );
                    },
                  ),
                  dashboardCard(
                    title: "Assessment",
                    icon: Icons.assignment,
                    colors: [Colors.purple, Colors.deepPurple],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ManageTrainerAssessmentScreen(currentUserId: widget.currentUserId,)),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget dashboardCard({
    required String title,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.last.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
