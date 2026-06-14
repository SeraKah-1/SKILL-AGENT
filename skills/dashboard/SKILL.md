# Token Monitor Dashboard Skill

This skill launches or checks the real-time cyberpunk token monitor web dashboard.

When the user runs `/dashboard` or `/token-monitor-dashboard`, you must:
1. Check if the dashboard server is already running (e.g. by checking if port 3000 is open or checking process list).
2. If it is not running, run the command `token-monitor-dashboard` in the background.
3. Inform the user that the dashboard is ready and active, and print the URL `http://localhost:3000` (or the correct port if it was started on another one) clearly so the user can open it in their browser.
