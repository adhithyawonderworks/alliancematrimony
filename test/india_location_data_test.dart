import 'package:adithyamatrimony/core/india_location_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('includes every Union Territory and custom city option', () {
    const unionTerritories = [
      'Andaman and Nicobar Islands',
      'Chandigarh',
      'Dadra and Nagar Haveli and Daman and Diu',
      'Delhi',
      'Jammu and Kashmir',
      'Ladakh',
      'Lakshadweep',
      'Puducherry',
    ];

    expect(kIndianStatesAndUnionTerritories, containsAll(unionTerritories));
    expect(citiesForState('Tamil Nadu'), contains('Chennai'));
    expect(citiesForState('Tamil Nadu'), contains(kLocationOther));
  });

  test('parses legacy city and state place strings', () {
    expect(parseIndianPlace('Chennai, Tamil Nadu'), (
      state: 'Tamil Nadu',
      city: 'Chennai',
    ));
  });
}
