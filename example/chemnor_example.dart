import 'package:chem_nor/chem_nor.dart';

void main() async {
  final finder = ChemNOR(genAiApiKey: 'your-api-key');
  final results =
      await finder.findListOfCompounds('a carboxylic acid compound');
  print(results);
}
