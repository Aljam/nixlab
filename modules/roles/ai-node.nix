{ config, pkgs, domains, ... }:

{
  services.ollama = {
    enable = true;
  # acceleration = "cuda"; # Crucial: Tells Ollama to grab the Tesla P40s
    environmentVariables = {
      OLLAMA_HOST = "127.0.0.1:11434"; 
      OLLAMA_ORIGINS = "127.0.0.1"; 
    };
  };

  services.open-webui = {
    enable = true;
    port = 8085;
    environment = {
      OLLAMA_API_BASE_URL = "http://127.0.0.1:11434/api";
      WEBUI_AUTH = "True"; # Forces login so the internet can't chat with your GPUs for free
    };
  };
  
  environment.systemPackages = with pkgs; [
    nvtopPackages.full # Better GPU monitoring than standard nvidia-smi
    gpustat
  ];
}
