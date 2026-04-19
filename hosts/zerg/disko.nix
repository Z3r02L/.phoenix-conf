{
  disko.devices = {
    disk = {
      # Примечание: замените на ваш реальный путь к диску, например /dev/nvme0n1 или /dev/sda
      device = "/dev/nvme0n1"; 
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "fmask=0077" "dmask=0077" ];
            };
          };
          luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "cryptroot";
              # Позволяет TRIM и быстрое шифрование работать через LUKS
              settings = {
                allowDiscards = true;
                bypassWorkqueues = true;
              };
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ]; # Принудительное форматирование
                subvolumes = {
                  "@root" = {
                    mountpoint = "/";
                    mountOptions = [ "compress=zstd:1" "noatime" "ssd" "discard=async" "commit=120" ];
                  };
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = [ "compress=zstd:1" "noatime" "ssd" "discard=async" "commit=120" ];
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [ "compress=zstd:1" "noatime" "ssd" "discard=async" "commit=120" ];
                  };
                  "@persist" = {
                    mountpoint = "/persist";
                    mountOptions = [ "compress=zstd:1" "noatime" "ssd" "discard=async" "commit=120" ];
                  };
                  "@snapshots" = {
                    mountpoint = "/snapshots";
                    mountOptions = [ "compress=zstd:1" "noatime" "ssd" "discard=async" "commit=120" ];
                  };
                  "@games" = {
                    mountpoint = "/games";
                    mountOptions = [ "compress=zstd:1" "noatime" "ssd" "discard=async" "commit=120" ];
                  };
                  "@cache" = {
                    mountpoint = "/var/cache";
                    mountOptions = [ "compress=zstd:1" "noatime" "ssd" "discard=async" "commit=120" ];
                  };
                  "@log" = {
                    mountpoint = "/var/log";
                    mountOptions = [ "compress=zstd:1" "noatime" "ssd" "discard=async" "commit=120" ];
                  };
                  "@tmp" = {
                    mountpoint = "/var/tmp";
                    mountOptions = [ "compress=zstd:1" "noatime" "ssd" "discard=async" "commit=120" ];
                  };
                  # Оптимизированные разделы без CoW
                  "@db" = {
                    mountpoint = "/var/lib/db";
                    mountOptions = [ "nodatacow" "noatime" "ssd" "discard=async" "commit=120" ];
                  };
                  "@docker" = {
                    mountpoint = "/var/lib/docker";
                    mountOptions = [ "nodatacow" "noatime" "ssd" "discard=async" "commit=120" ];
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
