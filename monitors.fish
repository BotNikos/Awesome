#!/bin/fish

if test $argv[1] = "mirror"
    xrandr --output $argv[3] --same-as $argv[2]

else if test $argv[1] = "right-of"
    xrandr --output $argv[3] --right-of $argv[2] --auto
else
    echo "wrong args"
end
