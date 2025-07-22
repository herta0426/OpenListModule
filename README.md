# OpenListModule （Magisk/通用模块）

自动部署 OpenList 服务，支持本地 Web 管理、密码重置、自动守护。兼容 Magisk、KSU、APatch 等主流模块管理器。

## openlist 来源与协议

- openlist 官方仓库：[https://github.com/OpenListTeam/OpenList/](https://github.com/OpenListTeam/OpenList/)
- 最新 release 自动拉取，源码及编译方法见官方仓库和 release 页面。
- 本模块所有脚本及集成方法同样遵循 AGPL-3.0 协议。

## 使用方法

1. 在支持的模块管理器中安装本模块。
2. 模块会自动拉取 openlist 最新 release 二进制，无需手动下载。
3. 安装后重启设备，服务自动启动。

### 服务使用说明

- 访问 WebUI: `127.0.0.1:5244`
- 默认用户名: `admin`
- 首次使用建议：
  1. 在模块管理器界面点击三角形按钮重置密码
  2. 截图保存新密码或添加到密码管理器
  3. 密码文件位置：`/data/adb/OpenList/data/password.txt`
- 手动操作命令：
  - 重置密码：`sh <模块目录>/action.sh`
  - 查看服务状态：`sh <模块目录>/service.sh status`

## 注意事项

- 如自动拉取失败，请手动下载 openlist 二进制并放入 `OpenListModule/` 目录。
- 所有数据和日志均存储于 `/data/adb/OpenList` 下。
- 卸载时自动备份数据到 `/sdcard/Download/OPListModule_backup`。
- 密码重置、服务状态等操作可在模块管理器界面或命令行执行。

## 协议声明

本模块所有脚本及集成方法同样遵循 AGPL-3.0 协议。