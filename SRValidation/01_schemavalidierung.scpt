#!/usr/bin/osascript
on run argv
  set BASEDIR to item 1 of argv as string
  tell application "iTerm2"
    # open first terminal start producer
    tell current session of current tab of current window
        write text "cd " & BASEDIR
        write text "bash ./01-1_avroproducer.sh"
        split horizontally with default profile
        split vertically with default profile
    end tell
    # open second terminal and start normal producer
    tell second session of current tab of current window
        write text "cd " & BASEDIR
        write text "bash ./01-2_normalproducer.sh"
    end tell
    # open third terminal and consumer 1
    tell third session of current tab of current window
        write text "cd " & BASEDIR
        write text "bash ./01-3_consumer.sh"
        split vertically with default profile
    end tell
    # open forth terminal consumer 2
    tell fourth session of current tab of current window
        write text "cd " & BASEDIR
        write text "bash ./01-3_consumer2.sh"
    end tell
  end tell
end run