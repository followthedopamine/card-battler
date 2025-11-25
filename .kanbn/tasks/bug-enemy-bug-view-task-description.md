---
created: 2025-11-24T23:36:42.047Z
updated: 2025-11-24T23:36:57.402Z
assigned: ""
progress: 0
tags: []
---

# Bug: Enemy bug (view task description)

E 0:00:40:450   Enemy.gd:136 @ _on_action_timer_timeout(): Unable to start the timer because it's not inside the scene tree. Either add it or set autostart to true.
  <C++ Error>   Condition "!is_inside_tree()" is true.
  <C++ Source>  scene/main/timer.cpp:117 @ start()
  <Stack Trace> Enemy.gd:136 @ _on_action_timer_timeout()
