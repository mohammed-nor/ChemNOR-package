# ChemNOR

ChemNOR is a Dart package designed for chemists and researchers to find relevant chemical compounds based on application descriptions. It leverages the power of Google Gemini AI to generate SMILES patterns and queries the PubChem database to retrieve detailed compound properties.

## Features

- **SMILES Generation**: Uses AI to suggest relevant SMILES patterns based on application descriptions.
- **Compound Search**: Searches the PubChem database for compounds matching generated SMILES patterns.
- **Property Retrieval**: Fetches detailed properties of compounds, including molecular weight, formula, and structural information.
- **Spectroscopy Analysis**: Modules for interpreting NMR, IR, and mass spectrometry data.
- **Retrosynthesis Assistance**: Helps in devising synthetic routes for target molecules.
- **Cheminformatics Utilities**: Provides tools for molecular similarity, clustering, and descriptor calculations.

## Installation

To use ChemNOR, add it to your Dart project's `pubspec.yaml` file:

```yaml
dependencies:
  chemnor:
    path: ./chemnor
```

Then, run the following command to install the package:

```bash
dart pub get
```

## Usage

Here is a simple example of how to use ChemNOR to find compounds based on an application description:

```dart
import 'package:chemnor/chemnor.dart';

void main() async {
  final chemnor = ChemNOR(genAiApiKey: 'YOUR_API_KEY');
  final results = await chemnor.findListOfCompounds('Find compounds for a new drug application.');
  print(results);
}
```

## Modules

- **chemnor_base.dart**: Main class for compound searching.
- **molecular_weight.dart**: Calculate molecular weight from formulas or SMILES.
- **smiles_parser.dart**: Parse SMILES strings into structured representations.
- **periodic_table.dart**: Access periodic table data and element properties.
- **reaction_predictor.dart**: Predict chemical reactions based on inputs.
- **nmr_interpreter.dart**: Analyze and interpret NMR spectra.
- **ir_interpreter.dart**: Identify functional groups from IR spectra.
- **mass_spec_interpreter.dart**: Interpret mass spectrometry data.
- **retrosynthesis.dart**: Assist in retrosynthetic analysis.
- **cheminformatics_utils.dart**: Various cheminformatics utilities.
- **property_calculator.dart**: Calculate molecular properties.
- **utils.dart**: General utility functions.

## Contributing

Contributions are welcome! Please submit a pull request or open an issue to discuss changes or enhancements.

## License

This project is licensed under the MIT License. See the LICENSE file for details.