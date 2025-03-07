import 'package:chem_nor/chem_nor.dart';

void main() async {
  final finder = ChemNOR(genAiApiKey: 'your-api-key');
  dynamic properties = await finder.getCompoundProperties(248);
  print(properties);
  dynamic list = await finder.getSubstructureCids('CC');
  print(list);
  final smiles = await finder.getRelevantSmiles('carboxylic acid compounds');
  print(smiles);
}
