import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SignupFieldsWidget extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final ValueChanged<Map<String, dynamic>>? onDataChanged;
  final XFile? selectedImageFile;
  final ValueChanged<XFile?>? onImageChanged;

  const SignupFieldsWidget({
    super.key,
    required this.formKey,
    this.onDataChanged,
    this.selectedImageFile,
    this.onImageChanged,
  });

  @override
  State<SignupFieldsWidget> createState() => _SignupFieldsWidgetState();
}

class _SignupFieldsWidgetState extends State<SignupFieldsWidget> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _jobController = TextEditingController();
  final _placeController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _fbLinkController = TextEditingController();
  final _parentsNameController = TextEditingController();
  final _parentsJobController = TextEditingController();
  final _referralController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  XFile? _selectedImageFile;
  String _selectedGender = 'Male';
  bool _fbNameMatch = false;

  @override
  void initState() {
    super.initState();
    _selectedImageFile = widget.selectedImageFile;
  }

  @override
  void didUpdateWidget(covariant SignupFieldsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedImageFile != oldWidget.selectedImageFile) {
      _selectedImageFile = widget.selectedImageFile;
    }
  }

  Map<String, dynamic> _collectData() {
    final nameParts = _nameController.text.trim().split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
    return {
      'first_name': firstName,
      'last_name': lastName,
      'phone': _phoneController.text.trim(),
      'dob': _dobController.text.trim(),
      'gender': _selectedGender,
      'job': _jobController.text.trim(),
      'place': _placeController.text.trim(),
      'height_cm': _heightController.text.trim(),
      'weight_kg': _weightController.text.trim(),
      'facebook_link': _fbLinkController.text.trim(),
      'parents_name': _parentsNameController.text.trim(),
      'parents_job': _parentsJobController.text.trim(),
      'image_url': _selectedImageFile?.path ?? '',
    };
  }

  void _notifyChanged() {
    widget.onDataChanged?.call(_collectData());
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 92,
      maxWidth: 1200,
    );
    if (pickedFile == null || !mounted) return;
    setState(() {
      _selectedImageFile = pickedFile;
    });
    widget.onImageChanged?.call(_selectedImageFile);
    _notifyChanged();
  }

  void _showPhotoPickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1520),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Profile Photo',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFFEEE0F0),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(
                Icons.photo_library_rounded,
                color: Color(0xFFC8556A),
              ),
              title: const Text(
                'Choose from Gallery',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  color: Color(0xFFEEE0F0),
                ),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.camera_alt_rounded,
                color: Color(0xFFC8556A),
              ),
              title: const Text(
                'Take a Photo',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  color: Color(0xFFEEE0F0),
                ),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _jobController.dispose();
    _placeController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _fbLinkController.dispose();
    _parentsNameController.dispose();
    _parentsJobController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  void _checkFbLink(String value) {
    // TODO: Replace with [Riverpod/Bloc] FB profile cross-check service
    final name = _nameController.text.trim().toLowerCase();
    final fb = value.toLowerCase();
    setState(() {
      _fbNameMatch =
          name.isNotEmpty &&
          fb.isNotEmpty &&
          fb.contains(name.split(' ').first);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSection(
          title: 'Personal Details',
          icon: Icons.person_outline_rounded,
          children: [
            _buildPhotoUpload(),
            const SizedBox(height: 14),
            _buildField(
              controller: _nameController,
              label: 'Full Name',
              hint: 'e.g. Priya Sharma',
              icon: Icons.badge_outlined,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 14),
            _buildGenderSelector(),
            const SizedBox(height: 14),
            _buildField(
              controller: _dobController,
              label: 'Date of Birth',
              hint: 'DD/MM/YYYY',
              icon: Icons.cake_outlined,
              keyboardType: TextInputType.datetime,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Date of birth required' : null,
            ),
            const SizedBox(height: 14),
            _buildField(
              controller: _phoneController,
              label: 'Mobile Number',
              hint: '+91 98765 43210',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (v) =>
                  (v == null || v.length < 10) ? 'Valid mobile required' : null,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSection(
          title: 'Professional & Physical',
          icon: Icons.work_outline_rounded,
          children: [
            _buildField(
              controller: _jobController,
              label: 'Occupation',
              hint: 'e.g. Software Engineer',
              icon: Icons.business_center_outlined,
            ),
            const SizedBox(height: 14),
            _buildField(
              controller: _placeController,
              label: 'City / Place',
              hint: 'e.g. Chennai, Tamil Nadu',
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _buildField(
                    controller: _heightController,
                    label: 'Height (cm)',
                    hint: '165',
                    icon: Icons.height_rounded,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField(
                    controller: _weightController,
                    label: 'Weight (kg)',
                    hint: '58',
                    icon: Icons.monitor_weight_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSection(
          title: 'Family Details',
          icon: Icons.family_restroom_rounded,
          children: [
            _buildField(
              controller: _parentsNameController,
              label: "Parent's Name",
              hint: "Father's / Mother's name",
              icon: Icons.people_outline_rounded,
            ),
            const SizedBox(height: 14),
            _buildField(
              controller: _parentsJobController,
              label: "Parent's Occupation",
              hint: 'e.g. Retired Government Officer',
              icon: Icons.work_history_outlined,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSection(
          title: 'Social Verification',
          icon: Icons.verified_user_outlined,
          children: [
            _buildField(
              controller: _fbLinkController,
              label: 'Facebook Profile Link',
              hint: 'https://facebook.com/yourprofile',
              icon: Icons.link_rounded,
              onChanged: _checkFbLink,
            ),
            if (_fbNameMatch) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D3D22).withAlpha(179),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF2D7A4F),
                    width: 0.5,
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 14,
                      color: Color(0xFF4ADE80),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Name matches FB profile. Last name will be masked until interest is accepted.',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11,
                          color: Color(0xFF4ADE80),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        _buildSection(
          title: 'Referral (Optional)',
          icon: Icons.card_giftcard_rounded,
          children: [
            _buildField(
              controller: _referralController,
              label: 'Referral Code',
              hint: 'Enter referral code if you have one',
              icon: Icons.discount_outlined,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF2D1A00).withAlpha(153),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFE8A87C).withAlpha(77),
                  width: 0.5,
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: Color(0xFFE8A87C),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Earn ₹100 bonus for every friend you refer who pays the ₹500 registration fee.',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11,
                        color: Color(0xFFE8A87C),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0x0AFFFFFF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x1AFFFFFF), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: const Color(0xFFC8556A)),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFEEE0F0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoUpload() {
    return GestureDetector(
      onTap: _showPhotoPickerSheet,
      child: Container(
        width: double.infinity,
        height: 90,
        decoration: BoxDecoration(
          color: const Color(0x1AFFFFFF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0x33FFFFFF),
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: _selectedImageFile == null
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 28,
                    color: Color(0xFFC8556A),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Upload Profile Photo',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 13,
                      color: Color(0xFF9A8A9E),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'JPG, PNG up to 5MB',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 11,
                      color: Color(0xFF6B5870),
                    ),
                  ),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(
                      File(_selectedImageFile!.path),
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF120D16).withAlpha(191),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 12,
                              color: Color(0xFFEEE0F0),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Change',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 10,
                                color: Color(0xFFEEE0F0),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF9A8A9E),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: ['Male', 'Female', 'Other'].map((g) {
            final isSelected = _selectedGender == g;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedGender = g),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFC8556A).withAlpha(51)
                        : const Color(0x1AFFFFFF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFC8556A)
                          : const Color(0x33FFFFFF),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    g,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? const Color(0xFFC8556A)
                          : const Color(0xFF9A8A9E),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF9A8A9E),
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: TextFormField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              onChanged: onChanged,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                color: Color(0xFFEEE0F0),
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13,
                  color: Color(0xFF6B5870),
                ),
                prefixIcon: Icon(
                  icon,
                  size: 16,
                  color: const Color(0xFF9A8A9E),
                ),
                suffixIcon: suffixIcon,
                filled: true,
                fillColor: const Color(0x1AFFFFFF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0x33FFFFFF),
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0x33FFFFFF),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFC8556A),
                    width: 1.5,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFB91C1C),
                    width: 1,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              validator: validator,
            ),
          ),
        ),
      ],
    );
  }
}
