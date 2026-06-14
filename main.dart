library business_card_scanner;

import 'dart:typed_data';

import 'package:logger/logger.dart';

import 'src/analyzers/analyzer_provider.dart';
import 'src/models/business_card_data.dart';
import 'src/ocr/ocr_service.dart';
import 'src/parsers/text_parser.dart';

export 'src/analyzers/analyzer_provider.dart';
export 'src/models/business_card_data.dart';
export 'src/ocr/general_ocr_service.dart';
export 'src/ocr/ocr_service.dart';
export 'src/parsers/text_parser.dart';

/// Main class for scanning and processing business cards
class BusinessCardScanner {

  /// Create a new BusinessCardScanner instance
  ///
  /// Optionally provide a custom [AnalyzerProvider] for AI-based analysis.
  /// If not provided, uses a default regex-based analyzer.
  BusinessCardScanner({AnalyzerProvider? analyzerProvider})
      : _ocrService = OcrService(),
        _textParser = const TextParser(),
        _analyzerProvider = analyzerProvider;
  final OcrService _ocrService;
  final TextParser _textParser;
  final AnalyzerProvider? _analyzerProvider;
  final Logger _logger = Logger();

  /// Scans a business card image and extracts structured data
  ///
  /// [imageBytes] - The image data as Uint8List
  /// Returns a [BusinessCardData] object containing extracted information
  Future<BusinessCardData> scan(Uint8List imageBytes) async {
    try {
      _logger.i('Starting business card scan');
      
      // Perform OCR
      final recognizedText = await _ocrService.recognizeText(imageBytes);
      
      // Parse text to extract information
      final parsedData = _textParser.parse(recognizedText);
      
      // If AI analyzer is provided, use it to enhance the data
      if (_analyzerProvider != null) {
        _logger.d('Using AI analyzer to enhance results');
        final enhancedData = await _analyzerProvider!.analyze(recognizedText);
        return parsedData.merge(enhancedData);
      }
      
      return parsedData;
    } catch (e, stackTrace) {
      _logger.e('Error during business card scan', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Dispose of resources
  void dispose() {
    _ocrService.dispose();
    _logger.i('BusinessCardScanner resources disposed');
  }
}
