{
  # Navigation
  ".." = "cd ..";
  "..." = "cd ../..";
  "...." = "cd ../../..";
  "....." = "cd ../../../..";

  # Git
  g = "git";
  ga = "git add";
  "ga." = "git add .";
  gc = "git commit -m \"";
  "gcan!" = "git commit --amend --no-edit";
  gcl = "git clone";
  gd = "git diff";
  gl = "git log --graph --oneline --all";
  gp = "git push";
  grc = "git rebase --continue";
  gs = "git status";

  # Nix & System
  ncg = "nix-collect-garbage -d";
  nd = "nix develop";
  nfu = "nix flake update";
  nhl = "nh os switch -n .";
  nopt = "nix-store --optimise";
  nr = "nix run";
  nrb = "git add . && nh os boot .";
  nrs = "git add . && nh os switch .";
  ns = "nix-shell -p";

  # Modern CLI
  cat = "bat";
  grep = "rg";
  ll = "eza -l --icons --group-directories-first --git";
  ls = "eza --icons --group-directories-first";
  lt = "eza --tree --icons --group-directories-first";
  top = "btop";
  v = "nvim";
  zed = "zeditor";

  # Productivity
  conf = "cd /home/zerg/.phoenix-conf";
  cp = "cp -iv";
  mkdir = "mkdir -p";
  mv = "mv -iv";
  path = "echo $PATH | tr ':' '\n'";
}
