# TO DO - Productivity & Focus App 🚀

A comprehensive Task Management and Focus Timer application built with Flutter. This app helps users manage their daily tasks, schedule them via a calendar, and stay focused using an integrated countdown timer.

## ✨ Key Features

### 📝 Task Management
* **CRUD Operations:** Create, Read, Update, and Delete tasks easily.
* **Time Range:** Set specific **Start Time** and **End Time** for each task (AM/PM format).
* **Smart Logic:** Automatically handles cross-day tasks (e.g., 11:00 PM to 1:00 AM) by adjusting the date logic.
* **Urgency Indicators:** Visual cues (Red text & Warning icon) for overdue tasks that haven't been completed.

### 📅 Interactive Calendar
* View tasks organized by date.
* Add tasks directly to specific dates via the Calendar interface.
* Visual indicators for the currently selected day and today.

### ⏳ Smart Focus Timer
* **Integrated Workflow:** Select a task directly from the "Today's Tasks" dropdown within the Timer page.
* **Auto-Set Duration:** The timer automatically sets the duration based on the selected task's time range.
* **Manual Control:** Custom hours/minutes/seconds picker for manual timer setting.
* **Status Updates:** Displays "Focus: [Task Name]" while running.

## 🛠️ Tech Stack & Packages

* **Framework:** Flutter (Dart)
* **Database:** [Drift](https://pub.dev/packages/drift) (SQLite abstraction)
* **State Management:** [Provider](https://pub.dev/packages/provider)
* **Calendar:** [table_calendar](https://pub.dev/packages/table_calendar)
* **Date Formatting:** [intl](https://pub.dev/packages/intl)
* **Picker:** Flutter Cupertino Picker & Material Time Picker.

## 🚀 Getting Started

### Prerequisites
* Flutter SDK installed.
* Android Studio / VS Code.

### Installation

1.  **Clone the repository**
    ```bash
    git clone [https://github.com/Yunnifa/todo_app.git](https://github.com/Yunnifa/todo_app.git)
    ```

2.  **Install dependencies**
    ```bash
    flutter pub get
    ```

3.  **Generate Database Code** (Important!)
    Since this project uses Drift, you need to generate the database code before running:
    ```bash
    dart run build_runner build
    ```

4.  **Run the App**
    ```bash
    flutter run
    ```

---
made by yui and gemini
