import 'dart:io';
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
  final int maxResultsPerSmiles = 10;

  final String model = 'gemini-2.0-flash';

  /// Constructor for ChemNOR, requires an API key for Google Generative AI.
  ChemNOR({required this.genAiApiKey});

  Future<String> generateContent(String userInput, String systemInstruction) async {
    final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$genAiApiKey');

    final headers = {
      'Content-Type': 'application/json',
    };

    final Map<String, dynamic> requestBody = {
      'contents': [
        {
          'parts': [
            {'text': systemInstruction},
            {'text': userInput}
          ]
        }
      ]
    };
    for (int i = 0; i < 3; i++) {
      try {
        final response = await http.post(
          url,
          headers: headers,
          body: jsonEncode(requestBody),
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          return data['candidates'][0]['content']['parts'][0]['text'];
        } else {
          throw Exception('Failed to generate content: ${response.statusCode}');
        }
      } catch (e) {
        if (e is SocketException) {
          print('Network error: ${e.message}. Retrying...');
          await Future.delayed(Duration(seconds: 2));
        } else {
          rethrow;
        }
      }
    }
    throw Exception('Failed to generate content after multiple attempts.');
  }

  // Object? get cid => cid;
  //
  // Object? get name => name;
  //
  // Object? get formula => formula;
  //
  // Object? get weight => weight;
  //
  // Object? get smiles => smiles;
  //
  // Object? get hbDonor => hbDonor;
  //
  // Object? get hbAcceptor => hbAcceptor;
  //
  // Object? get tpsa => tpsa;
  //
  // Object? get complexity => complexity;
  //
  // Object? get charge => charge;
  //
  // Object? get title => title;
  //
  // Object? get xlogp => xlogp;

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

  Future<String?> chemist(String userInput) async {
    String _systemInstruction = '''
    You are a professional organic chemist with extensive knowledge in:
    - Organic synthesis
    - Reaction mechanisms
    - Spectroscopy interpretation (NMR, IR, Mass Spec)
    - Retrosynthetic analysis
    - Named reactions
    - Stereochemistry
    - Functional group transformations
    
    Your responses should be:
    - Technical but clear
    - Include relevant chemical structures (in text form)
    - Use IUPAC nomenclature
    - Provide reaction equations where applicable
    - Highlight safety considerations
    - Cite important references when appropriate
    
    If a question is not related to organic chemistry, respond with:
    "I specialize in organic chemistry. Please ask questions related to that field."
  ''';
    try {
      final model = ChemNOR(genAiApiKey: genAiApiKey);
      final response = await model.generateContent(userInput, _systemInstruction);
      return response;
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  /// Uses Google Gemini AI to suggest relevant SMILES patterns
  /// based on the given application description.
  ///
  /// Returns a list of valid SMILES strings.
  Future<List<String>> getRelevantSmiles(String description) async {
    final _prompt = '''I'm a student that is very passion with chemistry and i hope that you will help me in the following task.
    Given the application: "$description", suggest 3-10 SMILES patterns representing 
    key functional groups or structural motifs relevant to this application.
    Return ONLY valid SMILES strings, one per line, with no additional text.
    Example:
    C(=O)O
    c1ccccc1
    NC(=O)N
    ''';
    String _systemInstruction = '''If a question is not related to organic chemistry of a specific application, respond with:
    "I specialize in organic chemistry. Please ask questions related to that field."''';

    final model = ChemNOR(genAiApiKey: genAiApiKey);
    final response = await model.generateContent(_prompt, _systemInstruction);

    // Extract SMILES using regex pattern
    final RegExp smilesRegex = RegExp(r'^[A-Za-z0-9@+\-\[\]\(\)\\/=#$.]+$', multiLine: true);
    final matches = smilesRegex.allMatches(response);

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
    final url = Uri.parse('$chempubBaseUrl/compound/fastidentity/SMILES/$encodedSmiles/cids/JSON');

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

    final _data = jsonDecode(response.body);
    final _properties = _data['PC_Compounds'][0]['props'];
    final _name = _findProperty(_properties, 'IUPAC Name') ?? 'Unnamed compound';
    final _formula = _findProperty(_properties, 'Molecular Formula') ?? 'N/A';
    final _weight = _findProperty(_properties, 'Molecular Weight') ?? 'N/A';
    final _smiles = _findProperty(_properties, 'Canonical SMILES') ?? 'N/A';
    final _hbDonor = _findivalPropertybylabel(_properties, 'Hydrogen Bond Donor', 'Count') ?? 'N/A';
    final _hbAcceptor = _findivalPropertybylabel(_properties, 'Hydrogen Bond Acceptor', 'Count') ?? 'N/A';
    final _tpsa = _findfvalPropertybylabel(_properties, 'Polar Surface Area', 'Topological') ?? 'N/A';
    final _complexity = _findfvalPropertybylabelonly(_properties, 'Compound Complexity') ?? 'N/A';
    final _charge = _findProperty(_properties, 'Charge') ?? 'N/A';
    final _title = _findProperty(_properties, 'Title') ?? 'N/A';
    final _xlogp = _findfvalPropertybylabel(_properties, 'XLogP3', 'Log P') ?? 'N/A';

    return {
      'cid': cid,
      'name': _name,
      'formula': _formula,
      'weight': _weight,
      'SMILES': _smiles,
      'Hydrogen Bond Donor': _hbDonor,
      'Hydrogen Bond Acceptor': _hbAcceptor,
      'TPSA': _tpsa,
      'Complexity': _complexity,
      'charge	': _charge,
      'Title': _title,
      'XLogP': _xlogp,
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

  String? _findfvalPropertybylabel(List<dynamic> properties, String name, String label) {
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

  String? _findivalPropertybylabel(List<dynamic> properties, String name, String label) {
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
  String _formatResults(List<Map<String, dynamic>> results, List<String> querySmiles) {
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
      buffer.writeln('Hydrogen Bond Acceptor: ${result['Hydrogen Bond Acceptor']}');
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
