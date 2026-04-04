function fish_greeting
   nitch
end

function fish_prompt
    set_color $fish_color_cwd
    echo -n (prompt_pwd)
    set_color normal
    echo -n ' > '
end

fish_add_path /home/roah/.spicetify
