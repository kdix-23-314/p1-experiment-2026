FROM python:3.10-slim

# SWI-Prolog のインストール
RUN apt-get update && apt-get install -y \
    swi-prolog \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 依存パッケージのインストール
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# アプリケーション起動
CMD ["python", "app.py"]