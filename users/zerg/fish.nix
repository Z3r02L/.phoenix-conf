{ config, pkgs, ... }:

{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      # Автозапуск Tmux
      if status is-interactive
      and not set -q TMUX
        exec tmux
      end

      set fish_greeting
      fish_vi_key_bindings
      starship init fish | source

      # Быстрое создание папки и переход в нее
      function mcd
        mkdir -p $argv
        cd $argv
      end

      # Умная распаковка архивов
      function extract
        if test -f $argv[1]
          switch $argv[1]
            case '*.tar.bz2'
              tar xjf $argv[1]
            case '*.tar.gz'
              tar xzf $argv[1]
            case '*.bz2'
              bunzip2 $argv[1]
            case '*.rar'
              unrar x $argv[1]
            case '*.gz'
              gunzip $argv[1]
            case '*.tar'
              tar xf $argv[1]
            case '*.tbz2'
              tar xjf $argv[1]
            case '*.tgp'
              tar xzf $argv[1]
            case '*.zip'
              unzip $argv[1]
            case '*.Z'
              uncompress $argv[1]
            case '*.7z'
              7z x $argv[1]
            case '*'
              echo "'$argv[1]' cannot be extracted via extract"
          end
        else
          echo "'$argv[1]' is not a valid file"
        end
      end

      # Yazi wrapper - выход в текущую директорию
      function yy
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        yazi $argv --cwd-file="$tmp"
        if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
          builtin cd -- "$cwd"
        end
        rm -f -- "$tmp"
      end

      # --- Видео-магия (FFmpeg) ---

      # Извлечь аудио из видео без потери качества
      function v-audio
        ffmpeg -i $argv[1] -vn -acodec copy $argv[1].m4a
      end

      # Конвертация в качественный GIF
      function v-gif
        set palette "/tmp/palette.png"
        set filters "fps=15,scale=480:-1:flags=lanczos"
        ffmpeg -v warning -i $argv[1] -vf "$filters,palettegen" -y $palette
        ffmpeg -v warning -i $argv[1] -i $palette -lavfi "$filters [x]; [x][1:v] paletteuse" -y $argv[2]
      end

      # Краткая информация о видеофайле
      function v-info
        ffprobe -v quiet -print_format json -show_format -show_streams $argv[1] | jq '.streams[] | select(.codec_type=="video") | {codec: .codec_name, width: .width, height: .height, fps: .avg_frame_rate}'
      end

      # Сжать видео для Telegram/Discord (цель ~8MB)
      function v-shrink
        ffmpeg -i $argv[1] -vcodec libx264 -crf 28 -preset faster -acodec mp3 -ab 128k $argv[1].small.mp4
      end
    '';
    shellAbbrs = import ./shell-aliases.nix;
  };
}
