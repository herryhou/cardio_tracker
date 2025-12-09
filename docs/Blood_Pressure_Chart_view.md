### **Blood Pressure Monitor: Dual-Chart UI/UX Specification**

**Goal:** Provide users with both precise clinical categorization and clear temporal trends of their blood pressure data.

---

### **1. Data Model (Per Reading)**

Each recorded blood pressure reading object should minimally contain:

* `id`: Unique identifier
* `timestamp`: Date and time of the reading (e.g., ISO 8601 string)
* `systolic`: Integer mmHg value
* `diastolic`: Integer mmHg value
* `heartRate` (Optional): Integer bpm value
* `notes` (Optional): String text (medication, exercise, stress, etc.)
* `clinicalCategory`: (Computed by backend/app logic) Enum: `Normal`, `Elevated`, `Stage1`, `Stage2`

---

### **2. Core Components (Layout)**

The UI will feature two primary charts, optimally displayed in a vertical stack on a mobile screen, with the trend chart usually taking more vertical space.

* **Chart A: Clinical Scatter Plot (Top/Contextual)**
* **Chart B: Time-Series Line Chart (Bottom/Primary)**

---

### **3. Chart A: Clinical Scatter Plot (Sys/Dia Categorization)**

* **Type:** 2D Scatter Plot
* **Axes:**
    * **X-Axis:** Systolic Pressure (Range: e.g., 70 - 170 mmHg)
    * **Y-Axis:** Diastolic Pressure (Range: e.g., 50 - 120 mmHg)
* **Background Zones (Critical):**
    * Implement **Plot Bands / Range Annotations** to create distinct, color-filled rectangular zones on the chart background. These zones must precisely match the clinical definitions.
    * **Colors:** Use distinct, high-contrast colors for each zone (e.g., Green for Normal, Yellow for Elevated, Orange for Stage 1, Red for Stage 2/Crisis).
    * **Labeling:** Each zone should have a subtle text label indicating its category.
* **Data Points:**
    * Each (Systolic, Diastolic) pair from the user's history is plotted as a single dot.
    * **Dot Color:** The dot's color will match the background zone it falls into.
    * **Size/Opacity:** Consider slightly transparent dots to show density in clustered areas.
* **Interaction:**
    * **Tap/Long Press:** Tapping a dot should display a small tooltip showing the exact Sys/Dia values, timestamp, and highlight the corresponding day/reading on **Chart B**.
    * **Zoom/Pan:** Basic pinch-to-zoom and drag-to-pan should be supported for exploring clusters of readings.

---

### **4. Chart B: Time-Series Line Chart (Trend Analysis)**

* **Type:** Line Chart with two distinct lines.
* **Axes:**
    * **X-Axis:** Time (Dynamic based on selected view: Day/Week/Month/Season).
    * **Y-Axis:** Blood Pressure (mmHg, Range: e.g., 60 - 200 mmHg).
* **Lines:**
    * **Systolic Line:** Solid, distinct color (e.g., dark blue).
    * **Diastolic Line:** Dashed, distinct but related color (e.g., light blue/teal).
    * **Aggregation (for Month/Season views):** When zoomed out, aggregate multiple daily readings to a daily average or median. Apply curve smoothing for better trend visualization.
* **Data Points:**
    * Each day's reading (or aggregated point) has a small dot on both lines.
    * **Optional:** Implement the "dumbbell" connector (thin vertical line) between Sys and Dia points for fine-grained views (Day/Week).
* **Background (Optional):** Light, semi-transparent horizontal background zones based on **Systolic** thresholds can be included as a *very rough* visual aid, but emphasize that the dot color in Chart A is the true category.
* **Interaction:**
    * **Time Selector:** Segmented control or dropdown for `Day / Week / Month / Season` views.
    * **Tap/Long Press:** Tapping a specific day/reading on the line chart should display a tooltip with exact values, `clinicalCategory`, `heartRate`, `notes`, and **highlight the corresponding dot on Chart A**.
    * **Scroll/Swipe:** Horizontal scrolling for navigating through time.

---

### **5. Interactivity & Linking**

* **Critical Feature:** When a data point is selected/tapped on *either* Chart A or Chart B, the *corresponding* data point on the *other* chart must visually highlight (e.g., larger ring, pulse animation, or different color) to show the connection.
* **Tooltips:** Ensure tooltips provide comprehensive data for the selected point, including `clinicalCategory` and any notes.

---

### **6. Visual Design & Accessibility**

* **Color Palette:** Ensure colors are distinct, follow accessibility guidelines (WCAG 2.1 contrast), and are color-blind friendly (e.g., by also using patterns or shapes if possible).
* **Typography:** Clear, legible fonts for labels and values.
* **Responsiveness:** Charts must adapt gracefully to different screen sizes and orientations.
* **Performance:** Optimize rendering for smooth scrolling and interaction with large datasets.

---

This specification provides a clear roadmap for implementing a powerful and accurate blood pressure monitoring visualization.