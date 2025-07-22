#!/system/bin/sh
# 模块初始化
MODDIR=${0%/*}
MODULE_NAME="OpenListModule"           # 日志/显示用
BINARY_NAME="openlist"           # 二进制文件名小写
MODULE_PROP="$MODDIR/module.prop"
LOG_DIR="/data/adb/OpenList/logs"
mkdir -p "$LOG_DIR"
chmod 0700 "$LOG_DIR"
LOG_FILE="$LOG_DIR/service.log"

# 配置路径
DATA_DIR="/data/adb/OpenList"
BINARY="$MODDIR/$BINARY_NAME"
PID_FILE="$MODDIR/$BINARY_NAME.pid"

# 标准化日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $MODULE_NAME:" "$@" >> "$LOG_FILE"
}

# 模块状态更新
update_module_status() {
    local status="$1" message="$2"
    [ ! -f "$MODULE_PROP" ] && return
    
    # 保留原有配置，只更新description
    grep -v '^description=' "$MODULE_PROP" > "${MODULE_PROP}.tmp"
    echo "description=$status | $message" >> "${MODULE_PROP}.tmp"
    mv -f "${MODULE_PROP}.tmp" "$MODULE_PROP"
    
    # 通知Magisk刷新
    touch "$MODDIR/auto_mount"
}

# 二进制文件准备
prepare_binary() {
    # 设置可执行权限（安全方式）
    if [ ! -x "$BINARY" ]; then
        chmod 0755 "$BINARY" >/dev/null 2>&1 || {
            log "错误: 无法设置可执行权限 - $BINARY"
            return 1
        }
    fi
    
    # 验证可执行权限
    if [ ! -x "$BINARY" ]; then
        log "错误: 二进制文件不可执行 - $BINARY"
        update_module_status "❌ 错误" "二进制文件不可执行"
        return 1
    fi
    return 0
}

# 等待系统完全启动
wait_for_system() {
    log "等待系统启动完成..."
    
    # Magisk标准启动检测方法
    while [ "$(getprop sys.boot_completed)" != "1" ]; do
        sleep 2
    done
    
    # 额外确认启动动画完成（可选）
    local bootanim=""
    for i in $(seq 1 15); do
        bootanim=$(getprop init.svc.bootanim 2>/dev/null)
        [ "$bootanim" = "stopped" ] && break
        sleep 2
    done
    
    log "系统启动完成（boot_completed=1, bootanim=$bootanim）"
}

# 检查服务状态
is_service_running() {
    [ ! -f "$PID_FILE" ] && return 1
    
    # shellcheck disable=SC2155
    local pid=$(cat "$PID_FILE" 2>/dev/null)
    [ -z "$pid" ] && return 1
    
    [ ! -d "/proc/$pid" ] && rm -f "$PID_FILE" && return 1
    
    grep -q "server" /proc/$pid/cmdline 2>/dev/null && return 0
    
    rm -f "$PID_FILE"
    return 1
}

# 启动服务进程
start_service() {
    log "启动服务..."
    
    # 清理旧进程（安全方式）
    if [ -f "$PID_FILE" ]; then
        local old_pid=$(cat "$PID_FILE")
        if [ -n "$old_pid" ] && [ "$old_pid" -eq "$old_pid" ] 2>/dev/null; then
            if grep -q "server" /proc/$old_pid/cmdline 2>/dev/null; then
                kill -TERM $old_pid >/dev/null 2>&1
                sleep 1
            fi
        fi
    fi
    rm -f "$PID_FILE"
    
    # 启动服务（Magisk标准方式）
    "$BINARY" server --data "$DATA_DIR" >>"$LOG_FILE" 2>&1 &
    local pid=$!
    sleep 2  # 等待进程初始化
    
    # 验证进程
    if grep -q "server" /proc/$pid/cmdline 2>/dev/null; then
        # 安全写入PID（原子操作）
        echo $pid > "${PID_FILE}.tmp"
        mv -f "${PID_FILE}.tmp" "$PID_FILE"
        
        log "服务启动成功 PID: $pid"
        update_module_status "✅ 运行中" "PID: $pid"
        return 0
    fi
    
    log "服务启动失败"
    update_module_status "❌ 错误" "启动失败"
    return 1
}

# 服务监控循环
monitor_service() {
    local restart_attempts=0
    local max_attempts=5
    
    while :; do
        if is_service_running; then
            restart_attempts=0
            sleep 30
        else
            restart_attempts=$((restart_attempts+1))
            
            if [ $restart_attempts -gt $max_attempts ]; then
                log "服务连续启动失败超过 $max_attempts 次，停止尝试"
                update_module_status "❌ 故障" "启动失败超过 $max_attempts 次"
                sleep 300  # 防止快速循环
                restart_attempts=0  # 重置计数器
                continue
            fi
            
            log "检测到服务停止 (尝试 $restart_attempts/$max_attempts)，尝试重启..."
            start_service || {
                # 指数退避
                local wait_time=$((restart_attempts * 10))
                log "重启失败，等待 ${wait_time}秒 后重试..."
                sleep $wait_time
            }
        fi
    done
}

# 主执行流程
main() {
    # 初始化日志
    echo " " >> "$LOG_FILE"
    log "==== 模块启动 ===="
    
    # 1. 准备执行环境
    prepare_binary || exit 1
    mkdir -p "$DATA_DIR"
    
    # 2. 等待系统完全启动
    wait_for_system
    
    # 3. 启动服务
    if ! start_service; then
        log "服务启动失败，进入监控循环尝试恢复"
    fi
    
    # 4. 进入监控循环
    monitor_service
}

# 执行主程序
main