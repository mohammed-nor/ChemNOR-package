import 'dart:convert';
import 'package:http/http.dart' as http;
import 'smiles_parser.dart';

/// Provides utilities for simulating and interpreting various spectroscopic data
/// including NMR, IR, UV-Vis and Mass Spectrometry based on molecular structures.
class Spectroscopy {
  /// Base URL for PubChem API
  static const String chempubBaseUrl = 'https://pubchem.ncbi.nlm.nih.gov/rest/pug';

  /// Simulates a 1H NMR spectrum based on a SMILES structure
  ///
  /// Returns a map containing:
  /// - peaks: List of predicted peaks with chemical shift, multiplicity, and assignment
  /// - summary: Text summary of the key spectral features
  static Future<Map<String, dynamic>> simulateProtonNmr(String smiles) async {
    if (!isSmilesValid(smiles)) {
      return {'error': 'Invalid SMILES structure'};
    }

    try {
      // Get molecule details to help with prediction
      final molDetails = await getSmilesDetails(smiles);

      // Parse the SMILES to extract structural information
      final molStructure = parseSmiles(smiles);

      // Predict NMR peaks based on functional groups
      final peaks = await _predictProtonNmrPeaks(smiles, molStructure, molDetails);

      // Generate a text summary of the spectrum
      final summary = _generateNmrSummary(peaks, molDetails);

      return {
        'peaks': peaks,
        'summary': summary,
      };
    } catch (e) {
      return {'error': 'Failed to simulate NMR spectrum: $e'};
    }
  }

  /// Simulates a 13C NMR spectrum based on a SMILES structure
  static Future<Map<String, dynamic>> simulateCarbonNmr(String smiles) async {
    if (!isSmilesValid(smiles)) {
      return {'error': 'Invalid SMILES structure'};
    }

    try {
      // Get molecule details to help with prediction
      final molDetails = await getSmilesDetails(smiles);

      // Parse the SMILES to extract structural information
      final molStructure = parseSmiles(smiles);

      // Predict carbon NMR peaks
      final peaks = await _predictCarbonNmrPeaks(smiles, molStructure, molDetails);

      return {
        'peaks': peaks,
        'summary': 'Carbon-13 NMR prediction for ${molDetails['iupacName'] ?? smiles}',
      };
    } catch (e) {
      return {'error': 'Failed to simulate 13C NMR spectrum: $e'};
    }
  }

  /// Simulates an IR spectrum based on a SMILES structure
  static Future<Map<String, dynamic>> simulateIrSpectrum(String smiles) async {
    if (!isSmilesValid(smiles)) {
      return {'error': 'Invalid SMILES structure'};
    }

    try {
      // Get molecule details
      final molDetails = await getSmilesDetails(smiles);

      // Predict IR bands based on functional groups
      final bands = await _predictIrBands(smiles, molDetails);

      return {
        'bands': bands,
        'summary': 'Predicted IR absorption bands for ${molDetails['iupacName'] ?? smiles}',
      };
    } catch (e) {
      return {'error': 'Failed to simulate IR spectrum: $e'};
    }
  }

  /// Simulates a mass spectrum based on a SMILES structure
  static Future<Map<String, dynamic>> simulateMassSpectrum(String smiles) async {
    if (!isSmilesValid(smiles)) {
      return {'error': 'Invalid SMILES structure'};
    }

    try {
      // Get molecule details
      final molDetails = await getSmilesDetails(smiles);

      // Calculate molecular weight
      final molecularWeight = molDetails['molecularWeight'] ?? 0.0;

      // Predict fragmentation patterns
      final fragments = await _predictMassFragments(smiles, molDetails);

      return {
        'molecularIon': molecularWeight,
        'fragments': fragments,
        'summary': 'Predicted mass spectrum for ${molDetails['iupacName'] ?? smiles}',
      };
    } catch (e) {
      return {'error': 'Failed to simulate mass spectrum: $e'};
    }
  }

  /// Attempts to fetch experimental spectroscopic data from PubChem if available
  static Future<Map<String, dynamic>> getExperimentalData(String smiles) async {
    try {
      // Convert SMILES to PubChem CID
      final molDetails = await getSmilesDetails(smiles);
      final cid = molDetails['cid'];

      if (cid == null) {
        return {'error': 'Could not find compound in PubChem'};
      }

      // Try to fetch experimental spectra
      final url = Uri.parse('$chempubBaseUrl/compound/cid/$cid/JSON?heading=Spectral Information');

      final response = await http.get(url);
      if (response.statusCode != 200) {
        return {'message': 'No experimental spectral data available'};
      }

      final data = jsonDecode(response.body);

      // Process and extract spectral data if available
      // This would depend on the specific structure of PubChem's response

      return {
        'hasExperimentalData': true,
        'cid': cid,
        'data': data,
      };
    } catch (e) {
      return {'error': 'Failed to retrieve experimental data: $e'};
    }
  }

  /// Helper method to predict proton NMR peaks based on SMILES structure
  static Future<List<Map<String, dynamic>>> _predictProtonNmrPeaks(String smiles, Map<String, dynamic> structure, Map<String, dynamic> details) async {
    // This is a simplified prediction based on common functional group patterns
    // A real implementation would use more sophisticated algorithms

    // Check for common functional groups and assign chemical shifts
    final peaks = <Map<String, dynamic>>[];

    // Identify functional groups present in the molecule
    final hasMethyl = smiles.contains('C') && !smiles.contains('=C');
    final hasAldehydeH = smiles.contains('C(=O)H');
    final hasAromaticH = smiles.contains('c1') || smiles.contains('C1=CC=CC=C1');
    final hasAlcoholOH = smiles.contains('OH') || smiles.contains('CO');
    final hasCarboxylicOH = smiles.contains('C(=O)OH') || smiles.contains('COOH');
    final hasAlkeneH = smiles.contains('C=C');

    // Add peaks based on identified functional groups
    if (hasMethyl) {
      peaks.add({
        'shift': 0.9,
        'multiplicity': 'singlet or triplet',
        'integral': 3,
        'assignment': 'Methyl group (-CH₃)',
      });
    }

    if (hasAldehydeH) {
      peaks.add({
        'shift': 9.8,
        'multiplicity': 'singlet',
        'integral': 1,
        'assignment': 'Aldehyde (-CHO)',
      });
    }

    if (hasAromaticH) {
      peaks.add({
        'shift': 7.3,
        'multiplicity': 'multiplet',
        'integral': 5, // assuming benzene or similar
        'assignment': 'Aromatic protons',
      });
    }

    if (hasAlcoholOH) {
      peaks.add({
        'shift': 3.5,
        'multiplicity': 'singlet (broad)',
        'integral': 1,
        'assignment': 'Hydroxyl group (-OH)',
      });
    }

    if (hasCarboxylicOH) {
      peaks.add({
        'shift': 12.0,
        'multiplicity': 'singlet (broad)',
        'integral': 1,
        'assignment': 'Carboxylic acid (-COOH)',
      });
    }

    if (hasAlkeneH) {
      peaks.add({
        'shift': 5.5,
        'multiplicity': 'multiplet',
        'integral': 2,
        'assignment': 'Alkene protons (C=C-H)',
      });
    }

    // If no peaks were identified, provide a generic response
    if (peaks.isEmpty) {
      peaks.add({
        'shift': 1.5,
        'multiplicity': 'complex',
        'integral': 'unknown',
        'assignment': 'Aliphatic protons',
      });
    }

    // Sort by chemical shift (ascending)
    peaks.sort((a, b) => a['shift'].compareTo(b['shift']));

    return peaks;
  }

  /// Helper method to predict carbon NMR peaks
  static Future<List<Map<String, dynamic>>> _predictCarbonNmrPeaks(String smiles, Map<String, dynamic> structure, Map<String, dynamic> details) async {
    // Simplified carbon-13 NMR prediction
    final peaks = <Map<String, dynamic>>[];

    // Check for common carbon environments
    final hasMethyl = smiles.contains('C') && !smiles.contains('=C');
    final hasCarbonyl = smiles.contains('C=O');
    final hasAromatic = smiles.contains('c1') || smiles.contains('C1=CC=CC=C1');
    final hasAlkene = smiles.contains('C=C');
    final hasAlcohol = smiles.contains('OH') || smiles.contains('CO');

    if (hasMethyl) {
      peaks.add({
        'shift': 20.0,
        'assignment': 'Methyl carbon (-CH₃)',
      });
    }

    if (hasCarbonyl) {
      peaks.add({
        'shift': 180.0,
        'assignment': 'Carbonyl carbon (C=O)',
      });
    }

    if (hasAromatic) {
      peaks.add({
        'shift': 128.0,
        'assignment': 'Aromatic carbon',
      });

      peaks.add({
        'shift': 135.0,
        'assignment': 'Substituted aromatic carbon',
      });
    }

    if (hasAlkene) {
      peaks.add({
        'shift': 120.0,
        'assignment': 'Alkene carbon (C=C)',
      });
    }

    if (hasAlcohol) {
      peaks.add({
        'shift': 65.0,
        'assignment': 'Carbon adjacent to hydroxyl (-C-OH)',
      });
    }

    // If no peaks were identified, provide a generic response
    if (peaks.isEmpty) {
      peaks.add({
        'shift': 30.0,
        'assignment': 'Aliphatic carbon',
      });
    }

    // Sort by chemical shift (ascending)
    peaks.sort((a, b) => a['shift'].compareTo(b['shift']));

    return peaks;
  }

  /// Helper method to predict IR bands
  static Future<List<Map<String, dynamic>>> _predictIrBands(String smiles, Map<String, dynamic> details) async {
    // Simplified IR prediction based on functional groups
    final bands = <Map<String, dynamic>>[];

    // Check for common functional groups that give characteristic IR bands
    final hasOH = smiles.contains('OH');
    final hasNH = smiles.contains('N') && !smiles.contains('NO');
    final hasCarbonyl = smiles.contains('C=O');
    final hasEster = smiles.contains('C(=O)O') || smiles.contains('COO');
    final hasAlkene = smiles.contains('C=C');
    final hasAromatic = smiles.contains('c1') || smiles.contains('C1=CC=CC=C1');
    final hasAlkyne = smiles.contains('C#C');

    if (hasOH) {
      bands.add({
        'wavenumber': 3400,
        'intensity': 'strong, broad',
        'assignment': 'O-H stretching',
      });
    }

    if (hasNH) {
      bands.add({
        'wavenumber': 3300,
        'intensity': 'medium',
        'assignment': 'N-H stretching',
      });
    }

    if (hasCarbonyl) {
      bands.add({
        'wavenumber': 1700,
        'intensity': 'strong',
        'assignment': 'C=O stretching',
      });
    }

    if (hasEster) {
      bands.add({
        'wavenumber': 1730,
        'intensity': 'strong',
        'assignment': 'Ester C=O stretching',
      });

      bands.add({
        'wavenumber': 1200,
        'intensity': 'strong',
        'assignment': 'C-O stretching',
      });
    }

    if (hasAlkene) {
      bands.add({
        'wavenumber': 1650,
        'intensity': 'medium',
        'assignment': 'C=C stretching',
      });
    }

    if (hasAromatic) {
      bands.add({
        'wavenumber': 3030,
        'intensity': 'weak',
        'assignment': 'Aromatic C-H stretching',
      });

      bands.add({
        'wavenumber': 1600,
        'intensity': 'medium',
        'assignment': 'Aromatic C=C stretching',
      });
    }

    if (hasAlkyne) {
      bands.add({
        'wavenumber': 2200,
        'intensity': 'medium',
        'assignment': 'C≡C stretching',
      });
    }

    // Add C-H stretching bands (present in almost all organic compounds)
    bands.add({
      'wavenumber': 2950,
      'intensity': 'medium',
      'assignment': 'C-H stretching (aliphatic)',
    });

    // Sort by wavenumber (descending)
    bands.sort((a, b) => b['wavenumber'].compareTo(a['wavenumber']));

    return bands;
  }

  /// Helper method to predict mass spectrum fragments
  static Future<List<Map<String, dynamic>>> _predictMassFragments(String smiles, Map<String, dynamic> details) async {
    // Simplified mass spectrum prediction
    final fragments = <Map<String, dynamic>>[];
    final molecularWeight = details['molecularWeight'] ?? 0.0;

    // Add the molecular ion
    fragments.add({
      'm/z': molecularWeight,
      'intensity': 100,
      'assignment': 'M⁺ (molecular ion)',
    });

    // Check for common fragmentation patterns
    final hasMethyl = smiles.contains('C') && !smiles.contains('=C');
    final hasEthyl = smiles.contains('CC');
    final hasCarbonyl = smiles.contains('C=O');
    final hasBenzyl = smiles.contains('C1=CC=CC=C1C');

    if (hasMethyl) {
      fragments.add({
        'm/z': molecularWeight - 15,
        'intensity': 40,
        'assignment': 'M⁺ - CH₃',
      });
    }

    if (hasEthyl) {
      fragments.add({
        'm/z': molecularWeight - 29,
        'intensity': 60,
        'assignment': 'M⁺ - C₂H₅',
      });
    }

    if (hasCarbonyl) {
      fragments.add({
        'm/z': molecularWeight - 28,
        'intensity': 70,
        'assignment': 'M⁺ - CO',
      });
    }

    if (hasBenzyl) {
      fragments.add({
        'm/z': 91,
        'intensity': 80,
        'assignment': 'Tropylium ion (C₇H₇⁺)',
      });
    }

    // Sort by m/z (descending)
    fragments.sort((a, b) => b['m/z'].compareTo(a['m/z']));

    return fragments;
  }

  /// Generates a text summary of the NMR spectrum
  static String _generateNmrSummary(List<Map<String, dynamic>> peaks, Map<String, dynamic> details) {
    final compoundName = details['iupacName'] ?? 'compound';
    final buffer = StringBuffer();

    buffer.writeln('¹H NMR prediction for $compoundName:');
    buffer.writeln();

    for (var peak in peaks) {
      buffer.write('δ ${peak['shift']} ppm');
      buffer.write(' (${peak['multiplicity']}');

      if (peak['integral'] is int) {
        buffer.write(', ${peak['integral']}H');
      }

      buffer.write(') - ${peak['assignment']}');
      buffer.writeln();
    }

    return buffer.toString();
  }
}

/// Interprets a 1H NMR spectrum from a SMILES string
Future<String> interpretNmr(String smiles) async {
  final result = await Spectroscopy.simulateProtonNmr(smiles);

  if (result.containsKey('error')) {
    return 'Error: ${result['error']}';
  }

  return result['summary'] as String;
}

/// Simulates a proton NMR spectrum from a SMILES string
Future<Map<String, dynamic>> simulateProtonNmr(String smiles) {
  return Spectroscopy.simulateProtonNmr(smiles);
}

/// Simulates a carbon NMR spectrum from a SMILES string
Future<Map<String, dynamic>> simulateCarbonNmr(String smiles) {
  return Spectroscopy.simulateCarbonNmr(smiles);
}

/// Simulates an IR spectrum from a SMILES string
Future<Map<String, dynamic>> simulateIrSpectrum(String smiles) {
  return Spectroscopy.simulateIrSpectrum(smiles);
}

/// Simulates a mass spectrum from a SMILES string
Future<Map<String, dynamic>> simulateMassSpectrum(String smiles) {
  return Spectroscopy.simulateMassSpectrum(smiles);
}
