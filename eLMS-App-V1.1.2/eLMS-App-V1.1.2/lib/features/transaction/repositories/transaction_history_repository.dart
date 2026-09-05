import 'dart:io';
import 'package:elms/common/models/data_class.dart';
import 'package:elms/core/api/api_client.dart';
import 'package:elms/core/api/api_params.dart';
import 'package:elms/features/transaction/models/transaction_history_model.dart';
import 'package:path_provider/path_provider.dart';

class TransactionHistoryRepository {
  Future<DataClass<TransactionHistoryModel>> fetch() async {
    try {
      final Map<String, dynamic> response = await Api.get(Apis.orders);
      return DataClass.fromResponse(TransactionHistoryModel.fromJson, response);
    } catch (e) {
      rethrow;
    }
  }

  /// Download invoice PDF for a specific order
  ///
  /// [orderId] - The order ID to download the invoice for
  /// Returns the local file path where the PDF was saved
  Future<String> downloadInvoice({required int orderId}) async {
    try {
      // Get the app's document directory
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String invoicesDir = '${appDocDir.path}/invoices';

      // Create invoices directory if it doesn't exist
      final Directory dir = Directory(invoicesDir);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // Create file path with timestamp to avoid conflicts
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String savePath = '$invoicesDir/invoice_${orderId}_$timestamp.pdf';

      // Download the PDF
      final String filePath = await Api.downloadPdf(
        Apis.invoiceDownload,
        savePath: savePath,
        data: {ApiParams.orderId: orderId},
      );

      return filePath;
    } catch (e) {
      rethrow;
    }
  }
}
