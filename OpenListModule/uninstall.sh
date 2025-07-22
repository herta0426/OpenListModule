#!/sbin/sh

# 日志文件路径
LOG_FILE="/sdcard/Download/OPListModule_uninstall.log"

# 清理旧日志
rm -f "$LOG_FILE"

# 将所有输出重定向到日志文件
exec > "$LOG_FILE" 2>&1

echo " "
echo "******************************"
echo "   OPListModule 安全卸载中...  "
echo "******************************"
# 确保脚本在正确的目录下运行
DATA_DIR="/data/adb/OpenList"
BACKUP_DIR="/sdcard/Download/OPListModule_backup"

# 创建备份目录
mkdir -p "$BACKUP_DIR"
echo "- 创建备份目录: $BACKUP_DIR"

# 安全备份数据
if [ -d "$DATA_DIR" ]; then
    BACKUP_FILE="${BACKUP_DIR}/backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    echo "- 正在备份数据到: $BACKUP_FILE"
    
    # 执行备份
    tar -czf "$BACKUP_FILE" -C "${DATA_DIR%/*}" "${DATA_DIR##*/}" 2>/dev/null
    
    if [ $? -eq 0 ] && [ -s "$BACKUP_FILE" ]; then
        echo "- 数据备份成功"
        echo "- 备份大小: $(du -sh "$BACKUP_FILE" | cut -f1)"
        
        # 安全删除数据目录
        rm -rf "$DATA_DIR"
        echo "- 已安全删除数据目录: $DATA_DIR"
    else
        echo "! 严重警告: 数据备份失败"
        echo "! 保留数据目录: $DATA_DIR"
        echo "! 请手动备份后删除"
    fi
else
    echo "- 未找到数据目录: $DATA_DIR"
fi

echo " "
echo "- 卸载完成!"
echo "- 模块文件已移除"
echo "- 数据备份在: $BACKUP_DIR"
echo "- 卸载日志已保存到: $LOG_FILE"

exit 0