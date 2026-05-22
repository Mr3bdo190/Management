import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/invoice_model.dart';
import 'package:intl/intl.dart';

class PdfService {
  Future<void> generateInvoicePdf(Invoice invoice, {required bool isShare}) async {
    final pdf = pw.Document();
    
    // جلب خطوط عربية احترافية من جوجل أونلاين لضمان تنسيق الكلمات العربية بشكل صحيح
    final arabicFont = await PdfGoogleFonts.amiriRegular();
    final arabicBoldFont = await PdfGoogleFonts.amiriBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(
          base: arabicFont,
          bold: arabicBoldFont,
        ),
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Padding(
              padding: const pw.EdgeInsets.all(20),
              child: pw.Column(
                cross: pw.CrossAxisAlignment.start,
                children: [
                  // الهيدر الخاص بالفاتورة
                  pw.Row(
                    main: pw.MainAxisAlignment.between,
                    children: [
                      pw.Text('فاتورة مبيعات', style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                      pw.Text('إدارة المصنع', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  pw.Divider(thickness: 2, color: PdfColors.blue900),
                  pw.SizedBox(height: 20),
                  
                  // بيانات العميل والفاتورة
                  pw.Text('اسم العميل: ${invoice.clientName}', style: pw.TextStyle(fontSize: 16)),
                  pw.Text('التاريخ: ${DateFormat('yyyy-MM-dd hh:mm a').format(invoice.date)}', style: pw.TextStyle(fontSize: 14)),
                  pw.Text('رقم الفاتورة: #${invoice.id.substring(0, 8).toUpperCase()}', style: pw.TextStyle(fontSize: 14)),
                  pw.SizedBox(height: 20),
                  
                  // جدول الأصناف
                  pw.TableHelper.fromTextArray(
                    headers: ['اسم الصنف / الخامة', 'الكمية', 'سعر الوحدة', 'الإجمالي'],
                    data: invoice.items.map((item) => [
                      item.name,
                      item.quantity.toString(),
                      '${item.price.toStringAsFixed(2)} ج.م',
                      '${item.total.toStringAsFixed(2)} ج.م',
                    ]).toList(),
                    cellAlignment: pw.Alignment.centerRight,
                    headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold),
                    headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
                    rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300))),
                  ),
                  pw.SizedBox(height: 30),
                  
                  // الملخص المالي للفاتورة
                  pw.Align(
                    alignment: pw.Alignment.centerLeft,
                    child: pw.Container(
                      width: 250,
                      child: pw.Column(
                        cross: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(main: pw.MainAxisAlignment.between, children: [pw.Text('الإجمالي المستحق:'), pw.Text('${invoice.subTotal.toStringAsFixed(2)} ج.م')]),
                          if (invoice.discount > 0)
                            pw.Row(main: pw.MainAxisAlignment.between, children: [pw.Text('الخصم:'), pw.Text('-${invoice.discount.toStringAsFixed(2)} ج.م', style: const pw.TextStyle(color: PdfColors.green))]),
                          pw.Divider(),
                          pw.Row(main: pw.MainAxisAlignment.between, children: [pw.Text('الصافي النهائي:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)), pw.Text('${invoice.grandTotal.toStringAsFixed(2)} ج.م', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))]),
                          pw.Row(main: pw.MainAxisAlignment.between, children: [pw.Text('المبلغ المدفوع:'), pw.Text('${invoice.paidAmount.toStringAsFixed(2)} ج.م')]),
                          pw.Divider(),
                          pw.Row(main: pw.MainAxisAlignment.between, children: [
                            pw.Text('المتبقي (دين):', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.red900)),
                            pw.Text('${invoice.remainingAmount.toStringAsFixed(2)} ج.م', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.red900))
                          ]),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    final bytes = await pdf.save();

    if (isShare) {
      // إرسال ومشاركة الملف مباشرة للواتساب أو أي تطبيق آخر
      await Printing.sharePdf(bytes: bytes, filename: 'فاتورة_${invoice.clientName}_${invoice.id.substring(0, 4)}.pdf');
    } else {
      // طباعة الفاتورة (تفتح نافذة الطباعة الرسمية للموبايل وتدعم طابعات البلوتوث والحرارية)
      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => bytes);
    }
  }
}
