import 'dart:convert';
import 'package:http/http.dart' as http;

/// A parser for SMILES (Simplified Molecular Input Line Entry System) notation.
///
/// SMILES is a string notation used to describe the structure of chemical species.
class SmilesParser {
  /// Base URL for PubChem API
  static const String chempubBaseUrl = 'https://pubchem.ncbi.nlm.nih.gov/rest/pug';

  /// Parses a SMILES string and returns structural information about the molecule.
  ///
  /// Returns a map containing:
  /// - atomCounts: Map of element symbols to counts
  /// - bondCounts: Map of bond types to counts
  /// - rings: Number of rings in the structure
  /// - branches: Number of branches in the structure
  /// - aromaticAtoms: Number of aromatic atoms
  /// - molecularFormula: The molecular formula (if simple parsing is possible)
  static Map<String, dynamic> parse(String smiles) {
    if (smiles.isEmpty) {
      return {'error': 'Empty SMILES string'};
    }

    final result = <String, dynamic>{
      'atomCounts': <String, int>{},
      'bondCounts': <String, int>{
        'single': 0,
        'double': 0,
        'triple': 0,
        'aromatic': 0,
      },
      'rings': 0,
      'branches': 0,
      'aromaticAtoms': 0,
    };

    try {
      _countAtoms(smiles, result);
      _countBonds(smiles, result);
      _countRings(smiles, result);
      _countBranches(smiles, result);
      _countAromaticAtoms(smiles, result);

      return result;
    } catch (e) {
      return {'error': 'Failed to parse SMILES: $e'};
    }
  }

  /// Counts atoms in the SMILES string and adds them to the result map
  static void _countAtoms(String smiles, Map<String, dynamic> result) {
    // Regular expression to match atoms
    // Matches both organic subset atoms [B,C,N,O,P,S,F,Cl,Br,I]
    // and atoms in square brackets like [Fe], [C@H], etc.
    final atomRegex = RegExp(r'Br|Cl|[BCNOPSFIbcnopsi]|(\[[^\]]+\])');

    final matches = atomRegex.allMatches(smiles);

    for (final match in matches) {
      String atomSymbol = match.group(0)!;

      // Handle bracketed atoms
      if (atomSymbol.startsWith('[') && atomSymbol.endsWith(']')) {
        // Extract the element symbol from bracketed atom
        final bracketContents = atomSymbol.substring(1, atomSymbol.length - 1);
        final symbolMatch = RegExp(r'^[A-Za-z][a-z]?').firstMatch(bracketContents);
        if (symbolMatch != null) {
          atomSymbol = symbolMatch.group(0)!;
          // Normalize the case for element symbols (first letter uppercase, rest lowercase)
          atomSymbol = atomSymbol[0].toUpperCase() + (atomSymbol.length > 1 ? atomSymbol.substring(1).toLowerCase() : '');
        }
      }

      // Convert lowercase organic symbols to uppercase (aromatic atoms)
      if (atomSymbol.length == 1 && atomSymbol == atomSymbol.toLowerCase()) {
        atomSymbol = atomSymbol.toUpperCase();
        result['aromaticAtoms'] = result['aromaticAtoms'] + 1;
      }

      // Count the atom
      if (!result['atomCounts'].containsKey(atomSymbol)) {
        result['atomCounts'][atomSymbol] = 0;
      }
      result['atomCounts'][atomSymbol] = result['atomCounts'][atomSymbol] + 1;
    }
  }

  /// Counts bonds in the SMILES string and adds them to the result map
  static void _countBonds(String smiles, Map<String, dynamic> result) {
    // Count explicit bonds
    result['bondCounts']['single'] = _countOccurrences(smiles, '-');
    result['bondCounts']['double'] = _countOccurrences(smiles, '=');
    result['bondCounts']['triple'] = _countOccurrences(smiles, '#');
    result['bondCounts']['aromatic'] = _countOccurrences(smiles, ':');

    // Count implicit single bonds (adjacent atoms without explicit bonds)
    // This is a rough approximation and may not be accurate for complex SMILES
    int implicitBonds = 0;
    final atomRegex = RegExp(r'Br|Cl|[BCNOPSFIbcnopsi]|(\[[^\]]+\])');
    final matches = atomRegex.allMatches(smiles);
    if (matches.length > 1) {
      // Simplistic assumption: atoms next to each other have implicit single bonds
      // This doesn't account for branch points and cycles properly
      implicitBonds = (matches.length - 1 - result['bondCounts']['single'] - result['bondCounts']['double'] - result['bondCounts']['triple'] - result['bondCounts']['aromatic']).toInt();

      // Adjust for branches and rings which reduce the count
      implicitBonds -= (result['branches'] as int);
      // We might need to adjust for ring closures too

      // Add implicit bonds to single bonds count
      if (implicitBonds > 0) {
        result['bondCounts']['single'] += implicitBonds;
      }
    }
  }

  /// Counts ring structures in the SMILES
  static void _countRings(String smiles, Map<String, dynamic> result) {
    // Ring structures are indicated by digit pairs
    final ringDigits = RegExp(r'[0-9]').allMatches(smiles);
    result['rings'] = ringDigits.length ~/ 2;
  }

  /// Counts branch structures in the SMILES
  static void _countBranches(String smiles, Map<String, dynamic> result) {
    // Branches are indicated by matching parentheses
    result['branches'] = _countOccurrences(smiles, '(');
  }

  /// Counts aromatic atoms in the SMILES
  static void _countAromaticAtoms(String smiles, Map<String, dynamic> result) {
    // Aromatic atoms are typically lowercase in SMILES
    final aromaticAtoms = RegExp(r'[bcnops]').allMatches(smiles);
    result['aromaticAtoms'] = aromaticAtoms.length;
  }

  /// Helper function to count occurrences of a character in a string
  static int _countOccurrences(String input, String char) {
    return input.split(char).length - 1;
  }

  /// Get detailed information about a molecule from its SMILES string using PubChem
  static Future<Map<String, dynamic>> getDetailedInfo(String smiles) async {
    try {
      final encodedSmiles = Uri.encodeComponent(smiles);
      final url = Uri.parse('$chempubBaseUrl/compound/smiles/$encodedSmiles/JSON');

      final response = await http.get(url);
      if (response.statusCode != 200) {
        return {'error': 'Failed to retrieve data from PubChem'};
      }

      final data = jsonDecode(response.body);
      if (data['PC_Compounds'] == null || data['PC_Compounds'].isEmpty) {
        return {'error': 'No compound data found'};
      }

      // Extract useful information
      final compound = data['PC_Compounds'][0];
      final result = <String, dynamic>{
        'cid': compound['id']['id']['cid'],
      };

      // Extract properties
      if (compound['props'] != null) {
        for (final prop in compound['props']) {
          if (prop['urn'] != null && prop['urn']['label'] != null) {
            final label = prop['urn']['label'];
            if (label == 'IUPAC Name' && prop['value'] != null && prop['value']['sval'] != null) {
              result['iupacName'] = prop['value']['sval'];
            } else if (label == 'Molecular Formula' && prop['value'] != null && prop['value']['sval'] != null) {
              result['molecularFormula'] = prop['value']['sval'];
            } else if (label == 'Molecular Weight' && prop['value'] != null && prop['value']['fval'] != null) {
              result['molecularWeight'] = prop['value']['fval'];
            }
          }
        }
      }

      return result;
    } catch (e) {
      return {'error': 'Error fetching detailed information: $e'};
    }
  }

  /// Validate if a SMILES string is valid
  static bool isValid(String smiles) {
    // Very basic validation
    if (smiles.isEmpty) return false;

    // Check for balanced parentheses
    int openParens = 0;
    for (int i = 0; i < smiles.length; i++) {
      if (smiles[i] == '(') openParens++;
      if (smiles[i] == ')') {
        openParens--;
        if (openParens < 0) return false;
      }
    }
    if (openParens != 0) return false;

    // Check for balanced square brackets
    int openBrackets = 0;
    for (int i = 0; i < smiles.length; i++) {
      if (smiles[i] == '[') openBrackets++;
      if (smiles[i] == ']') {
        openBrackets--;
        if (openBrackets < 0) return false;
      }
    }
    if (openBrackets != 0) return false;

    // Check that the SMILES contains at least one atom
    final atomRegex = RegExp(r'Br|Cl|[BCNOPSFIbcnopsi]|(\[[^\]]+\])');
    if (!atomRegex.hasMatch(smiles)) return false;

    return true;
  }
}

/// Parses SMILES strings and returns structural information.
Map<String, dynamic> parseSmiles(String smiles) {
  return SmilesParser.parse(smiles);
}

/// Gets detailed information about a molecule from its SMILES string.
Future<Map<String, dynamic>> getSmilesDetails(String smiles) {
  return SmilesParser.getDetailedInfo(smiles);
}

/// Validates if a SMILES string is properly formatted.
bool isSmilesValid(String smiles) {
  return SmilesParser.isValid(smiles);
}
