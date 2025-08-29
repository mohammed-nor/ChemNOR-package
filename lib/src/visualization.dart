import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'smiles_parser.dart';

/// Provides utilities for visualizing chemical structures from SMILES notation
class MoleculeVisualizer {
  /// Base URL for PubChem's visualization services
  static const String pubchemVisualizationUrl = 'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/smiles';

  /// Default image size for visualizations
  static const int defaultWidth = 500;
  static const int defaultHeight = 500;

  /// Generates a URL that displays the molecule visualization in PubChem
  ///
  /// This URL can be opened in a browser or embedded in applications
  static String getPubChemVisualizationUrl(String smiles) {
    final encodedSmiles = Uri.encodeComponent(smiles);
    return '$pubchemVisualizationUrl/$encodedSmiles/PNG';
  }

  /// Fetches a PNG image of the molecule from PubChem
  ///
  /// Returns the raw bytes of the PNG image that can be displayed or saved
  static Future<Uint8List> fetchMoleculeImage(String smiles, {int width = defaultWidth, int height = defaultHeight}) async {
    if (!isSmilesValid(smiles)) {
      throw ArgumentError('Invalid SMILES string provided');
    }

    final encodedSmiles = Uri.encodeComponent(smiles);
    final url = Uri.parse('$pubchemVisualizationUrl/$encodedSmiles/PNG?width=$width&height=$height');

    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch molecule image: ${response.statusCode}');
    }

    return response.bodyBytes;
  }

  /// Fetches an SVG representation of the molecule from PubChem
  ///
  /// Returns the SVG content as a string that can be displayed in web applications
  static Future<String> fetchMoleculeSvg(String smiles) async {
    if (!isSmilesValid(smiles)) {
      throw ArgumentError('Invalid SMILES string provided');
    }

    final encodedSmiles = Uri.encodeComponent(smiles);
    final url = Uri.parse('$pubchemVisualizationUrl/$encodedSmiles/SVG');

    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch molecule SVG: ${response.statusCode}');
    }

    return response.body;
  }

  /// Saves a molecule visualization as a PNG file
  ///
  /// Returns the path to the saved file
  static Future<String> saveMoleculeImage(String smiles, String filePath, {int width = defaultWidth, int height = defaultHeight}) async {
    final imageData = await fetchMoleculeImage(smiles, width: width, height: height);

    final file = File(filePath);
    await file.writeAsBytes(imageData);

    return filePath;
  }



  /// Returns the molecule structure as a data URL
  ///
  /// This can be used in HTML img tags directly without additional HTTP requests
  static Future<String> getMoleculeDataUrl(String smiles, {int width = defaultWidth, int height = defaultHeight}) async {
    final imageData = await fetchMoleculeImage(smiles, width: width, height: height);
    final base64Image = base64Encode(imageData);
    return 'data:image/png;base64,$base64Image';
  }
}

/// Draw a molecule visualization based on its SMILES string
///
/// Returns a URL to view the molecule
String drawMolecule(String smiles) {
  return MoleculeVisualizer.getPubChemVisualizationUrl(smiles);
}

/// Save a molecule visualization to a file
Future<String> saveMoleculeImage(String smiles, String filePath) {
  return MoleculeVisualizer.saveMoleculeImage(smiles, filePath);
}

/// Get an SVG representation of a molecule
Future<String> getMoleculeSvg(String smiles) {
  return MoleculeVisualizer.fetchMoleculeSvg(smiles);
}
