import 'package:ChemNOR/chemnor.dart';

void main() async {
  final finder = ChemNOR(genAiApiKey: 'your-api-key');
  final results = await finder.findCompounds('drug formulation');
  print(results);
}
