# ChemNOR
A Dart package that finds relevant chemical compounds using AI (Gemini) and PubChem.
Note : A Google Cloud [apiKey] is required for all requests.
## Installation

```
dependencies:
    chem_nor: ^0.1.5
```

### usage

```
import 'package:chem_nor/chem_nor.dart';

void main() async {
  final finder = ChemNOR(genAiApiKey: 'your-api-key');
  final results = await finder.findListOfCompounds('a carboxylic acid compound');
  print(results);
}
```
