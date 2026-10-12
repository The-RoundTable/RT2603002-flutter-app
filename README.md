<h1 align="center">Driver Monitoring System</h1>

<p align="center">
  <strong>A Flutter-based application for driver behavior monitoring and driving-risk visualization.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-Mobile%20App-02569B?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-Language-0175C2?logo=dart" alt="Dart">
  <img src="https://img.shields.io/badge/Supabase-Authentication-3FCF8E?logo=supabase" alt="Supabase">
  <img src="https://img.shields.io/badge/Status-In%20Development-orange" alt="Project Status">
</p>

---

<h2>About the Project</h2>

<p>
  The Driver Monitoring System (DMS) is a mobile application built with Flutter to provide a dashboard for monitoring driver behavior and visualizing potential driving risks. It combines camera access, user authentication, session management, and event-based monitoring into a single interface.
</p>

<p>
  The application is designed to support integration with an AI-powered backend that can analyze camera frames and identify indicators such as drowsiness, prolonged eye closure, yawning, and head-position changes.
</p>

<h2>Features</h2>

<ul>
  <li><strong>User Authentication:</strong> Secure sign-up and login using Supabase Auth.</li>
  <li><strong>Camera Preview:</strong> Access to the device camera for driver monitoring.</li>
  <li><strong>Frame Capture:</strong> Captures JPEG frames and exposes them as Base64-encoded data.</li>
  <li><strong>Monitoring Dashboard:</strong> Displays monitoring status, risk indicators, and recent events.</li>
  <li><strong>Risk Visualization:</strong> A gauge and status cards for presenting monitoring information.</li>
  <li><strong>Event Categories:</strong> Supports dashboard event types for drowsiness, closed eyes, yawning, and head pose.</li>
  <li><strong>State Management:</strong> Riverpod manages authentication, camera, and session state.</li>
  <li><strong>Navigation:</strong> GoRouter handles application navigation and authentication-based routing.</li>
</ul>

<h2>Technology Stack</h2>

<table>
  <tr>
    <th>Technology</th>
    <th>Purpose</th>
  </tr>
  <tr>
    <td>Flutter</td>
    <td>Cross-platform mobile application development</td>
  </tr>
  <tr>
    <td>Dart</td>
    <td>Application programming language</td>
  </tr>
  <tr>
    <td>Riverpod</td>
    <td>State management</td>
  </tr>
  <tr>
    <td>Supabase</td>
    <td>User authentication and profile data</td>
  </tr>
  <tr>
    <td>GoRouter</td>
    <td>Application routing and navigation</td>
  </tr>
  <tr>
    <td>Camera</td>
    <td>Camera preview and frame capture</td>
  </tr>
</table>

<h2>Project Structure</h2>

<pre>
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   │   └── supabase_config.dart
│   ├── models/
│   │   └── user_model.dart
│   ├── router/
│   │   └── app_router.dart
│   ├── services/
│   │   └── camera_service.dart
│   └── theme/
│       └── apptheme.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   └── auth_repository.dart
│   │   ├── presentation/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   └── providers/
│   │       └── auth_provider.dart
│   ├── dashboard/
│   │   ├── presentation/
│   │   │   └── dashboard_screen.dart
│   │   ├── providers/
│   │   │   ├── camera_provider.dart
│   │   │   ├── session_provider.dart
│   │   │   └── user_providers.dart
│   │   └── widgets/
│   │       ├── camera_preview_widget.dart
│   │       ├── recent_events_ticker.dart
│   │       ├── risk_gauge.dart
│   │       ├── session_button.dart
│   │       └── status_cards_grid.dart
│   ├── alerts/
│   ├── analytics/
│   ├── settings/
│   └── splash/
│       └── presentation/
│           └── splash_screen.dart
└── shared/
</pre>

<h2>Getting Started</h2>

<h3>Prerequisites</h3>

<ul>
  <li>Flutter SDK</li>
  <li>Dart SDK compatible with the project</li>
  <li>Android Studio or another configured Flutter development environment</li>
  <li>An Android emulator or physical device with camera support</li>
  <li>A Supabase project</li>
</ul>

<h3>1. Clone the Repository</h3>

<pre><code>git clone https://github.com/The-RoundTable/RT2603002-flutter-app.git
cd RT2603002-flutter-app</code></pre>

<h3>2. Configure Supabase</h3>

<p>
  Configure your Supabase project URL and publishable/anon key in the application's Supabase configuration.
</p>

<p>
  Keep secret server-side credentials out of the mobile application and source control. Supabase client-side keys are public by design; database access must be protected using appropriate Row Level Security (RLS) policies.
</p>

<h3>3. Install Dependencies</h3>

<pre><code>flutter pub get</code></pre>

<h3>4. Run the Application</h3>

<pre><code>flutter run</code></pre>

<p>Run Flutter commands from the project root directory.</p>

<h2>AI Backend Integration</h2>

<p>
  The monitoring dashboard currently uses simulated detection events to demonstrate its interface. Camera frame capture is implemented separately, and integration with the AI detection backend is a planned development step.
</p>

<p>The intended integration workflow is:</p>

<ol>
  <li>Capture frames from the device camera.</li>
  <li>Transmit frames to the AI backend using the agreed communication protocol.</li>
  <li>Receive and parse driver-monitoring results.</li>
  <li>Update the dashboard with actual detection events and risk indicators.</li>
  <li>Handle connection failures, reconnection, and monitoring-session cleanup.</li>
</ol>

<h2>Security</h2>

<ul>
  <li>Use Supabase Row Level Security to restrict access to user-specific records.</li>
  <li>Never expose service-role keys or other server-side secrets in the mobile app.</li>
  <li>Validate and authorize backend requests independently of the Flutter client.</li>
  <li>Request only the device permissions required by the application.</li>
</ul>

<h2>Development</h2>

<p>To format the code and run static analysis:</p>

<pre><code>dart format .
flutter analyze</code></pre>

<h2>Disclaimer</h2>

<p>
  This project is under development and is intended for demonstration and development purposes. It is not a certified driver-safety system and should not replace attentive driving or be relied upon as the sole means of detecting unsafe driving behavior.
</p>

<h2>License</h2>

<p>
  Add a <code>LICENSE</code> file to specify the terms under which this project may be used, modified, and distributed.
</p>

<hr>

<p align="center">
  <sub>Built with Flutter and Dart.</sub>
</p>
