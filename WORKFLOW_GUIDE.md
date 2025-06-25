# GitHub Actions 构建与发布指南

本项目现在支持使用GitHub Actions进行自动构建和发布。

## 🔧 配置要求

### 必需的Secrets配置
在你的GitHub仓库或组织中配置以下secrets：

1. `KEY_JKS`: base64编码的Android签名证书内容
2. `ALIAS`: 证书别名（例如: `release-key`）
3. `ANDROID_KEY_PASSWORD`: 密钥密码
4. `ANDROID_STORE_PASSWORD`: 证书库密码

### 配置证书的步骤

1. **准备证书文件**
   ```bash
   # 如果没有证书，创建一个新的（开发测试用）
   keytool -genkey -v -keystore release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias release-key
   ```

2. **将证书转换为base64**
   ```bash
   base64 -w 0 release-key.jks > certificate.base64
   ```

3. **在GitHub中配置Secrets**
   - 进入仓库/组织的Settings → Secrets and variables → Actions
   - 添加上述4个secret变量

## 🚀 使用方法

### 自动发布 (推荐)
当你推送带有`v`前缀的tag时，会自动触发构建和发布：

```bash
# 创建并推送release tag
git tag v1.0.0
git push origin v1.0.0
```

### 手动测试构建
1. 进入仓库的Actions页面
2. 选择"Test Build"workflow
3. 点击"Run workflow"
4. 选择调试级别和是否测试签名

## 📋 Workflow说明

### 发布Workflow (release.yml)
- **触发条件**: 推送带`v`前缀的tag (如: v1.0.0, v2.1.3)
- **功能**:
  - 自动构建release版APK
  - 使用提供的证书签名
  - 重命名APK为: `shadowsocksr-v2ray-版本号.apk`
  - 创建GitHub Release
  - 上传APK到Release页面
- **超时**: 60分钟
- **缓存**: 启用多级缓存加速构建

### 测试Workflow (test-build.yml)
- **触发条件**: 手动触发
- **功能**:
  - 测试构建流程
  - 验证签名配置
  - 提供详细的调试信息
- **调试级别**:
  - `basic`: 基础构建测试
  - `detailed`: 详细调试信息
  - `full`: 完整调试模式
- **超时**: 45分钟

## 🔍 调试指南

### 构建失败排查

1. **检查证书配置**
   - 运行测试workflow并启用签名测试
   - 确认所有4个secret都已正确配置

2. **查看构建日志**
   - 在Actions页面查看详细的构建日志
   - 每个步骤都有详细的调试信息

3. **下载构建产物**
   - 测试workflow会上传构建结果到Artifacts
   - 可以下载查看具体的错误信息

### 常见问题

1. **证书签名失败**
   ```
   解决方案: 确认KEY_JKS是正确的base64编码，ALIAS和密码正确
   ```

2. **构建超时**
   ```
   解决方案: 检查NDK和依赖下载，考虑使用缓存
   ```

3. **APK文件未找到**
   ```
   解决方案: 检查构建脚本和输出目录路径
   ```

## 📦 输出文件

### 成功构建后的产物
- **APK文件**: `shadowsocksr-v2ray-v版本号.apk`
- **位置**: GitHub Release页面
- **备份**: Actions Artifacts（保留30天）

### 文件命名规则
- 格式: `项目名-版本号.apk`
- 示例: `shadowsocksr-v2ray-v1.0.0.apk`

## ⚡ 性能优化

### 已启用的优化
1. **多级缓存**
   - Android SDK/NDK缓存
   - SBT依赖缓存
   - Scala包缓存

2. **并行构建**
   - 使用`-j8`参数进行并行编译
   - 优化依赖安装流程

3. **增量构建**
   - 智能缓存策略
   - 避免重复下载

### 预期构建时间
- **首次构建**: 30-45分钟（需要下载所有依赖）
- **后续构建**: 15-25分钟（使用缓存）

## 🔒 安全注意事项

1. **证书安全**
   - 使用organization级别的secrets
   - 定期轮换签名密钥
   - 不要在日志中输出敏感信息

2. **访问控制**
   - 限制谁可以创建release tag
   - 使用branch protection规则
   - 审查workflow修改

## 📝 发布流程

### 标准发布步骤
1. 完成开发和测试
2. 更新版本号和changelog
3. 创建并推送release tag
4. 等待自动构建完成
5. 检查release页面
6. 测试下载的APK

### Beta版本发布
- 使用包含`beta`、`alpha`或`rc`的tag
- 会自动标记为pre-release
- 例如: `v1.0.0-beta1`

## 🛠️ 自定义配置

### 修改构建参数
编辑`.github/workflows/release.yml`中的环境变量：
```yaml
env:
  NDK_VERSION: android-ndk-r12b
  ANDROID_COMPILE_SDK: "29"
  ANDROID_BUILD_TOOLS: "29.0.0"
```

### 修改APK命名
在release workflow的重命名步骤中修改：
```bash
NEW_NAME="你的项目名-${{ steps.version.outputs.version }}.apk"
``` 