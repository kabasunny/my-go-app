# 繝吶・繧ｹ繧､繝｡繝ｼ繧ｸ
FROM golang:1.23-alpine

# 蠢・ｦ√↑繝・・繝ｫ繧偵う繝ｳ繧ｹ繝医・繝ｫ
RUN apk add --no-cache git curl

# air繧偵う繝ｳ繧ｹ繝医・繝ｫ
RUN go install github.com/air-verse/air@v1.61.0

# 繧｢繝励Μ繧ｱ繝ｼ繧ｷ繝ｧ繝ｳ繝・ぅ繝ｬ繧ｯ繝医Μ繧剃ｽ懈・
WORKDIR /app

# 繝帙せ繝亥・縺ｮgo.mod, go.sum繧偵さ繝斐・縺励※萓晏ｭ倬未菫ゅｒ隗｣豎ｺ
COPY go.mod ./
COPY go.sum ./
RUN go mod download

# 繧ｽ繝ｼ繧ｹ繧ｳ繝ｼ繝峨ｒ繧ｳ繝斐・
COPY . .

# 繝昴・繝医ｒ蜈ｬ髢・
EXPOSE 8080

# air繧偵ョ繝輔か繝ｫ繝医・繧ｳ繝槭Φ繝峨→縺励※螳溯｡・
CMD ["air"]
