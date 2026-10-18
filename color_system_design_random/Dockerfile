# ベースイメージ
FROM python:3.11-slim

# Prolog のインストール
RUN apt-get update && \
    apt-get install -y swi-prolog && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 作業ディレクトリ
WORKDIR /app

# Python依存関係をコピーしてインストール
COPY requirements.txt .
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt


# アプリ本体をコピー
COPY . .

# コンテナ内で公開するポート
EXPOSE 8080

# アプリ起動コマンド
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:8080", "app:app"]
