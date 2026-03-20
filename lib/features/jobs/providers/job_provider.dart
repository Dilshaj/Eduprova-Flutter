import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eduprova/features/jobs/models/job_model.dart';

// Current active tab in Jobs section
enum JobsTab { recommended, applications, saved, posted_jobs }

final jobsTabProvider = NotifierProvider<JobsTabNotifier, JobsTab>(JobsTabNotifier.new);

class JobsTabNotifier extends Notifier<JobsTab> {
  @override
  JobsTab build() => JobsTab.recommended;
  void update(JobsTab tab) => state = tab;
}

// Search and Filter State
class JobFilters {
  final String keyword;
  final String? experience;
  final String? location;
  final List<String> salaryRange;
  final List<String> industry;
  final bool remoteOnly;
  
  // New tab-specific filters
  final String applicationStatus;
  final String dateRange;
  final String savedFilter;
  final String postedJobFilter;

  JobFilters({
    this.keyword = '',
    this.experience,
    this.location,
    this.salaryRange = const [],
    this.industry = const [],
    this.remoteOnly = false,
    this.applicationStatus = 'All Statuses',
    this.dateRange = 'Last 30 Days',
    this.savedFilter = 'All Saved',
    this.postedJobFilter = 'All Jobs',
  });

  JobFilters copyWith({
    String? keyword,
    String? experience,
    String? location,
    List<String>? salaryRange,
    List<String>? industry,
    bool? remoteOnly,
    String? applicationStatus,
    String? dateRange,
    String? savedFilter,
    String? postedJobFilter,
  }) {
    return JobFilters(
      keyword: keyword ?? this.keyword,
      experience: experience ?? this.experience,
      location: location ?? this.location,
      salaryRange: salaryRange ?? this.salaryRange,
      industry: industry ?? this.industry,
      remoteOnly: remoteOnly ?? this.remoteOnly,
      applicationStatus: applicationStatus ?? this.applicationStatus,
      dateRange: dateRange ?? this.dateRange,
      savedFilter: savedFilter ?? this.savedFilter,
      postedJobFilter: postedJobFilter ?? this.postedJobFilter,
    );
  }
}

final jobFiltersProvider = NotifierProvider<JobFiltersNotifier, JobFilters>(JobFiltersNotifier.new);

class JobFiltersNotifier extends Notifier<JobFilters> {
  @override
  JobFilters build() => JobFilters();
  void update(JobFilters filters) => state = filters;
  void reset() => state = JobFilters();
}

// Mock Jobs Provider (will be replaced by API calls later)
final jobsListProvider = Provider<List<Job>>((ref) {
  // Return mock data for now
  return [
    Job(
      id: '1',
      title: 'Senior Frontend Developer',
      company: 'Google',
      location: 'Bangalore, India',
      salary: '₹25L - ₹35L per year',
      type: 'Full-time',
      icon: 'https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_92x30dp.png',
      description: 'We are looking for a Senior Frontend Developer to lead our next-generation web application team...',
      workMode: 'Hybrid',
      postedAgo: 'Posted 2 hours ago',
      applicantsCount: 156,
      isSaved: true,
      hasApplied: false,
    ),
    Job(
      id: '2',
      title: 'UI/UX Designer',
      company: 'Meta',
      location: 'Remote',
      salary: '₹15L - ₹25L per year',
      type: 'Contract',
      icon: 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7b/Meta_Platforms_Inc._logo.svg/200px-Meta_Platforms_Inc._logo.svg.png',
      description: 'Join our design team to create immersive experiences for millions of users worldwide...',
      workMode: 'Remote',
      postedAgo: 'Posted 5 hours ago',
      applicantsCount: 0,
      isSaved: false,
      hasApplied: true,
    ),
    Job(
      id: '3',
      title: 'Backend Engineer (Nest.js)',
      company: 'Eduprova',
      location: 'Chennai, India',
      salary: '₹12L - ₹18L per year',
      type: 'Full-time',
      icon: '', // Will use fallback
      description: 'Help us build the most advanced learning platform for students in India...',
      workMode: 'On-site',
      postedAgo: 'Posted 1 day ago',
      applicantsCount: 42,
      isSaved: false,
      hasApplied: false,
    ),
  ];
});

// Filtered Jobs Provider (Recommended)
final filteredJobsProvider = Provider<List<Job>>((ref) {
  final allJobs = ref.watch(jobsListProvider);
  final filters = ref.watch(jobFiltersProvider);
  
  return allJobs.where((job) {
    // Keyword filter
    if (filters.keyword.isNotEmpty && 
        !job.title.toLowerCase().contains(filters.keyword.toLowerCase()) &&
        !job.company.toLowerCase().contains(filters.keyword.toLowerCase())) {
      return false;
    }
    
    // Remote filter
    if (filters.remoteOnly && job.workMode != 'Remote') {
      return false;
    }
    
    // In a real app, we would filter by salaryRange and industry here
    
    return true;
  }).toList();
});

// Saved Jobs Provider
final savedJobsProvider = Provider<List<Job>>((ref) {
  final allJobs = ref.watch(jobsListProvider);
  final filters = ref.watch(jobFiltersProvider);
  
  var jobs = allJobs.where((job) => job.isSaved).toList();
  
  if (filters.savedFilter == 'Submitted') {
    return jobs.where((job) => job.hasApplied).toList();
  } else if (filters.savedFilter == 'Not Submitted') {
    return jobs.where((job) => !job.hasApplied).toList();
  }
  
  return jobs;
});

// Applied Jobs Provider
final appliedJobsProvider = Provider<List<Job>>((ref) {
  final allJobs = ref.watch(jobsListProvider);
  
  var jobs = allJobs.where((job) => job.hasApplied).toList();
  
  // In a real app, filter by applicationStatus and dateRange here
  
  return jobs;
});

// Posted Jobs Provider
final postedJobsProvider = Provider<List<Job>>((ref) {
  // For now, returning a mock list of posted jobs
  return [
    Job(
      id: 'p1',
      title: 'Senior Software Manager',
      company: 'Eduprova',
      location: 'Visakhapatnam',
      salary: '₹10,00,000 - ₹20,00,000 per year',
      type: 'Full-time',
      icon: '',
      description: 'A Senior Software Manager oversees multiple software teams...',
      workMode: 'On-site',
      postedAgo: 'Posted 3 days ago',
      applicantsCount: 1,
      isSaved: false,
      hasApplied: false,
    ),
  ];
});
