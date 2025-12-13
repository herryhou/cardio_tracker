# Chart Carousel Feature Guide

## Overview

The chart carousel enhances the blood pressure visualization experience by providing an interactive, accessible, and user-friendly way to navigate between different chart views.

## Features

### 1. Page Indicators
- **What**: Smooth dot indicators at the bottom of the carousel
- **Purpose**: Shows current chart position and allows quick navigation
- **Appearance**: Expanding dots effect with theme colors

### 2. Chart Titles & Descriptions
- **What**: Clear titles and brief descriptions for each chart
- **Charts Available**:
  - **Trends**: Bar chart showing blood pressure over time
  - **Distribution**: Clinical scatter plot in AHA zones
- **Purpose**: Improves understanding of each chart's purpose

### 3. Swipe Hints
- **What**: Animated hint appearing on first app usage
- **Behavior**: Shows "Swipe to see more charts" with swipe icon
- **Persistence**: Remembers if user has seen the hint (via SharedPreferences)
- **Animation**: Slides right and fades in/out

### 4. Accessibility Features
- **Semantic Labels**: Screen reader announcements for chart changes
- **Navigation Hints**: Clear instructions for swipe navigation
- **Focus Management**: Proper focus handling for all interactive elements

## Usage Guide

### Basic Navigation
1. **Swipe Left/Right**: Navigate between charts
2. **Tap Dots**: Jump directly to a specific chart

### Time Range Selection
- The time range selector (Week/Month/Season/Year) applies to all charts
- Selected range persists across chart navigation

### Chart Interactions
- **Trends Chart**: Tap bars to see detailed readings
- **Distribution Chart**: Tap points for detailed information
- **Cross-chart Selection**: Selected reading persists when switching charts

## Technical Implementation

### Dependencies
- `smooth_page_indicator: ^1.1.0` - For page navigation dots
- `shared_preferences: ^2.2.2` - For storing hint visibility

### Key Components
- `HorizontalChartsContainer`: Main widget orchestrating the carousel
- `SwipeHint`: Animated hint widget
- Uses existing `BPRangeBarChart` and `InteractiveScatterPlot`

### Architecture Decisions
- **PageView.builder**: Efficient rendering with lazy loading
- **Widget tests**: Comprehensive test coverage for all features
- **Theme adaptation**: Respects light/dark theme settings

## Performance Considerations

- Only visible chart is fully rendered
- Hint animation stops after first interaction
- Efficient state management with Provider pattern

## Troubleshooting

### Swipe hint not showing?
- Only appears on first app launch
- Can be reset by clearing app data
- Manually controlled with `showSwipeHint` parameter

### Charts not loading?
- Verify BloodPressureProvider has data
- Check DatabaseService initialization
- Ensure filtered readings aren't empty