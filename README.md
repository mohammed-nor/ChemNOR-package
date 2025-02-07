# ChemNOR

A Dart package that finds relevant chemical compounds using AI (Gemini) and PubChem.
Note : A Google Cloud [api-key](https://ai.google.dev/gemini-api/docs/api-key) is required for all requests.

## Installation

```
dependencies:
    chem_nor: ^0.1.7
```

## usages

Finds relevant chemical compounds for a given application description.

* Uses AI to generate SMILES patterns.
* Searches PubChem for matching compounds.
* Retrieves properties of the top compounds found.
  Returns a formatted string containing search results.

```
import 'package:chem_nor/chem_nor.dart';

void main() async {
  final finder = ChemNOR(genAiApiKey: 'your-api-key');
  final results = await finder.findListOfCompounds('carboxylic acid compounds');
  print(results);
}
```

```
Output:
ChemNOR Compound Search Results
Generated at: 2025-02-06 13:55:01
Query SMILES patterns: C(=O)O, O=C(O)O, C(=O)C, C(=O)OC, C(=O)CC
====================================================
CID: 284
Name: formic acid
Molecular Formula: CH2O2
SMILES: C(=O)O
Hydrogen Bond Donor: 1
Hydrogen Bond Acceptor: 2
TPSA: 37.3
Complexity: 10.3
Charge: null
Title: N/A
XLogP: N/A
--------------------------------------------
CID: 767
Name: carbonic acid
Molecular Formula: CH2O3
SMILES: C(=O)(O)O
Hydrogen Bond Donor: 2
Hydrogen Bond Acceptor: 3
TPSA: 57.5
Complexity: 26.3
Charge: null
Title: N/A
XLogP: N/A
--------------------------------------------
CID: 177
Name: acetaldehyde
Molecular Formula: C2H4O
SMILES: CC=O
Hydrogen Bond Donor: 0
Hydrogen Bond Acceptor: 1
TPSA: 17.1
Complexity: 10.3
Charge: null
Title: N/A
XLogP: N/A
--------------------------------------------
CID: 7865
Name: methyl formate
Molecular Formula: C2H4O2
SMILES: COC=O
Hydrogen Bond Donor: 0
Hydrogen Bond Acceptor: 2
TPSA: 26.3
Complexity: 18
Charge: null
Title: N/A
XLogP: 0
--------------------------------------------
CID: 527
Name: propanal
Molecular Formula: C3H6O
SMILES: CCC=O
Hydrogen Bond Donor: 0
Hydrogen Bond Acceptor: 1
TPSA: 17.1
Complexity: 17.2
Charge: null
Title: N/A
XLogP: 0.6
--------------------------------------------
```

Searches PubChem for compounds containing the given SMILES pattern.
Returns a list of compound IDs (CIDs) matching the pattern.

```
import 'package:chem_nor/chem_nor.dart';

void main() async {
  final finder = ChemNOR(genAiApiKey: 'your-api-key');
  final results = await finder.getSubstructureCids('CC');
  print(results);
}
```

```
Output: [6324]
```

Uses Google Gemini AI to suggest relevant SMILES patterns based on the given application description.
Returns a list of valid SMILES strings.

```
import 'package:chem_nor/chem_nor.dart';

void main() async {
  final finder = ChemNOR(genAiApiKey: 'your-api-key');
  final results = await finder.getRelevantSmiles('carboxylic acid compounds');
  print(results);
}
```

```
Output: ['C(=O)O', 'O=C(O)O', 'C(=O)C', 'C(=O)OC', 'C(=O)CC']
```

Fetches compound properties from PubChem using the given CID.
Returns a map containing compound details like name, formula, weight, and SMILES.

```
import 'package:chem_nor/chem_nor.dart';

void main() async {
  final finder = ChemNOR(genAiApiKey: 'your-api-key');
  final results = await finder.getCompoundProperties('248');
  print(results);
}
```

```
Output:
{cid: 248, name: carboxymethyl(trimethyl)ammonium, formula: C5H12NO2+, weight: 118.15, CSMILES: C[N+](C)(C)CC(=O)O, Hydrogen Bond Donor: 1, Hydrogen Bond Acceptor: 2, TPSA: 37.3, Complexity: 93.1, charge	: N/A, Title: N/A, XLogP: N/A}
```
