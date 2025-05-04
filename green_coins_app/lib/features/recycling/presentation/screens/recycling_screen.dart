import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:green_coins_app/core/constants/app_constants.dart';
import 'package:green_coins_app/core/theme/app_theme.dart';
import 'package:green_coins_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:green_coins_app/features/recycling/domain/models/recycling_category_model.dart';
import 'package:green_coins_app/features/recycling/presentation/providers/recycling_provider.dart';
import 'package:green_coins_app/features/recycling/presentation/screens/recycling_form_screen.dart';
import 'package:green_coins_app/features/recycling/presentation/widgets/activity_list_item.dart';

class RecyclingScreen extends StatefulWidget {
  const RecyclingScreen({super.key});

  @override
  State<RecyclingScreen> createState() => _RecyclingScreenState();
}

class _RecyclingScreenState extends State<RecyclingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Add listener to reload data when tab changes
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        print('Tab changed to: ${_tabController.index}');
        _loadData();
      }
    });

    // Initial data load
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    print('RecyclingScreen: Loading data...');
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id;

    print('RecyclingScreen: User ID: $userId');
    if (userId != null) {
      try {
        // Load recycling categories
        final recyclingProvider = Provider.of<RecyclingProvider>(context, listen: false);
        print('RecyclingScreen: Loading categories...');
        await recyclingProvider.getCategories();
        print('RecyclingScreen: Categories loaded: ${recyclingProvider.categories.length}');

        // Load user recycling activities
        print('RecyclingScreen: Loading user activities...');
        await recyclingProvider.getUserActivities(userId);
        print('RecyclingScreen: Activities loaded: ${recyclingProvider.activities.length}');
        print('RecyclingScreen: Provider status: ${recyclingProvider.status}');
      } catch (e) {
        print('RecyclingScreen: Error loading data: $e');
      }
    } else {
      print('RecyclingScreen: User ID is null, cannot load data');
    }
  }

  // Method specifically for pull-to-refresh
  Future<void> _handleRefresh() async {
    await _loadData();
    // Show a snackbar to indicate refresh is complete
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Activities refreshed'),
          duration: Duration(seconds: 1),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
    return;
  }

  void _navigateToRecyclingForm(RecyclingCategoryModel category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RecyclingFormScreen(category: category),
      ),
    ).then((_) => _loadData());
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final recyclingProvider = Provider.of<RecyclingProvider>(context);

    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        leadingWidth: 40,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Icon(
            Icons.recycling_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          'Recycling',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // Refresh Button
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorWeight: 3,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withAlpha(180),
          labelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'Categories'),
            Tab(text: 'My Activities'),
          ],
        ),
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                // Categories tab
                RefreshIndicator(
                  onRefresh: _handleRefresh,
                  color: AppTheme.primaryColor,
                  backgroundColor: Colors.white,
                  displacement: 40,
                  child: Builder(
                    builder: (context) {
                      if (recyclingProvider.status == RecyclingStatus.loading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (recyclingProvider.categories.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.category_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No recycling categories available',
                                style: TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: _loadData,
                                child: const Text('Refresh'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.8,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: recyclingProvider.categories.length,
                          itemBuilder: (context, index) {
                            final category = recyclingProvider.categories[index];
                            return _buildCategoryCard(category);
                          },
                        );
                      }
                    },
                  ),
                ),

                // My Activities tab
                RefreshIndicator(
                  onRefresh: _handleRefresh,
                  color: AppTheme.primaryColor,
                  backgroundColor: Colors.white,
                  displacement: 40,
                  child: Builder(
                    builder: (context) {
                      if (recyclingProvider.status == RecyclingStatus.loading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (recyclingProvider.activities.isEmpty) {
                        // Use ListView with a single item for empty state to support pull-to-refresh
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(), // Ensures pull-to-refresh works
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.7, // Take most of the screen height
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.recycling,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(height: 16),
                                    const Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Text(
                                        'No recycling activities yet. Start recycling to earn coins!',
                                        style: TextStyle(fontSize: 16),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    ElevatedButton(
                                      onPressed: () {
                                        if (recyclingProvider.categories.isNotEmpty) {
                                          _tabController.animateTo(0); // Switch to categories tab
                                        } else {
                                          _loadData(); // Reload data if no categories
                                        }
                                      },
                                      child: Text(
                                        recyclingProvider.categories.isNotEmpty
                                            ? 'Go to Categories'
                                            : 'Refresh'
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Pull down to refresh',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      } else {
                        // Use ListView.builder directly with physics that allow pull-to-refresh
                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          physics: const AlwaysScrollableScrollPhysics(), // Ensures pull-to-refresh works
                          itemCount: recyclingProvider.activities.length,
                          itemBuilder: (context, index) {
                            final activity = recyclingProvider.activities[index];
                            return ActivityListItem(activity: activity);
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCategoryCard(RecyclingCategoryModel category) {
    // Use consistent green color for all categories
    Color categoryColor = AppTheme.primaryColor;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToRecyclingForm(category),
          borderRadius: BorderRadius.circular(12),
          splashColor: categoryColor.withAlpha(30),
          highlightColor: categoryColor.withAlpha(15),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Category icon with circular background
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      _getCategoryIcon(category.name),
                      color: AppTheme.primaryColor,
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Category name
                Text(
                  category.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 12),

                // Coin value badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        color: AppTheme.primaryColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${category.coinValue} / unit',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'electronic waste':
        return Icons.devices;
      case 'plastic':
        return Icons.local_drink;
      case 'paper':
        return Icons.description;
      case 'metal':
        return Icons.settings;
      case 'glass':
        return Icons.wine_bar;
      default:
        return Icons.recycling;
    }
  }
}
