import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../generated/l10n.dart';
import '../models/data_model.dart';
import '../utilities/time_functions.dart';

Future<void> exportAllAsJson() async {
  final String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
  if (selectedDirectory != null) {
    // ignore: unused_local_variable
    final File saveFile = File('$selectedDirectory/export.txt');
    // await saveFile.writeAsString(data);
  }
}

Future<void> exportRecipeToPdf({
  required Recipe recipe,
  required String bookName,
  required S s,
}) async {
  try {
    final String? dir = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Export "${recipe.name}.pdf"',
    );
    if (dir == null) return;

    // Load Comfortaa (supports full Latin/accented chars). Variable font
    // is used for both regular and bold — bold weight is handled via the
    // font's own weight axis.
    final fontData = await rootBundle.load(
      'fonts/google_fonts/Comfortaa-VariableFont_wght.ttf',
    );
    final font = pw.Font.ttf(fontData);

    final logoData = await rootBundle.load('assets/icons/splash_icon.png');
    final logo = pw.MemoryImage(logoData.buffer.asUint8List());

    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 48, vertical: 48),
        theme: pw.ThemeData.withFont(base: font, bold: font),
        build: (context) => _buildContent(recipe, bookName, s, logo),
      ),
    );

    final file = File('$dir/${recipe.name}.pdf');
    await file.writeAsBytes(await pdf.save());
  } catch (e) {
    debugPrint('exportRecipeToPdf error: $e');
  }
}

List<pw.Widget> _buildContent(Recipe recipe, String bookName, S s, pw.MemoryImage logo) {
  final brique = PdfColor.fromHex('#d65931');
  const grey   = PdfColors.grey700;

  final styleBody    = const pw.TextStyle(fontSize: 11);
  final styleMuted   = pw.TextStyle(fontSize: 10, color: grey);
  final styleTitle   = pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold);
  final styleSection = pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: brique);

  String fmtQty(double? qty) {
    if (qty == null) return '';
    return qty == qty.roundToDouble() ? qty.round().toString() : qty.toStringAsFixed(1);
  }

  String quillToText(String json) {
    if (json.isEmpty) return '';
    try {
      final ops = jsonDecode(json) as List;
      return ops.map((op) => (op as Map)['insert'] ?? '').join('').trimRight();
    } catch (_) {
      return json;
    }
  }

  return [

    // ── Header ─────────────────────────────────────────────────────────
    pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Row(children: [
          pw.Image(logo, width: 32, height: 32),
          pw.SizedBox(width: 8),
          pw.Text('Cuicuisine',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: brique)),
        ]),
        pw.Text(bookName, style: styleMuted),
      ],
    ),
    pw.Divider(color: brique, thickness: 1),
    pw.SizedBox(height: 10),

    // ── Recipe name ────────────────────────────────────────────────────
    pw.Text(recipe.name, style: styleTitle),
    pw.SizedBox(height: 6),

    // ── Quantity ───────────────────────────────────────────────────────
    if (recipe.quantity > 0 && recipe.quantityType.isNotEmpty)
      pw.Text('${recipe.quantity} ${recipe.quantityType}', style: styleMuted),

    // ── Times ──────────────────────────────────────────────────────────
    if (recipe.preparationTime > 0 || recipe.cookingTime > 0 || recipe.waitingTime > 0)
      pw.Padding(
        padding: const pw.EdgeInsets.only(top: 4),
        child: pw.Row(children: [
          if (recipe.preparationTime > 0)
            pw.Text('${s.time_widget_preparation}  ${minutesToTime(recipe.preparationTime)}    ', style: styleMuted),
          if (recipe.cookingTime > 0)
            pw.Text('${s.time_widget_cooking}  ${minutesToTime(recipe.cookingTime)}    ', style: styleMuted),
          if (recipe.waitingTime > 0)
            pw.Text('${s.time_widget_waiting}  ${minutesToTime(recipe.waitingTime)}', style: styleMuted),
        ]),
      ),

    // ── Ingredients ────────────────────────────────────────────────────
    if (recipe.recipeIngredients.isNotEmpty) ...[
      pw.SizedBox(height: 20),
      pw.Text(s.ingredient_widget_title, style: styleSection),
      pw.Divider(thickness: 0.5),
      ...recipe.recipeIngredients.map((ing) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 3),
        child: pw.Row(children: [
          pw.Text('-  ', style: styleBody),
          pw.Expanded(child: pw.Text(ing.getName(), style: styleBody)),
          pw.Text(
            ing.getUnit().isNotEmpty
                ? '${fmtQty(ing.quantity)} ${ing.getUnit()}'
                : fmtQty(ing.quantity),
            style: styleMuted,
          ),
        ]),
      )),
    ],

    // ── Steps ──────────────────────────────────────────────────────────
    if (recipe.steps.isNotEmpty) ...[
      pw.SizedBox(height: 20),
      pw.Text(s.steps_widget_title, style: styleSection),
      pw.Divider(thickness: 0.5),
      ...recipe.steps.asMap().entries.map((entry) {
        final i    = entry.key;
        final step = entry.value;
        return pw.Padding(
          padding: const pw.EdgeInsets.only(top: 10),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('${i + 1}.  ', style: styleSection),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(quillToText(step.step), style: styleBody),
                    if (step.time > 0)
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(top: 3),
                        child: pw.Text(minutesToTime(step.time), style: styleMuted),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    ],

  ];
}
