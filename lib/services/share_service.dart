import 'dart:io';

import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Handles sharing files and opening WhatsApp with a pre-filled contact.
///
/// WhatsApp note: Pakistani phone numbers are stored by farmers as
/// `0300-1234567`. The wa.me deep-link requires the international format
/// `923001234567`. Without normalisation, WhatsApp opens a blank "new chat"
/// instead of the customer's contact — the share silently fails.
class ShareService {
  ShareService._();

  // ---------------------------------------------------------------------------
  // File sharing
  // ---------------------------------------------------------------------------

  /// Shares [file] using the system share sheet (share_plus).
  ///
  /// On Android this opens the standard chooser (WhatsApp, Gmail, Drive, etc.).
  static Future<void> shareFile(File file) async {
    final xFile = XFile(file.path);
    await Share.shareXFiles([xFile]);
  }

  // ---------------------------------------------------------------------------
  // WhatsApp
  // ---------------------------------------------------------------------------

  /// Opens WhatsApp with [phone] pre-selected and [message] pre-filled.
  ///
  /// [phone] is normalised from Pakistani local format (`0300-XXXXXXX`) to
  /// the international format required by wa.me (`923XXXXXXXXX`).
  /// If normalisation produces an empty string the method does nothing.
  static Future<void> openWhatsApp({
    required String phone,
    String? message,
  }) async {
    final normalised = normalizePhoneForWhatsapp(phone);
    if (normalised.isEmpty) return;

    final encoded = message != null ? Uri.encodeComponent(message) : '';
    final urlStr  = encoded.isNotEmpty
        ? 'https://wa.me/$normalised?text=$encoded'
        : 'https://wa.me/$normalised';

    final uri = Uri.parse(urlStr);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ---------------------------------------------------------------------------
  // Phone number normalisation
  // ---------------------------------------------------------------------------

  /// Converts a raw Pakistani phone string to the format required by wa.me.
  ///
  /// Rules (in order):
  ///   1. Strip all non-digit characters (spaces, dashes, dots, parentheses).
  ///   2. If the result starts with `0`, replace the leading `0` with `92`
  ///      (country code for Pakistan).
  ///   3. If the result already starts with `92`, leave it unchanged.
  ///   4. If empty after stripping, return `''` — callers should guard on this.
  ///
  /// Examples:
  ///   `0300-1234567`  → `923001234567`
  ///   `0321 987 6543` → `923219876543`
  ///   `923001234567`  → `923001234567`  (already normalised)
  ///   `+92300-1234567`→ `923001234567`
  static String normalizePhoneForWhatsapp(String raw) {
    // Step 1: strip everything except digits
    final digits = raw.replaceAll(RegExp(r'[^\d]'), '');

    if (digits.isEmpty) return '';

    // Step 2: replace leading 0 with 92 (Pakistani country code)
    if (digits.startsWith('0')) {
      return '92${digits.substring(1)}';
    }

    // Step 3: already has country code
    return digits;
  }
}
