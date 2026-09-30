FROM node:20-slim

# 1. 设置工作目录为标准的 /app（切忌使用 /tmp，避免容器平台 tmpfs 覆盖或 noexec 导致 .so 加载失败）
WORKDIR /app

# 2. 声明构建参数，默认打包 index.js，也可通过 --build-arg JS_FILE=nodes/deployzy.js 打包具体节点
ARG JS_FILE=index.js

# 3. 安装运行所需的核心系统工具
RUN apt-get update && apt-get install -y --no-install-recommends \
    openssl curl iproute2 bash procps ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 4. 复制 package.json 与 package-lock.json，并执行依赖安装
COPY package*.json ./
RUN npm install --no-audit --no-fund --omit=dev

# 5. 复制启动脚本和首页
COPY ${JS_FILE} ./index.js
COPY index.html ./

# 6. 配置运行目录与权限
RUN chmod +x index.js && \
    mkdir -p .npm .tmp && \
    chmod -R 777 /app

# 7. 暴露端口（3000 为 Deployzy 默认检测端口，8080 备用）
EXPOSE 3000/tcp
EXPOSE 8080/tcp

# 8. 设置环境变量（移除极其危险的 48MB 内存限制，设为标准生产环境）
ENV PORT=3000 \
    NODE_ENV=production

# 9. 启动命令
CMD ["node", "index.js"]
