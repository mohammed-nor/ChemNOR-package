/// Parses chemical formulas into a map of element symbols and their counts.
/// Example: "C6H12O6" => {"C": 6, "H": 12, "O": 6}
Map<String, int> parseFormula(String formula) {
  final Map<String, int> elementCounts = {};
  final RegExp exp = RegExp(r'([A-Z][a-z]?)(\d*)');
  for (final Match match in exp.allMatches(formula)) {
    final String element = match.group(1)!;
    final String countStr = match.group(2)!;
    final int count = countStr.isEmpty ? 1 : int.parse(countStr);
    elementCounts[element] = (elementCounts[element] ?? 0) + count;
  }
  return elementCounts;
}
