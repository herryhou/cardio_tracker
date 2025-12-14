# CSV Editor Feature Design

## Overview
A full-screen CSV editor that allows users to view, edit, and replace all blood pressure readings in a single operation. The feature exports all readings as CSV, displays them in an inline text editor, validates changes, and atomically updates the database.

## Requirements
- Display all readings in CSV format within the app
- Allow free-form text editing of CSV data
- Comprehensive validation before database updates
- Last-update-wins conflict handling
- Support bulk replacement of all readings

## Architecture

### Data Flow
1. **Export Phase**:
   - Fetch all readings ordered by timestamp
   - Convert to CSV using existing `CsvExportService`
   - Display in editor widget

2. **Edit Phase**:
   - User edits CSV in text editor
   - Track dirty state for save button enablement
   - Auto-save draft to prevent data loss

3. **Import Phase**:
   - Parse CSV line-by-line with error collection
   - Validate all readings comprehensively
   - On success: atomic database replacement
   - On failure: show detailed errors without saving

### Components
- **CsvEditorScreen**: Full-screen modal with text editor
- **CsvImportService**: New service for CSV parsing and validation
- **ReadingValidator**: Implements all validation rules
- **CsvEditorProvider**: State management for editor

## UI/UX Design

### Layout
- Header with title and close button
- Scrollable text area with monospace font
- Line numbers in left margin
- Fixed header row for reference
- Status bar showing line count and reading count
- Bottom action bar with Cancel/Save buttons

### Visual Design
- Neumorphic theme matching app design
- Syntax highlighting for CSV columns
- Loading states during validation
- Error dialog with line-by-line issues
- Success confirmation dialog

### Features
- Undo/redo support
- Auto-save draft
- Keyboard shortcuts (Cmd/Ctrl+S)
- Zoom controls
- Confirmation before closing with unsaved changes

## Validation Rules

### Field-Level Validation
- **Date**: Valid ISO 8601 format, not future
- **Systolic**: 40-250 mmHg
- **Diastolic**: 30-180 mmHg
- **Heart Rate**: 20-220 bpm
- **Notes**: Optional, max 500 characters

### Cross-Field Validation
- Systolic ≥ Diastolic
- No duplicate timestamps
- Minimum 1 reading, maximum 10,000 readings
- Reasonable heart rate for BP values

### Error Handling
- Line-by-line error reporting
- Specific error messages
- Fix-and-retry workflow
- No database changes on validation failure

## Database Strategy

### Update Approach
- Single atomic transaction
- Delete all existing readings
- Batch insert new readings
- Auto rollback on errors
- Last-update-wins conflict resolution

### Performance
- Stream parsing for large CSVs
- Background validation
- Progress indicators
- Batch database operations

### Safety
- Backup creation before update
- Complete validation before changes
- Force restart after update
- Sync integration (mark for Cloudflare sync)

## Technical Implementation

### New Dependencies
- No new dependencies required (uses existing csv package)

### File Structure
```
lib/
├── infrastructure/
│   └── services/
│       ├── csv_export_service.dart (existing)
│       └── csv_import_service.dart (new)
├── presentation/
│   ├── screens/
│   │   └── csv_editor_screen.dart (new)
│   └── providers/
│       └── csv_editor_provider.dart (new)
└── core/
    └── validators/
        └── reading_validator.dart (new)
```

### Integration Points
- Modify DashboardScreen to add "Edit All" button
- Extend BloodPressureReadingRepository for batch operations
- Update CsvExportService if needed for consistency

## Future Enhancements
- Partial CSV updates (instead of full replacement)
- Real-time validation as user types
- CSV template downloads
- Import history and revert functionality
- Advanced conflict resolution UI