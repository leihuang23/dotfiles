{ config, pkgs, user, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
in

{
  home.username = user;
  home.homeDirectory = "/Users/${user}";
  home.stateVersion = "24.11";
  home.packages = with pkgs; [
    # cli i use constantly
    ripgrep   # fast search
    fd        # fast find
    fzf       # fuzzy finder
    jq        # json on the command line
    lazygit
    neovim
    zoxide    # smart cd (replaces omz 'z' plugin)
    # the font everything renders in
    nerd-fonts.hack
  ];
  fonts.fontconfig.enable = true;
  home.sessionVariables.EDITOR = "nvim";

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;      # ghost text from history
    syntaxHighlighting.enable = true;  # commands turn green when valid
    initContent = ''
      bindkey '^f' autosuggest-accept
      [[ -f ~/.zsh/extra.zsh ]] && source ~/.zsh/extra.zsh
    '';
    shellAliases = {
      ".." = "cd ..";
      add = "git add .";
      push = "git push";
      pull = "git pull";
      m = "git switch main";
      co = "codex --full-auto";
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$cmd_duration$line_break$character";
      character = {
        success_symbol = "[❯](purple)";
        error_symbol = "[❯](red)";
      };
      cmd_duration.format = "[$duration]($style) ";
    };
  };

  programs.git = {
    enable = true;
    settings.user = {
      name = "leihuang";
      email = "leihuang531@gmail.com";
    };
  };

  # Edit-in-place: the real file stays in my repo, ~/.config just points at it.
  home.file.".config/wezterm".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/wezterm";
  home.file.".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/nvim";
  home.file.".config/herdr".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/herdr";
  home.file.".zsh/extra.zsh".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.zsh/extra.zsh";
  home.file.".kimi-code/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.kimi-code/config.toml";
  home.file.".kimi-code/tui.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.kimi-code/tui.toml";
  home.file.".kimi-code/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.kimi-code/AGENTS.md";
  home.file.".local/bin/install-skill".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/bin/install-skill";

  home.file.".codex/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".config/opencode/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  # Grok loads global rules from ~/.grok/{AGENTS,Agents,Claude}.md
  home.file.".grok/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  # Kimi Code reads ~/.agents/AGENTS.md as generic cross-tool instructions.
  home.file.".agents/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  # RTK instructions SSOT (Codex init + agents that @include this file)
  home.file.".codex/RTK.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/RTK.md";
}
