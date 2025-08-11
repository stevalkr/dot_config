{
  dns = {
    rules = [
      {
        outbound = "any";
        server = "dns-direct";
      }
      {
        domain_suffix = [
          "crates.io"
          "fastly.net"
          "roblox.com"
          "rbxcdn.com"
          "cloudfront.net"
          "edgesuite.net"
          "akamai.net"
          "cachix.org"
          "cache.nixos.org"
        ];
        server = "dns-ipv4only";
      }
      {
        domain_suffix = "parsec.app";
        server = "dns-direct";
      }
      {
        domain_suffix = [
          "shanghaitech.edu.cn"
          "ieee.org"
        ];
        server = "dns-shanghaitech";
      }
      {
        clash_mode = "Direct";
        server = "dns-direct";
      }
      {
        clash_mode = "Global";
        server = "dns-proxy";
      }
    ];
    servers = [
      { address = "https://8.8.8.8/dns-query"; }
      { address = "https://8.8.4.4/dns-query"; }
      {
        address = "https://8.8.8.8/dns-query";
        strategy = "ipv4_only";
        tag = "dns-ipv4only";
      }
      {
        address = "https://8.8.8.8/dns-query";
        detour = "proxy";
        tag = "dns-proxy";
      }
      {
        address = "https://223.5.5.5/dns-query";
        detour = "direct";
        tag = "dns-direct";
      }
      {
        address = "local";
        detour = "direct";
        tag = "dns-shanghaitech";
      }
    ];
  };
  experimental = {
    clash_api = {
      access_control_allow_private_network = true;
      external_controller = "0.0.0.0:9090";
    };
  };
  inbounds = [
    {
      listen = "0.0.0.0";
      listen_port = 7892;
      tag = "mixed-in";
      type = "mixed";
    }
    {
      address = [
        "172.19.0.1/30"
        "fdfe:dcba:9876::1/126"
      ];
      auto_route = true;
      strict_route = true;
      tag = "tun-in";
      type = "tun";
    }
  ];
  outbounds = [
    {
      default = "cloudcone";
      outbounds = [
        "cloudcone"
        "racknerd"
        "direct"
      ];
      tag = "proxy";
      type = "selector";
    }
    {
      default = "cloudcone";
      outbounds = [
        "proxy"
        "direct"
        "cloudcone"
        "racknerd"
      ];
      tag = "openai";
      type = "selector";
    }
    {
      default = "cloudcone";
      outbounds = [
        "proxy"
        "direct"
        "cloudcone"
        "racknerd"
      ];
      tag = "reddit";
      type = "selector";
    }
    {
      default = "cloudcone";
      outbounds = [
        "proxy"
        "direct"
        "cloudcone"
        "racknerd"
      ];
      tag = "dazn & disney+ & netflix";
      type = "selector";
    }
    {
      multiplex = {
        enabled = true;
      };
      password = "{{ op://Private/Server-CloudCone/Proxy Password }}";
      server = "cc-proxy.ethero.xyz";
      server_port = 4433;
      tag = "cloudcone";
      tls = {
        enabled = true;
        server_name = "cc-proxy.ethero.xyz";
      };
      type = "trojan";
    }
    {
      multiplex = {
        enabled = true;
      };
      password = "{{ op://Private/Server-RackNerd/Proxy Password }}";
      server = "rn-proxy.ethero.xyz";
      server_port = 11443;
      tag = "racknerd";
      tls = {
        enabled = true;
        server_name = "rn-proxy.ethero.xyz";
      };
      type = "trojan";
    }
    {
      tag = "direct";
      type = "direct";
    }
  ];
  route = {
    auto_detect_interface = true;
    final = "proxy";
    rule_set = [
      {
        tag = "geoip-cn";
        type = "remote";
        url = "https://raw.githubusercontent.com/SagerNet/sing-geoip/rule-set/geoip-cn.srs";
      }
      {
        tag = "geosite-cn";
        type = "remote";
        url = "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-cn.srs";
      }
      {
        tag = "geosite-geolocation-cn";
        type = "remote";
        url = "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-geolocation-cn.srs";
      }
      {
        tag = "geosite-category-ads-all";
        type = "remote";
        url = "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-category-ads-all.srs";
      }
      {
        tag = "geosite-bilibili";
        type = "remote";
        url = "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-bilibili.srs";
      }
      {
        tag = "geosite-tencent";
        type = "remote";
        url = "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-tencent.srs";
      }
      {
        tag = "geosite-icloud";
        type = "remote";
        url = "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-icloud.srs";
      }
      {
        tag = "geosite-apple";
        type = "remote";
        url = "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-apple.srs";
      }
      {
        tag = "geosite-openai";
        type = "remote";
        url = "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-openai.srs";
      }
      {
        tag = "geosite-dazn";
        type = "remote";
        url = "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-dazn.srs";
      }
      {
        tag = "geosite-disney";
        type = "remote";
        url = "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-disney.srs";
      }
      {
        tag = "geosite-netflix";
        type = "remote";
        url = "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-netflix.srs";
      }
      {
        tag = "geosite-reddit";
        type = "remote";
        url = "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-reddit.srs";
      }
      {
        tag = "geosite-google";
        type = "remote";
        url = "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-google.srs";
      }
      {
        tag = "geosite-linkedin";
        type = "remote";
        url = "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-linkedin.srs";
      }
    ];
    rules = [
      { action = "sniff"; }
      {
        action = "hijack-dns";
        protocol = "dns";
      }
      {
        ip_is_private = true;
        outbound = "direct";
      }
      {
        clash_mode = "Direct";
        outbound = "direct";
      }
      {
        clash_mode = "Global";
        outbound = "proxy";
      }
      {
        action = "reject";
        rule_set = "geosite-category-ads-all";
      }
      {
        domain_suffix = [
          "docker.io"
          "docker.com"
          "sagernet.org"
        ];
        outbound = "proxy";
      }
      {
        domain_suffix = [
          "ieee.org"
          "github.io"
          "overleaf.com"
          "namesilo.com"
          "bitwarden.eu"
          "bitwarden.com"
          "notifymydevice.com"
        ];
        outbound = "direct";
      }
      {
        outbound = "proxy";
        rule_set = [
          "geosite-apple"
          "geosite-google"
          "geosite-linkedin"
        ];
      }
      {
        outbound = "openai";
        rule_set = "geosite-openai";
      }
      {
        outbound = "reddit";
        rule_set = "geosite-reddit";
      }
      {
        outbound = "dazn & disney+ & netflix";
        rule_set = [
          "geosite-dazn"
          "geosite-disney"
          "geosite-netflix"
        ];
      }
      {
        outbound = "direct";
        rule_set = [
          "geoip-cn"
          "geosite-cn"
          "geosite-geolocation-cn"
          "geosite-bilibili"
          "geosite-tencent"
          "geosite-icloud"
        ];
      }
    ];
  };
}
