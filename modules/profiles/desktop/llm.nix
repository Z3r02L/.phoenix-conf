{ config, pkgs, lib, inputs, ... }:

let
  llm-agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  # ── LLM-инструменты ────────────────────────────────────────────────
  # Примечание: многие пакеты из llm-agents.nix не имеют гидраций
  # в кеше numtide и собираются локально. Оставлены только стабильные.
  environment.systemPackages = [
    llm-agents.opencode            # AI-ассистент для терминали
    llm-agents.claude-code-router  # Маршрутизатор к любым LLM-провайдерам
    llm-agents.cli-proxy-api       # Универсальный прокси

    # Следующие пакеты могут собираться локально (нет в кеше numtide):
    llm-agents.omp               # Multi-agent для opencode
    llm-agents.rtk               # Экономия токенов

    # CLI-клиенты (npm-based — всегда собираются локально):
    # llm-agents.qwen-code
    # llm-agents.gemini-cli
    # llm-agents.kilocode-cli
    # llm-agents.code
  ];

  # ── Переменные окружения ──────────────────────────────────────────
  # TODO: API-ключи будут загружаться из SOPS-секретов после настройки
  # Инструкция: см. SETUP.md
  environment.sessionVariables = {
    OLLAMA_HOST = "localhost:11434";
  };

  # ── Генерация конфигурационных файлов ─────────────────────────────
  # Шаблоны конфигов — заполните API ключи в environment.variables выше,
  # затем скопируйте конфиги в ~/.config/ вручную или через home-manager

  environment.etc."cli-proxy-api/config.yaml.example".text = ''
    # cli-proxy-api конфигурация
    # Документация: https://github.com/numtide/llm-agents.nix
    # Скопируйте в ~/.config/cli-proxy-api/config.yaml и заполните ключи
    # API-ключи загружаются из SOPS: /run/secrets/llm/

    server:
      host: 127.0.0.1
      port: 8317

    providers:
      - name: openai
        type: openai
        api_key: ""  # Загрузить из /run/secrets/llm/openai-api-key
        # base_url: http://localhost:11434/v1  # раскомментируйте для Ollama

      - name: anthropic
        type: anthropic
        api_key: ""  # Загрузить из /run/secrets/llm/anthropic-api-key

      - name: google
        type: google
        api_key: ""  # Загрузить из /run/secrets/llm/google-api-key

      # Локальная Ollama (без ключа)
      - name: ollama
        type: openai
        base_url: http://localhost:11434/v1
        api_key: ""
  '';

  environment.etc."claude-code-router/config.json.example".text = ''
    {
      "providers": {
        "openai": {
          "type": "openai",
          "api_key": "",  # Загрузить из /run/secrets/llm/openai-api-key
          "base_url": ""  # Загрузить из /run/secrets/llm/openai-base-url
        },
        "anthropic": {
          "type": "anthropic",
          "api_key": ""  # Загрузить из /run/secrets/llm/anthropic-api-key
        },
        "ollama": {
          "type": "openai",
          "base_url": "http://localhost:11434/v1",
          "api_key": ""
        }
      },
      "default_provider": "openai"
    }
  '';
}
