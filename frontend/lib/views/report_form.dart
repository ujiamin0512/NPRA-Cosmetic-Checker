import 'package:flutter/material.dart';
import '../databases/report_db.dart';
import '../databases/user_db.dart';
import '../models/reports.dart';
import 'map_picker_page.dart'; 
import '../models/location_data.dart';

class ReportFormPage extends StatefulWidget {
  const ReportFormPage({
    super.key, 
    this.report,
    this.initialProductName,
    this.initialNotificationNumber,
  });

  final Report? report;
  final String? initialProductName;
  final String? initialNotificationNumber;

  @override
  State<ReportFormPage> createState() => _ReportFormPageState();
}

class _ReportFormPageState extends State<ReportFormPage> {
  late final TextEditingController _productController;
  late final TextEditingController _notificationController;
  late final TextEditingController _problemController;
  late final TextEditingController _purchaseDateController;
  late final TextEditingController _purchasePlaceController;
  
  // Store latitude and longitude separately
  double? _latitude;
  double? _longitude;
  
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _productController = TextEditingController(
      text: widget.report?.productName ?? widget.initialProductName,
    );
    _notificationController = TextEditingController(
      text: widget.report?.notificationNumber ?? widget.initialNotificationNumber,
    );
    _problemController = TextEditingController(text: widget.report?.problem);
    _purchaseDateController =
        TextEditingController(text: widget.report?.purchaseDate);
    _purchasePlaceController =
        TextEditingController(text: widget.report?.purchasePlace);
    
    // Load existing coordinates if editing
    _latitude = widget.report?.latitude;
    _longitude = widget.report?.longitude;
  }

  @override
  void dispose() {
    _productController.dispose();
    _notificationController.dispose();
    _problemController.dispose();
    _purchaseDateController.dispose();
    _purchasePlaceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final String? userId = UserDatabase.currentUserId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to submit a report.')),
      );
      return;
    }

    if (_productController.text.trim().isEmpty ||
        _problemController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product name and problem are required.')),
      );
      return;
    }

    setState(() {
      _submitting = true;
    });

    final Report report = Report(
      id: widget.report?.id,
      userId: userId,
      productName: _productController.text.trim(),
      notificationNumber: _notificationController.text.trim(),
      problem: _problemController.text.trim(),
      purchaseDate: _purchaseDateController.text.trim(),
      purchasePlace: _purchasePlaceController.text.trim(),
      latitude: _latitude,
      longitude: _longitude,
    );
    
    if (widget.report == null) {
      await ReportDatabase.makeReport(report);
    } else {
      await ReportDatabase.editReport(report);
    }

    if (!mounted) return;

    setState(() {
      _submitting = false;
    });

    Navigator.of(context).pop(true);
  }

  Future<void> _pickPurchaseDate() async {
    FocusScope.of(context).unfocus();

    DateTime initialDate = DateTime.now();
    if (_purchaseDateController.text.isNotEmpty) {
      final DateTime? parsed =
          DateTime.tryParse(_purchaseDateController.text.trim());
      if (parsed != null) {
        initialDate = parsed;
      }
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      final String formattedDate =
          '${picked.year.toString().padLeft(4, '0')}-'
          '${picked.month.toString().padLeft(2, '0')}-'
          '${picked.day.toString().padLeft(2, '0')}';

      setState(() {
        _purchaseDateController.text = formattedDate;
      });
    }
  }

  Future<void> _pickPurchasePlace() async {
    FocusScope.of(context).unfocus();

    // Prepare initial location if editing with existing coordinates
    LocationData? initialLocation;
    if (_latitude != null && _longitude != null && _purchasePlaceController.text.isNotEmpty) {
      initialLocation = LocationData(
        placeName: _purchasePlaceController.text,
        latitude: _latitude!,
        longitude: _longitude!,
      );
    }

    final LocationData? result = await Navigator.of(context).push<LocationData>(
      MaterialPageRoute(
        builder: (context) => MapPickerPage(
          initialLocation: initialLocation,
        ),
      ),
    );

    // If a result is returned, update the text field and coordinates
    if (result != null) {
      setState(() {
        _purchasePlaceController.text = result.placeName;
        _latitude = result.latitude;
        _longitude = result.longitude;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.report == null ? 'Report Form' : 'Edit Report',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1D0CC2),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: <Widget>[
            _OutlinedField(
              controller: _productController,
              label: 'Product Name',
            ),
            _OutlinedField(
              controller: _notificationController,
              label: 'Notification Number',
            ),
            _OutlinedField(
              controller: _problemController,
              label: 'Problem',
            ),
            _OutlinedField(
              controller: _purchaseDateController,
              label: 'Purchased Date',
              readOnly: true,
              onTap: _pickPurchaseDate,
              suffixIcon: const Icon(
                Icons.calendar_today,
                color: Color(0xFF1D0CC2),
              ),
            ),
            
            _OutlinedField(
              controller: _purchasePlaceController,
              label: 'Place of Purchase',
              readOnly: true, 
              onTap: _pickPurchasePlace, 
              suffixIcon: const Icon(
                Icons.map, 
                color: Color(0xFF1D0CC2),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D0CC2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                onPressed: _submitting ? null : _submit,
                child: Text(
                  _submitting ? 'Submitting...' : 'Submit',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OutlinedField extends StatelessWidget {
  const _OutlinedField({
    required this.controller,
    required this.label,
    this.onTap,
    this.readOnly = false,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String label;
  final VoidCallback? onTap;
  final bool readOnly;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          border: const UnderlineInputBorder(),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}