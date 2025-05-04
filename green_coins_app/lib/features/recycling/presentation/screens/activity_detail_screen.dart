import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:green_coins_app/core/theme/app_theme.dart';
import 'package:green_coins_app/features/recycling/domain/models/recycling_activity_model.dart';
import 'package:green_coins_app/features/recycling/presentation/providers/recycling_provider.dart';
import 'pickup_scheduling_screen.dart';

class ActivityDetailScreen extends StatefulWidget {
  final RecyclingActivityModel activity;

  const ActivityDetailScreen({
    Key? key,
    required this.activity,
  }) : super(key: key);

  @override
  _ActivityDetailScreenState createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> {
  late RecyclingActivityModel _activity;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _activity = widget.activity;
  }

  Future<void> _navigateToPickupScheduling() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PickupSchedulingScreen(
          activity: _activity,
          isNewSubmission: false,
        ),
      ),
    );

    if (result == true) {
      // Refresh activity data
      setState(() {
        _isLoading = true;
      });

      try {
        final recyclingProvider = Provider.of<RecyclingProvider>(context, listen: false);
        await recyclingProvider.getUserActivities(_activity.userId);
        
        // Find the updated activity
        final updatedActivity = recyclingProvider.activities.firstWhere(
          (a) => a.id == _activity.id,
          orElse: () => _activity,
        );
        
        setState(() {
          _activity = updatedActivity;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Not scheduled';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('EEEE, MMMM d, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;
    
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        icon = Icons.hourglass_empty;
        break;
      case 'approved':
        color = AppTheme.successColor;
        icon = Icons.check_circle;
        break;
      case 'rejected':
        color = AppTheme.errorColor;
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupStatusBadge(String? status) {
    if (status == null) return const SizedBox.shrink();
    
    Color color;
    IconData icon;
    String text = status;
    
    switch (status.toLowerCase()) {
      case 'scheduled':
        color = Colors.blue;
        icon = Icons.schedule;
        break;
      case 'completed':
        color = AppTheme.successColor;
        icon = Icons.check_circle;
        break;
      case 'cancelled':
        color = AppTheme.errorColor;
        icon = Icons.cancel;
        break;
      case 'not_required':
        return const SizedBox.shrink(); // Don't show badge for not_required
      default:
        color = Colors.grey;
        icon = Icons.help;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasPickupScheduled = _activity.pickupStatus == 'scheduled';
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recycling Details'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status and date card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Status',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              _buildStatusBadge(_activity.status),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                'Submitted on: ${_formatDate(_activity.createdAt)}',
                                style: TextStyle(
                                  color: AppTheme.textSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                          if (_activity.updatedAt != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.update, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  'Last updated: ${_formatDate(_activity.updatedAt!)}',
                                  style: TextStyle(
                                    color: AppTheme.textSecondaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Recycling details card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recycling Details',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow('Category', _activity.categoryName ?? 'Unknown'),
                          _buildDetailRow('Quantity', '${_activity.quantity} units'),
                          _buildDetailRow('Coins Earned', '${_activity.coinsEarned} coins'),
                          if (_activity.notes != null && _activity.notes!.isNotEmpty)
                            _buildDetailRow('Notes', _activity.notes!),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Pickup details card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Pickup Details',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_activity.pickupStatus != null && _activity.pickupStatus != 'not_required')
                                _buildPickupStatusBadge(_activity.pickupStatus),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (hasPickupScheduled) ...[
                            _buildDetailRow('Date', _formatDate(_activity.pickupDate!)),
                            _buildDetailRow('Time Slot', _activity.pickupTimeSlot ?? 'Not specified'),
                            _buildDetailRow('Address', _activity.pickupAddress ?? 'Not specified'),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _navigateToPickupScheduling,
                                icon: const Icon(Icons.edit),
                                label: const Text('Update Pickup Details'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.secondaryColor,
                                ),
                              ),
                            ),
                          ] else ...[
                            const Text(
                              'No pickup scheduled for this recycling activity.',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _navigateToPickupScheduling,
                                icon: const Icon(Icons.local_shipping),
                                label: const Text('Schedule a Pickup'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.secondaryColor,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
