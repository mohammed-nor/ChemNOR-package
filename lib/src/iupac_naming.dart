import 'dart:convert';
import 'package:http/http.dart' as http;

/// Utilities for IUPAC naming of chemical compounds.
class IupacNaming {
  /// Base URL for PubChem API.
  final String chempubBaseUrl = 'https://pubchem.ncbi.nlm.nih.gov/rest/pug';

  /// Generates an IUPAC name from a SMILES notation using PubChem API.
  ///
  /// Returns the IUPAC name as a string if successful.
  /// Returns null if an error occurs or the compound cannot be found.
  ///
  /// Example:
  /// ```dart
  /// final namer = IupacNaming();
  /// final iupacName = await namer.generateIupacName('CCO');
  /// print(iupacName); // 'ethanol'
  /// ```
  Future<String?> generateIupacName(String smiles) async {
    try {
      // Step 1: Convert SMILES to CID using PubChem API
      final cidList = await _getSmilesAsCid(smiles);
      if (cidList.isEmpty) {
        return null;
      }

      // Step 2: Get the compound properties using the first CID
      final cid = cidList.first;
      final properties = await _getCompoundProperties(cid);

      // Step 3: Extract and return the IUPAC name
      return properties['name'];
    } catch (e) {
      print('Error generating IUPAC name: $e');
      return null;
    }
  }

  /// Batch convert multiple SMILES strings to IUPAC names.
  ///
  /// Returns a map where keys are the original SMILES strings and
  /// values are the corresponding IUPAC names.
  Future<Map<String, String?>> batchGenerateIupacNames(List<String> smilesList) async {
    final Map<String, String?> result = {};
    for (final smiles in smilesList) {
      result[smiles] = await generateIupacName(smiles);
    }
    return result;
  }

  /// Converts a SMILES string to a PubChem CID.
  Future<List<int>> _getSmilesAsCid(String smiles) async {
    final encodedSmiles = Uri.encodeComponent(smiles);
    final url = Uri.parse('$chempubBaseUrl/compound/smiles/$encodedSmiles/cids/JSON');

    final response = await http.get(url);
    if (response.statusCode != 200) {
      return [];
    }

    final data = jsonDecode(response.body);
    if (data['IdentifierList'] == null || data['IdentifierList']['CID'] == null) {
      return [];
    }

    return (data['IdentifierList']['CID'] as List).cast<int>().toList();
  }

  /// Fetches compound properties from PubChem using the given CID.
  Future<Map<String, dynamic>> _getCompoundProperties(int cid) async {
    final url = Uri.parse('$chempubBaseUrl/compound/cid/$cid/JSON');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch compound properties');
    }

    final data = jsonDecode(response.body);
    final properties = data['PC_Compounds'][0]['props'];

    // Extract the IUPAC name
    String? name = _findProperty(properties, 'IUPAC Name') ?? _findProperty(properties, 'Preferred IUPAC Name');

    // If IUPAC name is not found, fall back to other names
    name ??= _findProperty(properties, 'Systematic Name') ?? _findProperty(properties, 'Traditional Name') ?? 'Unnamed compound';

    return {
      'name': name,
      'cid': cid,
    };
  }

  /// Extracts a specific property from the PubChem response.
  String? _findProperty(List<dynamic> properties, String label) {
    try {
      for (var prop in properties) {
        if (prop['urn']['label'] == label) {
          return prop['value']['sval'] ?? prop['value']['fval']?.toString();
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

/// Convenience function to generate an IUPAC name from a SMILES notation.
///
/// This is a shorthand for creating an IupacNaming instance and calling
/// generateIupacName on it.
Future<String?> generateIupacName(String smiles) async {
  final namer = IupacNaming();
  return await namer.generateIupacName(smiles);
}
