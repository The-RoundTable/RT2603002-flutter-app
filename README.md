<h1 align="center">Driver Monitoring System (DMS)</h1>

<p align="center">
  A Flutter mobile application for driver monitoring, camera-based observation, and driving-risk event visualization.
</p>

<hr>

<h2>Overview</h2>

<p>
  The Driver Monitoring System is a Flutter-based application designed to provide a monitoring dashboard for driver-related events. It includes Supabase authentication, camera preview and frame capture, session management, and visual indicators for potential driving risks.
</p>

<blockquote>
  <strong>Development status:</strong> The supplied Flutter source currently uses simulated detection events. Camera frames are exposed separately, but a WebSocket connection to the AI backend was not present in the supplied <code>lib/</code> source.
</blockquote>

<h2>Features</h2>

<ul>
  <li><strong>Authentication:</strong> User registration and login with Supabase Auth.</li>
  <li><strong>Navigation:</strong> Authentication-aware routing with GoRouter.</li>
  <li><strong>Camera Preview:</strong> Camera preview using Flutter's camera package.</li>
  <li><strong>Frame Capture:</strong> Captures JPEG frames and exposes them as Base64-encoded strings through a Dart stream.</li>
  <li><strong>Monitoring Dashboard:</strong> Session status, risk gauge, recent events, and detection categories.</li>
  <li><strong>Demo Events:</strong> Simulated drowsiness, closed-eye, yawning, and head-pose events.</li>
  <li><strong>State Management:</strong> Riverpod providers for authentication, camera, and session state.</li>
  <li><strong>Dark UI:</strong> A dark dashboard interface with visual status indicators.</li>
</ul>

<h2>Tech Stack</h2>

<ul>
  <li>Flutter and Dart</li>
  <li>Riverpod for state management</li>
  <li>Supabase for authentication and profile lookup</li>
  <li>GoRouter for navigation</li>
  <li>Flutter Camera package for camera access and frame capture</li>
</ul>

<p>Refer to <code>pubspec.yaml</code> in the full repository for exact dependency versions.</p>

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

<p>
  Some directories, including <code>alerts</code>, <code>analytics</code>, <code>settings</code>, and <code>shared</code>, were placeholders in the supplied source snapshot.
</p>

<h2>Getting Started</h2>

<h3>Prerequisites</h3>

<ul>
  <li>Flutter SDK compatible with the project</li>
  <li>Android Studio or another configured Flutter development environment</li>
  <li>An Android emulator or physical device with camera support</li>
  <li>A Supabase project</li>
</ul>

<h3>1. Clone the Repository</h3>

<pre><code>git clone https://github.com/The-RoundTable/RT2603002-flutter-app.git
cd RT2603002-flutter-app</code></pre>

<h3>2. Configure Supabase</h3>

<p>Configure your Supabase project URL and publishable/anon key in:</p>

<pre><code>lib/core/constants/supabase_config.dart</code></pre>

<p>Follow the configuration approach already implemented in the project.</p>

<p>
  <strong>Security:</strong> Never place a Supabase <code>service_role</code> key or an <code>sb_secret_...</code> key in a Flutter application or commit it to GitHub. Client-side publishable/anon keys are intended to be public; protect user data with correctly configured Row Level Security (RLS) policies.
</p>

<h3>3. Install Dependencies</h3>

<p>Run this command from the project root, where <code>pubspec.yaml</code> is located:</p>

<pre><code>flutter pub get</code></pre>

<h3>4. Run the Application</h3>

<pre><code>flutter run</code></pre>

<h2>Supabase Configuration</h2>

<p>
  The supplied Dart source retrieves profile information from a <code>profiles</code> table using the authenticated user's ID. Ensure that your database schema and access policies match the application's implementation.
</p>

<p>
  Enable Row Level Security where appropriate and configure policies so authenticated users can access only the records they are authorized to access. Client-side filtering is not a substitute for database security.
</p>

<h2>Camera Permissions</h2>

<p>Verify that the necessary camera permissions are configured for each target platform.</p>

<p><strong>Android:</strong></p>

<pre><code>android/app/src/main/AndroidManifest.xml</code></pre>

<p>Verify that the required camera permission is declared.</p>

<p><strong>iOS:</strong></p>

<pre><code>ios/Runner/Info.plist</code></pre>

<p>Add an appropriate <code>NSCameraUsageDescription</code> entry.</p>

<h2>AI Backend Integration</h2>

<p>
  The current dashboard uses simulated events to demonstrate its interface. Camera frames are exposed separately as Base64-encoded JPEG data.
</p>

<p>To integrate the actual AI backend:</p>

<ol>
  <li>Configure the backend endpoint and connection protocol.</li>
  <li>Stream camera frames to the backend in the expected format.</li>
  <li>Receive and parse detection responses.</li>
  <li>Map responses to the application's event model.</li>
  <li>Update session state using actual backend results.</li>
  <li>Replace the mock event generator with backend-driven events.</li>
  <li>Implement connection error handling, reconnection, and session cleanup.</li>
  <li>Test detection latency and alert behavior on target devices.</li>
</ol>

<p>
  Until integration is complete, simulated dashboard events should not be treated as actual driver-risk detections.
</p>

<h2>Development</h2>

<p>The main state-management components in the supplied source include:</p>

<ul>
  <li><code>authProvider</code> — Authentication state</li>
  <li><code>authActionsProvider</code> — Authentication actions</li>
  <li><code>cameraProvider</code> — Camera lifecycle and frame capture</li>
  <li><code>sessionProvider</code> — Monitoring-session state and demo events</li>
</ul>

<p>Format the Dart code and run static analysis before submitting changes:</p>

<pre><code>dart format .
flutter analyze</code></pre>

<h2>Safety Disclaimer</h2>

<p>
  This project is a development prototype, not a certified driver-safety system. It must not replace attentive driving or be relied upon as the sole means of detecting unsafe driving behavior.
</p>

<h2>License</h2>

<p>
  No license file was included in the supplied source snapshot. Add a <code>LICENSE</code> file and update this section before distributing the project publicly.
</p>
