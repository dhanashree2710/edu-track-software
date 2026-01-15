
import 'package:edutrack_application/modules/Admin/presentation/views/admin_dashboard.dart';
import 'package:edutrack_application/modules/Admin/presentation/views/admin_register.dart';
import 'package:edutrack_application/modules/Assessment/presentation/widgets/manage_assessment.dart';
import 'package:edutrack_application/modules/Attendence/presentation/views/view_attendenc_card.dart';
import 'package:edutrack_application/modules/Batch/presentation/widgets/manage_batch.dart';
import 'package:edutrack_application/modules/Login/presentation/views/role_selection_screen.dart';
import 'package:edutrack_application/modules/Login/presentation/views/user_role_login.dart';
import 'package:edutrack_application/modules/Student/presentation/widgets/manage_student.dart';
import 'package:edutrack_application/modules/Trainer/presentation/views/trainer_dashboard.dart';
import 'package:edutrack_application/modules/Trainer/presentation/widgets/manage_trainer.dart';
import 'package:edutrack_application/modules/Trainer/presentation/widgets/manage_trainer_assessment.dart';
import 'package:edutrack_application/modules/Trainer/presentation/widgets/view_trainer_batch.dart';
import 'package:edutrack_application/utils/common/user_session.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../components/kdrt_colors.dart';

class CommonScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final String role;
  final String? empId;

  const CommonScaffold({
    super.key,
    this.empId,
    required this.title,
    required this.body,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff3f5efb), Color(0xfffc466b)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: AssetImage('assets/logo.png'),
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: body,
    );
  }

  /// === Drawer based on role ===
  Widget _buildDrawer(BuildContext context) {
    List<Widget> menuItems = [
      DrawerHeader(
        decoration: const BoxDecoration(color: Colors.white),
        child: Image.asset(
          role == "admin" || role == "super admin"
              ? 'assets/admin_drawer.png'
              : 'assets/employee_drawer.png',
          fit: BoxFit.cover,
        ),
      ),

      ListTile(
        leading: const Icon(Icons.home, color: KDRTColors.darkBlue),
        title: const Text("Dashboard"),
        onTap: () {
          Navigator.pop(context); // Close the drawer first

          // Determine which dashboard to open based on role
          Widget dashboardPage;

          if (role == "admin" || role == "super admin") {
            dashboardPage = AdminDashboard(  currentUserId: UserSession().userId ?? '',
            currentUserRole: role,);
          } else if (role == "trainer") {
            dashboardPage =  TrainerDashboard(
              currentUserId: UserSession().userId ?? '',
              currentUserRole: role,
            );
          } else {
            dashboardPage = AdminDashboard(
    currentUserId: UserSession().userId ?? '',
    currentUserRole: role,
  );
          }

          // Clear all previous screens and go to Dashboard
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => dashboardPage),
            (route) => false, // Remove all routes to make dashboard the root
          );
        },
      ),
    ];

    // === Admin Role ===
    if (role == "admin") {
      menuItems.addAll([
        // _drawerItem(
        //   context,
        //   icon: Icons.manage_accounts,
        //   label: "Manage User Role",
        //   page: UserListScreen(
        //     currentUserId: UserSession().userId ?? '',
        //     currentUserRole: role,
        //   ),
        // ),
         _drawerItem(
          context,
          icon: Icons.manage_accounts,
          label: "Manage User Role",
          page: AdminRegisterScreen(
            currentUserId: UserSession().userId ?? '',
            currentUserRole: role,
          ),
        ),
        _drawerItem(
          context,
          icon: Icons.people_alt,
          label: "Manage Trainer",
          page: ManageTrainerScreen()
        ),
        _drawerItem(
          context,
          icon: Icons.group,
          label: "Manage Batch",
          page: ManageBatchScreen()
        ),

        _drawerItem(
          context,
          icon: Icons.school,
          label: "Manage Students",
          page: ManageStudentScreen(  ),
        ),
        _drawerItem(
          context,
            icon: Icons.visibility,
          label: "View Attendance",
          page: ViewAttendanceScreen()
        ),

        _drawerItem(
          context,
          icon: Icons.task_rounded,
          label: "Assessment",
          page: ManageAssessmentScreen()
        ),
      
       

      ]);
    }
   
    // === Employee Role ===
    else if (role == "trainer") {
      menuItems.addAll([
          _drawerItem(
          context,
          icon: Icons.group,
          label: "View Batch",
          page: TrainerCollegesScreen(currentUserId: UserSession().userId ?? '',)
        ),
          _drawerItem(
          context,
          icon: Icons.task_rounded,
          label: "Assessment",
          page: ManageTrainerAssessmentScreen(currentUserId: UserSession().userId ?? '',)
        ),
        // _drawerItem(
        //   context,
        //     icon: Icons.visibility,
        //   label: "View Attendance",
        //   page: AttendanceDashboardForLoginUser(
        //     currentUserId: UserSession().userId ?? '',
        //     currentUserRole: role,
        //   ),
        // ),
        // _drawerItem(
        //   context,
        //   icon: Icons.event_busy,

        //   label: "Leave Appliaction",
        //   page: LeaveApplicationScreen(
        //     currentUserId: UserSession().userId ?? '',
        //     currentUserRole: role,
        //   ),
        // ),
        // _drawerItem(
        //   context,
        //   icon: Icons.assignment_turned_in,
        //   label: "Leave Status",
        //   page: EmployeeLeaveHistoryScreen(
        //     currentUserId: UserSession().userId ?? '',
        //   ),
        // ),
        // _drawerItem(
        //   context,
        //   icon: Icons.task_rounded,
        //   label: "Tasks Allocation",
        //   page: TaskAllocationScreen(
        //     currentUserId: UserSession().userId ?? '',
        //     currentUserRole: role,
        //   ),
        // ),
        // _drawerItem(
        //   context,
        //   icon: Icons.assignment,
        //   label: "Task List",
        //   page: ParticularEmployeeTaskListScreen(
        //     currentUserId: UserSession().userId ?? '',
        //     currentUserRole: role,
        //   ),
        // ),
        // _drawerItem(
        //   context,
        //   icon: Icons.school,
        //   label: "Task Report",
        //   page: EmployeeTaskReportScreen(
        //   employeeId: UserSession().userId ?? '',       
          
        //   ),
        // ),
        
      ]);
    }
    // // === Intern Role ===
    // else if (role == "intern") {
    //   menuItems.addAll([
    //     _drawerItem(
    //       context,
    //       icon: Icons.access_time,
    //       label: "Attendance",
    //       page: AttendanceScreen(
    //         currentUserId: UserSession().userId ?? '',
    //         currentUserRole: role,
    //       ),
    //     ),
    //      _drawerItem(
    //       context,
    //         icon: Icons.visibility,
    //       label: "View Attendance",
    //       page: AttendanceDashboardForLoginUser(
    //         currentUserId: UserSession().userId ?? '',
    //         currentUserRole: role,
    //       ),
    //     ),
    //     _drawerItem(
    //       context,
    //       icon: Icons.event_busy,

    //       label: "Leave Appliaction",
    //       page: LeaveApplicationScreen(
    //         currentUserId: UserSession().userId ?? '',
    //         currentUserRole: role,
    //       ),
    //     ),
    //     _drawerItem(
    //       context,
    //       icon: Icons.assignment_turned_in,
    //       label: "Leave Status",
    //       page: EmployeeLeaveHistoryScreen(
    //         currentUserId: UserSession().userId ?? '',
    //       ),
    //     ),
    //     _drawerItem(
    //       context,
    //       icon: Icons.assignment,
    //       label: "Task List",
    //       page: ParticularEmployeeTaskListScreen(
    //         currentUserId: UserSession().userId ?? '',
    //         currentUserRole: role,
    //       ),
    //     ),
    //     _drawerItem(
    //       context,
    //       icon: Icons.school,
    //       label: "Task Report",
    //       page: EmployeeTaskReportScreen(
    //       employeeId: UserSession().userId ?? '',
          
    //       ),
    //     ),
    //   ]);
    // }

    // === Logout option for all roles ===
    menuItems.add(
      ListTile(
        leading: const Icon(Icons.logout, color: Colors.red),
        title: const Text("Logout", style: TextStyle(color: Colors.red)),
        onTap: () => _showLogoutConfirmation(context),
      ),
    );

    return Drawer(
      backgroundColor: Colors.white,
      child: SingleChildScrollView(child: Column(children: menuItems)),
    );
  }

  /// === Drawer item builder ===
  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    Widget? page,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: KDRTColors.darkBlue),
      title: Text(label),
      onTap:
          onTap ??
          () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => page!),
            );
          },
    );
  }

  /// === Logout confirmation dialog ===
 void _showLogoutConfirmation(BuildContext context) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => Dialog(
      backgroundColor: KDRTColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/confirmation.json',
              height: 120,
              width: 120,
            ),
            const SizedBox(height: 16),
            const Text(
              'Are you sure you want to logout?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    try {
                      // 1️⃣ Firebase logout (safe even if not used)
                      await FirebaseAuth.instance.signOut();

                      // 2️⃣ CLEAR LOCAL SESSION (MOST IMPORTANT)
                      UserSession().clear();

                      // 3️⃣ Navigate to Login (NO APP CLOSE)
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RoleSelectionScreen(),
                        ),
                        (_) => false,
                      );
                    } catch (e) {
                      debugPrint("Logout error: $e");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KDRTColors.darkBlue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Yes'),
                ),

                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KDRTColors.cyan,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('No'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
}