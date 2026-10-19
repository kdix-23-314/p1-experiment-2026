# インタラクティブGA実行用
# iga.htmlで利用

import os
import webbrowser

"""
クラス名と色データを受け取り、CSSファイルを生成する
"""
def parse_colors_and_generate_css(class_names, color_data, output_filename):
    with open(output_filename, "w", encoding="utf-8") as file:
        for class_name, color_info in zip(class_names, color_data):
            try:
                bg_color = color_info.split(", ")[0].split(": ")[1].strip()
                text_color = color_info.split(", ")[1].split(": ")[1].strip()
                file.write(f".{class_name} {{\n")
                file.write(f"    background-color: #{bg_color};\n")
                file.write(f"    color: #{text_color};\n")
                file.write(f"}}\n\n")
            except IndexError:
                print(f"不正な行がありました: {color_info.strip()}")
                continue


def generate_html_with_css(html_template_path, css_filename, output_html_path):
    with open(html_template_path, encoding="utf-8") as f:
        html_content = f.read()

    # 'theme.css' を置換する
    relative_css_path = os.path.relpath(css_filename, os.path.dirname(output_html_path))
    new_html = html_content.replace('theme.css', relative_css_path)

    with open(output_html_path, "w", encoding="utf-8") as f:
        f.write(new_html)


# スクリプトの絶対パスを基準にディレクトリを指定
base_dir = os.path.dirname(os.path.abspath(__file__))

txt_dir = os.path.normpath(os.path.join(base_dir, "../static/iga/colors_txt"))
css_dir = os.path.normpath(os.path.join(base_dir, "../static/iga/themes_css"))
html_dir = os.path.normpath(os.path.join(base_dir, "../static/iga/uis_html"))
output = os.path.normpath(os.path.join(base_dir, "../static/iga/output"))
base_html_path = os.path.normpath(os.path.join(base_dir, "../static/iga/ui_new_ver.html"))

# クラス名（順番通り）
class_names = [
    "status1color-change", "status2color-change", "status3color-change",
    "status4color-change", "status5color-change", 
    "status6color-change", "status7color-change", "status101color-change",
    "status102color-change", "status103color-change", 
    "status11color-change", "button1color-change", "button21color-change",
    "button22color-change", "button31color-change", 
    "button32color-change", "button41color-change", "button42color-change", 
    "uicolor-change"
]



os.makedirs(txt_dir, exist_ok=True)
os.makedirs(css_dir, exist_ok=True)
os.makedirs(html_dir, exist_ok=True)
os.makedirs(output, exist_ok=True)

max_usage_limit = 7

# output/colors_{i}.txt のUI化
for k in range(4, max_usage_limit + 1):
    
    
    txt_filename = os.path.join(output, f"colors_{k}.txt")
    css_filename = os.path.join(css_dir, f"theme_{k}.css")
    html_filename = os.path.join(html_dir, f"ui_new_ver_{k}.html")

    if not os.path.exists(txt_filename):
        print(f"ファイルが見つかりません: {txt_filename}")
        continue

    with open(txt_filename, encoding="utf-8") as f:
        color_data = f.readlines()

    # CSS ファイルを生成
    parse_colors_and_generate_css(class_names, color_data, css_filename)
    print(f"CSSファイル '{css_filename}' を生成しました。")

    # HTML ファイルを生成
    generate_html_with_css(base_html_path, css_filename, html_filename)


# output/favorite_{i}.txt のUI化
for i in range(1, 3):
    
    txt_filename = os.path.join(output, f"favorite_{i}.txt")
    css_filename = os.path.join(css_dir, f"theme_f{i}.css")
    html_filename = os.path.join(html_dir, f"ui_new_ver_f{i}.html")

    if not os.path.exists(txt_filename):
        print(f"ファイルが見つかりません: {txt_filename}")
        continue

    with open(txt_filename, encoding="utf-8") as f:
        color_data = f.readlines()

    # CSS ファイルを生成
    parse_colors_and_generate_css(class_names, color_data, css_filename)
    print(f"CSSファイル '{css_filename}' を生成しました。")

    # HTML ファイルを生成
    generate_html_with_css(base_html_path, css_filename, html_filename)