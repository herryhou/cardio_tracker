enum SyncState {
  idle,
  syncing,
  success,
  error,
}

class SyncStatus {
  final String id;
  final SyncState lastSyncState;
  final DateTime? lastSyncTime;
  final String? errorMessage;
  final int pendingReadingsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  SyncStatus({
    required this.id,
    required this.lastSyncState,
    this.lastSyncTime,
    this.errorMessage,
    required this.pendingReadingsCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SyncStatus.fromJson(Map<String, dynamic> json) {
    return SyncStatus(
      id: json['id'] as String,
      lastSyncState: SyncState.values.firstWhere(
        (e) => e.toString() == 'SyncState.${json['lastSyncState']}',
      ),
      lastSyncTime: json['lastSyncTime'] != null
          ? DateTime.parse(json['lastSyncTime'] as String)
          : null,
      errorMessage: json['errorMessage'] as String?,
      pendingReadingsCount: json['pendingReadingsCount'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lastSyncState': lastSyncState.toString().split('.').last,
      'lastSyncTime': lastSyncTime?.toIso8601String(),
      'errorMessage': errorMessage,
      'pendingReadingsCount': pendingReadingsCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  SyncStatus copyWith({
    String? id,
    SyncState? lastSyncState,
    DateTime? lastSyncTime,
    String? errorMessage,
    int? pendingReadingsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SyncStatus(
      id: id ?? this.id,
      lastSyncState: lastSyncState ?? this.lastSyncState,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      errorMessage: errorMessage ?? this.errorMessage,
      pendingReadingsCount: pendingReadingsCount ?? this.pendingReadingsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isSyncing => lastSyncState == SyncState.syncing;
  bool get needsSync => pendingReadingsCount > 0;
  bool get hasError => lastSyncState == SyncState.error;

  @override
  String toString() {
    return 'SyncStatus(id: $id, lastSyncState: $lastSyncState, lastSyncTime: $lastSyncTime, errorMessage: $errorMessage, pendingReadingsCount: $pendingReadingsCount, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SyncStatus &&
        other.id == id &&
        other.lastSyncState == lastSyncState &&
        other.lastSyncTime == lastSyncTime &&
        other.errorMessage == errorMessage &&
        other.pendingReadingsCount == pendingReadingsCount &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        lastSyncState.hashCode ^
        lastSyncTime.hashCode ^
        errorMessage.hashCode ^
        pendingReadingsCount.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}