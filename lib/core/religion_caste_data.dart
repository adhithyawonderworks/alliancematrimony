/// Religion and caste/community reference data, modeled after the fields
/// commonly collected by matrimony platforms (e.g. BharatMatrimony,
/// Shaadi.com, Jeevansathi). Each religion maps to its most common
/// caste/community options. "Other" is always appended so a user can type
/// in a value that isn't listed.
library;

const String kOtherOption = 'Other';

const List<String> kReligions = [
  'Hindu',
  'Muslim',
  'Christian',
  'Sikh',
  'Jain',
  'Buddhist',
  'Parsi',
  'Jewish',
  'Bahai',
  'No Religion',
  kOtherOption,
];

const Map<String, List<String>> kCastesByReligion = {
  'Hindu': [
    'Brahmin',
    'Kshatriya',
    'Vaishya',
    'Rajput',
    'Maratha',
    'Yadav',
    'Reddy',
    'Kamma',
    'Kapu',
    'Nair',
    'Nadar',
    'Chettiar',
    'Iyer',
    'Iyengar',
    'Gounder',
    'Mudaliar',
    'Pillai',
    'Vanniyar',
    'Vellalar',
    'Jat',
    'Kayastha',
    'Agarwal',
    'Bania',
    'Kurmi',
    'Gupta',
    'SC/ST',
    'OBC',
    kOtherOption,
  ],
  'Muslim': [
    'Sunni',
    'Shia',
    'Syed',
    'Sheikh',
    'Pathan',
    'Ansari',
    'Qureshi',
    'Mughal',
    kOtherOption,
  ],
  'Christian': [
    'Roman Catholic',
    'Protestant',
    'Orthodox',
    'CSI (Church of South India)',
    'Baptist',
    'Pentecostal',
    kOtherOption,
  ],
  'Sikh': ['Jat Sikh', 'Khatri', 'Ramgarhia', 'Arora', 'Saini', kOtherOption],
  'Jain': ['Digambar', 'Shwetambar', 'Agarwal Jain', kOtherOption],
  'Buddhist': ['Theravada', 'Mahayana', 'Navayana', kOtherOption],
  'Parsi': [kOtherOption],
  'Jewish': [kOtherOption],
  'Bahai': [kOtherOption],
  'No Religion': [kOtherOption],
  kOtherOption: [kOtherOption],
};

/// Returns the caste/community options for a given religion, always
/// ending with the "Other" option so users can specify their own.
List<String> castesFor(String? religion) {
  if (religion == null || religion.isEmpty) return [kOtherOption];
  return kCastesByReligion[religion] ?? [kOtherOption];
}
