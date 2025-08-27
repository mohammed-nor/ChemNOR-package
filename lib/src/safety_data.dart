import 'dart:convert';
import 'package:http/http.dart' as http;

/// Provides access to chemical safety data, including hazard classifications,
/// safety precautions, and regulatory information.
class SafetyData {
  /// Base URL for PubChem API.
  static const String chempubBaseUrl = 'https://pubchem.ncbi.nlm.nih.gov/rest/pug';

  /// Cached safety data to minimize API calls
  static final Map<String, Map<String, dynamic>> _cache = {};

  /// Retrieves safety data for a chemical compound by name or identifier.
  ///
  /// Parameters:
  /// - [chemical]: The name, CAS number, or other identifier for the chemical
  /// - [useCached]: Whether to use cached data if available (default: true)
  ///
  /// Returns a map containing safety information including:
  /// - GHS classifications
  /// - Hazard statements (H-codes)
  /// - Precautionary statements (P-codes)
  /// - Signal word (Danger/Warning)
  /// - Pictograms
  static Future<Map<String, dynamic>> getSafetyData(String chemical, {bool useCached = true}) async {
    // Check cache first if enabled
    if (useCached && _cache.containsKey(chemical)) {
      return Map.from(_cache[chemical]!);
    }

    try {
      // Step 1: Search for the compound to get its CID
      final cid = await _getCompoundCID(chemical);
      if (cid == null) {
        return {'error': 'Compound not found'};
      }

      // Step 2: Get safety data using the CID
      final safetyData = await _fetchSafetyData(cid);

      // Cache the result
      _cache[chemical] = Map.from(safetyData);

      return safetyData;
    } catch (e) {
      return {'error': 'Failed to retrieve safety data: $e'};
    }
  }

  /// Searches for a compound by name or identifier and returns its CID.
  static Future<int?> _getCompoundCID(String chemical) async {
    final encodedName = Uri.encodeComponent(chemical);
    final url = Uri.parse('$chempubBaseUrl/compound/name/$encodedName/cids/JSON');

    final response = await http.get(url);
    if (response.statusCode != 200) {
      return null;
    }

    final data = jsonDecode(response.body);
    if (data['IdentifierList'] == null || data['IdentifierList']['CID'] == null) {
      return null;
    }

    return data['IdentifierList']['CID'][0];
  }

  /// Fetches safety data for a compound using its CID.
  static Future<Map<String, dynamic>> _fetchSafetyData(int cid) async {
    // Get the GHS classification data
    final ghsUrl = Uri.parse('$chempubBaseUrl/compound/cid/$cid/JSON?heading=GHS Classification');

    final response = await http.get(ghsUrl);
    if (response.statusCode != 200) {
      return {'error': 'Failed to retrieve GHS data'};
    }

    try {
      final data = jsonDecode(response.body);
      final result = <String, dynamic>{
        'cid': cid,
        'ghs': <String, dynamic>{},
        'hazard_statements': <String>{},
        'precautionary_statements': <String>{},
        'signal_word': '',
        'pictograms': <String>[],
      };

      // Process GHS data
      if (data['PC_Compounds'] != null && data['PC_Compounds'][0]['props'] != null) {
        final props = data['PC_Compounds'][0]['props'];

        // Extract GHS information
        for (var prop in props) {
          if (prop['urn'] != null && prop['urn']['label'] != null && prop['urn']['label'].toString().contains('GHS')) {
            final label = prop['urn']['label'];
            final value = prop['value'];

            if (value != null) {
              if (value['sval'] != null) {
                if (label == 'GHS Hazard Statements') {
                  result['hazard_statements'] = _parseStatements(value['sval']);
                } else if (label == 'GHS Precautionary Statements') {
                  result['precautionary_statements'] = _parseStatements(value['sval']);
                } else if (label == 'GHS Signal Word') {
                  result['signal_word'] = value['sval'];
                } else if (label == 'GHS Pictograms') {
                  result['pictograms'] = value['sval'].toString().split(';');
                } else {
                  result['ghs'][label] = value['sval'];
                }
              }
            }
          }
        }
      }

      // If we couldn't find GHS data, try to get safety data from other sources
      if (result['hazard_statements'].isEmpty) {
        await _enrichWithAdditionalData(cid, result);
      }

      return result;
    } catch (e) {
      return {'error': 'Error parsing safety data: $e'};
    }
  }

  /// Parses statements like "H302; H315" into a set of individual codes
  static Set<String> _parseStatements(String statements) {
    if (statements.isEmpty) return {};

    return statements.split(';').map((s) => s.trim()).where((s) => s.isNotEmpty).toSet();
  }

  /// Enriches the safety data with information from additional PubChem sources
  static Future<void> _enrichWithAdditionalData(int cid, Map<String, dynamic> result) async {
    try {
      // Try to get LCSS (Laboratory Chemical Safety Summary) data
      final lcssUrl = Uri.parse('$chempubBaseUrl/compound/cid/$cid/JSON?heading=Safety and Hazards');

      final response = await http.get(lcssUrl);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Process LCSS data (implementation depends on the specific data structure)
        // This is a simplified example
        if (data['Record'] != null && data['Record']['Section'] != null) {
          // Process sections to extract safety information
          // Implementation depends on the specific data structure
        }
      }
    } catch (e) {
      // Just log the error, don't throw
      print('Error enriching safety data: $e');
    }
  }

  /// Returns a description for a specific hazard statement code
  static String? getHazardStatementDescription(String code) {
    return _hazardStatements[code];
  }

  /// Returns a description for a specific precautionary statement code
  static String? getPrecautionaryStatementDescription(String code) {
    return _precautionaryStatements[code];
  }

  /// Map of common GHS hazard statement codes to descriptions
  static final Map<String, String> _hazardStatements = {
    'H200': 'Unstable explosive',
    'H201': 'Explosive; mass explosion hazard',
    'H202': 'Explosive; severe projection hazard',
    'H203': 'Explosive; fire, blast or projection hazard',
    'H204': 'Fire or projection hazard',
    'H205': 'May mass explode in fire',
    'H220': 'Extremely flammable gas',
    'H221': 'Flammable gas',
    'H222': 'Extremely flammable aerosol',
    'H223': 'Flammable aerosol',
    'H224': 'Extremely flammable liquid and vapour',
    'H225': 'Highly flammable liquid and vapour',
    'H226': 'Flammable liquid and vapour',
    'H227': 'Combustible liquid',
    'H228': 'Flammable solid',
    'H229': 'Pressurized container: may burst if heated',
    'H230': 'May react explosively even in the absence of air',
    'H231': 'May react explosively even in the absence of air at elevated pressure and/or temperature',
    'H240': 'Heating may cause an explosion',
    'H241': 'Heating may cause a fire or explosion',
    'H242': 'Heating may cause a fire',
    'H250': 'Catches fire spontaneously if exposed to air',
    'H251': 'Self-heating; may catch fire',
    'H252': 'Self-heating in large quantities; may catch fire',
    'H260': 'In contact with water releases flammable gases which may ignite spontaneously',
    'H261': 'In contact with water releases flammable gas',
    'H270': 'May cause or intensify fire; oxidizer',
    'H271': 'May cause fire or explosion; strong oxidizer',
    'H272': 'May intensify fire; oxidizer',
    'H280': 'Contains gas under pressure; may explode if heated',
    'H281': 'Contains refrigerated gas; may cause cryogenic burns or injury',
    'H290': 'May be corrosive to metals',
    'H300': 'Fatal if swallowed',
    'H301': 'Toxic if swallowed',
    'H302': 'Harmful if swallowed',
    'H303': 'May be harmful if swallowed',
    'H304': 'May be fatal if swallowed and enters airways',
    'H305': 'May be harmful if swallowed and enters airways',
    'H310': 'Fatal in contact with skin',
    'H311': 'Toxic in contact with skin',
    'H312': 'Harmful in contact with skin',
    'H313': 'May be harmful in contact with skin',
    'H314': 'Causes severe skin burns and eye damage',
    'H315': 'Causes skin irritation',
    'H316': 'Causes mild skin irritation',
    'H317': 'May cause an allergic skin reaction',
    'H318': 'Causes serious eye damage',
    'H319': 'Causes serious eye irritation',
    'H320': 'Causes eye irritation',
    'H330': 'Fatal if inhaled',
    'H331': 'Toxic if inhaled',
    'H332': 'Harmful if inhaled',
    'H333': 'May be harmful if inhaled',
    'H334': 'May cause allergy or asthma symptoms or breathing difficulties if inhaled',
    'H335': 'May cause respiratory irritation',
    'H336': 'May cause drowsiness or dizziness',
    'H340': 'May cause genetic defects',
    'H341': 'Suspected of causing genetic defects',
    'H350': 'May cause cancer',
    'H351': 'Suspected of causing cancer',
    'H360': 'May damage fertility or the unborn child',
    'H361': 'Suspected of damaging fertility or the unborn child',
    'H362': 'May cause harm to breast-fed children',
    'H370': 'Causes damage to organs',
    'H371': 'May cause damage to organs',
    'H372': 'Causes damage to organs through prolonged or repeated exposure',
    'H373': 'May cause damage to organs through prolonged or repeated exposure',
    'H400': 'Very toxic to aquatic life',
    'H401': 'Toxic to aquatic life',
    'H402': 'Harmful to aquatic life',
    'H410': 'Very toxic to aquatic life with long lasting effects',
    'H411': 'Toxic to aquatic life with long lasting effects',
    'H412': 'Harmful to aquatic life with long lasting effects',
    'H413': 'May cause long lasting harmful effects to aquatic life',
    'H420': 'Harms public health and the environment by destroying ozone in the upper atmosphere',
  };

  /// Map of common GHS precautionary statement codes to descriptions
  static final Map<String, String> _precautionaryStatements = {
    'P101': 'If medical advice is needed, have product container or label at hand',
    'P102': 'Keep out of reach of children',
    'P103': 'Read carefully and follow all instructions',
    'P201': 'Obtain special instructions before use',
    'P202': 'Do not handle until all safety precautions have been read and understood',
    'P210': 'Keep away from heat, hot surfaces, sparks, open flames and other ignition sources. No smoking',
    'P220': 'Keep away from clothing and other combustible materials',
    'P221': 'Take any precaution to avoid mixing with combustibles',
    'P222': 'Do not allow contact with air',
    'P223': 'Do not allow contact with water',
    'P230': 'Keep wetted with...',
    'P231': 'Handle and store contents under inert gas',
    'P232': 'Protect from moisture',
    'P233': 'Keep container tightly closed',
    'P234': 'Keep only in original packaging',
    'P235': 'Keep cool',
    'P240': 'Ground and bond container and receiving equipment',
    'P241': 'Use explosion-proof electrical/ventilating/lighting equipment',
    'P242': 'Use non-sparking tools',
    'P243': 'Take action to prevent static discharges',
    'P244': 'Keep valves and fittings free from oil and grease',
    'P250': 'Do not subject to grinding/shock/friction',
    'P251': 'Do not pierce or burn, even after use',
    'P260': 'Do not breathe dust/fume/gas/mist/vapours/spray',
    'P261': 'Avoid breathing dust/fume/gas/mist/vapours/spray',
    'P262': 'Do not get in eyes, on skin, or on clothing',
    'P263': 'Avoid contact during pregnancy and while nursing',
    'P264': 'Wash thoroughly after handling',
    'P270': 'Do not eat, drink or smoke when using this product',
    'P271': 'Use only outdoors or in a well-ventilated area',
    'P272': 'Contaminated work clothing should not be allowed out of the workplace',
    'P273': 'Avoid release to the environment',
    'P280': 'Wear protective gloves/protective clothing/eye protection/face protection',
    // Additional precautionary statements can be added as needed
  };
}

/// Convenience function to get safety data for a chemical.
Future<Map<String, dynamic>> getSafetyData(String chemical) {
  return SafetyData.getSafetyData(chemical);
}
