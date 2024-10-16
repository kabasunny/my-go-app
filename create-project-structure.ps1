# .env ファイルのパス
$envFilePath = ".env"

# .env ファイルの読み込み
if (Test-Path $envFilePath) {
    Get-Content $envFilePath | ForEach-Object {
        # 空行やコメント行を無視
        if ($_ -match "^\s*#") { return }
        if ($_ -match "^\s*$") { return }
        # 環境変数を設定
        $name, $value = $_ -split "=", 2
        $name = $name.Trim()
        $value = $value.Trim()
        [System.Environment]::SetEnvironmentVariable($name, $value, [System.EnvironmentVariableTarget]::Process)
    }
}

# 環境変数を使用
$rootPath = $env:ROOT_PATH
Write-Output "Root path is: $rootPath"

# ディレクトリの作成
New-Item -ItemType Directory -Path $rootPath -Force
New-Item -ItemType Directory -Path "$rootPath/api" -Force

# Goモジュールの初期化
cd "$rootPath/api"
go mod init my-go-app

# 依存関係の追加
go get -u github.com/gin-gonic/gin
go get -u gorm.io/driver/mysql
go get -u gorm.io/gorm


# シンプルなmain.goを作成
$mainGoPath = "$rootPath/api/main.go"
$mainGoContent = @"
package main

import (
    "github.com/gin-gonic/gin"
)

func main() {
    router := gin.Default()
    router.GET("/ping", func(c *gin.Context) {
        c.JSON(200, gin.H{
            "message": "pong",
        })
    })
    router.Run(":8080")
}
"@
Set-Content -Path $mainGoPath -Value $mainGoContent

# Dockerfile の作成
$dockerfilePath = "$rootPath/api/Dockerfile"
$dockerfileContent = @"
# ベースイメージ
FROM golang:1.23-alpine

# 必要なツールをインストール
RUN apk add --no-cache git curl

# airをインストール
RUN go install github.com/air-verse/air@v1.61.0

# アプリケーションディレクトリを作成
WORKDIR /app

# ホスト側のgo.mod, go.sumをコピーして依存関係を解決
COPY go.mod ./
COPY go.sum ./
RUN go mod download

# ソースコードをコピー
COPY . .

# ポートを公開
EXPOSE 8080

# airをデフォルトのコマンドとして実行
CMD ["air"]
"@
# Dockerfile の作成
Set-Content -Path $dockerfilePath -Value $dockerfileContent
Write-Output "Dockerfile created at: $dockerfilePath"

# docker-compose.yml の作成
$dockerComposePath = "$rootPath/docker-compose.yml"
$dockerComposeContent = @"
version: '3.8'
services:
  go-app:
    build:
      context: ./api
      dockerfile: Dockerfile
    container_name: go-app
    volumes:
      - ./api:/app
      - /app/air
    ports:
      - '8086:8080'
    environment:
      - GO_ENV=development
    command: ["air"]
"@
# docker-compose.yml の作成
Set-Content -Path $dockerComposePath -Value $dockerComposeContent
Write-Output "docker-compose.yml created at: $dockerComposePath"
