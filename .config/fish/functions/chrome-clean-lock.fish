function chrome-clean-lock --description 'Remove Google Chrome singleton lock files'
    rm -f ~/.config/google-chrome/Singleton{Cookie,Lock,Socket}
end
