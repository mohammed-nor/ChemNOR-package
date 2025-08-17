import 'package:chem_nor/chem_nor.dart';
import 'package:chem_nor/key.dart';

void main() async {
  final finder = ChemNOR(genAiApiKey: key);
  dynamic properties = await finder.getCompoundProperties(248);
  print(properties);
  dynamic list = await finder.getSubstructureCids('CC');
  print(list);
  final smiles = await finder.getRelevantSmiles('carboxylic acid compounds');
  print(smiles);
  dynamic chat = await finder.chemist('hello , please educate me about carboxymethyl(trimethyl)ammonium ');
  print(chat);
  dynamic propertie = await finder.findListOfCompoundsJSN('carboxylic acid compounds');
  print(propertie);
}
