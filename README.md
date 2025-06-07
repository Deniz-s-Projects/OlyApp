# OlyApp 📱

**Your Digital Companion for Life in Olydorf**

OlyApp is a mobile app built by and for residents of the Olympiadorf (Olydorf) in Munich. Whether you’re a newcomer or a long-time resident, OlyApp helps you stay connected, organized, and involved in the community.

---

## 🚀 Features

### ✅ Calendar
- View events, parties, meetings, and administrative deadlines.
- Events are synced from the server and admins can create new ones.
- Attendees can check in via QR code generated for each event.

### ✅ Item Exchange
- Browse items your neighbors are giving away or selling.
- Add new listings with images and chat with interested people.

### ✅ Maintenance Requests
- Submit issues in your room or building directly from the app.
- Attach photos, chat with admins and track ticket status.

### ✅ Directory
- Browse residents who opted in to be listed and start private chats.

### ✅ Map
- Interactive map of Olydorf with filterable pins and route planning.

### ✅ Transit
- Check upcoming departures and pin your favorite stops.

### ✅ Booking
- Reserve shared spaces and manage your bookings.

### ✅ Bulletin Board
- Post announcements or offers and comment on posts.

### ✅ Push Notifications
- Get notified about new events and important announcements.

### ✅ Admin Tools
- Manage events, maintenance tickets, bookings, pins and notifications.

---

## 🛠️ Tech Stack

- **Flutter** for cross-platform mobile development (Android + iOS)
- **Dart** as the main programming language
- Node.js / Express + MongoDB backend

---

## 📦 Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/DenizOzturk95/OlyApp
   cd olyapp
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

   To point the app at a different backend, pass a custom API URL:
   ```bash
   flutter run --dart-define=API_URL=https://prod.example.com
   ```

## 🧪 Running Tests

Install dependencies and run the unit tests:

```bash
flutter pub get
flutter analyze
flutter test
npm test
```

All tests live in the `test/` directory and are executed automatically in CI.
---

## 🖥️ Backend Server

The optional Node.js backend lives in the `server/` directory.

### Prerequisites

- **Node.js** installed (v18+ recommended)
- **MongoDB** running locally if you want persistent storage

### Setup

1. Install dependencies:
   ```bash
   cd server
   npm install
   ```

2. Copy the example environment file and adjust values if needed:
   ```bash
   cp .env.example .env
   ```
   This file sets `MONGODB_URI` and `PORT`. If no `MONGODB_URI` is provided,
   an in-memory database is used.

### Running

Start the server:
```bash
npm start
```

During development you can automatically restart on changes with:
```bash
npm run dev
```

When running the Flutter app, point it at this backend with:
```bash
flutter run --dart-define=API_URL=http://localhost:3000
```

### Backend Tests

Run server tests with:
```bash
cd server
npm install  # install dev dependencies like jest
npm test
```


## 📲 Coming Soon

- Will announce more features 

---

## 🤝 Community-Driven

OlyApp is built with feedback from Olydorf residents and managed by students who live here. Contributions, suggestions, and ideas are welcome!

---

## 📣 Contact

Questions? Ideas? Want to contribute?

Reach out to the team or open an issue on GitHub.

---

**Made with ❤️ in Olydorf**

![image](https://github.com/user-attachments/assets/f2c2701d-2c1c-44ef-940b-1acb52945c04)

