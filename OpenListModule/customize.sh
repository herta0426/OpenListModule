#!/sbin/sh
SKIPUNZIP=0

# 变量定义，便于维护
BIN_NAME="openlist"
DATA_DIR="/data/adb/OpenList"
DATA_STORE_DIR="$DATA_DIR/data"
PASSWORD_FILE="$DATA_STORE_DIR/password.txt"

# 日志规范化
LOG_DIR="$DATA_DIR/logs"
mkdir -p "$LOG_DIR"
chmod 0700 "$LOG_DIR"
LOG_FILE="$LOG_DIR/install.log"
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] customize.sh: $*" >> "$LOG_FILE"
}

install_module() {
    log "开始安装"
    ui_print " "
    ui_print "******************************"
    ui_print "   OpenList 服务安装中...  "
    ui_print "******************************"
    
    # 核心文件检查
    ui_print "- 检查核心文件..."
    log "检查核心文件"

    # 1. OpenList 可执行文件检查
    if [ -f "$MODPATH/$BIN_NAME" ]; then
        chmod 0755 "$MODPATH/$BIN_NAME"
        ui_print "- 设置 $BIN_NAME 可执行权限"
        log "设置 $BIN_NAME 可执行权限"
    else
        ui_print "! 错误: 未找到 $BIN_NAME 可执行文件"
        log "未找到 $BIN_NAME 可执行文件，安装失败"
        abort "安装失败: 缺少 $BIN_NAME 可执行文件"
    fi
    
    # 2. service.sh 服务脚本检查
    if [ -f "$MODPATH/service.sh" ]; then
        chmod 0755 "$MODPATH/service.sh"
        ui_print "- 设置 service.sh 可执行权限"
        log "设置 service.sh 可执行权限"
    else
        ui_print "! 警告: 未找到 service.sh 服务脚本"
        log "未找到 service.sh 服务脚本"
    fi
    
    # 3. action.sh 操作脚本检查
    if [ -f "$MODPATH/action.sh" ]; then
        chmod 0755 "$MODPATH/action.sh"
        ui_print "- 设置 action.sh 可执行权限"
        log "设置 action.sh 可执行权限"
    else
        ui_print "! 警告: 未找到 action.sh 操作脚本"
        log "未找到 action.sh 操作脚本"
    fi
    
    # 创建数据目录结构
    ui_print "- 创建数据目录结构..."
    mkdir -p "$DATA_STORE_DIR"
    chmod 0755 "$DATA_DIR" "$DATA_STORE_DIR"
    ui_print "  - 主目录: $DATA_DIR"
    ui_print "  - 数据存储目录: $DATA_STORE_DIR"
    log "创建数据目录结构 $DATA_STORE_DIR"
    
    # 完成提示
    ui_print " "
    ui_print "✅ 安装成功!"
    log "安装完成"
    ui_print " "
    ui_print "使用说明:"
    ui_print "1. 重启设备使服务生效"
    ui_print "2. 访问 WebUI: 127.0.0.1:5244"
    ui_print "3. 用户名: admin"
    ui_print "4. 首次使用:"
    ui_print "   a. 在Magisk模块界面点击三角形按钮重置密码"
    ui_print "   b. 截图保存密码或添加到密码管理器"
    ui_print "   c. 密码文件位置: $PASSWORD_FILE"
    ui_print "5. 手动操作:"
    ui_print "   - 重置密码: sh $MODPATH/action.sh"
    ui_print "   - 查看状态: sh $MODPATH/service.sh status"
    ui_print " "
    
    # 添加重启提示
    ui_print "⚠️ 请重启设备以启动服务"
    ui_print " "
}

# 执行安装
install_module