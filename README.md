# ChemNOR
A Dart package that finds relevant chemical compounds using AI (Gemini) and PubChem.

## Installation
```yaml
dependencies:
  smart_compound_finder: ^0.1.0
  

### usage
import 'package:smart_compound_finder/smart_compound_finder.dart';

void main() async {
  final finder = SmartCompoundFinder(genAiApiKey: 'your-api-key');
  final results = await finder.findCompounds('drug formulation');
  print(results);
}