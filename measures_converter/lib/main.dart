import 'package:flutter/material.dart';
import 'converters/unit_converter.dart';

void main() {
  runApp(const MeasuresConverterApp());
}

class MeasuresConverterApp extends StatelessWidget {
  const MeasuresConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Measures Converter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const ConverterScreen(),
    );
  }
}

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final TextEditingController _valueController = TextEditingController(text: '100');

  UnitCategory _selectedCategory = UnitCategory.length;
  late List<String> _availableUnits;
  String? _fromUnit;
  String? _toUnit;

  String _resultText = '';

  @override
  void initState() {
    super.initState();
    _refreshUnitsForCategory(_selectedCategory);
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  void _refreshUnitsForCategory(UnitCategory category) {
    _availableUnits = UnitConverter.unitsForCategory(category);
    _fromUnit = _availableUnits.isNotEmpty ? _availableUnits.first : null;
    _toUnit = _availableUnits.length > 1 ? _availableUnits[1] : _fromUnit;
    _resultText = '';
    setState(() {});
  }

  void _convert() {
    final raw = _valueController.text.trim();

    if (raw.isEmpty) {
      setState(() => _resultText = 'Please enter a value.');
      return;
    }

    final value = double.tryParse(raw);
    if (value == null) {
      setState(() => _resultText = 'Invalid number. Example: 12.5');
      return;
    }

    if (_fromUnit == null || _toUnit == null) {
      setState(() => _resultText = 'Please select both units.');
      return;
    }

    try {
      final out = UnitConverter.convert(
        value: value,
        fromUnitKey: _fromUnit!,
        toUnitKey: _toUnit!,
      );

      final formattedIn = value.toStringAsFixed(1);
      final formattedOut = out.toStringAsFixed(3);

      setState(() {
        _resultText = '$formattedIn $_fromUnit are $formattedOut $_toUnit';
      });
    } catch (e) {
      setState(() => _resultText = 'Conversion error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Measures Converter'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          children: [
            const SizedBox(height: 8),
            const _SectionTitle(title: 'Measure Type'),
            const SizedBox(height: 8),

            SegmentedButton<UnitCategory>(
              segments: const <ButtonSegment<UnitCategory>>[
                ButtonSegment(value: UnitCategory.length, label: Text('Distance')),
                ButtonSegment(value: UnitCategory.weight, label: Text('Weight')),
              ],
              selected: <UnitCategory>{_selectedCategory},
              onSelectionChanged: (set) {
                final next = set.first;
                _selectedCategory = next;
                _refreshUnitsForCategory(next);
              },
            ),

            const SizedBox(height: 22),
            const _SectionTitle(title: 'Value'),
            const SizedBox(height: 8),

            TextField(
              controller: _valueController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                hintText: 'Enter a number (e.g., 100)',
              ),
            ),

            const SizedBox(height: 22),
            const _SectionTitle(title: 'From'),
            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              value: _fromUnit,
              items: _availableUnits
                  .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                  .toList(),
              onChanged: (v) => setState(() => _fromUnit = v),
              decoration: const InputDecoration(border: UnderlineInputBorder()),
            ),

            const SizedBox(height: 22),
            const _SectionTitle(title: 'To'),
            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              value: _toUnit,
              items: _availableUnits
                  .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                  .toList(),
              onChanged: (v) => setState(() => _toUnit = v),
              decoration: const InputDecoration(border: UnderlineInputBorder()),
            ),

            const SizedBox(height: 18),
            Center(
              child: ElevatedButton(
                onPressed: _convert,
                child: const Text('Convert'),
              ),
            ),

            const SizedBox(height: 20),
            Center(
              child: Text(
                _resultText.isEmpty
                    ? 'Select units and tap Convert.'
                    : _resultText,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }
}
