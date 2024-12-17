function ll --wraps=ls --wraps='ls -la' --wraps='ls -l' --description 'alias ll ls -l'
  ls -l $argv
        
end
