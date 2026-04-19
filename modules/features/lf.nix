{
  inputs,
  lib,
  ...
}: let
  inherit (lib) getExe;
in {
  perSystem = { pkgs, ... }: let
    conf = pkgs.writeText "lf-config" ''
      set reverse true
      set preview true
      set hidden true
      set drawbox true
      set icons true
      set ignorecase true

      cmd drag-out %${getExe pkgs.ripdrag} -a -x "$fx"
      cmd editor-open $$EDITOR "$f"
      cmd edit-dir $$EDITOR .

      map . set hidden!
      map D delete
      map p paste
      map dd cut
      map y copy
      map \` mark-load
      map ' mark-load
      map <enter> open
      map a rename
      map r reload
      map C clear
      map U unselect

      map do drag-out

      map g~ cd
      map gh cd
      map g/ /
      map gd cd ~/Downloads
      map gt cd /tmp
      map gv cd ~/Videos
      map go cd ~/Documents
      map gc cd ~/.config
      map gn cd ~/nixconf
      map gp cd ~/Projects
      map gs cd ~/.local/share
      map gm cd /run/media

      map ee editor-open
      map e. edit-dir
      map V %${getExe pkgs.bat} --paging=always --theme=gruvbox "$f"

      map <C-d> 5j
      map <C-u> 5k

      setlocal ~/Projects sortby time
      setlocal ~/Projects/* sortby time
      setlocal ~/Downloads/ sortby time
    '';
  in {
    packages.lf = inputs.wrappers.lib.makeWrapper {
      inherit pkgs;
      package = pkgs.lf;
      flags = {
        "-config" = "${conf}";
      };
    };
  };
}
