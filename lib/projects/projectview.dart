import 'package:flutter/material.dart';

class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Stack(
        children: [
          /// Main Content
          CustomScrollView(
            slivers: [
              /// Sticky Header
              SliverAppBar(
                pinned: true,
                floating: false,
                backgroundColor: colorScheme.background.withOpacity(0.8),
                elevation: 0,
                toolbarHeight: 69,
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: colorScheme.outline),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.arrow_back_ios,
                                  color: colorScheme.primary,
                                  size: 16,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Website Redesign",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.45,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.more_vert,
                              color: colorScheme.onSurface,
                              size: 20,
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              /// Main Content Area
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(10, 16, 10, 149),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    /// Progress Summary Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [colorScheme.primary, colorScheme.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.2),
                            blurRadius: 25,
                            offset: const Offset(0, 20),
                          ),
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          /// Abstract Pattern Decoration
                          Positioned(
                            right: -64,
                            top: -64,
                            child: Container(
                              width: 128,
                              height: 128,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            left: -48,
                            bottom: -48,
                            child: Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          
                          /// Content
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Project Progress",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "66%",
                                        style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(
                                      Icons.trending_up,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "12/18 tasks completed",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                  Text(
                                    "5 days left",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Stack(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(9999),
                                    ),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.66,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(9999),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    /// Task List Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Active Tasks Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Active Tasks",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                borderRadius: BorderRadius.circular(9999),
                              ),
                              child: Text(
                                "3 tasks",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.onSurface.withOpacity(0.4),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        /// Task List
                        _buildTaskTile(
                          context,
                          title: "Design System Documentation",
                          priority: "High",
                          priorityColor: colorScheme.error,
                          dueDate: "Overdue",
                          dueDateColor: colorScheme.error,
                          showCheckbox: true,
                        ),

                        const SizedBox(height: 12),

                        _buildTaskTile(
                          context,
                          title: "User Testing Sessions",
                          priority: "Medium",
                          priorityColor: const Color(0xFFFBBF24),
                          dueDate: "Tomorrow",
                          dueDateColor: colorScheme.onSurface.withOpacity(0.4),
                          showCheckbox: true,
                        ),

                        const SizedBox(height: 12),

                        _buildTaskTile(
                          context,
                          title: "Homepage Wireframes",
                          priority: "Low",
                          priorityColor: colorScheme.primary,
                          dueDate: "Nov 30",
                          dueDateColor: colorScheme.onSurface.withOpacity(0.4),
                          showCheckbox: true,
                        ),

                        const SizedBox(height: 16),

                        /// Completed Tasks Header
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            "Completed Tasks",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurface.withOpacity(0.4),
                            ),
                          ),
                        ),

                        /// Completed Task
                        _buildTaskTile(
                          context,
                          title: "Brand Identity System",
                          isCompleted: true,
                          showCheckbox: false,
                        ),
                      ],
                    ),
                  ]),
                ),
              ),
            ],
          ),

          /// Sticky Add Task Button Container
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colorScheme.background.withOpacity(0),
                    colorScheme.background.withOpacity(0.9),
                    colorScheme.background,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// Add Task Button
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colorScheme.primary, colorScheme.secondary],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.4),
                          blurRadius: 50,
                          offset: const Offset(0, 25),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Add New Task",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  /// Home Indicator
                  Container(
                    width: 128,
                    height: 6,
                    decoration: BoxDecoration(
                      color: colorScheme.outline,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskTile(
    BuildContext context, {
    required String title,
    String? priority,
    Color? priorityColor,
    String? dueDate,
    Color? dueDateColor,
    bool isCompleted = false,
    bool showCheckbox = true,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted 
            ? colorScheme.surface.withOpacity(0.4)
            : colorScheme.surface,
        border: Border.all(
          color: isCompleted 
              ? colorScheme.outline.withOpacity(0.5)
              : colorScheme.outline,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Checkbox or Checkmark
          if (showCheckbox) ...[
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.3),
                    width: 2,
                  ),
                ),
              ),
            ),
          ] else ...[
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                color: Colors.white,
                size: 12,
              ),
            ),
          ],
          
          const SizedBox(width: 12),
          
          /// Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Title and Priority
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isCompleted 
                              ? colorScheme.onSurface.withOpacity(0.6)
                              : colorScheme.onSurface,
                          decoration: isCompleted 
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    if (priority != null && !isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: (priorityColor ?? colorScheme.primary).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          priority.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: priorityColor ?? colorScheme.primary,
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                /// Due Date
                if (!isCompleted)
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: dueDateColor ?? colorScheme.onSurface.withOpacity(0.4),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        dueDate ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: dueDateColor == colorScheme.error 
                              ? FontWeight.w500 
                              : FontWeight.w400,
                          color: dueDateColor ?? colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    "DONE",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}