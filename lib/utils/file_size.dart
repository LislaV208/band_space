class FileSize {
  static const _multiplier = 1024;

  final int _bytes;

  FileSize.bytes(int value) : _bytes = value {
    if (value < 0) {
      throw ArgumentError('File size cannot be negative');
    }
  }
  FileSize.kilobytes(int value) : this.bytes(value * _multiplier);
  FileSize.megabytes(int value) : this.kilobytes(value * _multiplier);
  FileSize.gigabytes(int value) : this.megabytes(value * _multiplier);
  FileSize.terabytes(int value) : this.gigabytes(value * _multiplier);

  int get bytes => _bytes;
  double get kilobytes => bytes / _multiplier;
  double get megabytes => kilobytes / _multiplier;
  double get gigabytes => megabytes / _multiplier;
  double get terabytes => gigabytes / _multiplier;

  @override
  String toString() {
    if (terabytes >= 1.0) return '${terabytes.toStringAsFixed(2)} TB';
    if (gigabytes >= 1.0) return '${gigabytes.toStringAsFixed(2)} GB';
    if (megabytes >= 1.0) return '${megabytes.toStringAsFixed(2)} MB';
    if (kilobytes >= 1.0) return '${kilobytes.toStringAsFixed(2)} KB';

    return '$bytes B';
  }
}
