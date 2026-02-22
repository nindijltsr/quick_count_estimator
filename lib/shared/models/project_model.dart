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
  
  // Nullable fields untuk hasil estimasi /  output
  final int? workerCount;
  final int? estimatedDuration;
  final double? totalCost;

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
    this.workerCount,
    this.estimatedDuration,
    this.totalCost,
  });

  factory ProjectModel.fromMap(Map<String, dynamic> data, String documentId) {
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
      workerCount: data['worker_count'],
      estimatedDuration: data['estimated_duration'],
      totalCost: (data['total_cost'] as num?)?.toDouble(),
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
      'worker_count': workerCount,
      'estimated_duration': estimatedDuration,
      'total_cost': totalCost,
    };
  }
}