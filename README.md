<div align="center">


<img src="app_icon.png" alt="ChemNOR Logo" width="120" height="120" style="border-radius: 24px;" />
</div>
<div align="center">
<img src="https://img.shields.io/badge/ChemNOR-v0.5.2-6C63FF?style=for-the-badge&logo=dart&logoColor=white" alt="ChemNOR Version"/>

# ⚗️ ChemNOR

### _Chemical Heuristic Evaluation of Molecules Networking for Optimized Reactivity_

A powerful **Dart package** that discovers relevant chemical compounds using **Google Gemini AI** and **PubChem** — your all-in-one chemistry toolkit.

[![pub.dev](https://img.shields.io/pub/v/chem_nor?label=pub.dev&style=flat-square&color=0175C2&logo=dart)](https://pub.dev/packages/chem_nor)
[![License](https://img.shields.io/github/license/mohammed-nor/ChemNOR-package?style=flat-square&color=green)](LICENSE)
[![SDK](https://img.shields.io/badge/Dart%20SDK-%3E%3D3.2.0-0175C2?style=flat-square&logo=dart)](https://dart.dev)
[![Issues](https://img.shields.io/github/issues/mohammed-nor/ChemNOR-package?style=flat-square)](https://github.com/mohammed-nor/ChemNOR-package/issues)

</div>

---

## 📖 Overview

**ChemNOR** combines the power of **Google Gemini AI** with the vast **PubChem** chemical database to give you:

- 🔬 **AI-driven compound discovery** via SMILES pattern generation
- 💬 **Conversational AI Chemist** for chemistry Q&A
- 🧪 **Formula parsing, IUPAC naming, and molecular weight calculation**
- 📊 **NMR, IR, and Mass spectroscopy simulation**
- ⚖️ **Automatic chemical equation balancing**
- 🛡️ **GHS safety data retrieval**
- 🖼️ **Molecular structure visualization**

> **Note:** A Google Cloud [API Key](https://ai.google.dev/gemini-api/docs/api-key) is required for AI features.

---

## 🚀 Installation

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  chem_nor: ^0.5.2
```

Then run:

```bash
dart pub get
```

---

## ⚙️ Initialization

### Default Model (`gemini-2.5-flash`)

```dart
import 'package:chem_nor/chem_nor.dart';

final chemNor = ChemNOR(genAiApiKey: 'your-api-key');
```

### Specifying a Model

```dart
final chemNor = ChemNOR(
  genAiApiKey: 'your-api-key',
  model: GeminiModel.gemini_2_5_pro,
);
```

**Available models:**

| Model | Identifier |
|---|---|
| Gemini 2.5 Flash Lite | `GeminiModel.gemini_2_5_flash_lite` |
| Gemini 2.5 Flash | `GeminiModel.gemini_2_5_flash` |
| Gemini 2.5 Pro | `GeminiModel.gemini_2_5_pro` |
| Gemini 3 Flash Preview | `GeminiModel.gemini_3_flash_preview` |
| Gemini 3 Pro Preview | `GeminiModel.gemini_3_pro_preview` |

```dart
// Print all available models
print(ChemNOR.availableModels);
```

---

## 🧬 Core Features

### 1. 🔍 Find Relevant Compounds

Finds chemical compounds matching an application description using AI-generated SMILES patterns and PubChem lookups.

```dart
import 'package:chem_nor/chem_nor.dart';

void main() async {
  final chemNor = ChemNOR(genAiApiKey: 'your-api-key');
  final results = await chemNor.findListOfCompounds('carboxylic acid compounds');
  print(results);
}
```

<details>
<summary>📄 View Text Output</summary>

```
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
--------------------------------------------
CID: 767
Name: carbonic acid
Molecular Formula: CH2O3
SMILES: C(=O)(O)O
Hydrogen Bond Donor: 2
Hydrogen Bond Acceptor: 3
TPSA: 57.5
Complexity: 26.3
--------------------------------------------
```
</details>

For **JSON output**, use `findListOfCompoundsJSN`:

```dart
final results = await chemNor.findListOfCompoundsJSN('carboxylic acid compounds');
print(results);
```

---

### 2. 🔎 Substructure Search

Searches PubChem for compounds containing a given SMILES pattern and returns a list of matching compound IDs (CIDs).

```dart
final cids = await chemNor.getSubstructureCids('CC');
print(cids); // Output: [6324]
```

---

### 3. 🤖 AI SMILES Generation

Uses Gemini AI to suggest relevant SMILES patterns based on a chemical application description.

```dart
final smiles = await chemNor.getRelevantSmiles('carboxylic acid compounds');
print(smiles);
// Output: [C(=O)O, CC(=O)O, c1ccccc1C(=O)O, OC(=O)C(=O)O, ...]
```

---

### 4. 📋 Compound Properties

Fetches detailed compound properties from PubChem using a CID.

```dart
final props = await chemNor.getCompoundProperties('248');
print(props);
// Output: {cid: 248, name: carboxymethyl(trimethyl)ammonium, formula: C5H12NO2+, weight: 118.15, ...}
```

---

### 5. 💬 AI Chemist

Chat with an AI chemist specializing in chemistry topics. Uses Gemini AI with chemistry-focused context.

```dart
void main() async {
  final chemNor = ChemNOR(genAiApiKey: 'your-api-key');
  final response = await chemNor.Chemist(
    'Please educate me about carboxymethyl(trimethyl)ammonium'
  );
  print(response);
}
```

> The `Chemist` method focuses on chemistry-related questions. Use the `chat` method for general-purpose conversation with optional chat history context.

---

## 🧰 Additional Modules

### 📐 Formula Parser

Parses chemical formulas into element maps.

```dart
final elements = parseFormula('H2SO4');
print(elements); // Output: {H: 2, S: 1, O: 4}
```

---

### 🏷️ IUPAC Naming

Generates IUPAC names from SMILES notation via PubChem.

```dart
final name = await generateIupacName('CCO');
print(name); // Output: ethanol
```

---

### ⚖️ Molecular Weight

Calculates molecular weight from a chemical formula.

```dart
final weight = calculateMolecularWeight('H2O');
print('Water molecular weight: $weight g/mol');
// Output: Water molecular weight: 18.01528 g/mol
```

---

### 🌡️ Periodic Table

Access detailed information about any element.

```dart
final oxygen = PeriodicTable.getBySymbol('O');
print('Oxygen: atomic number ${oxygen?.atomicNumber}, mass ${oxygen?.atomicMass}');
// Output: Oxygen: atomic number 8, mass 15.999

final metals = PeriodicTable.getByCategory('transition metal');
print('Number of transition metals: ${metals.length}');
// Output: Number of transition metals: 38
```

---

### ⚗️ Reaction Balancer

Automatically balances chemical equations.

```dart
final balanced = ReactionBalancer.balance('H2 + O2 = H2O');
print(balanced); // Output: 2H2 + O2 = 2H2O
```

---

### 🛡️ Safety Data (GHS)

Retrieves GHS chemical safety classifications and hazard codes.

```dart
final safetyInfo = await getSafetyData('acetone');
print('Signal word: ${safetyInfo['signal_word']}');
print('Hazard statements: ${safetyInfo['hazard_statements']}');
// Output:
// Signal word: Danger
// Hazard statements: {H225, H319, H336}
```

---

### 🔗 SMILES Parser

Analyzes SMILES notation to extract structural information.

```dart
final structure = parseSmiles('CCO');
print(structure);
// Output: {atomCounts: {C: 2, O: 1}, bondCounts: {single: 2, ...}, rings: 0, ...}

final isValid = isSmilesValid('C1=CC=CC=C1');
print('Is benzene SMILES valid? $isValid'); // Output: true
```

---

### 📡 Spectroscopy Simulation

Simulates **NMR**, **IR**, and **Mass Spectrometry** data from molecular structures.

```dart
// Proton NMR
final nmrData = await simulateProtonNmr('CCO');
print(nmrData['summary']);
// Output:
// ¹H NMR prediction for ethanol:
// δ 0.9 ppm (triplet, 3H) - Methyl group (-CH₃)
// δ 3.5 ppm (singlet (broad), 1H) - Hydroxyl group (-OH)
// δ 3.6 ppm (quartet, 2H) - CH₂ adjacent to oxygen

// IR Spectrum
final irData = await simulateIrSpectrum('CCO');
print('IR bands: ${irData['bands'].length}'); // Output: IR bands: 4
```

---

### 🖼️ Molecular Visualization

Generates a PubChem URL to visualize a compound from SMILES.

```dart
final url = drawMolecule('CCO');
print(url);
// Output: https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/smiles/CCO/PNG
```

---

## 🔬 Complete Example

Combine all modules for a comprehensive chemical analysis pipeline:

```dart
import 'package:chem_nor/chem_nor.dart';

void main() async {
  final chemNor = ChemNOR(genAiApiKey: 'your-api-key');

  // 1. Find compounds related to a query
  final compounds = await chemNor.findListOfCompounds('analgesic compounds');

  if (compounds.isNotEmpty) {
    final smiles = 'CC(=O)OC1=CC=CC=C1C(=O)O'; // Aspirin SMILES

    // 2. Get IUPAC name
    final name = await generateIupacName(smiles);

    // 3. Calculate molecular weight
    final formula = 'C9H8O4';
    final weight = calculateMolecularWeight(formula);

    // 4. Get GHS safety information
    final safety = await getSafetyData('aspirin');

    // 5. Simulate NMR spectrum
    final nmrData = await simulateProtonNmr(smiles);

    // 6. Generate visualization
    final visUrl = drawMolecule(smiles);

    // 7. Print comprehensive report
    print('Compound:          $name');
    print('Formula:           $formula');
    print('Molecular Weight:  $weight g/mol');
    print('Safety Signal:     ${safety['signal_word']}');
    print('NMR Summary:       ${nmrData['summary']}');
    print('Visualization:     $visUrl');
  }
}
```

---

## 📦 Module Summary

| Module | Function | Description |
|---|---|---|
| 🔬 ChemNOR Core | `findListOfCompounds` | AI + PubChem compound search |
| 🔬 ChemNOR Core | `findListOfCompoundsJSN` | JSON-formatted compound search |
| 🔬 ChemNOR Core | `getSubstructureCids` | PubChem substructure search |
| 🔬 ChemNOR Core | `getRelevantSmiles` | AI-generated SMILES suggestions |
| 🔬 ChemNOR Core | `getCompoundProperties` | PubChem compound property lookup |
| 💬 Chemist | `Chemist` / `chat` | AI chemistry chatbot |
| 📐 Formula Parser | `parseFormula` | Element map from formula |
| 🏷️ IUPAC Naming | `generateIupacName` | SMILES → IUPAC name |
| ⚖️ Molecular Weight | `calculateMolecularWeight` | Formula → molecular weight |
| 🌡️ Periodic Table | `PeriodicTable.getBySymbol` | Element data lookup |
| ⚗️ Reaction Balancer | `ReactionBalancer.balance` | Equation balancing |
| 🛡️ Safety Data | `getSafetyData` | GHS hazard information |
| 🔗 SMILES Parser | `parseSmiles` / `isSmilesValid` | SMILES structure analysis |
| 📡 Spectroscopy | `simulateProtonNmr` / `simulateIrSpectrum` | Spectrum simulation |
| 🖼️ Visualization | `drawMolecule` | PubChem structure image URL |

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

<div align="center">

Made with ❤️ for the chemistry and Dart community.

[![GitHub](https://img.shields.io/badge/GitHub-ChemNOR--package-181717?style=flat-square&logo=github)](https://github.com/mohammed-nor/ChemNOR-package)

</div>
