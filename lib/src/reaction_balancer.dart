import 'dart:math';
import 'formula_parser.dart';

/// A class for balancing chemical equations
class ReactionBalancer {
  /// Balances a chemical equation.
  ///
  /// Input format: "H2 + O2 = H2O" or "H2 + O2 -> H2O"
  /// Output format: "2H2 + O2 = 2H2O"
  ///
  /// Returns the balanced equation as a string.
  /// If the equation cannot be balanced, returns an error message.
  static String balance(String equation) {
    try {
      // Normalize the equation
      equation = equation.replaceAll(' ', '');
      equation = equation.replaceAll('->', '=');

      // Split into reactants and products
      final parts = equation.split('=');
      if (parts.length != 2) {
        return 'Error: Invalid equation format. Use format like "H2 + O2 = H2O"';
      }

      final reactants = parts[0].split('+');
      final products = parts[1].split('+');

      // Parse compounds and count elements
      final reactantCompounds = reactants.map((r) => _parseCompound(r.trim())).toList();
      final productCompounds = products.map((p) => _parseCompound(p.trim())).toList();

      // Get all unique elements in the reaction
      final allElements = <String>{};
      for (var compound in [...reactantCompounds, ...productCompounds]) {
        allElements.addAll(compound.keys);
      }

      // Construct the coefficient matrix for solving the system of equations
      final matrix = _constructMatrix(reactantCompounds, productCompounds, allElements.toList());

      // Solve the system using Gaussian elimination
      final coefficients = _solveMatrix(matrix);
      if (coefficients == null) {
        return 'Error: Could not balance equation. The equation may be invalid.';
      }

      // Scale coefficients to smallest possible integers
      final scaledCoefficients = _scaleCoefficients(coefficients);

      // Format the balanced equation
      return _formatBalancedEquation(reactants, products, scaledCoefficients.sublist(0, reactants.length), scaledCoefficients.sublist(reactants.length));
    } catch (e) {
      return 'Error balancing equation: $e';
    }
  }

  /// Parses a compound into a map of elements and their counts
  static Map<String, int> _parseCompound(String compound) {
    // Use the formula parser from the package
    return parseFormula(compound);
  }

  /// Constructs the coefficient matrix for solving the system of equations
  static List<List<double>> _constructMatrix(List<Map<String, int>> reactants, List<Map<String, int>> products, List<String> elements) {
    final numReactants = reactants.length;
    final numProducts = products.length;
    final numCompounds = numReactants + numProducts;

    // Create a matrix with one row per element and one column per compound
    // Plus an extra column for the constants (which are all zeros)
    final matrix = List.generate(elements.length, (_) => List.filled(numCompounds + 1, 0.0));

    // Fill the matrix with the element counts
    for (var i = 0; i < elements.length; i++) {
      final element = elements[i];

      // Reactants have positive coefficients
      for (var j = 0; j < numReactants; j++) {
        matrix[i][j] = reactants[j][element]?.toDouble() ?? 0.0;
      }

      // Products have negative coefficients
      for (var j = 0; j < numProducts; j++) {
        matrix[i][numReactants + j] = -(products[j][element]?.toDouble() ?? 0.0);
      }
    }

    return matrix;
  }

  /// Solves the system of linear equations using Gaussian elimination
  /// Returns a list of coefficients if the system is solvable
  static List<double>? _solveMatrix(List<List<double>> matrix) {
    final numRows = matrix.length;
    final numCols = matrix[0].length;
    final numVars = numCols - 1;

    // Create a copy of the matrix for manipulation
    final m = List.generate(numRows, (i) => List.from(matrix[i]));

    // If we have fewer equations than variables, we need to set one coefficient
    if (numRows < numVars - 1) {
      // Add a row that sets the first coefficient to 1
      m.add(List.filled(numCols, 0.0));
      m[numRows][0] = 1.0;
    }

    // Apply Gaussian elimination
    int r = 0;
    for (int c = 0; c < numVars && r < m.length; c++) {
      // Find pivot
      int pivot = r;
      while (pivot < m.length && m[pivot][c].abs() < 1e-10) {
        pivot++;
      }

      if (pivot == m.length) {
        // No pivot found for this column
        continue;
      }

      // Swap rows
      if (pivot != r) {
        final temp = m[r];
        m[r] = m[pivot];
        m[pivot] = temp;
      }

      // Normalize the pivot row
      final pivotValue = m[r][c];
      for (int j = c; j < numCols; j++) {
        m[r][j] /= pivotValue;
      }

      // Eliminate other rows
      for (int i = 0; i < m.length; i++) {
        if (i != r && m[i][c].abs() > 1e-10) {
          final factor = m[i][c];
          for (int j = c; j < numCols; j++) {
            m[i][j] -= factor * m[r][j];
          }
        }
      }

      r++;
    }

    // Back substitution
    final solution = List.filled(numVars, 0.0);
    solution[numVars - 1] = 1.0; // Set the last variable to 1 for a parameterized solution

    for (int i = min(numRows, numVars) - 1; i >= 0; i--) {
      double sum = 0.0;
      for (int j = i + 1; j < numVars; j++) {
        sum += m[i][j] * solution[j];
      }
      solution[i] = -sum;
    }

    return solution;
  }

  /// Scales the coefficients to the smallest possible integers
  static List<int> _scaleCoefficients(List<double> coefficients) {
    // Find the GCD of all coefficients
    int findGCD(int a, int b) {
      while (b != 0) {
        final temp = b;
        b = a % b;
        a = temp;
      }
      return a;
    }

    // Convert to integers with a scaling factor
    const scaleFactor = 1000000;
    final intCoefficients = coefficients.map((c) => (c * scaleFactor).round()).toList();

    // Find the GCD of all coefficients
    int gcd = intCoefficients[0].abs();
    for (int i = 1; i < intCoefficients.length; i++) {
      gcd = findGCD(gcd, intCoefficients[i].abs());
    }

    // Scale down by the GCD
    return intCoefficients.map((c) => (c / gcd).round()).toList();
  }

  /// Formats the balanced equation with the calculated coefficients
  static String _formatBalancedEquation(List<String> reactants, List<String> products, List<int> reactantCoefficients, List<int> productCoefficients) {
    String formatCompound(String compound, int coefficient) {
      if (coefficient == 1) {
        return compound.trim();
      } else {
        return '$coefficient${compound.trim()}';
      }
    }

    final formattedReactants = List.generate(reactants.length, (i) => formatCompound(reactants[i], reactantCoefficients[i]));

    final formattedProducts = List.generate(products.length, (i) => formatCompound(products[i], productCoefficients[i]));

    return '${formattedReactants.join(' + ')} = ${formattedProducts.join(' + ')}';
  }
}
