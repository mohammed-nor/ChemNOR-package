import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

/// ChemNOR class is responsible for finding relevant chemical compounds
/// based on an application description.
///
/// It uses Google Gemini AI to suggest relevant SMILES (Simplified Molecular
/// Input Line Entry System) patterns and queries the PubChem database
/// to find compounds matching those patterns.
class ChemNOR {
  /// API key for Google Generative AI.
  final String genAiApiKey;

  /// Base URL for PubChem API.
  final String chempubBaseUrl = 'https://pubchem.ncbi.nlm.nih.gov/rest/pug';

  /// Maximum number of results per SMILES pattern.
  final int maxResultsPerSmiles = 5;

  /// Constructor for ChemNOR, requires an API key for Google Generative AI.
  ChemNOR({required this.genAiApiKey});

  /// Finds relevant chemical compounds for a given application description.
  ///
  /// - Uses AI to generate SMILES patterns.
  /// - Searches PubChem for matching compounds.
  /// - Retrieves properties of the top compounds found.
  ///
  /// Returns a formatted string containing search results.
  Future<String> findListOfCompounds(String applicationDescription) async {
    try {
      // Step 1: Get relevant SMILES patterns from AI
      final smilesList = await getRelevantSmiles(applicationDescription);

      // Step 2: Search PubChem for each SMILES pattern
      final Set<int> uniqueCids = {};
      for (String smiles in smilesList) {
        final cids = await getSubstructureCids(smiles);
        uniqueCids.addAll(cids.take(maxResultsPerSmiles));
      }

      // Step 3: Fetch properties for collected CIDs
      final List<Map<String, dynamic>> results = [];
      for (int cid in uniqueCids.take(10)) {
        try {
          results.add(await getCompoundProperties(cid));
        } catch (e) {
          results.add({'error': 'CID $cid: ${e.toString()}'});
        }
      }

      return _formatResults(results, smilesList);
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  /// Uses Google Gemini AI to suggest relevant SMILES patterns
  /// based on the given application description.
  ///
  /// Returns a list of valid SMILES strings.
  Future<List<String>> getRelevantSmiles(String description) async {
    final prompt = '''
    Given the application: "$description", suggest 3-5 SMILES patterns representing 
    key functional groups or structural motifs relevant to this application.
    Return ONLY valid SMILES strings, one per line, with no additional text.
    Example:
    C(=O)O
    c1ccccc1
    NC(=O)N
    ''';

    final model = GenerativeModel(model: 'gemini-pro', apiKey: genAiApiKey);
    final response = await model.generateContent([Content.text(prompt)]);

    // Extract SMILES using regex pattern
    final RegExp smilesRegex =
        RegExp(r'^[A-Za-z0-9@+\-\[\]\(\)\\/=#$.]+$', multiLine: true);
    final matches = smilesRegex.allMatches(response.text ?? '');

    if (matches.isEmpty) {
      throw Exception('No valid SMILES found in AI response');
    }

    return matches.map((m) => m.group(0)!).toList();
  }

  /// Searches PubChem for compounds containing the given SMILES pattern.
  ///
  /// Returns a list of compound IDs (CIDs) matching the pattern.
  Future<List<int>> getSubstructureCids(String smiles) async {
    final encodedSmiles = Uri.encodeComponent(smiles);
    final url = Uri.parse(
        '$chempubBaseUrl/compound/fastidentity/SMILES/$encodedSmiles/cids/JSON');

    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Substructure search failed for SMILES: $smiles');
    }

    final data = jsonDecode(response.body);
    return (data['IdentifierList']['CID'] as List).cast<int>().toList();
  }

  /// Fetches compound properties from PubChem using the given CID.
  ///
  /// Returns a map containing compound details like name, formula, weight, and SMILES.
  Future<Map<String, dynamic>> getCompoundProperties(int cid) async {
    final url = Uri.parse('$chempubBaseUrl/compound/cid/$cid/JSON');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch properties for CID $cid');
    }

    final data = jsonDecode(response.body);
    final properties = data['PC_Compounds'][0]['props'];

    return {
      'cid': cid,
      'name': _findfvalPropertybylabel(properties, 'Allowed', 'IUPAC Name') ??
          'Unnamed compound',
      'formula':
          _findProperty(properties, 'Molecular Formula') ?? 'Unnamed compound',
      'weight': _findfvalPropertybylabelonly(properties, 'Molecular Weight') ??
          'Unnamed compound',
      'CSMILES': _findfvalPropertybylabel(properties, 'Absolute', 'SMILES') ??
          'Unnamed compound',
      'Hydrogen Bond Donor': _findivalPropertybylabel(
              properties, 'Hydrogen Bond Donor', 'Count') ??
          'Unnamed compound',
      'Hydrogen Bond Acceptor': _findivalPropertybylabel(
              properties, 'Hydrogen Bond Acceptor', 'Count') ??
          'Unnamed compound',
      'TPSA': _findfvalPropertybylabel(
              properties, 'Polar Surface Area', 'Topological') ??
          'Unnamed compound',
      'Complexity':
          _findfvalPropertybylabelonly(properties, 'Compound Complexity') ??
              'Unnamed compound',
      'charge	': _findProperty(properties, 'Charge') ?? 'N/A',
      'Title': _findProperty(properties, 'Title') ?? 'N/A',
      'XLogP': _findfvalPropertybylabel(properties, 'XLogP3', 'Log P') ??
          'Unnamed compound',
    };
  }

  /// Extracts a specific property from the PubChem response.
  ///
  /// Returns the property value as a string if found, otherwise null.

  String? _findProperty(List<dynamic> properties, String label) {
    try {
      final prop = properties.firstWhere(
        (p) => p['urn']['label'] == label,
        orElse: () => null,
      );
      return prop['value']['sval'] ?? prop['value']['fval'].toString();
    } catch (e) {
      return null;
    }
  }

  String? _findfvalPropertybylabel(
      List<dynamic> properties, String name, String label) {
    try {
      final prop = properties.firstWhere(
        (p) => p['urn']['name'] == name && p['urn']['label'] == label,
        orElse: () => null,
      );
      return prop['value']['sval'] ?? prop['value']['fval'].toString();
    } catch (e) {
      return null;
    }
  }

  String? _findivalPropertybylabel(
      List<dynamic> properties, String name, String label) {
    try {
      final prop = properties.firstWhere(
        (p) => p['urn']['name'] == name && p['urn']['label'] == label,
        orElse: () => null,
      );
      return prop['value']['sval'] ?? prop['value']['ival'].toString();
    } catch (e) {
      return null;
    }
  }

  String? _findfvalPropertybylabelonly(List<dynamic> properties, String label) {
    try {
      final prop = properties.firstWhere(
        (p) => p['urn']['label'] == label,
        orElse: () => null,
      );
      return prop['value']['sval'] ?? prop['value']['fval'].toString();
    } catch (e) {
      return null;
    }
  }

  /// Formats the search results into a human-readable string.
  ///
  /// Includes details such as query SMILES patterns and compound properties.
  String _formatResults(
      List<Map<String, dynamic>> results, List<String> querySmiles) {
    final buffer = StringBuffer();
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

    buffer.writeln('ChemNOR Compound Search Results');
    buffer.writeln('Generated at: ${dateFormat.format(DateTime.now())}');
    buffer.writeln('Query SMILES patterns: ${querySmiles.join(', ')}');
    buffer.writeln('====================================================\n');

    for (final result in results) {
      if (result.containsKey('error')) {
        buffer.writeln('Error: ${result['error']}');
        continue;
      }

      buffer.writeln('CID: ${result['cid']}');
      buffer.writeln('Name: ${result['name']}');
      buffer.writeln('Molecular Formula: ${result['formula']}');
      buffer.writeln('SMILES: ${result['CSMILES']}');
      buffer.writeln('Hydrogen Bond Donor: ${result['Hydrogen Bond Donor']}');
      buffer.writeln(
          'Hydrogen Bond Acceptor: ${result['Hydrogen Bond Acceptor']}');
      buffer.writeln('TPSA: ${result['TPSA']}');
      buffer.writeln('Complexity: ${result['Complexity']}');
      buffer.writeln('Charge: ${result['charge']}');
      buffer.writeln('Title: ${result['Title']}');
      buffer.writeln('XLogP: ${result['XLogP']}');
      buffer.writeln('--------------------------------------------');
    }

    return buffer.toString();
  }
}
