# KeepIPv6Alive

定期通过 ping6 / curl 检测 IPv6 连通性，确保 IPv6 地址不会因空闲而被回收。

> 适用场景：部分 ISP 或路由器在 IPv6 无流量一段时间后会回收地址或断开连接，本脚本通过周期性发包保持 IPv6 活跃。

## 工作原理

1. 每 60 秒通过指定网卡 (`enp8s0`) 向 `2400:3200::1`（阿里 DNS）发送 3 个 ping6 包
2. 若 ping6 失败，fallback 使用 curl 访问 `https://ipv6.ustc.edu.cn`（中科大 IPv6 测速站）
3. 所有结果写入日志 `ipv6_keepalive.log`（最大保留 500 行，超出后自动裁剪）

## 安装与部署

### 1. 克隆仓库

```bash
git clone https://github.com/University-Pro/KeepIPV6Alive.git
```

### 2. 调整配置（如需要）

编辑 [IPV6.sh](IPV6.sh)，按实际情况修改以下变量：

```bash
INTERFACE="enp8s0"          # 网卡名称
TARGET_PING="2400:3200::1"  # ping6 目标地址
TARGET_CURL="https://ipv6.ustc.edu.cn"  # curl 备选地址
```

### 3. 安装 systemd timer

```bash
sudo cp ipv6-keepalive.service /etc/systemd/system/
sudo cp ipv6-keepalive.timer  /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now ipv6-keepalive.timer
```

### 4. 验证运行状态

```bash
systemctl status ipv6-keepalive.timer
systemctl status ipv6-keepalive.service
tail -f /Disk/Local/NetworkKeepLive/ipv6_keepalive.log
```

## 文件说明

| 文件 | 说明 |
|------|------|
| [IPV6.sh](IPV6.sh) | 主脚本：ping6 + curl fallback |
| `ipv6-keepalive.service` | systemd oneshot 服务，调用脚本 |
| `ipv6-keepalive.timer` | systemd timer，每 60s 触发一次 |

## 定时策略

- 开机后 **30 秒** 首次触发
- 之后每隔 **60 秒** 执行一次
- `Persistent=true`：若错过触发时间（如关机期间），开机后立即补执行

## License

MIT
