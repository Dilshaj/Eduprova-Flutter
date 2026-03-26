import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../models/interview_session_model.dart';
import '../models/interview_feedback_model.dart';

class InterviewPdfGenerator {
  static Future<void> generateAndSave({
    required InterviewSession session,
    required InterviewFeedback feedback,
  }) async {
    final pdf = pw.Document();

    // Load logo
    pw.ImageProvider? logoImage;
    try {
      final logoData = await rootBundle.load('assets/logos/eduprova-logo.png');
      logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
    } catch (e) {
      // Fallback if logo loading fails
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(logoImage),
          pw.SizedBox(height: 20),
          _buildSessionInfo(session, feedback),
          pw.SizedBox(height: 20),
          _buildScoreOverview(feedback),
          pw.SizedBox(height: 20),
          _buildStrengthsAndImprovements(feedback),
          pw.SizedBox(height: 20),
          pw.Divider(thickness: 1, color: PdfColors.grey300),
          pw.SizedBox(height: 10),
          pw.Header(level: 1, text: 'Detailed Question Analysis'),
          ...feedback.detailedAnalysis.asMap().entries.map(
            (entry) => _buildQuestionAnalysis(entry.key + 1, entry.value),
          ),
        ],
      ),
    );

    final output = await getApplicationDocumentsDirectory();
    final file = File("${output.path}/Interview_Report_${session.id}.pdf");
    await file.writeAsBytes(await pdf.save());

    await OpenFilex.open(file.path);
  }

  static pw.Widget _buildHeader(pw.ImageProvider? logo) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'AI Interview Report',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromInt(0xFF0066FF),
              ),
            ),
            pw.Text(
              'Powered by Eduprova AI',
              style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
            ),
          ],
        ),
        if (logo != null) pw.Image(logo, width: 60),
      ],
    );
  }

  static pw.Widget _buildSessionInfo(
    InterviewSession session,
    InterviewFeedback feedback,
  ) {
    final dateStr = session.createdAt != null
        ? "${session.createdAt!.day}/${session.createdAt!.month}/${session.createdAt!.year}"
        : "N/A";

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: const pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Interview Type:', session.typeLabel),
          _buildInfoRow('Session ID:', session.id),
          _buildInfoRow('Date:', dateStr),
          _buildInfoRow('Duration:', session.durationDisplay),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
            ),
          ),
          pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  static pw.Widget _buildScoreOverview(InterviewFeedback feedback) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        _buildScoreCard('Overall Score', feedback.overallScore, PdfColors.blue),
        _buildScoreCard(
          'Technical Score',
          feedback.technicalScore,
          PdfColors.green,
        ),
        _buildScoreCard(
          'Communication',
          feedback.communicationScore,
          PdfColors.purple,
        ),
      ],
    );
  }

  static pw.Widget _buildScoreCard(String label, double score, PdfColor color) {
    return pw.Container(
      width: 150,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: color, width: 2),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            '${score.round()}/100',
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildStrengthsAndImprovements(InterviewFeedback feedback) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: _buildListSection(
            'Key Strengths',
            feedback.strengths,
            PdfColors.green,
          ),
        ),
        pw.SizedBox(width: 20),
        pw.Expanded(
          child: _buildListSection(
            'Areas for Improvement',
            feedback.improvements,
            PdfColors.orange,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildListSection(
    String title,
    List<String> items,
    PdfColor color,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title.toUpperCase(),
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
        pw.SizedBox(height: 8),
        ...items.map(
          (item) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('• ', style: pw.TextStyle(color: color)),
                pw.Expanded(
                  child: pw.Text(item, style: const pw.TextStyle(fontSize: 10)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildQuestionAnalysis(
    int index,
    DetailedAnalysisItem item,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 15),
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey200),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'QUESTION $index',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue,
                ),
              ),
              pw.Text(
                'Score: ${item.score.round()}/10',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: item.score >= 7 ? PdfColors.green : PdfColors.orange,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            item.question,
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          _buildAnalysisField('Your Answer:', item.userAnswer),
          _buildAnalysisField('Feedback:', item.feedback),
          _buildAnalysisField(
            'Suggested Answer:',
            item.detailedAnswer,
            isCorrection: true,
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildAnalysisField(
    String label,
    String content, {
    bool isCorrection = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 6),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: isCorrection ? PdfColors.green700 : PdfColors.grey600,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            content,
            style: pw.TextStyle(
              fontSize: 9,
              color: PdfColors.black,
              fontStyle: isCorrection
                  ? pw.FontStyle.italic
                  : pw.FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }
}
