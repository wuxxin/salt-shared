
ubuntu-f10-fix:

mkdir -p ~/.config/gtk-3.0 
cat << EOF > ~/.config/gtk-3.0/gtk.css 
@binding-set NoKeyboardNavigation { 
     unbind "F10" 
} 

* { 
    gtk-key-bindings: NoKeyboardNavigation 
} 

EOF