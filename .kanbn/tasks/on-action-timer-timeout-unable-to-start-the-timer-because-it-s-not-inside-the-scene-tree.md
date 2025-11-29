---
created: 2025-11-24T07:37:10.818Z
updated: 2025-11-28T03:02:18.782Z
assigned: ""
progress: 0
tags: []
completed: 2025-11-28T03:02:18.782Z
---

# on_action_timer_timeout(): Unable to start the timer because it's not inside the scene tree

E 0:01:24:326   Enemy.gd:132 @ _on_action_timer_timeout(): Unable to start the timer because it's not inside the scene tree. Either add it or set autostart to true.
  <C++ Error>   Condition "!is_inside_tree()" is true.
  <C++ Source>  scene/main/timer.cpp:117 @ start()
  <Stack Trace> Enemy.gd:132 @ _on_action_timer_timeout()
