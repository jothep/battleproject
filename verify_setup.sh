#!/bin/bash

echo "========================================="
echo "  重构验证脚本"
echo "========================================="
echo ""

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查函数
check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $1"
        return 0
    else
        echo -e "${RED}✗${NC} $1 (缺失)"
        return 1
    fi
}

check_json() {
    if python3 -m json.tool "$1" > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} $1 (JSON 格式正确)"
        return 0
    else
        echo -e "${RED}✗${NC} $1 (JSON 格式错误)"
        return 1
    fi
}

total=0
passed=0

echo "1️⃣  检查核心系统文件..."
echo ""
files=(
    "scripts/core/DebugConfig.gd"
    "scripts/core/ResourceManager.gd"
    "scripts/data/SkillData.gd"
    "scripts/data/CharacterData.gd"
    "utils/JSONLoader.gd"
)

for file in "${files[@]}"; do
    total=$((total + 1))
    if check_file "$file"; then
        passed=$((passed + 1))
    fi
done

echo ""
echo "2️⃣  检查配置文件..."
echo ""

config_files=(
    "data/skills/attack.json"
    "data/skills/skill_1.json"
    "data/skills/skill_2.json"
    "data/skills/skill_3.json"
    "data/skills/noble.json"
    "data/characters/p1.json"
    "data/characters/p2.json"
)

for file in "${config_files[@]}"; do
    total=$((total + 1))
    if check_json "$file"; then
        passed=$((passed + 1))
    fi
done

echo ""
echo "3️⃣  检查测试文件..."
echo ""
test_files=(
    "test_data_loading.gd"
    "test_data_loading.tscn"
)

for file in "${test_files[@]}"; do
    total=$((total + 1))
    if check_file "$file"; then
        passed=$((passed + 1))
    fi
done

echo ""
echo "4️⃣  检查 project.godot 配置..."
echo ""

if grep -q "DebugConfig=" project.godot; then
    echo -e "${GREEN}✓${NC} DebugConfig 已注册为 Autoload"
    passed=$((passed + 1))
else
    echo -e "${RED}✗${NC} DebugConfig 未注册"
fi
total=$((total + 1))

if grep -q "ResourceManager=" project.godot; then
    echo -e "${GREEN}✓${NC} ResourceManager 已注册为 Autoload"
    passed=$((passed + 1))
else
    echo -e "${RED}✗${NC} ResourceManager 未注册"
fi
total=$((total + 1))

echo ""
echo "========================================="
echo "  验证结果: $passed/$total 通过"
echo "========================================="

if [ $passed -eq $total ]; then
    echo -e "${GREEN}🎉 所有检查通过！可以在 Godot 中运行测试了。${NC}"
    echo ""
    echo "下一步："
    echo "1. 打开 Godot 编辑器"
    echo "2. 运行 test_data_loading.tscn 场景"
    echo "3. 查看详细测试清单: TEST_CHECKLIST.md"
    exit 0
else
    echo -e "${RED}❌ 有 $((total - passed)) 项检查失败，请修复后再测试。${NC}"
    exit 1
fi
