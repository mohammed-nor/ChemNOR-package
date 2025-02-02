# ChemNOR
A Dart package that finds relevant chemical compounds using AI (Gemini) and PubChem.
Note : A Google Cloud [apiKey] is required for all requests.
## Installation

```
dependencies:
    chem_nor: ^0.1.5
```

## usages
Finds relevant chemical compounds for a given application description.
* Uses AI to generate SMILES patterns.
* Searches PubChem for matching compounds.
* Retrieves properties of the top compounds found.
Returns a formatted string containing search results.
```
import 'package:chem_nor/chem_nor.dart';

void main() async {
  final finder = ChemNOR(genAiApiKey: 'your-api-key');
  final results = await finder.findListOfCompounds('carboxylic acid compounds');
  print(results);
}
```
Searches PubChem for compounds containing the given SMILES pattern.
Returns a list of compound IDs (CIDs) matching the pattern.
```
import 'package:chem_nor/chem_nor.dart';

void main() async {
  final finder = ChemNOR(genAiApiKey: 'your-api-key');
  final results = await finder.getSubstructureCids('CC');
  print(results);
}
```
Uses Google Gemini AI to suggest relevant SMILES patterns based on the given application description.
Returns a list of valid SMILES strings.
```
import 'package:chem_nor/chem_nor.dart';

void main() async {
  final finder = ChemNOR(genAiApiKey: 'your-api-key');
  final results = await finder.getRelevantSmiles('carboxylic acid compounds');
  print(results);
}
```
Fetches compound properties from PubChem using the given CID.
Returns a map containing compound details like name, formula, weight, and SMILES.
```
import 'package:chem_nor/chem_nor.dart';

void main() async {
  final finder = ChemNOR(genAiApiKey: 'your-api-key');
  final results = await finder.getCompoundProperties('248');
  print(results);
}
```