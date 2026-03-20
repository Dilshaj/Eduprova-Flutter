class Job {
  final String id;
  final String title;
  final String company;
  final String location;
  final String salary;
  final String type; // e.g., Full-time, Part-time
  final String icon; // company logo URL or asset path
  final String? description;
  final String? workMode; // e.g., Remote, On-site, Hybrid
  final String? postedAgo;
  final int applicantsCount;
  final List<String> applicantAvatars;
  final bool isSaved;
  final bool hasApplied;
  final DateTime? createdAt;

  Job({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.salary,
    required this.type,
    required this.icon,
    this.description,
    this.workMode,
    this.postedAgo,
    this.applicantsCount = 0,
    this.applicantAvatars = const [],
    this.isSaved = false,
    this.hasApplied = false,
    this.createdAt,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    final id = json['id'] ?? json['_id'] ?? '';
    
    // Handle salary formatting if min/max are provided instead of a string
    String salaryStr = json['salary'] ?? '';
    if (salaryStr.isEmpty && json['salaryMin'] != null && json['salaryMax'] != null) {
      salaryStr = '₹${json['salaryMin']} - ₹${json['salaryMax']} per year';
    }

    return Job(
      id: id.toString(),
      title: json['title'] ?? '',
      company: json['company'] ?? '',
      location: json['location'] ?? '',
      salary: salaryStr,
      type: json['type'] ?? json['time'] ?? 'Full-time',
      icon: json['companyLogo'] ?? json['icon'] ?? '',
      description: json['description'],
      workMode: json['workMode'],
      postedAgo: json['postedAgo'],
      applicantsCount: json['applicantsCount'] ?? 0,
      applicantAvatars: List<String>.from(json['applicantAvatars'] ?? []),
      isSaved: json['isSaved'] ?? false,
      hasApplied: json['hasApplied'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'location': location,
      'salary': salary,
      'type': type,
      'icon': icon,
      'description': description,
      'workMode': workMode,
      'postedAgo': postedAgo,
      'applicantsCount': applicantsCount,
      'applicantAvatars': applicantAvatars,
      'isSaved': isSaved,
      'hasApplied': hasApplied,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  Job copyWith({
    bool? isSaved,
    bool? hasApplied,
  }) {
    return Job(
      id: id,
      title: title,
      company: company,
      location: location,
      salary: salary,
      type: type,
      icon: icon,
      description: description,
      workMode: workMode,
      postedAgo: postedAgo,
      applicantsCount: applicantsCount,
      applicantAvatars: applicantAvatars,
      isSaved: isSaved ?? this.isSaved,
      hasApplied: hasApplied ?? this.hasApplied,
      createdAt: createdAt,
    );
  }
}

class JobApplication {
  final String id;
  final String jobId;
  final String status;
  final DateTime appliedAt;
  final Job? job;

  JobApplication({
    required this.id,
    required this.jobId,
    required this.status,
    required this.appliedAt,
    this.job,
  });

  factory JobApplication.fromJson(Map<String, dynamic> json) {
    final rawJobId = json['jobId'];
    String jid = '';
    Job? jobData;

    if (rawJobId is String) {
      jid = rawJobId;
    } else if (rawJobId is Map<String, dynamic>) {
      jobData = Job.fromJson(rawJobId);
      jid = jobData.id;
    }

    return JobApplication(
      id: json['id'] ?? json['_id'] ?? '',
      jobId: jid,
      status: json['status'] ?? 'Pending',
      appliedAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      job: jobData,
    );
  }
}
