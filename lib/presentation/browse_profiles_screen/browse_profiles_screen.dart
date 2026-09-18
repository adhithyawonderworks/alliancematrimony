import 'dart:ui';

import 'package:flutter/material.dart';

import '../../widgets/empty_state_widget.dart';
import './widgets/browse_filter_chips_widget.dart';
import './widgets/payment_unlock_banner_widget.dart';
import './widgets/profile_card_widget.dart';

class MatrimonyProfile {
  final String id;
  final String firstName;
  final String maskedLastName;
  final int age;
  final String job;
  final String place;
  final String heightCm;
  final String religion;
  final String caste;
  final String imageUrl;
  final String semanticLabel;
  final bool isVerified;
  final bool isNew;
  final String education;
  final String motherTongue;

  const MatrimonyProfile({
    required this.id,
    required this.firstName,
    required this.maskedLastName,
    required this.age,
    required this.job,
    required this.place,
    required this.heightCm,
    required this.religion,
    required this.caste,
    required this.imageUrl,
    required this.semanticLabel,
    required this.isVerified,
    required this.isNew,
    required this.education,
    required this.motherTongue,
  });

  String get displayName => '$firstName ${maskedLastName[0]}***';

  factory MatrimonyProfile.fromMap(Map<String, dynamic> map) {
    return MatrimonyProfile(
      id: map['id'] as String,
      firstName: map['firstName'] as String,
      maskedLastName: map['maskedLastName'] as String,
      age: map['age'] as int,
      job: map['job'] as String,
      place: map['place'] as String,
      heightCm: map['heightCm'] as String,
      religion: map['religion'] as String,
      caste: map['caste'] as String,
      imageUrl: map['imageUrl'] as String,
      semanticLabel: map['semanticLabel'] as String,
      isVerified: map['isVerified'] as bool,
      isNew: map['isNew'] as bool,
      education: map['education'] as String,
      motherTongue: map['motherTongue'] as String,
    );
  }
}

class BrowseProfilesScreen extends StatefulWidget {
  const BrowseProfilesScreen({super.key});

  @override
  State<BrowseProfilesScreen> createState() => _BrowseProfilesScreenState();
}

class _BrowseProfilesScreenState extends State<BrowseProfilesScreen> {
  // TODO: Replace with [Riverpod/Bloc] for production
  bool _isPaid = false;
  bool _isLoading = true;
  bool _showSearchBar = false;
  String _activeFilter = 'All';
  String _searchQuery = '';
  static const List<String> _filterOptions = [
    'All',
    'New',
    'Verified',
    'Hindu',
    'Christian',
    'Muslim',
  ];
  final List<String> _sentInterests = [];
  late List<MatrimonyProfile> _profiles;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  static const List<Map<String, dynamic>> _profileMaps = [
    {
      'id': 'p001',
      'firstName': 'Kavitha',
      'maskedLastName': 'Subramaniam',
      'age': 26,
      'job': 'Software Engineer',
      'place': 'Chennai, Tamil Nadu',
      'heightCm': '163 cm',
      'religion': 'Hindu',
      'caste': 'Brahmin',
      'imageUrl':
          'https://img.rocket.new/generatedImages/rocket_gen_img_19205d2aa-1763296356182.png',
      'semanticLabel':
          'Young Indian woman with long dark hair smiling warmly in professional attire',
      'isVerified': true,
      'isNew': false,
      'education': 'B.Tech Computer Science',
      'motherTongue': 'Tamil',
    },
    {
      'id': 'p002',
      'firstName': 'Ananya',
      'maskedLastName': 'Krishnamurthy',
      'age': 24,
      'job': 'Doctor (MBBS)',
      'place': 'Bengaluru, Karnataka',
      'heightCm': '158 cm',
      'religion': 'Hindu',
      'caste': 'Vellalar',
      'imageUrl':
          'https://img.rocket.new/generatedImages/rocket_gen_img_11024eed6-1773839583061.png',
      'semanticLabel':
          'South Indian woman in traditional saree with floral jewelry smiling',
      'isVerified': true,
      'isNew': true,
      'education': 'MBBS, MD',
      'motherTongue': 'Kannada',
    },
    {
      'id': 'p003',
      'firstName': 'Deepika',
      'maskedLastName': 'Narayanan',
      'age': 28,
      'job': 'Bank Manager',
      'place': 'Coimbatore, Tamil Nadu',
      'heightCm': '160 cm',
      'religion': 'Hindu',
      'caste': 'Mudaliar',
      'imageUrl':
          'https://img.rocket.new/generatedImages/rocket_gen_img_1bfc4a653-1763295413296.png',
      'semanticLabel':
          'Indian woman in formal office wear with confident expression',
      'isVerified': false,
      'isNew': false,
      'education': 'MBA Finance',
      'motherTongue': 'Tamil',
    },
    {
      'id': 'p004',
      'firstName': 'Meenakshi',
      'maskedLastName': 'Venkataraman',
      'age': 25,
      'job': 'Teacher',
      'place': 'Madurai, Tamil Nadu',
      'heightCm': '155 cm',
      'religion': 'Hindu',
      'caste': 'Nadar',
      'imageUrl':
          'https://images.unsplash.com/photo-1697312929925-9746319ae875',
      'semanticLabel':
          'Young Indian woman with traditional bindi and earrings in garden setting',
      'isVerified': true,
      'isNew': true,
      'education': 'B.Ed, M.A. Literature',
      'motherTongue': 'Tamil',
    },
    {
      'id': 'p005',
      'firstName': 'Preethi',
      'maskedLastName': 'Balasubramanian',
      'age': 27,
      'job': 'Data Analyst',
      'place': 'Hyderabad, Telangana',
      'heightCm': '162 cm',
      'religion': 'Hindu',
      'caste': 'Chettiar',
      'imageUrl':
          'https://img.rocket.new/generatedImages/rocket_gen_img_14b3a32aa-1772054739413.png',
      'semanticLabel':
          'Professional Indian woman at laptop smiling in modern office',
      'isVerified': true,
      'isNew': false,
      'education': 'B.Sc Statistics, MS Data Science',
      'motherTongue': 'Telugu',
    },
    {
      'id': 'p006',
      'firstName': 'Saranya',
      'maskedLastName': 'Chandrasekaran',
      'age': 23,
      'job': 'Chartered Accountant',
      'place': 'Trichy, Tamil Nadu',
      'heightCm': '157 cm',
      'religion': 'Hindu',
      'caste': 'Pillai',
      'imageUrl':
          'https://images.unsplash.com/photo-1614855918624-d184f79a112a',
      'semanticLabel':
          'Indian woman in traditional silk saree with gold jewelry at temple',
      'isVerified': false,
      'isNew': true,
      'education': 'B.Com, CA Final',
      'motherTongue': 'Tamil',
    },
    {
      'id': 'p007',
      'firstName': 'Nithya',
      'maskedLastName': 'Raghunathan',
      'age': 29,
      'job': 'Civil Engineer',
      'place': 'Pune, Maharashtra',
      'heightCm': '165 cm',
      'religion': 'Hindu',
      'caste': 'Iyengar',
      'imageUrl':
          'https://images.unsplash.com/photo-1675018996213-dab82e090a2e',
      'semanticLabel':
          'Indian woman in casual western wear smiling outdoors in sunny setting',
      'isVerified': true,
      'isNew': false,
      'education': 'B.E. Civil Engineering',
      'motherTongue': 'Tamil',
    },
    {
      'id': 'p008',
      'firstName': 'Lavanya',
      'maskedLastName': 'Parthasarathy',
      'age': 26,
      'job': 'Pharmacist',
      'place': 'Kochi, Kerala',
      'heightCm': '159 cm',
      'religion': 'Hindu',
      'caste': 'Nair',
      'imageUrl':
          'https://images.unsplash.com/photo-1604247618324-3656e0c5b24b',
      'semanticLabel':
          'Young South Indian woman with jasmine flowers in hair wearing kurta',
      'isVerified': true,
      'isNew': true,
      'education': 'B.Pharm',
      'motherTongue': 'Malayalam',
    },
  ];

  @override
  void initState() {
    super.initState();
    _profiles = _profileMaps.map(MatrimonyProfile.fromMap).toList();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  List<MatrimonyProfile> get _filteredProfiles {
    final query = _searchQuery.trim().toLowerCase();
    Iterable<MatrimonyProfile> results = _profiles;

    if (_activeFilter == 'New') {
      results = results.where((p) => p.isNew);
    } else if (_activeFilter == 'Verified') {
      results = results.where((p) => p.isVerified);
    } else if (_activeFilter != 'All') {
      results = results.where((p) => p.religion == _activeFilter);
    }

    if (query.isNotEmpty) {
      results = results.where((profile) {
        final haystack = [
          profile.firstName,
          profile.job,
          profile.place,
          profile.religion,
          profile.caste,
          profile.education,
          profile.motherTongue,
          profile.displayName,
        ].join(' ').toLowerCase();

        return haystack.contains(query);
      });
    }

    return results.toList();
  }

  void _toggleSearchBar() {
    setState(() {
      _showSearchBar = !_showSearchBar;
      if (!_showSearchBar) {
        _searchController.clear();
        _searchQuery = '';
        _searchFocusNode.unfocus();
      }
    });

    if (_showSearchBar) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _searchFocusNode.requestFocus();
        }
      });
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1520),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Browse Filters',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFEEE0F0),
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 10,
                children: _filterOptions.map((filter) {
                  final isSelected = _activeFilter == filter;
                  return ChoiceChip(
                    label: Text(
                      filter,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF9A8A9E),
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _activeFilter = filter);
                      Navigator.pop(sheetContext);
                    },
                    backgroundColor: const Color(0xFF2A1E2E),
                    selectedColor: const Color(0xFFC8556A),
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xFFC8556A)
                          : const Color(0x33FFFFFF),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC8556A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    return Scaffold(
      backgroundColor: const Color(0xFF120D16),
      body: RefreshIndicator(
        color: const Color(0xFFC8556A),
        backgroundColor: const Color(0xFF1E1520),
        onRefresh: () async {
          // TODO: Replace with [Riverpod/Bloc] profile refresh
          await Future.delayed(const Duration(milliseconds: 800));
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildGlassAppBar(),
            SliverToBoxAdapter(
              child: BrowseFilterChipsWidget(
                activeFilter: _activeFilter,
                onFilterChanged: (f) => setState(() => _activeFilter = f),
              ),
            ),
            if (_showSearchBar)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1520),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0x33FFFFFF),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        color: Color(0xFFEEE0F0),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search by name, job, city or community',
                        hintStyle: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13,
                          color: Color(0xFF9A8A9E),
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: Color(0xFFC8556A),
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: Color(0xFF9A8A9E),
                                ),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (!_isPaid)
              SliverToBoxAdapter(
                child: PaymentUnlockBannerWidget(
                  onPay: () => setState(() => _isPaid = true),
                ),
              ),
            if (_isLoading)
              _buildSkeletonGrid(isTablet)
            else if (_filteredProfiles.isEmpty)
              SliverFillRemaining(
                child: EmptyStateWidget(
                  icon: Icons.favorite_border_rounded,
                  title: 'No profiles found',
                  subtitle:
                      'Try adjusting your filters or search to find more compatible matches',
                  ctaLabel: 'Clear Filters',
                  onCta: () {
                    setState(() {
                      _activeFilter = 'All';
                      _searchQuery = '';
                      _searchController.clear();
                    });
                  },
                ),
              )
            else
              _buildProfileGrid(isTablet),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF120D16).withAlpha(179),
              border: const Border(
                bottom: BorderSide(color: Color(0x1AFFFFFF), width: 1),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFC8556A), Color(0xFFE8A87C)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Adithya',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFEEE0F0),
                              ),
                            ),
                            TextSpan(
                              text: ' Matrimony',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFFC8556A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _showSearchBar ? Icons.search_off_rounded : Icons.search_rounded,
                        color: const Color(0xFFEEE0F0),
                        size: 22,
                      ),
                      onPressed: _toggleSearchBar,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.tune_rounded,
                        color: Color(0xFFEEE0F0),
                        size: 22,
                      ),
                      onPressed: _showFilterSheet,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      expandedHeight: 60,
    );
  }

  Widget _buildProfileGrid(bool isTablet) {
    final crossAxisCount = isTablet ? 3 : 2;
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate((context, index) {
          final profile = _filteredProfiles[index];
          return _AnimatedProfileCard(
            index: index,
            profile: profile,
            isPaid: _isPaid,
            hasInterest: _sentInterests.contains(profile.id),
            onInterest: () {
              setState(() {
                if (_sentInterests.contains(profile.id)) {
                  _sentInterests.remove(profile.id);
                } else {
                  _sentInterests.add(profile.id);
                }
              });
            },
          );
        }, childCount: _filteredProfiles.length),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 0.62,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
      ),
    );
  }

  Widget _buildSkeletonGrid(bool isTablet) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) => Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1520),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A1E2E),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SkeletonBox(width: 90, height: 12),
                      SizedBox(height: 6),
                      _SkeletonBox(width: 60, height: 10),
                      SizedBox(height: 6),
                      _SkeletonBox(width: 70, height: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
          childCount: 6,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isTablet ? 3 : 2,
          childAspectRatio: 0.62,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  const _SkeletonBox({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF2A1E2E),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

class _AnimatedProfileCard extends StatefulWidget {
  final int index;
  final MatrimonyProfile profile;
  final bool isPaid;
  final bool hasInterest;
  final VoidCallback onInterest;

  const _AnimatedProfileCard({
    required this.index,
    required this.profile,
    required this.isPaid,
    required this.hasInterest,
    required this.onInterest,
  });

  @override
  State<_AnimatedProfileCard> createState() => _AnimatedProfileCardState();
}

class _AnimatedProfileCardState extends State<_AnimatedProfileCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(
      Duration(milliseconds: (widget.index * 60).clamp(0, 400)),
      () {
        if (mounted) _controller.forward();
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: ProfileCardWidget(
          profile: widget.profile,
          isPaid: widget.isPaid,
          hasInterest: widget.hasInterest,
          onInterest: widget.onInterest,
        ),
      ),
    );
  }
}
