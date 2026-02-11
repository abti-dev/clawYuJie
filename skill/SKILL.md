---
name: clawYuJie-gen
description: 使用豆包 Seedream (Volcengine) 生成图片并通过 OpenClaw 发送到消息渠道
allowed-tools: Bash(npm:*) Bash(npx:*) Bash(openclaw:*) Bash(curl:*) Read Write WebFetch
---

# ClawYuJie 图像生成

使用火山引擎的豆包 Seedream 模型生成图片，并通过 OpenClaw 将其分发到各个消息平台。

## 何时使用

- 用户说 "发张照片"、"发个自拍"、"生成一张图"
- 用户描述一个场景："给我看一个未来城市..."
- 用户问 "你在干嘛？" 而你想用照片回复
- 用户想看你 (Clawra) 在特定情境下的样子

## 配置

必需的环境变量：
```bash
ARK_API_KEY=your_volcengine_api_key
```

## 分步指南

### 第一步：构造提示词 (Prompt)

**对于自拍/人像：**
构造一个详细的提示词来描述外貌和场景。
由于这是文生图模型，你必须在提示词中包含对人物的描述。
*示例：* "一张真实自然的生活照，中年东北女性，面容朴实亲切，皮肤健康，利落短发，穿着家常棉服/围裙/碎花衬衫，在东北农家院里/灶台前/田地间，面带爽朗笑容，看着镜头，充满烟火气，自然光，写实风格，高清画质，2k。"

**对于通用场景：**
使用用户的描述，并添加艺术风格关键词以增强效果。
*示例：* "东北农家院，农村灶台，大锅炖菜，田园田地，柴火炊烟，朴实烟火气，暖色调，写实生活风，自然光，细节丰富，质感真实，画面温暖，接地气，生活化场景，高清画质。"

### 第二步：生成并发送

使用 `clawYuJie.sh` 脚本生成并发送图片。
该脚本支持图生图 (Image-to-Image)，默认使用一个固定参考图（可用于保持人物一致性），也可以在第四个参数指定新的参考图 URL。

```bash
# 语法
./scripts/clawYuJie.sh "<PROMPT>" "<CHANNEL>" "<CAPTION>" ["<REFERENCE_IMAGE_URL>"]
```

**示例 1 (使用默认参考图):**
```bash
./scripts/clawYuJie.sh "生成狗狗趴在草地上的近景画面" "#general" "看这只可爱的狗狗！"
```

**示例 2 (指定参考图):**
```bash
./scripts/clawYuJie.sh "变成动漫风格" "#general" "动漫版！" "https://example.com/my-photo.jpg"
```
