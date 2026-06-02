import 'dart:convert';

import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../../models/data_model.dart';
import '../../utilities/time_functions.dart';

// Simple, flat widget tree designed for flutter_to_pdf export.
// Uses only primitive widgets (Text, Row, Column, Padding, SizedBox, Divider)
// that flutter_to_pdf can traverse without rebuilding complex custom widgets.
// Text colors are hardcoded dark so the PDF is readable on white paper.
class RecipePdfView extends StatelessWidget {
  final Recipe recipe;
  final String bookName;

  const RecipePdfView({
    super.key,
    required this.recipe,
    required this.bookName,
  });

  static const _textPrimary   = TextStyle(color: Color(0xFF1a1a1a), fontSize: 13);
  static const _textSecondary = TextStyle(color: Color(0xFF666666), fontSize: 11);
  static const _textTitle     = TextStyle(color: Color(0xFF1a1a1a), fontSize: 22, fontWeight: FontWeight.bold);
  static const _textSection   = TextStyle(color: Color(0xFFd65931), fontSize: 14, fontWeight: FontWeight.bold);

  String _formatQty(double? qty) {
    if (qty == null) return '';
    return qty == qty.roundToDouble() ? qty.round().toString() : qty.toStringAsFixed(1);
  }

  String _quillToText(String json) {
    if (json.isEmpty) return '';
    try {
      final ops = jsonDecode(json) as List;
      return ops.map((op) => (op as Map)['insert'] ?? '').join('').trimRight();
    } catch (_) {
      return json;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Header ────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('CuiCuisine', style: TextStyle(color: Color(0xFFd65931), fontSize: 18, fontWeight: FontWeight.bold)),
              Text(bookName, style: _textSecondary),
            ],
          ),
          const Divider(color: Color(0xFFd65931)),
          const SizedBox(height: 16),

          // ── Recipe name ───────────────────────────────────────────────
          Text(recipe.name, style: _textTitle),
          const SizedBox(height: 8),

          // ── Quantity ──────────────────────────────────────────────────
          if (recipe.quantity > 0 && recipe.quantityType.isNotEmpty)
            Text('${recipe.quantity} ${recipe.quantityType}', style: _textSecondary),

          // ── Times ─────────────────────────────────────────────────────
          if (recipe.preparationTime > 0 || recipe.cookingTime > 0 || recipe.waitingTime > 0) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                if (recipe.preparationTime > 0)
                  Text('⏱ ${minutesToTime(recipe.preparationTime)}   ', style: _textSecondary),
                if (recipe.cookingTime > 0)
                  Text('🔥 ${minutesToTime(recipe.cookingTime)}   ', style: _textSecondary),
                if (recipe.waitingTime > 0)
                  Text('⌛ ${minutesToTime(recipe.waitingTime)}', style: _textSecondary),
              ],
            ),
          ],

          // ── Ingredients ───────────────────────────────────────────────
          if (recipe.recipeIngredients.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(s.ingredient_widget_title, style: _textSection),
            const SizedBox(height: 8),
            ...recipe.recipeIngredients.map((ing) {
              final name = ing.getName();
              final unit = ing.getUnit();
              final qty  = _formatQty(ing.quantity);
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Text('• ', style: _textPrimary),
                    Expanded(child: Text(name, style: _textPrimary)),
                    Text(unit.isNotEmpty ? '$qty $unit' : qty, style: _textSecondary),
                  ],
                ),
              );
            }),
          ],

          // ── Steps ─────────────────────────────────────────────────────
          if (recipe.steps.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(s.steps_widget_title, style: _textSection),
            const SizedBox(height: 8),
            ...recipe.steps.asMap().entries.map((entry) {
              final i    = entry.key;
              final step = entry.value;
              final text = _quillToText(step.step);
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${i + 1}. ', style: _textSection),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(text, style: _textPrimary),
                          if (step.time > 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text('⏱ ${minutesToTime(step.time)}', style: _textSecondary),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],

        ],
      ),
    );
  }
}
