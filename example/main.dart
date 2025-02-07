import 'package:chem_nor/chem_nor.dart';

void main() async {
  final finder = ChemNOR(genAiApiKey: 'your-api-key');
  dynamic results = await finder.findListOfCompounds('a carboxylic acid compound');
  print(results);
  dynamic properties = await finder.getCompoundProperties(248);
  print(properties);
  dynamic list = await finder.getSubstructureCids('CC');
  print(list);
  final Smiles = await finder.getRelevantSmiles('carboxylic acid compounds');
  print(Smiles);
}
