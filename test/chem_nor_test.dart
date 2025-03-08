import 'package:chem_nor/chem_nor.dart';
import 'package:test/test.dart';

void main() async {
  final finder =
      ChemNOR(genAiApiKey: 'AIzaSyCR80a7Gb4kSGd5rX9ingZhJKSw9b9hQgQ');
  dynamic properties = await finder.getCompoundProperties(248);
  print(properties);
  //print(finder.charge);
  dynamic list = await finder.getSubstructureCids('CC');
  print(list);
  final smiles = await finder.getRelevantSmiles('carboxylic acid compounds');
  print(smiles);
  dynamic chat = await finder.chemist(
      'hello , please educate me about carboxymethyl(trimethyl)ammonium ');
  print(chat);
}
