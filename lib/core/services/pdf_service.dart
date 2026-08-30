import 'package:flutter/foundation.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {

  static Future<void> generateDailyReport({
    required String childName,
    required int aiChat,
    required int speech,
    required int games,
    required int stories,
    required int songs,
    required int emotion,
    required int routine,
  }) async {

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {

          return pw.Column(
            crossAxisAlignment:
            pw.CrossAxisAlignment.start,
            children: [

              pw.Text(
                "SensiBuddy Daily Report",
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight:
                  pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 20),

              pw.Text(
                "Child: $childName",
              ),

              pw.Text(
                "Date: ${DateTime.now().toString().split(' ')[0]}",
              ),

              pw.Divider(),

              pw.Text(
                "Today's Progress",
                style: pw.TextStyle(
                  fontWeight:
                  pw.FontWeight.bold,
                  fontSize: 18,
                ),
              ),

              pw.SizedBox(height: 10),

              pw.Text("Talk with AI: $aiChat%"),
              pw.Text("Speech Therapy: $speech%"),
              pw.Text("Games: $games%"),
              pw.Text("Stories: $stories%"),
              pw.Text("Songs: $songs%"),
              pw.Text("Emotion: $emotion%"),
              pw.Text("Routine: $routine%"),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async =>
          pdf.save(),
    );
  }

  static Future<void> generateWeeklyReport({
    required String childId,
  }) async {

    // Weekly PDF generation will be added later

    debugPrint(
      "Generating weekly report for: $childId",
    );
  }
}