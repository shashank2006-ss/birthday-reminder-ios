# 🎂 Birthday Reminder - iOS App (SwiftUI)

A modern, native iOS application built with **Swift 5.10 / Swift 6** and **SwiftUI**. Designed for iPhone and iPad, featuring an interactive calendar, rich lock-screen notifications, exact-time reminders, and multi-platform automated wish dispatching via **WhatsApp**, **SMS / iMessage**, and **Telegram**.

---

## 🌟 Key Features

1. **Native SwiftUI (iOS Human Interface Guidelines)**:
   - Dynamic cards with countdown badges (*"Today! 🎉"*, *"Tomorrow"*, *"In 5 days"*), turning age, and platform indicators.
   - Clean SF Symbols iconography, native system forms, and light/dark mode support.
   - Instant search by name, phone number, or date.

2. **Interactive Calendar View**:
   - Monthly grid with highlighted dots on days that have birthdays.
   - Tap any day to inspect all birthdays on that date with an instant **"Send Wish"** button.
   - Smooth month-to-month navigation (`<` and `>`).

3. **Scheduled Date & Exact Time (UserNotifications)**:
   - Configure the exact reminder/send time (e.g., 00:00 midnight or 09:30 AM).
   - Powered by iOS `UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)`:
     - Triggers on the exact date and minute.
     - Automatically recurs every year without manual rescheduling.
     - Lock-screen rich notification with **"🚀 Send Now"** and **"✏️ Edit & Send"** action buttons.

4. **Multi-Platform Messaging Engine**:
   - **WhatsApp**: Directly opens WhatsApp with the contact and pre-populates your custom message for an effortless 1-tap send (`whatsapp://send?phone=...&text=...`).
   - **SMS / iMessage**: Features both native URL launch (`sms:...`) and in-app `MFMessageComposeViewController` sheet so you can send SMS without leaving the app.
   - **Telegram**: Launches directly into Telegram chat via handle or URL share (`tg://resolve?domain=...`).

5. **Review & Edit Before Sending**:
   - When the scheduled notification fires:
     - Tap **"🚀 Send Now"** to trigger immediate delivery.
     - Tap **"✏️ Edit & Send"** (or tap the card in-app) to open the live message editor, customize your wish, and then send.
   - 4 built-in quick templates: *Classic*, *Funny*, *Heartfelt*, and *Short*.

6. **Unlimited Contacts**:
   - Store unlimited friends and family with offline persistence (`UserDefaults` + Codable JSON).
   - Toggle individual notifications on/off with swipe actions.

---

## 📂 Project Structure

```text
birthday-reminder-ios/
├── BirthdayReminder.xcodeproj/     # Xcode Project (Open directly in Xcode)
│   └── project.pbxproj
├── BirthdayReminder/
│   ├── BirthdayReminderApp.swift   # @main App entry point & Notification setup
│   ├── Info.plist                  # URL Schemes (whatsapp, tg, sms)
│   ├── Models/
│   │   ├── Person.swift            # Contact model & date arithmetic
│   │   └── SocialPlatform.swift    # WhatsApp, SMS, Telegram enums & colors
│   ├── Services/
│   │   ├── BirthdayStore.swift     # Persistent storage & state management
│   │   ├── NotificationManager.swift # UserNotifications scheduling & actions
│   │   └── MessagingManager.swift  # WhatsApp, SMS, Telegram URL schemes
│   ├── Views/
│   │   ├── ContentView.swift       # TabView (Upcoming vs Calendar)
│   │   ├── UpcomingListView.swift  # Searchable contact list
│   │   └── Components/
│   │       ├── PersonCardView.swift       # Modern contact card
│   │       ├── QuickSendSheet.swift       # Live message editor & sender
│   │       ├── AddEditPersonSheet.swift   # Add/Edit form sheet
│   │       ├── CalendarMonthView.swift    # Interactive month grid
│   │       └── MessageComposeView.swift   # In-app SMS composer
│   └── Resources/
│       └── Assets.xcassets         # AppIcon & AccentColor
├── .github/workflows/
│   └── build-ios.yml               # GitHub Actions CI workflow
└── README.md
```

---

## 🛠️ How to Run & Build on Mac

### Step 1: Open in Xcode
1. Double-click [`BirthdayReminder.xcodeproj`](file:///Users/shashanksingh/.gemini/antigravity/scratch/birthday-reminder-ios/BirthdayReminder.xcodeproj) or run in terminal:
   ```bash
   open /Users/shashanksingh/.gemini/antigravity/scratch/birthday-reminder-ios/BirthdayReminder.xcodeproj
   ```
2. In the top bar of Xcode, select your **Target Device** (e.g. *iPhone 15 Pro Simulator* or your connected physical iPhone).
3. Press **`Cmd + R`** (or click the **Play** button) to build and run!

### Step 2: Push to GitHub (@shashank2006-ss)
To push this project to your GitHub repository:
```bash
cd /Users/shashanksingh/.gemini/antigravity/scratch/birthday-reminder-ios
git init
git add .
git commit -m "Initial commit of Birthday Reminder iOS app"
git remote add origin https://github.com/shashank2006-ss/birthday-reminder-ios.git
git branch -M main
git push -u origin main
```
*Note: Make sure to first create the empty repository `birthday-reminder-ios` at [github.com/new](https://github.com/new).*

Once pushed, the GitHub Actions workflow in `.github/workflows/build-ios.yml` will automatically build the app in the cloud on macOS runners!

---

## 📱 Permissions on iOS

When you first open the app on your device:
1. Tap **"Allow"** when prompted for **Notifications**. This enables the app to schedule local exact-minute alarms and show lock-screen action buttons (*"Send Now"* / *"Edit & Send"*).
