# ChemNOR
A Dart package that finds relevant chemical compounds using AI (Gemini) and PubChem.
Note : A Google Cloud [apiKey] is required for all requests.
## Installation

```
dependencies:
    chem_nor: ^0.1.5
```

### usages

```
import 'package:chem_nor/chem_nor.dart';

void main() async {
  final finder = ChemNOR(genAiApiKey: 'your-api-key');
  final results = await finder.findListOfCompounds('carboxylic acid compounds');
  print(results);
}
```
```
import 'package:chem_nor/chem_nor.dart';

void main() async {
  final finder = ChemNOR(genAiApiKey: 'your-api-key');
  final results = await finder.getSubstructureCids('CC');
  print(results);
}
```
```
import 'package:chem_nor/chem_nor.dart';

void main() async {
  final finder = ChemNOR(genAiApiKey: 'your-api-key');
  final results = await finder.getRelevantSmiles('carboxylic acid compounds');
  print(results);
}
```
```
import 'package:chem_nor/chem_nor.dart';

void main() async {
  final finder = ChemNOR(genAiApiKey: 'your-api-key');
  final results = await finder.getCompoundProperties('248');
  print(results);
}
```