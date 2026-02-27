import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 96),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.arrow_back,
                                size: 16,
                                color: colorScheme.onSurface,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          Text(
                            "Profile",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              "Edit",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// Profile Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(bottom: 32),
                      child: Column(
                        children: [
                          /// Profile Image with Edit Button
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 128,
                                height: 128,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: colorScheme.primary.withOpacity(0.2),
                                    width: 4,
                                  ),
                                ),
                                child: Container(
                                  width: 112,
                                  height: 112,
                                  margin: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: colorScheme.primary.withOpacity(0.3),
                                    image: const DecorationImage(
                                      image: NetworkImage(
                                        'https://via.placeholder.com/112',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 4,
                                bottom: 4,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: theme.scaffoldBackgroundColor,
                                      width: 2,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x1A000000),
                                        blurRadius: 15,
                                        offset: Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.edit,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          /// Name and Email
                          Column(
                            children: [
                              Text(
                                "Alex Johnson",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.6,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "alex.johnson@stitchtask.com",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    /// Stats Grid
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(bottom: 32),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              context,
                              label: "Projects",
                              value: "24",
                              gradient: LinearGradient(
                                colors: [colorScheme.primary, colorScheme.primary],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              context,
                              label: "Tasks",
                              value: "142",
                              gradient: LinearGradient(
                                colors: [colorScheme.secondary, colorScheme.primary],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              context,
                              label: "Score",
                              value: "98%",
                              gradient: LinearGradient(
                                colors: [const Color(0xFF3B82F6), const Color(0xFFA855F7)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// Personal Information Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(bottom: 32),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0D000000),
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "PERSONAL INFORMATION",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.4,
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildInfoTile(
                              context,
                              label: "Full Name",
                              value: "Alex Johnson",
                            ),
                            const SizedBox(height: 16),
                            _buildInfoTile(
                              context,
                              label: "Email Address",
                              value: "alex.johnson@stitchtask.com",
                            ),
                            const SizedBox(height: 16),
                            _buildInfoTile(
                              context,
                              label: "Current Role",
                              value: "Senior Product Designer",
                            ),
                          ],
                        ),
                      ),
                    ),

                    /// Activity Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "RECENT ACTIVITY",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.4,
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildActivityTile(
                            context,
                            icon: Icons.check_circle,
                            iconColor: colorScheme.primary,
                            title: "Task completed",
                            subtitle: "You completed 'Design Review'",
                          ),
                          const SizedBox(height: 16),
                          _buildActivityTile(
                            context,
                            icon: Icons.chat,
                            iconColor: colorScheme.secondary,
                            title: "New comment",
                            subtitle: "Sarah commented on your task",
                          ),
                          const SizedBox(height: 16),
                          _buildActivityTile(
                            context,
                            icon: Icons.assignment,
                            iconColor: const Color(0xFF3B82F6),
                            title: "Task assigned",
                            subtitle: "New task 'Update mockups'",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// Bottom Navigation Bar
            // Positioned(
            //   left: 0,
            //   right: 0,
            //   bottom: 0,
            //   child: Container(
            //     height: 64,
            //     decoration: BoxDecoration(
            //       color: colorScheme.surface.withOpacity(0.9),
            //       border: Border(
            //         top: BorderSide(color: colorScheme.outline),
            //       ),
            //     ),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceAround,
            //       children: [
            //         _buildNavItem(context, icon: Icons.home, label: "Home", isActive: false),
            //         _buildNavItem(context, icon: Icons.search, label: "Search", isActive: false),
            //         _buildNavItem(context, icon: Icons.add_circle, label: "Create", isActive: false),
            //         _buildNavItem(context, icon: Icons.person, label: "Profile", isActive: true),
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String label,
    required String value,
    required Gradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context, {
    required String label,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface.withOpacity(0.4),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityTile(BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            size: 14,
            color: iconColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurface.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget _buildNavItem(BuildContext context, {
  //   required IconData icon,
  //   required String label,
  //   required bool isActive,
  // }) {
  //   final colorScheme = Theme.of(context).colorScheme;
  //   final color = isActive ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.4);
    
  //   return Column(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [
  //       Icon(
  //         icon,
  //         size: 18,
  //         color: color,
  //       ),
  //       const SizedBox(height: 4),
  //       Text(
  //         label,
  //         style: TextStyle(
  //           fontSize: 10,
  //           fontWeight: FontWeight.w500,
  //           color: color,
  //         ),
  //       ),
  //     ],
  //   );
  // }
}