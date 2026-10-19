from flask import Flask, render_template, request, session, redirect, url_for
import subprocess
import os
import shutil
import json
import random

import requests

# ーーーーーーーーーーーーーーーーーーーーーー
# テスト用追加
import time
# ーーーーーーーーーーーーーーーーーーーーーー


app = Flask(__name__)
app.secret_key = 'your_secret_key_here'  # セッション利用には必須

GAS_WEBAPP_URL = "https://script.google.com/macros/s/AKfycbxUqQYql611rbhXHcSfIo9x4UuN-zUyZfO-SBxbE7th7Fj6wVg9-G_8MtJBhBBzs7wC/exec"



# ーーーーーーーーーーーーーーーーーーーーーー
# ルーティング
#
# 目的: 各HTMLとのルーティング設定
# ーーーーーーーーーーーーーーーーーーーーーー

@app.route('/')
@app.route('/iga')
def iga():
    return render_template('iga.html')


@app.route('/iga_exec')
def iga_exec():
    return render_template('iga_exec.html')


# ーーーーーーーーーーーーーーーーーーーーーー
# iga_early メソッド
#
# タブ: [IGA]
# 使用: iga.html
# 目的: 初期集団の生成
# ーーーーーーーーーーーーーーーーーーーーーー
@app.route('/iga_early', methods=['POST'])
def iga_early():

    # ーーーーーーーーーーーーーーーーーーーーーー
    # テスト用追加
    session['start_time'] = time.time()  # 開始時間を記録
    session['iga_exec_clicks'] = 2       # クリック回数を2に初期化
    # ーーーーーーーーーーーーーーーーーーーーーー

    # 追加：ID管理用の最大番号を6に初期化（IGA_01 〜 IGA_06）
    session['iga_max_id_num'] = 6

    try:
        # 入力値（テーマ名）を取得
        theme = request.form['theme']

        base_dir = os.path.dirname(os.path.abspath(__file__))

        # === ① Prolog の実行 ===
        prolog_dir = os.path.join(base_dir, 'prolog')
        prolog_file = os.path.join(prolog_dir, 'main.pl')
        prolog_query = f"consult('{prolog_file}'), export_colors('{theme}'), halt."

        prolog_result = subprocess.run(
            ['swipl', '-g', prolog_query],
            capture_output=True, 
            text=True, 
            cwd=prolog_dir
        )

        # === ② Python の実行 ===
        python_dir = os.path.join(base_dir, 'scripts')
        # generates_auto_iga.py → 初期集団を6つランダムに生成するメソッド
        python_file = os.path.join(python_dir, 'generates_auto_iga.py')
        python_result = subprocess.run(
            ['python3', python_file], capture_output=True, text=True, cwd=python_dir
        )

        # エラー出力を stdout と stderr の両方から取得
        prolog_output = prolog_result.stdout + "\n" + prolog_result.stderr
        python_output = python_result.stdout + "\n" + python_result.stderr

        output = (
             "▼ Prolog 実行結果:\n" + prolog_output + "\n\n"
             "▼ Python 実行結果:\n" + python_output
        )
        
        # Prologが失敗した場合にエラーを表示
        if prolog_result.returncode != 0:
            return render_template('iga.html', result=f"Prolog 実行エラー:\n{prolog_output}")
        
        return render_template('iga.html', result=output)

    except Exception as e:
        return render_template('iga.html', result=f"エラー: {str(e)}")


# ーーーーーーーーーーーーーーーーーーーーーーーーーー
# iga_generate_prolog メソッド
# （prologでのswap実装）
#
# タブ: [IGA]
# 使用: iga.html
# 目的: 初期集団から選択した二つのお気に入りで
# 　　  1回目のインタラクティブGAを実行する
# 補足: IGAの候補（6種類）
#      ./iga/colors_txt/colors_4...colors_9
# ーーーーーーーーーーーーーーーーーーーーーーーーーー
@app.route('/iga_generate_prolog', methods=['POST'])
def iga_generate_prolog():
    import os
    import json
    import shutil
    import subprocess
    import random

    # --- favorites を取得 ---
    favorites_json = request.form.get("favorites")
    if not favorites_json:
        return "エラー: favoritesが送られてきていません"

    # 送られてくるデータ例: {"IGA_01": 90, "IGA_02": 90, "IGA_03": 40, ...}
    score_map = json.loads(favorites_json)
    print(f"受け取ったスコアデータ: {score_map}")

    #【追加】評価点に基づいて上位2つの親IDを決定するルーレット選択ロジック
    # 点数の高い順（降順）にグループ化する
    # 例: {90: ["IGA_01", "IGA_02", "IGA_03"], 40: ["IGA_04"], ...}
    grouped_by_score = {}
    for ui_id, score in score_map.items():
        score = int(score)  # 確実に整数化
        grouped_by_score.setdefault(score, []).append(ui_id)

    # 点数の高い順にソートされたスコアのリスト
    sorted_scores = sorted(grouped_by_score.keys(), reverse=True)

    selected_parents = []

    # 上位から順に2つの親が埋まるまで選択
    for score in sorted_scores:
        candidates = grouped_by_score[score]
        
        # この点数グループの候補をシャッフル（ルーレット効果）
        random.shuffle(candidates)
        
        while candidates and len(selected_parents) < 2:
            selected_parents.append(candidates.pop(0))
            
        if len(selected_parents) == 2:
            break

    print(f"★ ルーレット選択により決定された親: {selected_parents}")
    favorites = selected_parents  # これ以降は従来の処理に流すため変数名を合わせる


    #  今回決定した親のID（親関係）を定義
    parent_relations = {
        "FAVORITE_01_was": favorites[0],
        "FAVORITE_02_was": favorites[1]
    }
    
    # 次世代の `iga_generate_repeat_prolog` に引き継げるようにセッションへ保存
    session['last_parent_relations'] = parent_relations

    
    
    # ★ フォームからテーマを直接安全に取得
    current_theme = request.form.get("theme", "")

    # スプレッドシート記録用の送信処理
    try:
        payload = {
            "theme": current_theme,
            "scores": score_map
        }
        # バックグラウンドでGASにPOST送信（タイムアウトを設けてメイン処理の遅延を防ぐ）
        response = requests.post(GAS_WEBAPP_URL, json=payload, timeout=5)
        print(f"GAS送信結果 (初期): {response.text}")
    except Exception as e:
        print(f"GAS送信エラー (初期): {str(e)}")



    # --- ディレクトリ確認 ---
    base_dir = os.path.dirname(os.path.abspath(__file__))
    txt_dir = os.path.join(base_dir, "static", "iga", "colors_txt")
    out_dir = os.path.join(base_dir, "static", "iga", "output")
    os.makedirs(out_dir, exist_ok=True)

    # --- favorite と UI ファイルマップ ---
    favorite_files = []
    ui_map = {
        "IGA_01": "colors_4.txt",
        "IGA_02": "colors_5.txt",
        "IGA_03": "colors_6.txt",
        "IGA_04": "colors_7.txt",
        "IGA_05": "colors_8.txt",
        "IGA_06": "colors_9.txt",
    }

    # --- Safe copy: favorite_1.txt / favorite_2.txt にコピー ---
    for i, ui_id in enumerate(favorites, start=1):
        src_file = ui_map.get(ui_id)
        if not src_file:
            return f"エラー: 不明なUI ID {ui_id}"
        src = os.path.join(txt_dir, src_file)
        dst = os.path.join(out_dir, f"favorite_{i}.txt")
        if os.path.abspath(src) != os.path.abspath(dst):
            shutil.copy(src, dst)
        favorite_files.append(dst)

    # 初期選択されたファイルをあらかじめ output フォルダ側にもコピーしておく
    for file_key, file_name in ui_map.items():
        shutil.copy(os.path.join(txt_dir, file_name), os.path.join(out_dir, file_name))

    favorite_1_file = favorite_files[0]
    favorite_2_file = favorite_files[1]

    # === Prolog の実行 ===
    # --- 出力先の 6 ファイル ---
    colors_files = {
        "colors_4": os.path.join(out_dir, "colors_4.txt"),
        "colors_5": os.path.join(out_dir, "colors_5.txt"),
        "colors_6": os.path.join(out_dir, "colors_6.txt"),
        "colors_7": os.path.join(out_dir, "colors_7.txt"),
        "colors_X": os.path.join(out_dir, "colors_X.txt")
    }

    # --- Prolog の実行 ---
    theme_json = request.form.get("theme")
    prolog_dir = os.path.join(base_dir, 'prolog')
    prolog_file = os.path.join(prolog_dir, 'main.pl')
    mutation_1 = os.path.join(out_dir, 'mutation_1.txt')
    mutation_2 = os.path.join(out_dir, 'mutation_2.txt')
    temp_swap_file = colors_files.get('colors_X', os.path.join(out_dir, 'colors_X.txt'))  
    
    # ★ 修正: shell=True を避け、コマンドリストからクエリを生成
    prolog_commands = [
        f"consult('{prolog_file}')",
        # Ratio 0.5でペア1を作成
        f"export_colors_mutation('{theme_json}')",
        f"swap_until_valid('{favorite_1_file}', '{favorite_2_file}', 0.5, '{colors_files['colors_4']}', '{colors_files['colors_5']}', 6000)",
        # Ratio 0.33でペア2を作成
        f"export_colors_mutation('{theme_json}')",
        f"swap_until_valid('{favorite_1_file}', '{favorite_2_file}', 0.33, '{colors_files['colors_6']}', '{colors_files['colors_7']}', 6000)",
    ]
    
    # 3. 確率的突然変異(Mutation)フェーズ
    mutation_occurred = False
    # 交叉で生成された6つのファイルをチェック
    files_to_check = ['colors_4', 'colors_5', 'colors_6', 'colors_7']

    for file_key in files_to_check:
        # 10%の抽選に当たり、かつ、まだこの世代で突然変異が起きていない場合
        if not mutation_occurred and random.random() < 0.30:
        
            mutation_occurred = True
            print(f"--- Info: Mutation triggered for {file_key} ---") # サーバーログ
        
            target_file = colors_files[file_key]
        
            # 突然変異コマンドをリストに追加
            # (mutation1とswapする)
            prolog_commands.append(f"export_colors_mutation('{theme_json}')")
            prolog_commands.append(
                f"swap_until_valid('{target_file}','{mutation_1}', 0.20, "
                f"'{target_file}','{temp_swap_file}', 6000)"
            )
        
            # 突然変異は世代に1回までなので、ループを抜ける
            break

    if not mutation_occurred:
        print("--- Info: No mutation triggered this generation ---") # サーバーログ

    # 4. 最後にPrologを終了するコマンドを追加
    prolog_commands.append("halt")

    #5. リスト内の全コマンドをカンマで連結し、単一のPrologクエリ文字列を生成
    #   最後にピリオドを追加する
    final_prolog_query = ", ".join(prolog_commands) + "."

    prolog_result = subprocess.run(
        ['swipl', '-g', final_prolog_query], 
        capture_output=True,
        text=True,
        cwd=prolog_dir
    )
    
    # === Python の実行 ===
    python_dir = os.path.join(base_dir, 'scripts')
    python_file = os.path.join(python_dir, 'generates_iga_8.py')
    subprocess.run(
        ['python3', python_file], capture_output=True, text=True, cwd=python_dir
    )

    # --- 実行結果確認 ---
    if prolog_result.returncode != 0:
        # stdout も含めてエラー出力
        error_output = prolog_result.stdout + "\n" + prolog_result.stderr
        return f"Prolog 実行エラー:\n{error_output}"

    return render_template('iga_exec.html', result="swap by Prolog 完了（4ファイル生成）")


# ーーーーーーーーーーーーーーーーーーーーーーーーーー
# iga_generate_repeat_prolog メソッド
# （prologでのswap実装）
#
# タブ: [IGA]
# 使用: iga_exec.html
# 目的: 8つの候補から選択されたお気に入りを用いて
# 　　  2回目以降のインタラクティブGAを実行する
# 補足: IGAの候補（8種類）
# 　　  ./iga/output/favorite_1...favorite_2
#      ./iga/output/colors_4...colors_9
# ーーーーーーーーーーーーーーーーーーーーーーーーーー
@app.route('/iga_generate_repeat_prolog', methods=['POST'])
def iga_generate_repeat_prolog():

    # ーーーーーーーーーーーーーーーーーーーーーー
    # テスト用追加
    if 'iga_exec_clicks' in session:
        session['iga_exec_clicks'] += 1
    # ーーーーーーーーーーーーーーーーーーーーーー

    import os
    import json
    import shutil
    import subprocess
    import random

    # --- favorites を取得 ---
    favorites_json = request.form.get("favorites")
    if not favorites_json:
        return "エラー: favoritesが送られてきていません"

    # 送られてくるデータ例: {"FAVORITE_01": 100, "IGA_01": 80, ...}
    score_map = json.loads(favorites_json)
    print(f"受け取ったリピートスコアデータ: {score_map}")

    # 点数の高い順（降順）にグループ化する
    grouped_by_score = {}
    for ui_id, score in score_map.items():
        score = int(score)  # 確実に整数化
        grouped_by_score.setdefault(score, []).append(ui_id)

    # 点数の高い順にソートされたスコアのリスト
    sorted_scores = sorted(grouped_by_score.keys(), reverse=True)

    selected_parents = []

    # 上位から順に2つの親が埋まるまで選択
    for score in sorted_scores:
        candidates = grouped_by_score[score]
        
        # 同点グループ内をシャッフル（ルーレット効果）
        random.shuffle(candidates)
        
        while candidates and len(selected_parents) < 2:
            selected_parents.append(candidates.pop(0))
            
        if len(selected_parents) == 2:
            break

    print(f"★ リピート世代のルーレット選択により決定された親: {selected_parents}")
    favorites = selected_parents  # これ以降は従来の処理に流すため変数名を合わせる



    # ★ 今回選ばれた親（直前の世代のどのIDだったか）の関係を記録
    new_parent_relations = {
        "FAVORITE_01_was": favorites[0],
        "FAVORITE_02_was": favorites[1]
    }

    # ★ 安全に現在のテーマを取得
    current_theme = request.form.get("theme", "")

    # スプレッドシート記録用の送信処理
    try:
        payload = {
            "theme": current_theme,
            "scores": score_map,
            # 前回の親関係（この採点データにおけるFAVORITE_01, 02の正体）を送信
            "parent_relations": session.get('last_parent_relations', {}) 
        }
        response = requests.post(GAS_WEBAPP_URL, json=payload, timeout=5)
        print(f"GAS送信結果 (リピート): {response.text}")
    except Exception as e:
        print(f"GAS送信エラー (リピート): {str(e)}")

    # 次の世代へ向けて、新しく決まった親の関係をセッションに上書き保存
    session['last_parent_relations'] = new_parent_relations

    # --- ディレクトリ確認 ---
    base_dir = os.path.dirname(os.path.abspath(__file__))
    out_dir = os.path.join(base_dir, "static", "iga", "output")
    os.makedirs(out_dir, exist_ok=True)

    # --- favorite と UI ファイルマップ ---
    ui_map = {
        "FAVORITE_01": "favorite_1.txt",
        "FAVORITE_02": "favorite_2.txt",
        "IGA_01": "colors_4.txt",
        "IGA_02": "colors_5.txt",
        "IGA_03": "colors_6.txt",
        "IGA_04": "colors_7.txt"
    }

    # --- Safe copy: favorite_1.txt / favorite_2.txt にコピー ---
    file_contents = []
    favorite_files = []
    for i, ui_id in enumerate(favorites, start=1):
        src_file = ui_map.get(ui_id)
        if not src_file:
            return f"エラー: 不明なUI ID {ui_id}"
        
        src = os.path.join(out_dir, src_file)

        # 一度ファイルを読み込んでメモリに中身をキープする
        with open(src, "r") as f:
            file_contents.append(f.read())

    # 読み込みがすべて終わった後に、ターゲットファイルへ書き出す
    favorite_files = []
    for i, content in enumerate(file_contents, start=1):
        dst = os.path.join(out_dir, f"favorite_{i}.txt")
        with open(dst, "w") as f:
            f.write(content)
        print(f"★ favorite_{i}.txt に選択されたデータを安全に書き込みました", flush=True)
        favorite_files.append(dst)

    favorite_1_file = favorite_files[0]
    favorite_2_file = favorite_files[1]

    # === Prolog の実行 ===
    # --- 出力先の 6 ファイル ---
    colors_files = {
        "colors_4": os.path.join(out_dir, "colors_4.txt"),
        "colors_5": os.path.join(out_dir, "colors_5.txt"),
        "colors_6": os.path.join(out_dir, "colors_6.txt"),
        "colors_7": os.path.join(out_dir, "colors_7.txt"),
    }
    
    # --- Prolog の実行 ---
    theme_json = request.form.get("theme")
    prolog_dir = os.path.join(base_dir, 'prolog')
    prolog_file = os.path.join(prolog_dir, 'main.pl')
    mutation_1 = os.path.join(out_dir, 'mutation_1.txt')
    mutation_2 = os.path.join(out_dir, 'mutation_2.txt')
    temp_swap_file = colors_files.get('colors_X', os.path.join(out_dir, 'colors_X.txt')) 

    prolog_commands = [
        # 1. main.plの読み込み
        f"consult('{prolog_file}')",

        # 2. 交叉(Crossover)フェーズ - ペア1 (Ratio 0.5)
        f"export_colors_mutation('{theme_json}')",
        f"swap_until_valid('{favorite_1_file}', '{favorite_2_file}', 0.5, '{colors_files['colors_4']}', '{colors_files['colors_5']}', 6000)",
        
        # 3. 交叉(Crossover)フェーズ - ペア2 (Ratio 0.33)
        f"export_colors_mutation('{theme_json}')",
        f"swap_until_valid('{favorite_1_file}', '{favorite_2_file}', 0.33, '{colors_files['colors_6']}', '{colors_files['colors_7']}', 6000)"
    ]

    mutation_occurred = False
    # 交叉で生成された6つのファイルをチェック
    files_to_check = ['colors_4', 'colors_5', 'colors_6', 'colors_7']

    for file_key in files_to_check:
        # 10%の抽選に当たり、かつ、まだこの世代で突然変異が起きていない場合
        if not mutation_occurred and random.random() < 0.30:
        
            mutation_occurred = True
            print(f"--- Info: Mutation triggered for {file_key} ---") # サーバーログ
        
            target_file = colors_files[file_key]
        
            # 突然変異コマンドをリストに追加
            # (mutation1とswapする)
            prolog_commands.append(f"export_colors_mutation('{theme_json}')")
            prolog_commands.append(
                f"swap_until_valid('{target_file}','{mutation_1}', 0.20, "
                f"'{target_file}','{temp_swap_file}', 6000)"
            )
        
            # 突然変異は世代に1回までなので、ループを抜ける
            break

    if not mutation_occurred:
        print("--- Info: No mutation triggered this generation ---") # サーバーログ

    # 4. 最後にPrologを終了するコマンドを追加
    prolog_commands.append("halt")
    
    final_prolog_query = ", ".join(prolog_commands) + "."

    # --- 実行 ---
    # コマンドをリストで渡す
    prolog_result = subprocess.run(
        ['swipl', '-g', final_prolog_query], # ['コマンド', '引数1', '引数2'] の形式
        capture_output=True,
        text=True,
        cwd=prolog_dir
    )
    
    # === Python の実行 ===
    python_dir = os.path.join(base_dir, 'scripts')
    python_file = os.path.join(python_dir, 'generates_iga_8.py')
    subprocess.run(
        ['python3', python_file], capture_output=True, text=True, cwd=python_dir
    )

    # --- 実行結果確認 ---
    if prolog_result.returncode != 0:
        # Prologのエラーは stdout にも出ることがあるため、両方キャッチする
        error_output = prolog_result.stdout + "\n" + prolog_result.stderr
        return f"Prolog 実行エラー:\n{error_output}"

    return render_template('iga_exec.html', result="swap by Prolog 完了（4ファイル生成）")


# アプリケーションの実行
if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8000)