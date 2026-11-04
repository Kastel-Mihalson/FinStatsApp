/// Собирает CSV с разделителем `;` (как ждёт Excel в русской локали),
/// BOM в начале для корректной кодировки UTF-8 и CRLF между строками.
String buildCsv(List<String> header, List<List<String>> rows) {
  final lines = [header, ...rows].map((row) => row.map(_escape).join(';'));
  return '\uFEFF${lines.join('\r\n')}\r\n';
}

String _escape(String value) {
  final needsQuotes = value.contains(';') ||
      value.contains('"') ||
      value.contains('\n') ||
      value.contains('\r');
  if (!needsQuotes) return value;
  return '"${value.replaceAll('"', '""')}"';
}
