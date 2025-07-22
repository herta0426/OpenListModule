#!/system/bin/sh
MODDIR=${0%/*}
DATA_DIR="/data/adb/OpenList"
LOG_DIR="/data/adb/OpenList/logs"

# 确保数据目录存在
mkdir -p "$DATA_DIR"
chmod 0700 "$DATA_DIR"
mkdir -p "$LOG_DIR"
chmod 0700 "$LOG_DIR"

LOG_FILE="$LOG_DIR/action.log"
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] action.sh:" "$@" >> "$LOG_FILE"
}

# 重置密码
ui_print "正在重置管理员密码..."
OUTPUT=$("$MODDIR/openlist" admin random --data "$DATA_DIR" 2>&1)
RESULT=$?
ui_print "$OUTPUT"

if [ $RESULT -eq 0 ]; then
    log "密码重置成功"
    echo "$(date): 密码重置成功" >> "$DATA_DIR/password.log"
else
    log "密码重置失败: $OUTPUT"
    ui_print "✖ 密码重置失败！错误信息:"
    ui_print "$OUTPUT"
    echo "$(date): 密码重置失败: $OUTPUT" >> "$DATA_DIR/error.log"
    exit $RESULT
fi