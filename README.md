# ChemNOR

ChemNOR (_Chemical Heuristic Evaluation of Molecules Networking for Optimized Reactivity_).
Dart package that finds relevant chemical compounds using AI (Gemini) and PubChem.
level up your chemistry knowledge and use it to chat with your Ai chemist!


Note : A Google Cloud [API-key](https://ai.google.dev/gemini-api/docs/api-key) is required for all requests.

## Installation

```
dependencies:
    chem_nor: ^0.3.1
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
Output: {cid: 248, name: carboxymethyl(trimethyl)ammonium, formula: C5H12NO2+, weight: 118.15, CSMILES: C[N+](C)(C)CC(=O)O, Hydrogen Bond Donor: 1, Hydrogen Bond Acceptor: 2, TPSA: 37.3, Complexity: 93.1, charge	: N/A, Title: N/A, XLogP: N/A}
```

Giving the ability to chat with Ai using text as an input.
return a text if only the question is related to chemistry that is containing compound description.

```
import 'package:chem_nor/chem_nor.dart';

void main() async {
  final finder = ChemNOR(genAiApiKey: 'your-api-key');
  dynamic chat = await finder.Chemist('hello , please educate me about carboxymethyl(trimethyl)ammonium ');
  print(chat);
}
```

```
Carboxymethyl(trimethyl)ammonium, more accurately referred to as (carboxymethyl)trimethylammonium, is a quaternary ammonium cation with the formula  [(CH<sub>3</sub>)<sub>3</sub>N<sup>+</sup>CH<sub>2</sub>COOH].  It's often found as an inner salt or zwitterion due to the presence of both positive and negative charges within the molecule.  The negative charge resides on the carboxylate group (-COO<sup>-</sup>) and the positive charge on the quaternary nitrogen.  This internal salt formation is depicted as:


(CH3)3N+CH2COO-

**Key properties and characteristics:**

* **High polarity and water solubility:** Due to the zwitterionic nature, (carboxymethyl)trimethylammonium compounds are highly polar and readily dissolve in water.
* **Crystalline solids:**  They typically exist as crystalline solids in their pure form.
* **Amphoteric behavior:**  While existing predominantly as a zwitterion near neutral pH, (carboxymethyl)trimethylammonium can act as both an acid (donating a proton from the carboxylic acid group) and a base (accepting a proton, though less readily, at the carboxylate group).  This depends on the pH of the solution.
* **Derivatives and applications:** This moiety is often encountered as part of larger molecules, notably in certain polymers and as a functional group in various applications.  For example, it's found in some betaines, which are types of amphoteric surfactants.  A common example is *cocamidopropyl betaine*, used in personal care products.

**Synthesis:**

(Carboxymethyl)trimethylammonium can be synthesized through the reaction of trimethylamine with chloroacetic acid:


N(CH3)3 + ClCH2COOH  ---> (CH3)3N+CH2COO- + HCl


*Safety Considerations:*

* Trimethylamine is a flammable gas with a strong odor. Handle in a well-ventilated area and use appropriate personal protective equipment (PPE).
* Chloroacetic acid is corrosive and can cause severe burns.  Handle with extreme caution using appropriate PPE.  The reaction itself generates HCl, which is also corrosive.  The reaction should be carried out in a fume hood.


**Spectroscopic characteristics:**

* **NMR:**  The <sup>1</sup>H NMR spectrum would show distinct signals for the methyl groups attached to nitrogen and the methylene group adjacent to the carboxylate. The chemical shifts would be influenced by the solvent and pH.
* **IR:** The IR spectrum would show characteristic absorptions for the carboxylate group (strong band around 1600 cm<sup>-1</sup>) and C-N stretches.

It's important to remember that while the zwitterionic form is prevalent, the actual equilibrium between the various charged states depends on the pH of the surrounding medium.
```