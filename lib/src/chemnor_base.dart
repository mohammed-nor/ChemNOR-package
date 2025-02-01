import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class ChemNOR {
  final String genAiApiKey;
  final String chempubBaseUrl = 'https://pubchem.ncbi.nlm.nih.gov/rest/pug';
  final int maxResultsPerSmiles = 5;

  ChemNOR({required this.genAiApiKey});

  Future<String> findCompounds(String applicationDescription) async {
    try {
      // Step 1: Get relevant SMILES patterns from AI
      final smilesList = await _getRelevantSmiles(applicationDescription);

      // Step 2: Search PubChem for each SMILES pattern
      final Set<int> uniqueCids = {};
      for (String smiles in smilesList) {
        final cids = await _getSubstructureCids(smiles);
        uniqueCids.addAll(cids.take(maxResultsPerSmiles));
      }

      // Step 3: Fetch properties for collected CIDs
      final List<Map<String, dynamic>> results = [];
      for (int cid in uniqueCids.take(10)) {
        try {
          results.add(await _getCompoundProperties(cid));
        } catch (e) {
          results.add({'error': 'CID $cid: ${e.toString()}'});
        }
      }

      return _formatResults(results, smilesList);
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  Future<List<String>> _getRelevantSmiles(String description) async {
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

    if (matches.isEmpty)
      throw Exception('No valid SMILES found in AI response');

    return matches.map((m) => m.group(0)!).toList();
  }

  Future<List<int>> _getSubstructureCids(String smiles) async {
    final encodedSmiles = Uri.encodeComponent(smiles);
    final url = Uri.parse(
        '$chempubBaseUrl/compound/substructure/smiles/$encodedSmiles/cids/JSON');

    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Substructure search failed for SMILES: $smiles');
    }

    final data = jsonDecode(response.body);
    return (data['IdentifierList']['CID'] as List).cast<int>().toList();
  }

  Future<Map<String, dynamic>> _getCompoundProperties(int cid) async {
    final url = Uri.parse('$chempubBaseUrl/compound/cid/$cid/JSON');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch properties for CID $cid');
    }

    final data = jsonDecode(response.body);
    final properties = data['PC_Compounds'][0]['props'];

    return {
      'cid': cid,
      'name': _findProperty(properties, 'IUPAC Name') ?? 'Unnamed compound',
      'formula': _findProperty(properties, 'Molecular Formula') ?? 'N/A',
      'weight': _findProperty(properties, 'Molecular Weight') ?? 'N/A',
      'smiles': _findProperty(properties, 'Canonical SMILES') ?? 'N/A',
    };
  }

  String? _findProperty(List<dynamic> properties, String name) {
    try {
      final prop = properties.firstWhere(
        (p) => p['urn']['label'] == name,
        orElse: () => null,
      );
      return prop['value']['sval'] ?? prop['value']['fval'].toString();
    } catch (e) {
      return null;
    }
  }

  String _formatResults(
      List<Map<String, dynamic>> results, List<String> querySmiles) {
    final buffer = StringBuffer();
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

    buffer.writeln('Smart Compound Search Results');
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
      buffer.writeln('Molecular Weight: ${result['weight']}');
      buffer.writeln('Canonical SMILES: ${result['smiles']}');
      buffer.writeln('--------------------------------------------');
    }

    return buffer.toString();
  }
}
