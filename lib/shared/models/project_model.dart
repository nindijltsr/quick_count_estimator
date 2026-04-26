import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectModel {
  final String projectId;
  final String userId;
  final String surveyorName;
  final String surveyorEmail;
  final String projectName;
  final String clientName;
  final String address;
  final String phoneNumber;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String statusPerhitungan;

  // Output Estimasi
  final int? workerCount;
  final int? estimatedDuration;
  final double? totalCost;

  // Snapshot harga & koefisien saat proyek disimpan
  final Map<String, double> snapshotHargaMaterial;
  final Map<String, double> snapshotHargaUpah;
  final Map<String, double> snapshotKoefisien;
  final DateTime? tanggalSnapshotDiambil;

  ProjectModel({
    required this.projectId,
    required this.userId,
    required this.surveyorName,
    required this.surveyorEmail,
    required this.projectName,
    required this.clientName,
    required this.address,
    required this.phoneNumber,
    required this.createdAt,
    required this.updatedAt,
    this.statusPerhitungan = 'belum',
    this.workerCount,
    this.estimatedDuration,
    this.totalCost,
    this.snapshotHargaMaterial = const {},
    this.snapshotHargaUpah = const {},
    this.snapshotKoefisien = const {},
    this.tanggalSnapshotDiambil,
  });

  factory ProjectModel.fromMap(Map<String, dynamic> data, String documentId) {
    // Helper type-safe untuk Map<String, double>
    Map<String, double> parseDoubleMap(dynamic raw) {
      if (raw == null || raw is! Map) return {};
      return raw.map(
        (k, v) => MapEntry(k.toString(), (v as num?)?.toDouble() ?? 0.0),
      );
    }

    return ProjectModel(
      projectId: documentId,
      userId: data['user_id'] ?? '',
      surveyorName: data['surveyor_name'] ?? 'Surveyor',
      surveyorEmail: data['surveyor_email'] ?? '-',
      projectName: data['project_name'] ?? 'Tanpa Nama',
      clientName: data['client_name'] ?? '-',
      address: data['address'] ?? '-',
      phoneNumber: data['phone_number'] ?? '-',
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      statusPerhitungan: data['status_perhitungan'] as String? ?? 'belum',
      workerCount: data['worker_count'],
      estimatedDuration: data['estimated_duration'],
      totalCost: (data['total_cost'] as num?)?.toDouble(),
      snapshotHargaMaterial: parseDoubleMap(data['snapshot_harga_material']),
      snapshotHargaUpah: parseDoubleMap(data['snapshot_harga_upah']),
      snapshotKoefisien: parseDoubleMap(data['snapshot_koefisien']),
      tanggalSnapshotDiambil: (data['tanggal_snapshot_diambil'] as Timestamp?)
          ?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'surveyor_name': surveyorName,
      'surveyor_email': surveyorEmail,
      'project_name': projectName,
      'client_name': clientName,
      'address': address,
      'phone_number': phoneNumber,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
      'status_perhitungan': statusPerhitungan,
      'worker_count': workerCount,
      'estimated_duration': estimatedDuration,
      'total_cost': totalCost,
      'snapshot_harga_material': snapshotHargaMaterial,
      'snapshot_harga_upah': snapshotHargaUpah,
      'snapshot_koefisien': snapshotKoefisien,
      'tanggal_snapshot_diambil': tanggalSnapshotDiambil != null
          ? Timestamp.fromDate(tanggalSnapshotDiambil!)
          : null,
    };
  }
}
