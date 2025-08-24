{
  "dns": {
    "servers": [
      { "address": "https://8.8.8.8/dns-query" },
      { "address": "https://8.8.4.4/dns-query" },
      {
        "tag": "dns-ipv4only",
        "address": "https://8.8.8.8/dns-query",
        "strategy": "ipv4_only"
      },
      {
        "tag": "dns-proxy",
        "address": "https://8.8.8.8/dns-query",
        "detour": "proxy"
      },
      {
        "tag": "dns-direct",
        "address": "https://223.5.5.5/dns-query",
        "detour": "direct"
      },
      {
        "tag": "dns-local",
        "address": "local",
        "detour": "direct"
      }
    ],
    "rules": [
      {
        "outbound": "any",
        "server": "dns-direct"
      },
      {
        "domain_suffix": [
          "crates.io",
          "fastly.net",
          "roblox.com",
          "rbxcdn.com",
          "cloudfront.net",
          "edgesuite.net",
          "akamai.net",
          "cachix.org",
          "cache.nixos.org"
        ],
        "server": "dns-ipv4only"
      },
      {
        "domain_suffix": "parsec.app",
        "server": "dns-direct"
      },
      {
        "domain_suffix": [
          "shanghaitech.edu.cn",
          "ieee.org"
        ],
        "server": "dns-local"
      },
      {
        "clash_mode": "Direct",
        "server": "dns-direct"
      },
      {
        "clash_mode": "Global",
        "server": "dns-proxy"
      }
    ]
  },
  "inbounds": [
    {
      "type": "mixed",
      "tag": "mixed-in",
      "listen": "0.0.0.0",
      "listen_port": 7892
    },
    {
      "type": "tun",
      "tag": "tun-in",
      "address": [
        "172.19.0.1/30",
        "fdfe:dcba:9876::1/126"
      ],
      "auto_route": true,
      "strict_route": true
    }
  ],
  "outbounds": [
    {
      "type": "selector",
      "tag": "proxy",
      "outbounds": [
        "cloudcone",
        "racknerd",
        "direct"
      ],
      "default": "cloudcone"
    },
    {
      "type": "selector",
      "tag": "openai",
      "outbounds": [
        "proxy",
        "direct",
        "cloudcone",
        "racknerd"
      ],
      "default": "cloudcone"
    },
    {
      "type": "selector",
      "tag": "reddit",
      "outbounds": [
        "proxy",
        "direct",
        "cloudcone",
        "racknerd"
      ],
      "default": "cloudcone"
    },
    {
      "type": "selector",
      "tag": "dazn & disney+ & netflix",
      "outbounds": [
        "proxy",
        "direct",
        "cloudcone",
        "racknerd"
      ],
      "default": "cloudcone"
    },
    {
      "type": "trojan",
      "tag": "cloudcone",
      "server": "cc-proxy.ethero.xyz",
      "server_port": 4433,
      "password": "{{ op://Private/Server-CloudCone/Proxy Password }}",
      "tls": {
        "enabled": true,
        "server_name": "cc-proxy.ethero.xyz"
      },
      "multiplex": {
        "enabled": true
      }
    },
    {
      "type": "trojan",
      "tag": "racknerd",
      "server": "rn-proxy.ethero.xyz",
      "server_port": 11443,
      "password": "{{ op://Private/Server-RackNerd/Proxy Password }}",
      "tls": {
        "enabled": true,
        "server_name": "rn-proxy.ethero.xyz"
      },
      "multiplex": {
        "enabled": true
      }
    },
    {
      "type": "direct",
      "tag": "direct"
    }
  ],
  "route": {
    "rules": [
      {
        "action": "sniff"
      },
      {
        "protocol": "dns",
        "action": "hijack-dns"
      },
      {
        "ip_is_private": true,
        "outbound": "direct"
      },
      {
        "clash_mode": "Direct",
        "outbound": "direct"
      },
      {
        "clash_mode": "Global",
        "outbound": "proxy"
      },
      {
        "rule_set": "geosite-category-ads-all",
        "action": "reject"
      },
      {
        "domain_suffix": [
          "docker.io",
          "docker.com",
          "sagernet.org"
        ],
        "outbound": "proxy"
      },
      {
        "domain_suffix": [
          "ieee.org",
          "github.io",
          "overleaf.com",
          "namesilo.com",
          "bitwarden.eu",
          "bitwarden.com",
          "notifymydevice.com"
        ],
        "outbound": "direct"
      },
      {
        "rule_set": [
          "geosite-apple",
          "geosite-google",
          "geosite-linkedin"
        ],
        "outbound": "proxy"
      },
      {
        "rule_set": "geosite-openai",
        "outbound": "openai"
      },
      {
        "rule_set": "geosite-reddit",
        "outbound": "reddit"
      },
      {
        "rule_set": [
          "geosite-dazn",
          "geosite-disney",
          "geosite-netflix"
        ],
        "outbound": "dazn & disney+ & netflix"
      },
      {
        "rule_set": [
          "geoip-cn",
          "geosite-cn",
          "geosite-geolocation-cn",
          "geosite-bilibili",
          "geosite-tencent",
          "geosite-icloud"
        ],
        "outbound": "direct"
      }
    ],
    "rule_set": [
      {
        "type": "remote",
        "tag": "geoip-cn",
        "format": "binary",
        "url": "https://raw.githubusercontent.com/SagerNet/sing-geoip/rule-set/geoip-cn.srs"
      },
      {
        "type": "remote",
        "tag": "geosite-cn",
        "format": "binary",
        "url": "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-cn.srs"
      },
      {
        "type": "remote",
        "tag": "geosite-geolocation-cn",
        "format": "binary",
        "url": "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-geolocation-cn.srs"
      },
      {
        "type": "remote",
        "tag": "geosite-category-ads-all",
        "format": "binary",
        "url": "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-category-ads-all.srs"
      },
      {
        "type": "remote",
        "tag": "geosite-bilibili",
        "format": "binary",
        "url": "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-bilibili.srs"
      },
      {
        "type": "remote",
        "tag": "geosite-tencent",
        "format": "binary",
        "url": "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-tencent.srs"
      },
      {
        "type": "remote",
        "tag": "geosite-icloud",
        "format": "binary",
        "url": "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-icloud.srs"
      },
      {
        "type": "remote",
        "tag": "geosite-apple",
        "format": "binary",
        "url": "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-apple.srs"
      },
      {
        "type": "remote",
        "tag": "geosite-openai",
        "format": "binary",
        "url": "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-openai.srs"
      },
      {
        "type": "remote",
        "tag": "geosite-dazn",
        "format": "binary",
        "url": "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-dazn.srs"
      },
      {
        "type": "remote",
        "tag": "geosite-disney",
        "format": "binary",
        "url": "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-disney.srs"
      },
      {
        "type": "remote",
        "tag": "geosite-netflix",
        "format": "binary",
        "url": "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-netflix.srs"
      },
      {
        "type": "remote",
        "tag": "geosite-reddit",
        "format": "binary",
        "url": "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-reddit.srs"
      },
      {
        "type": "remote",
        "tag": "geosite-google",
        "format": "binary",
        "url": "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-google.srs"
      },
      {
        "type": "remote",
        "tag": "geosite-linkedin",
        "format": "binary",
        "url": "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-linkedin.srs"
      }
    ],
    "final": "proxy",
    "auto_detect_interface": true
  },
  "experimental": {
    "clash_api": {
      "external_controller": "127.0.0.1:9090",
      "access_control_allow_private_network": true
    }
  }
}
