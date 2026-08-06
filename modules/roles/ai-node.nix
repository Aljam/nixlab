{ config, pkgs, domains, ... }:

{
  # 1. Enable Ollama (The LLM Engine)
  services.ollama = {
    enable = true;
    # acceleration = "cuda"; # Crucial: Tells Ollama to grab the Tesla P40s
    
    # Allow Open WebUI and other local apps to communicate with the API
    environmentVariables = {
      OLLAMA_HOST = "0.0.0.0:11434"; 
      OLLAMA_ORIGINS = "*"; 
    };
  };

  # 2. Enable Open WebUI (The Frontend Interface)
  services.open-webui = {
    enable = true;
    port = 8085; # Binds WebUI to port 8085
    
    # Point the frontend directly to the local Ollama engine
    environment = {
      OLLAMA_API_BASE_URL = "http://127.0.0.1:11434/api";
      WEBUI_AUTH = "True"; # Forces login so the internet can't chat with your GPUs for free
    };
  };

  # 3. Open the Firewall for the Local Network and HAProxy
  networking.firewall.allowedTCPPorts = [ 
    11434 # Ollama API (useful if you want to connect cursor/vscode from navi)
    8085  # Open WebUI (for HAProxy to route to)
  ];
  
  # 4. Optional: Add some CLI tools for AI management
  environment.systemPackages = with pkgs; [
    nvtopPackages.full # Better GPU monitoring than standard nvidia-smi
    gpustat
  ];
}
