import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:green_coins_app/core/constants/app_constants.dart';
import 'package:green_coins_app/core/theme/app_theme.dart';
import 'package:green_coins_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:green_coins_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:green_coins_app/features/recycling/domain/models/recycling_category_model.dart';
import 'package:green_coins_app/features/recycling/domain/models/recycling_activity_model.dart';
import 'package:green_coins_app/features/recycling/presentation/providers/recycling_provider.dart';
import 'pickup_scheduling_screen.dart';

class RecyclingFormScreen extends StatefulWidget {
  final RecyclingCategoryModel category;

  const RecyclingFormScreen({
    super.key,
    required this.category,
  });

  @override
  State<RecyclingFormScreen> createState() => _RecyclingFormScreenState();
}

class _RecyclingFormScreenState extends State<RecyclingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();

  File? _imageFile;
  XFile? _pickedFile;
  bool _isLoading = false;
  int _calculatedCoins = 0;

  // Pickup scheduling data
  bool _schedulePickup = false;
  Map<String, dynamic>? _pickupData;

  @override
  void initState() {
    super.initState();
    _quantityController.addListener(_calculateCoins);
  }

  @override
  void dispose() {
    _quantityController.removeListener(_calculateCoins);
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _calculateCoins() {
    if (_quantityController.text.isNotEmpty) {
      try {
        final quantity = double.parse(_quantityController.text);
        setState(() {
          _calculatedCoins = (quantity * widget.category.coinValue).toInt();
        });
      } catch (e) {
        setState(() {
          _calculatedCoins = 0;
        });
      }
    } else {
      setState(() {
        _calculatedCoins = 0;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _pickedFile = pickedFile;
        if (!kIsWeb) {
          _imageFile = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> _navigateToPickupScheduling() async {
    // Create a dummy activity for the pickup scheduling screen
    final dummyActivity = RecyclingActivityModel(
      id: 0,
      userId: 0,
      categoryId: widget.category.id,
      quantity: 0,
      coinsEarned: 0,
      status: 'pending',
      createdAt: DateTime.now().toString(),
    );

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PickupSchedulingScreen(
          activity: dummyActivity,
          isNewSubmission: true,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _schedulePickup = true;
        _pickupData = result;
      });
    }
  }

  Future<void> _submitRecycling() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final recyclingProvider = Provider.of<RecyclingProvider>(context, listen: false);
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);

    final userId = authProvider.user?.id;

    if (userId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final quantity = double.parse(_quantityController.text);

      // Convert image to base64 if needed
      String? imageBase64;
      if (_pickedFile != null) {
        // In a real app, you would convert the image to base64 here
        // For web and mobile compatibility:
        if (kIsWeb) {
          // For web, read the bytes from the XFile
          // imageBase64 = base64Encode(await _pickedFile!.readAsBytes());
        } else if (_imageFile != null) {
          // For mobile, read the bytes from the File
          // imageBase64 = base64Encode(await _imageFile!.readAsBytes());
        }
      }

      // Prepare pickup data if scheduled
      String? pickupDate;
      String? pickupTimeSlot;
      String? pickupAddress;

      if (_schedulePickup && _pickupData != null) {
        pickupDate = _pickupData!['pickup_date'];
        pickupTimeSlot = _pickupData!['pickup_time_slot'];
        pickupAddress = _pickupData!['pickup_address'];
      }

      final result = await recyclingProvider.submitActivity(
        userId: userId,
        categoryId: widget.category.id,
        quantity: quantity,
        proofImage: imageBase64,
        notes: _notesController.text,
        pickupDate: pickupDate,
        pickupTimeSlot: pickupTimeSlot,
        pickupAddress: pickupAddress,
      );

      if (!mounted) return;

      if (result.containsKey('id')) {
        // Update coin balance
        await profileProvider.getCoinBalance(userId);
        authProvider.updateCoinBalance(profileProvider.coinBalance);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppConstants.recyclingSubmitSuccessMessage),
            backgroundColor: AppTheme.successColor,
          ),
        );

        Navigator.of(context).pop();
      } else if (result.containsKey('error')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error']),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recycle ${widget.category.name}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category info card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _getCategoryIcon(widget.category.name),
                            color: AppTheme.primaryColor,
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.category.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.monetization_on,
                                      color: AppTheme.primaryColor,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${widget.category.coinValue} coins per unit',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.category.description,
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Quantity field
              Text(
                'Quantity',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  hintText: 'Enter quantity',
                  suffixText: 'units',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a quantity';
                  }
                  try {
                    final quantity = double.parse(value);
                    if (quantity <= 0) {
                      return 'Quantity must be greater than 0';
                    }
                  } catch (e) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Calculated coins
              if (_calculatedCoins > 0)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'You will earn $_calculatedCoins coins',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // Photo upload
              Text(
                'Proof Photo (Optional)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: _pickedFile == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.camera_alt,
                              size: 48,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap to take a photo',
                              style: TextStyle(
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: kIsWeb
                              ? Image.network(
                                  _pickedFile!.path,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Text('Error loading image'),
                                    );
                                  },
                                )
                              : Image.file(
                                  _imageFile!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Notes field
              Text(
                'Notes (Optional)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  hintText: 'Add any additional information',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Pickup scheduling option
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
                        children: [
                          Icon(
                            Icons.local_shipping,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Schedule a Pickup',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'We can pick up your recyclables at your preferred time and location.',
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          if (_schedulePickup && _pickupData != null)
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Pickup scheduled for:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text('Date: ${_pickupData!['pickup_date']}'),
                                    Text('Time: ${_pickupData!['pickup_time_slot']}'),
                                    Text('Address: ${_pickupData!['pickup_address']}'),
                                  ],
                                ),
                              ),
                            )
                          else
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _navigateToPickupScheduling,
                                icon: const Icon(Icons.calendar_today),
                                label: const Text('Schedule Pickup'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.secondaryColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitRecycling,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Submit Recycling'),
                ),
              ),
            ],
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
