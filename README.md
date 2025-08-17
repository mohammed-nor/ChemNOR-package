# ChemNOR

ChemNOR (_Chemical Heuristic Evaluation of Molecules Networking for Optimized Reactivity_).
Dart package that finds relevant chemical compounds using AI (Gemini) and PubChem.
level up your chemistry knowledge and use it to chat with your Ai chemist!

Note : A Google Cloud [API-key](https://ai.google.dev/gemini-api/docs/api-key) is required for all requests.

## Installation

```
dependencies:
    chem_nor: ^0.3.2
```

## usages

Finds relevant chemical compounds for a given application description.

* Uses AI to generate SMILES patterns.
* Searches PubChem for matching compounds.
* Retrieves properties of the top compounds found.

Returns a formatted string containing search results as Text or in JSON format using the `findListOfCompoundsJSN` method:

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

```
import 'package:chem_nor/chem_nor.dart';

void main() async {
  final finder = ChemNOR(genAiApiKey: 'your-api-key');
  final results = await finder.findListOfCompoundsJSN('carboxylic acid compounds');
  print(results);
}
```

```
Output: {"query_application_description":"carboxylic acid compounds","generated_smiles_patterns":["C(=O)O","c1ccccc1C(=O)O","OC(=O)C(=O)O","C=CC(=O)O","CC(=O)C(=O)O","OC(C(=O)O)C","NC(C(=O)O)C","OC(=O)CCC(=O)O"],"retrieved_compounds":[{"cid":284,"name":"formic acid","formula":"CH2O2","weight":"46.025","SMILES":"N/A","Hydrogen Bond Donor":"1","Hydrogen Bond Acceptor":"2","TPSA":"37.3","Complexity":"10.3","charge\t":"N/A","Title":"N/A","XLogP":"N/A"},{"cid":243,"name":"benzoic acid","formula":"C7H6O2","weight":"122.12","SMILES":"N/A","Hydrogen Bond Donor":"1","Hydrogen Bond Acceptor":"2","TPSA":"37.3","Complexity":"103","charge\t":"N/A","Title":"N/A","XLogP":"1.9"},{"cid":971,"name":"oxalic acid","formula":"C2H2O4","weight":"90.03","SMILES":"N/A","Hydrogen Bond Donor":"2","Hydrogen Bond Acceptor":"4","TPSA":"74.6","Complexity":"71.5","charge\t":"N/A","Title":"N/A","XLogP":"N/A"},{"cid":6581,"name":"acrylic acid","formula":"C3H4O2","weight":"72.06","SMILES":"N/A","Hydrogen Bond Donor":"1","Hydrogen Bond Acceptor":"2","TPSA":"37.3","Complexity":"55.9","charge\t":"N/A","Title":"N/A","XLogP":"0.3"},{"cid":1060,"name":"2-oxopropanoic acid","formula":"C3H4O3","weight":"88.06","SMILES":"N/A","Hydrogen Bond Donor":"1","Hydrogen Bond Acceptor":"3","TPSA":"54.4","Complexity":"84","charge\t":"N/A","Title":"N/A","XLogP":"N/A"},{"cid":612,"name":"2-hydroxypropanoic acid","formula":"C3H6O3","weight":"90.08","SMILES":"N/A","Hydrogen Bond Donor":"2","Hydrogen Bond Acceptor":"3","TPSA":"57.5","Complexity":"59.1","charge\t":"N/A","Title":"N/A","XLogP":"-0.7"},{"cid":602,"name":"2-aminopropanoic acid","formula":"C3H7NO2","weight":"89.09","SMILES":"N/A","Hydrogen Bond Donor":"2","Hydrogen Bond Acceptor":"3","TPSA":"63.3","Complexity":"61.8","charge\t":"N/A","Title":"N/A","XLogP":"-3"},{"cid":1110,"name":"succinic acid","formula":"C4H6O4","weight":"118.09","SMILES":"N/A","Hydrogen Bond Donor":"2","Hydrogen Bond Acceptor":"4","TPSA":"74.6","Complexity":"92.6","charge\t":"N/A","Title":"N/A","XLogP":"-0.6"}]}
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
Output: [C(=O)O, CC(=O)O, c1ccccc1C(=O)O, OC(=O)C(=O)O, C=CC(=O)O, CC(O)C(=O)O, C(=O)[O-], C(=O)OC, C(=O)N]
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
Output: {cid: 248, name: carboxymethyl(trimethyl)ammonium, formula: C5H12NO2+, weight: 118.15, SMILES: N/A, Hydrogen Bond Donor: 1, Hydrogen Bond Acceptor: 2, TPSA: 37.3, Complexity: 93.1, charge	: N/A, Title: N/A, XLogP: N/A}
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
You've asked about **carboxymethyl(trimethyl)ammonium**. This compound is a fascinating example in organic chemistry, particularly known for its zwitterionic nature. While your given name describes the cationic part, the compound typically exists as an internal salt, commonly known as **glycine betaine**.

Let's break down its chemistry:

### 1. Chemical Structure and Nomenclature

The name "carboxymethyl(trimethyl)ammonium" refers to the quaternary ammonium cation with a carboxymethyl group attached to the nitrogen. However, due to the acidic nature of the carboxylic acid group (pKa ~2.3-2.5) and the basicity of the trimethylamine moiety, the proton from the carboxylic acid readily transfers to the nitrogen in a formal sense, or more accurately, the carboxylate anion is formed and exists as an internal ion pair with the quaternary ammonium center. This results in a zwitterionic structure.

*   **Common Name:** Glycine betaine, Betaine, Trimethylglycine (TMG)
*   **IUPAC Name (for the zwitterion):** 2-(trimethylammonio)ethanoate
    *   The term "ethanoate" comes from acetic acid (ethanoic acid), where the methylene group (-CH2-) is attached to the nitrogen.
    *   "Trimethylammonio" describes the positively charged nitrogen with three methyl groups.

*   **Chemical Structure (Zwitterion Form):**
    ```
          O
         //
    (CH3)3N+ - CH2 - C
                   \
                    O-
    ```
    (Linear representation: (CH3)3N$^+$-CH2-COO$^-$)

*   **Molecular Formula:** C$_{5}$H$_{11}$NO$_{2}$ (note: the IUPAC name C5H13NO2 for the protonated form vs C5H11NO2 for the zwitterion)
*   **Molar Mass:** 117.15 g/mol

### 2. Classification

*   **Quaternary Ammonium Compound:** It contains a nitrogen atom bonded to four carbon atoms, giving it a permanent positive charge.
*   **Betaine:** A specific type of zwitterionic compound that has a positively charged functional group (like a quaternary ammonium group) and a negatively charged functional group (like a carboxylate group) that are not adjacent, and the overall molecule is neutral. Glycine betaine is the simplest N-methylated betaine.
*   **Amino Acid Derivative:** It can be considered a derivative of the amino acid glycine (H$_{2}$N-CH$_{2}$-COOH) where the amine nitrogen is fully methylated and exists as a quaternary ammonium center.

### 3. Key Properties

*   **Physical State:** Typically a white crystalline solid at room temperature.
*   **Solubility:** Highly soluble in water due to its zwitterionic nature, which facilitates strong interactions with water molecules. Sparingly soluble in ethanol.
*   **Amphoteric Nature:** Although it is an internal salt, its zwitterionic structure means it can accept or donate protons in specific conditions. However, the internal proton transfer from carboxylic acid to nitrogen is already complete.
*   **Stability:** Relatively stable, especially in its solid form. It's not particularly reactive under normal storage conditions.

### 4. Organic Synthesis

Glycine betaine can be synthesized through several routes, commonly involving the alkylation of an appropriate precursor:

*   **Method 1: Alkylation of Glycine:**
    Glycine itself can be exhaustively methylated using a strong methylating agent in the presence of a base.
    **Reactants:** Glycine (H$_{2}$N-CH$_{2}$-COOH), Methylating agent (e.g., Methyl Iodide (CH$_{3}$I), Dimethyl Sulfate ((CH$_{3}$O)$_{2}$SO$_{2}$)), Base (e.g., Na$_{2}$CO$_{3}$, NaOH).
    **Reaction Equation (simplified):**
    `H2N-CH2-COOH + 3 CH3I + 2 Base → (CH3)3N+-CH2-COO- + 3 HI (or salt)`
    This is an S$_{N}$2 reaction where the nitrogen's lone pair acts as a nucleophile. Multiple alkylations occur until the quaternary ammonium salt is formed.

*   **Method 2: Reaction of Trimethylamine with Chloroacetic Acid:**
    This is a common and efficient laboratory and industrial synthesis. Trimethylamine acts as a nucleophile to displace the chloride from chloroacetic acid.
    **Reactants:** Trimethylamine (N(CH$_{3}$)$_{3}$), Chloroacetic Acid (Cl-CH$_{2}$-COOH).
    **Reaction Equation:**
    `N(CH3)3 + Cl-CH2-COOH → (CH3)3N+-CH2-COOH · Cl-`
    (trimethylammonium chloroacetate, a salt)
    This salt then readily converts to the zwitterion (glycine betaine) either by internal proton transfer or by deprotonation in the presence of a mild base:
    `(CH3)3N+-CH2-COOH · Cl- <=> (CH3)3N+-CH2-COO- + HCl` (internal salt formation)

### 5. Spectroscopy Interpretation

*   **$^1$H NMR Spectroscopy:**
    *   **δ ~3.7-3.9 ppm (singlet, 2H):** Characteristic of the methylene protons (-CH$_{2}$-) adjacent to both the positively charged nitrogen and the carboxylate group. Their signal is shifted downfield due to the electron-withdrawing effects.
    *   **δ ~3.2-3.4 ppm (singlet, 9H):** The nine equivalent protons of the three methyl groups attached to the quaternary ammonium nitrogen. Also shifted downfield due to the positive charge on nitrogen.
*   **IR Spectroscopy:**
    *   **~1550-1610 cm$^{-1}$ (strong, broad):** Asymmetric stretching vibration of the carboxylate anion (COO$^{-}$). This is a key distinguishing feature from a neutral carboxylic acid C=O (~1700-1725 cm$^{-1}$).
    *   **~1400 cm$^{-1}$ (medium):** Symmetric stretching vibration of the carboxylate anion.
    *   **2800-3000 cm$^{-1}$:** C-H stretches from methyl and methylene groups.
*   **Mass Spectrometry (MS):**
    *   **Molecular Ion (M+):** Typically observed at m/z 117 (for C$_{5}$H$_{11}$NO$_{2}$).
    *   **Fragmentation:** Common fragmentation patterns might include loss of a methyl group (M-15), loss of CO$_{2}$ (M-44), or other characteristic cleavages depending on the ionization method.

### 6. Applications

Glycine betaine is biologically significant and has various industrial applications:

*   **Nutritional Supplement:** Widely used as a dietary supplement. It acts as a methyl donor in various metabolic pathways, particularly in the methionine cycle, where it helps in the remethylation of homocysteine to methionine. It's beneficial for liver health, cardiovascular health (by lowering homocysteine levels), and athletic performance.
*   **Osmolyte:** In biology, it functions as an osmoprotectant, helping cells and organisms maintain osmotic balance and protect against stress (e.g., high salinity, extreme temperatures).
*   **Food Industry:** Used as a food additive, humectant, and flavor enhancer in certain products.
*   **Cosmetics and Personal Care:** Incorporated into skin care and hair care products as a moisturizer, humectant, and anti-static agent due to its zwitterionic nature which can interact with charged surfaces (like hair).

### 7. Safety Considerations

Glycine betaine is generally regarded as safe (GRAS) by regulatory bodies like the FDA when used as a food ingredient or supplement at recommended doses.

*   **Handling:** As a pure chemical, it should be handled with standard laboratory safety practices, including wearing appropriate personal protective equipment (lab coat, gloves, eye protection).
*   **Storage:** Store in a cool, dry place, away from incompatible materials.
*   **Toxicity:** Acute toxicity is low. High doses might lead to gastrointestinal discomfort (nausea, diarrhea) or a "fishy" body odor due to its metabolism into trimethylamine.
*   **MSDS (Material Safety Data Sheet):** Always consult the specific MSDS for the product being used for detailed information on hazards, handling, storage, and first aid.

In summary, carboxymethyl(trimethyl)ammonium, most commonly known as glycine betaine, is a crucial zwitterionic compound with diverse roles in biochemistry and practical applications, synthesized via straightforward alkylation reactions.

---
**References:**

*   Clayden, J., Greeves, N., & Warren, S. (2012). *Organic Chemistry* (2nd ed.). Oxford University Press.
*   Carey, F. A., & Sundberg, R. J. (2007). *Advanced Organic Chemistry Part B: Reactions and Synthesis* (5th ed.). Springer.
*   PubChem. (Accessed various dates). National Library of Medicine. [https://pubchem.ncbi.nlm.nih.gov/](https://pubchem.ncbi.nlm.nih.gov/)
*   Craig, G. B. (2004). Betaine: a new role for an old nutrient. *Journal of the American Dietetic Association*, 104(2), 273-274.
```