% 色セットの定義
:- consult('color_set_data.pl').

% 色のRGB値
:- consult('color_data.pl').

% color_set/3 の定義からパレットを取得(1.7.1から追加)
get_color_palettes(ColorSetName, ValidColors, UiColorList) :-
    color_set(ColorSetName, ValidColors, UiColorList), !.

% 既存の color_set/2 の定義からパレットを取得（UI色は固定）(1.7.1から追加)
get_color_palettes(ColorSetName, ValidColors, [ui_default_bg]) :-
    color_set(ColorSetName, ValidColors).

:- use_module(library(lists)).


% RGB値から輝度を計算する
calculate_brightness(R, G, B, Brightness) :-
    Brightness is 0.299 * R + 0.587 * G + 0.114 * B.

% 背景色に基づいて文字色を決定する
get_text_color(BgColor, TextColor) :-
    color_hex(BgColor, BgRGB),
    % RGB値を取得
    atom_string(BgRGB, BgHex),
    string_concat("0x", BgHex, BgHexWithPrefix),
    number_string(BgValue, BgHexWithPrefix),
    % RGBの16進数からR, G, Bを抽出
    R is (BgValue // 65536) mod 256,
    G is (BgValue // 256) mod 256,
    B is BgValue mod 256,
    % 輝度を計算
    calculate_brightness(R, G, B, Brightness),
    % 輝度が高ければ文字色を黒に、低ければ白に
    (Brightness > 128 -> TextColor = black; TextColor = white).

% 隣接する場所の色が異なることを保証
neighbor_different(A, B) :- A \= B.

% 特定の場所の色が同じことを保証
same_color(A, B) :- A = B.

% 色の使用回数をカウントする
count_color_usage(_, [], 0).
count_color_usage(Color, [Color | Rest], Count) :-
    count_color_usage(Color, Rest, CountRest),
    Count is CountRest + 1.
count_color_usage(Color, [OtherColor | Rest], Count) :-
    Color \= OtherColor,
    count_color_usage(Color, Rest, Count).

% 指定された色が最大使用回数を超えないように制限
limit_color_usage(Color, MaxUsage, Statuses) :-
    count_color_usage(Color, Statuses, Count),
    Count =< MaxUsage.

% 全ての色の使用回数をn回以下に制限
limit_all_colors_usage([], _, _).
limit_all_colors_usage([Color | RestColors], MaxUsage, Statuses) :-
    limit_color_usage(Color, MaxUsage, Statuses),
    limit_all_colors_usage(RestColors, MaxUsage, Statuses).

% 全ての組み合わせを生成して出力
generate_combinations_with_text_color(ColorSet, MaxUsage,
                                       Status1,
                                       Status2, Status3,
                                       Status4,
                                       Status5, Status6,
                                       Status7,
                                       Status10_1, 
                                       Status10_2, Status10_3,
                                       Status11,
                                       Button1, Button2_1,
                                       Button2_2,
                                       Button3_1, 
                                       Button3_2, Button4_1,
                                       Button4_2,
                                       UiBgColor) :- % <-- 1.7.1より追加
    % ▼ 1.7.1修正: color_set/2 から get_color_palettes/3 に変更
    get_color_palettes(ColorSet, ValidColors, UiColorList),  % 色セットを取得

    % ▼ 1.7.1追加: UI背景色を候補から選択
    member(UiBgColor, UiColorList),

    % 各ステータスについて色を設定（指定されていない場合はバックトラッキングで全ての色を試す）
    member(Status1, ValidColors),
    member(Status2, ValidColors),
    neighbor_different(Status1, Status2),

    member(Status3, ValidColors),
    member(Status4, ValidColors),
    neighbor_different(Status1, Status3),
    neighbor_different(Status3, Status4),

    member(Status5, ValidColors),
    member(Status6, ValidColors),
    neighbor_different(Status3, Status5),
    neighbor_different(Status5, Status6),
    neighbor_different(Status4, Status6),

    member(Status7, ValidColors),
    neighbor_different(Status6, Status7),

    member(Status10_1, ValidColors),
    member(Status10_2, ValidColors),
    member(Status10_3, ValidColors),
    same_color(Status10_1, Status10_2),
    same_color(Status10_2, Status10_3),
    neighbor_different(Status10_1, Status7),
    neighbor_different(Status10_2, Status7),
    neighbor_different(Status10_3, Status7),

    member(Status11, ValidColors),
    neighbor_different(Status10_1, Status11),
    neighbor_different(Status10_2, Status11),
    neighbor_different(Status10_3, Status11),

    member(Button1, ValidColors),
    member(Button2_1, ValidColors),
    neighbor_different(Button1, Button2_1),

    member(Button2_2, ValidColors),
    same_color(Button2_1, Button2_2),
    neighbor_different(Button1, Button2_2),

    member(Button3_1, ValidColors),
    member(Button3_2, ValidColors),
    neighbor_different(Button3_1, Button3_2),
    same_color(Button2_1, Button3_2),
    same_color(Button1, Button3_1),

    member(Button4_1, ValidColors),
    neighbor_different(Status11, Button4_1),
    member(Button4_2, ValidColors),
    neighbor_different(Button4_1, Button4_2),

    % 色の使用回数を制限
    limit_all_colors_usage(ValidColors, MaxUsage,
                                         [Status1, Status2,
                                          Status3, Status4, 
                                          Status5, Status6,
                                          Status7, Status10_1,
                                          Status10_2, Status10_3,
                                          Status11,
                                          Button1, Button2_1,
                                          Button2_2, Button3_1,
                                          Button3_2, Button4_1,
                                          Button4_2]),

    % 組み合わせを表示
    print_with_rgb_and_text_color([status1-Status1,
                                   status2-Status2,
                                   status3-Status3, 
                                   status4-Status4,
                                   status5-Status5,
                                   status6-Status6,
                                   status7-Status7,
                                   status10_1-Status10_1,
                                   status10_2-Status10_2,
                                   status10_3-Status10_3,
                                   status11-Status11,
                                   button1-Button1,
                                   button2_1-Button2_1,
                                   button2_2-Button2_2, 
                                   button3_1-Button3_1,
                                   button3_2-Button3_2,
                                   button4_1-Button4_1, 
                                   button4_2-Button4_2,
                                   ui_bg-UiBgColor]). % <-- 1.7.1追加


% 変数とそのRGB値および文字色を指定された形式で表示
print_with_rgb_and_text_color([]).
print_with_rgb_and_text_color([Var-Color | Rest]) :-
    color_hex(Color, RGB),  % 色名からRGB値を取得
    get_text_color(Color, TextColor),  % 背景色に基づき文字色を決定
    color_hex(TextColor, TextRGB),  % 文字色のRGB値を取得
    format('"背景色: ~w, 文字色: ~w",~n', [RGB, TextRGB]),
    print_with_rgb_and_text_color(Rest).


% 色と文字色のペアをファイルに書き出す
save_colors_to_file(FileName, ColorPairs) :-
    open(FileName, write, Stream),
    forall(member(background_text(BG, TXT), ColorPairs),
           format(Stream, "背景色: ~w, 文字色: ~w~n", [BG, TXT])),
    close(Stream).

% 背景色に対する文字色を求めてリストを作る
build_color_pairs([], []).
build_color_pairs([Color | Rest], [background_text(BG, TXT) | RestPairs]) :-
    color_hex(Color, BG),
    get_text_color(Color, TextColor),
    color_hex(TextColor, TXT),
    build_color_pairs(Rest, RestPairs).


% ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
% export_colors_sysB メソッド
% - ColorSetName: テーマ名
% 
% systemBにおける集団の生成
% ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー


% MaxUsage = 4〜9 の間繰り返して、初期集団を6種類生成
% シャッフルの動作を追加
export_colors_sysB(ColorSetName) :-
    forall(
        between(4, 9, M),
        (
            % デバッグ表示
            format('--- Run ~w ---~n', [M]),
            format(atom(FileName), '../static/index/colors_txt/colors_~w.txt', [M]),
            export_random_colors_to_file(ColorSetName, M, FileName) % シャッフル
        )
    ).


% ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
% export_colors メソッド
% - ColorSetName: テーマ名
% 
% IGAにおける初期集団の生成
% ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー


% MaxUsage = 4〜9 の間繰り返して、初期集団を6種類生成
% シャッフルの動作を追加
export_colors(ColorSetName) :-
    forall(
        between(4, 9, M),
        (
            % デバッグ表示
            format('--- Run ~w ---~n', [M]),
            format(atom(FileName), '../static/iga/colors_txt/colors_~w.txt', [M]),
            export_random_colors_to_file(ColorSetName, M, FileName) % シャッフル
        )
    ).


% ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
% export_colors_mutation メソッド
% - ColorSetName: テーマ名
% 
% 突然変異を行う
% ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー

export_colors_mutation(ColorSetName) :-
    forall(
        between(1, 2, M),
        (
            % デバッグ表示
            format('--- Run ~w ---~n', [M]),
            format(atom(FileName), '../static/iga/output/mutation_~w.txt', [M]),
            export_random_colors_to_file(ColorSetName, 4, FileName) % シャッフル
        )
    ).




% ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
% Swapに関する動作
% ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー

% ------------------------
% ファイル行を読み込む（安全版）
% ------------------------
read_color_file_safe(FileName, Lines) :-
    open(FileName, read, Stream),
    read_lines(Stream, Lines),
    close(Stream).

read_lines(Stream, []) :-
    at_end_of_stream(Stream).

read_lines(Stream, [Line|Rest]) :-
    \+ at_end_of_stream(Stream),
    read_line_to_string(Stream, Line),
    read_lines(Stream, Rest).

% ------------------------
% 行を指定インデックスで入れ替える
% ------------------------
swap_at_indices(L1, L2, [], L1, L2).
swap_at_indices(L1, L2, [I|Rest], NewL1, NewL2) :-
    nth1(I, L1, E1),
    nth1(I, L2, E2),
    set_nth(L1, I, E2, TmpL1),
    set_nth(L2, I, E1, TmpL2),
    swap_at_indices(TmpL1, TmpL2, Rest, NewL1, NewL2).

set_nth([_|T], 1, X, [X|T]).
set_nth([H|T], N, X, [H|R]) :-
    N > 1, N1 is N - 1,
    set_nth(T, N1, X, R).

% ------------------------
% 行リストをファイルに保存
% ------------------------
save_lines_to_file(FileName, Lines) :-
    open(FileName, write, Stream),
    forall(member(Line, Lines),
           format(Stream, "~w~n", [Line])),
    close(Stream).

% ------------------------
% ファイルを割合でランダムに行入れ替え
% ------------------------
swap_lines(File1, File2, Ratio, OutFile1, OutFile2) :-
    read_color_file_safe(File1, L1),
    read_color_file_safe(File2, L2),
    length(L1, Len1),
    length(L2, Len2),
    MinLen is min(Len1, Len2),
    SwapCount is max(1, round(MinLen * Ratio)),
    numlist(1, MinLen, Indices),
    random_permutation(Indices, Shuffled),
    length(SwapIndices, SwapCount),
    append(SwapIndices, _, Shuffled),
    swap_at_indices(L1, L2, SwapIndices, NewL1, NewL2),
    save_lines_to_file(OutFile1, NewL1),
    save_lines_to_file(OutFile2, NewL2),
    !.

% ------------------------
% 複数割合で一気にswap
% RatiosList = [(Ratio1, Out1, Out2), ...]
% ------------------------
swap_multiple_ratios(File1, File2,
                     [(Ratio1, OutA1, OutA2),
                      (Ratio2, OutB1, OutB2),
                      (Ratio3, OutC1, OutC2)]) :-
    swap_lines(File1, File2, Ratio1, OutA1, OutA2),
    swap_lines(File1, File2, Ratio2, OutB1, OutB2),
    swap_lines(File1, File2, Ratio3, OutC1, OutC2).

% ------------------------
% 例: テーマに応じた mutation 処理
% ------------------------
export_colors_mutation(_ThemeJson) :-
    % 必要に応じて処理を追加
    true.







% ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
% 既存ファイルの「検証（査定）」(app_ver1.6.1より追加)
% ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー

% ファイルの全行をリストに読み込む
read_lines_from_file(File, Lines) :-
    setup_call_cleanup(
        open(File, read, Stream),
        read_lines(Stream, Lines),
        close(Stream)
    ).

% ファイルの終端を正しく扱う堅牢なバージョン
read_lines(Stream, Lines) :-
    read_line_to_string(Stream, Line),
    (   Line == end_of_file
    ->  Lines = []
    ;   Lines = [Line|Rest],
        read_lines(Stream, Rest)
    ).

% 1行からHEXコード(文字列)を抽出する
parse_line_to_hex_string(Line, HexString) :-
    split_string(Line, ",", " ", [BgPart | _]),
    split_string(BgPart, ":", " ", [_, TempHexStr]),
    string_upper(TempHexStr, HexString).

% 1行を処理し、不正な行は無視するヘルパー
process_line(Line, [HexString]) :-
    string_length(Line, L), L > 0, % 空行は無視
    catch(parse_line_to_hex_string(Line, HexString), _, fail), !.
process_line(_, []). % 不正な行は空リストを返す

% 【更新】HEX文字列のリストを色名(アトム)のリストに変換する
hex_strings_to_names([], []).
hex_strings_to_names([HexString|RestStrings], [Name|RestNames]) :-
    % 文字列をアトムに変換してから照合する
    atom_string(HexAtom, HexString),
    color_hex(Name, HexAtom),
    hex_strings_to_names(RestStrings, RestNames).

% 【更新】エラー報告を強化したテキストファイル読み込み
extract_color_names_from_file(File, ColorNames) :-
    read_lines_from_file(File, Lines),
    maplist(process_line, Lines, HexStringLists),
    flatten(HexStringLists, HexStringList),
    % ▼ 1.7.1修正: 18 から 19 に変更
    (   length(HexStringList, 19)
    ->  true
    ;   length(HexStringList, ActualLen),
        % ▼ 修正: 18 から 19 に変更
        format('File Error: Expected 19 valid color lines in "~w", but found ~w.~n', [File, ActualLen]),
        fail
    ),
    (   hex_strings_to_names(HexStringList, ColorNames)
    ->  true
    ;   % どのHEXコードが未定義か特定してエラー表示
        member(BadHexStr, HexStringList),
        atom_string(BadHexAtom, BadHexStr),
        \+ color_hex(_, BadHexAtom),
        format('Data Error: The color code "~w" from file "~w" is not defined in color_data.pl.~n', [BadHexStr, File]),
        fail
    ).

% 制約違反時に詳細なエラーを出力するヘルパー述語
check_and_report(Goal, Msg) :-
    (   call(Goal)
    ->  true
    ;   format('Constraint Failed: ~w~n', [Msg]),
        fail
    ).

% MaxUsageを考慮せず、失敗箇所を特定するバージョン
% ファイルから読み込んだ配色リストが制約を満たすかチェックする
check_constraints(ColorNames) :-
    % 色名リストを各変数に割り当て
    % ▼ 1.7.1修正: 19番目の変数 _UiBgColor を追加（制約がないため _ で無視）
    ColorNames = [
        Status1, Status2, Status3, Status4,
        Status5, Status6, Status7,
        Status10_1, Status10_2, Status10_3,
        Status11,
        Button1, Button2_1, Button2_2,
        Button3_1, Button3_2, Button4_1, Button4_2,
        _UiBgColor % <-- 19番目の要素
    ],
    % 配置に関する制約を一つずつチェック
    check_and_report(neighbor_different(Status1, Status2), 'status1 and status2 must be different.'),
    check_and_report(neighbor_different(Status1, Status3), 'status1 and status3 must be different.'),
    check_and_report(neighbor_different(Status3, Status4), 'status3 and status4 must be different.'),
    % check_and_report(neighbor_different(Status3, Status5), 'status3 and status5 must be different.'),
    % check_and_report(neighbor_different(Status5, Status6), 'status5 and status6 must be different.'),
    % check_and_report(neighbor_different(Status4, Status6), 'status4 and status6 must be different.'),
    % check_and_report(neighbor_different(Status6, Status7), 'status6 and status7 must be different.'),
    % check_and_report(same_color(Status10_1, Status10_2), 'status10_1 and status10_2 must be the same.'),
    % check_and_report(same_color(Status10_2, Status10_3), 'status10_2 and status10_3 must be the same.'),
    % check_and_report(neighbor_different(Status10_1, Status7), 'status10_1 and status7 must be different.'),
    % check_and_report(neighbor_different(Status10_2, Status7), 'status10_2 and status7 must be different.'),
    % check_and_report(neighbor_different(Status10_3, Status7), 'status10_3 and status7 must be different.'),
    % check_and_report(neighbor_different(Status10_1, Status11), 'status10_1 and status11 must be different.'),
    % check_and_report(neighbor_different(Status10_2, Status11), 'status10_2 and status11 must be different.'),
    % check_and_report(neighbor_different(Status10_3, Status11), 'status10_3 and status11 must be different.'),
    % check_and_report(neighbor_different(Button1, Button2_1), 'button1 and button2_1 must be different.'),
    % check_and_report(same_color(Button2_1, Button2_2), 'button2_1 and button2_2 must be the same.'),
    % check_and_report(neighbor_different(Button1, Button2_2), 'button1 and button2_2 must be different.'),
    % check_and_report(neighbor_different(Button3_1, Button3_2), 'button3_1 and button3_2 must be different.'),
    % check_and_report(same_color(Button2_1, Button3_2), 'button2_1 and button3_2 must be the same.'),
    % check_and_report(same_color(Button1, Button3_1), 'button1 and button3_1 must be the same.'),
    % check_and_report(neighbor_different(Status11, Button4_1), 'status11 and button4_1 must be different.'),
    check_and_report(neighbor_different(Button4_1, Button4_2), 'button4_1 and button4_2 must be different.').


% MaxUsageを引数に取らないバージョン
% メインの検証（査定）述語
% 使い方:
% ?- check_constraints_from_file('../static/colors_txt/colors_maxusage_4_1.txt').
check_constraints_from_file(FileName) :-
    (   catch(extract_color_names_from_file(FileName, ColorNames), E, (print_message(error, E), fail)),
        catch(check_constraints(ColorNames), E, (print_message(error, E), fail))
    ->  format('~w: All constraints passed successfully.~n', [FileName])
    ;   % エラーメッセージは各述語内で表示されるため、ここでは汎用メッセージのみ
        format('~w: One or more constraints failed.~n', [FileName]),
        fail
    ).








% ------------------------
% 色の組み合わせを「ランダムに探索して」保存する述語 (app_ver1.6.0より追加 常に制約を満たすシャッフル生成)
% ------------------------】
export_random_colors_to_file(ColorSetName, MaxUsage, FileName) :-
    % 最初に利用可能な色のリストを取得
    % ▼ 1.7.1修正: color_set/2 から get_color_palettes/3 に変更
    get_color_palettes(ColorSetName, ValidColors, UiColorList),
    
    % ★★★★★★★★★★★★★★★★★★★★★★★★★★★
    % ★ 修正点：解を探す前に、色のリストをシャッフルする ★
    % ★★★★★★★★★★★★★★★★★★★★★★★★★★★
    % これにより、member/2が色を選ぶ順番がランダムになり、
    % 結果として見つかる解の組み合わせがランダムになる。
    random_permutation(ValidColors, ShuffledColors),
    % ▼ 1.7.1追加: UI色リストもシャッフル
    random_permutation(UiColorList, ShuffledUiColors),

    % シャッフルされた色のリストを使って、制約を満たす組み合わせを一つ見つける
    (   generate_combination_with_constraints(ShuffledColors, ShuffledUiColors, MaxUsage,
            S1, S2, S3, S4, S5, S6, S7,
            S101, S102, S103, S11, B1, B21, B22, B31, B32, B41, B42,
            UiBgColor) % <-- 1.7.1追加
    ->
        % 見つかった組み合わせを変数リストにまとめる
        Vars = [S1, S2, S3, S4, S5, S6, S7, S101, S102, S103, S11, B1, B21, B22, B31, B32, B41, B42, UiBgColor], % <-- 1.7.1追加
        
        % 背景色と文字色のペアを作成する
        build_color_pairs(Vars, ColorPairs),
        
        % ★ 修正点：ここではもうシャッフルは行わない
        % ColorPairsは正しい順序になっているため、そのまま保存する
        save_colors_to_file(FileName, ColorPairs)
    ;
        % 解が見つからなかった場合のエラーメッセージ
        format('Warning: Could not find a valid color combination for ~w with MaxUsage=~w.~n', [ColorSetName, MaxUsage])
    ).

% ゴールのリストを順番に実行するためのヘルパー述語
execute_goals([]).
execute_goals([Goal|Rest]) :-
    call(Goal),
    execute_goals(Rest).

% 制約グループ1：Status変数とそれに依存するButton4に関する制約
apply_status_group_constraints(ColorList,
                               Status1, Status2, Status3, Status4,
                               Status5, Status6, Status7,
                               Status10_1, Status10_2, Status10_3,
                               Status11, Button4_1, Button4_2) :-
    member(Status1, ColorList),
    member(Status2, ColorList),
    neighbor_different(Status1, Status2),
    member(Status3, ColorList),
    member(Status4, ColorList),
    neighbor_different(Status1, Status3),
    neighbor_different(Status3, Status4),
    member(Status5, ColorList),
    member(Status6, ColorList),
    neighbor_different(Status3, Status5),
    neighbor_different(Status5, Status6),
    neighbor_different(Status4, Status6),
    member(Status7, ColorList),
    neighbor_different(Status6, Status7),
    member(Status10_1, ColorList),
    member(Status10_2, ColorList),
    member(Status10_3, ColorList),
    same_color(Status10_1, Status10_2),
    same_color(Status10_2, Status10_3),
    neighbor_different(Status10_1, Status7),
    neighbor_different(Status10_2, Status7),
    neighbor_different(Status10_3, Status7),
    member(Status11, ColorList),
    neighbor_different(Status10_1, Status11),
    neighbor_different(Status10_2, Status11),
    neighbor_different(Status10_3, Status11),
    member(Button4_1, ColorList),
    neighbor_different(Status11, Button4_1),
    member(Button4_2, ColorList),
    neighbor_different(Button4_1, Button4_2).

% Button制約のサブ述語1（土台）
apply_button_base_constraints(ColorList, Button1, Button2_1) :-
    member(Button1, ColorList),
    member(Button2_1, ColorList),
    neighbor_different(Button1, Button2_1).

% Button制約のサブ述語2
apply_button2_2_constraints(ColorList, Button1, Button2_1, Button2_2) :-
    member(Button2_2, ColorList),
    same_color(Button2_1, Button2_2),
    neighbor_different(Button1, Button2_2).

% Button制約のサブ述語3
apply_button3_constraints(ColorList, Button1, Button2_1, Button3_1, Button3_2) :-
    member(Button3_1, ColorList),
    member(Button3_2, ColorList),
    neighbor_different(Button3_1, Button3_2),
    same_color(Button2_1, Button3_2),
    same_color(Button1, Button3_1).

% 制約グループ2：Button1, Button2, Button3に関する制約（内部でさらにシャッフル）
apply_button_group_constraints(ColorList,
                                Button1, Button2_1, Button2_2,
                                Button3_1, Button3_2) :-
    % 最初に、他のボタン変数が依存する土台を解決
    apply_button_base_constraints(ColorList, Button1, Button2_1),

    % 後続の独立したゴールを定義
    Goal2_2 = apply_button2_2_constraints(ColorList, Button1, Button2_1, Button2_2),
    Goal3   = apply_button3_constraints(ColorList, Button1, Button2_1, Button3_1, Button3_2),
    
    % ゴールのリストを作成し、実行順序をシャッフル
    Goals = [Goal2_2, Goal3],
    random_permutation(Goals, ShuffledGoals),
    execute_goals(ShuffledGoals).


% 制約の適用順序をシャッフルするメイン述語
% ▼ 1.7.1修正: ShuffledUiColors と UiBgColor をシグネチャに追加
generate_combination_with_constraints(ColorList, ShuffledUiColors, MaxUsage,
                                      Status1, Status2, Status3, Status4,
                                      Status5, Status6, Status7,
                                      Status10_1, Status10_2, Status10_3,
                                      Status11,
                                      Button1, Button2_1, Button2_2,
                                      Button3_1, Button3_2, Button4_1,
                                      Button4_2,
                                      UiBgColor) :- % <-- 1.7.1追加
    /*
    % 独立した制約グループをゴールとして定義
    StatusGroupGoal = apply_status_group_constraints(ColorList,
        Status1, Status2, Status3, Status4,
        Status5, Status6, Status7,
        Status10_1, Status10_2, Status10_3,
        Status11, Button4_1, Button4_2),
    
    ButtonGroupGoal = apply_button_group_constraints(ColorList,
        Button1, Button2_1, Button2_2,
        Button3_1, Button3_2),

    % ▼ 1.7.1追加: UI色を選択するゴール
    UiGoal = member(UiBgColor, ShuffledUiColors),

    % ゴールのリストを作成
    % ▼ 1.7.1修正: UiGoal をリストに追加
    Goals = [StatusGroupGoal, ButtonGroupGoal, UiGoal],

    % ★ゴールの実行順序をシャッフル★
    random_permutation(Goals, ShuffledGoals),

    % シャッフルされた順序でゴールを実行
    execute_goals(ShuffledGoals),

    % 最後に、全ての色が決定してから使用回数制限をチェック
    limit_all_colors_usage(ColorList, MaxUsage,
        [Status1, Status2, Status3, Status4, 
         Status5, Status6, Status7, Status10_1,
         Status10_2, Status10_3, Status11,
         Button1, Button2_1, Button2_2, Button3_1,
         Button3_2, Button4_1, Button4_2]).

    % 全体での回数制限チェック
    limit_all_colors_usage(ColorList, MaxUsage,
        [Status1, Status2, Status3, Status4, 
         Status5, Status6, Status7, Status10_1,
         Status10_2, Status10_3, Status11,
         Button1, Button2_1, Button2_2, Button3_1,
         Button3_2, Button4_1, Button4_2]),
    */

    % --- 1. Status 系の選択と隣接関係のチェック ---
    member(Status1, ColorList),
    member(Status2, ColorList), neighbor_different(Status1, Status2),

    member(Status3, ColorList), neighbor_different(Status1, Status3),
    member(Status4, ColorList), neighbor_different(Status3, Status4),

    member(Status5, ColorList), neighbor_different(Status3, Status5),
    member(Status6, ColorList), neighbor_different(Status5, Status6), neighbor_different(Status4, Status6),

    member(Status7, ColorList), neighbor_different(Status6, Status7),

    % ★ 緩和点1: Status10_1, Status10_2, Status10_3 の同色制約(same_color)を排除し、自由な色を選べるように変更
    member(Status10_1, ColorList),
    member(Status10_2, ColorList),
    member(Status10_3, ColorList),
    neighbor_different(Status10_1, Status7),
    neighbor_different(Status10_2, Status7),
    neighbor_different(Status10_3, Status7),

    member(Status11, ColorList), 
    neighbor_different(Status10_1, Status11),
    neighbor_different(Status10_2, Status11),
    neighbor_different(Status10_3, Status11),

    % --- 2. Button 系の選択と隣接関係のチェック ---
    member(Button1, ColorList),
    member(Button2_1, ColorList), neighbor_different(Button1, Button2_1),

    % ★ 緩和点2: Button2_1 と Button2_2 の同色制約(same_color)を排除
    member(Button2_2, ColorList), neighbor_different(Button1, Button2_2),

    % Button3 系の選択
    member(Button3_1, ColorList),
    member(Button3_2, ColorList), neighbor_different(Button3_1, Button3_2),

    member(Button4_1, ColorList), neighbor_different(Status11, Button4_1),
    member(Button4_2, ColorList), neighbor_different(Button4_1, Button4_2),

    % --- 3. UI背景色の選択 ---
    member(UiBgColor, ShuffledUiColors),

    % --- 4. 全体の使用回数制限チェック（高速化のため最後に一気に判定） ---
    limit_all_colors_usage(ColorList, MaxUsage,
        [Status1, Status2, Status3, Status4, 
         Status5, Status6, Status7, Status10_1,
         Status10_2, Status10_3, Status11,
         Button1, Button2_1, Button2_2, Button3_1,
         Button3_2, Button4_1, Button4_2]).



% ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
% Swapと検証を組み合わせ、制約を満たすまで繰り返す app_ver1.6.3より追加
% ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー

% メイン述語：試行回数の上限を指定して呼び出す
swap_until_valid(File1, File2, Ratio, OutFile1, OutFile2, MaxRetries) :-
    format('Attempting to generate valid files (max ~w retries)...~n', [MaxRetries]),
    % 第7引数に「元のMaxRetries」を追加してループを呼び出す
    swap_and_check_loop(File1, File2, Ratio, OutFile1, OutFile2, MaxRetries, MaxRetries).

% ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
% swap_and_check_loop (カウンタが0になった場合の定義) 1.7.0より追加
% ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー

% カウンタが0になったら、フォールバック処理を「連鎖」で呼び出す
swap_and_check_loop(File1, File2, Ratio, OutFile1, OutFile2, 0, OriginalMaxRetries) :-
    format('~nRetries exceeded. Forcing mutation 1 fallback...~n'),
    (   
        % 1. mutation1 を試行
        swap_and_check_loop_mutation1(File1, File2, Ratio, OutFile1, OutFile2, OriginalMaxRetries)
    ->  
        % 1a. mutation1 が成功した場合
        true 
    ;   
        % 1b. mutation1 が失敗した場合
        format('~nMutation 1 fallback failed. Forcing mutation 2 fallback...~n'),
        (
            % 2. mutation2 を試行
            swap_and_check_loop_mutation2(File1, File2, Ratio, OutFile1, OutFile2, OriginalMaxRetries)
        -> 
            % 2a. mutation2 が成功した場合
            true
        ;
            % 2b. mutation2 も失敗した場合
            format('~nMutation 2 fallback failed. All swap attempts failed.~n'),
            % 3. 最終手段: 元のファイルをコピーして終了
            copy_files_as_last_resort(File1, File2, OutFile1, OutFile2)
        )
    ),
    !. % 3段階のいずれかが成功すれば、全体を「成功」として終了する

% 内部ループ
swap_and_check_loop(File1, File2, Ratio, OutFile1, OutFile2, RetriesLeft, OriginalMaxRetries) :-
    RetriesLeft > 0,
    swap_lines(File1, File2, Ratio, OutFile1, OutFile2),
    (   catch(check_constraints_from_file(OutFile1), _, fail),
        catch(check_constraints_from_file(OutFile2), _, fail)
    ->  format('~nSuccess! Generated valid files.~n'),
        !
    ;   format('--> Generated files are not valid. Retrying... (~w retries left)~n', [RetriesLeft - 1]),
        NextRetries is RetriesLeft - 1,
        swap_and_check_loop(File1, File2, Ratio, OutFile1, OutFile2, NextRetries, OriginalMaxRetries)
    ).


% ファイルを割合でランダムに行入れ替え
swap_lines(File1, File2, Ratio, OutFile1, OutFile2) :-
    % 以前はread_color_file_safe/2 を使用していたが、一貫性のために変更
    read_lines_from_file(File1, L1),
    read_lines_from_file(File2, L2),
    length(L1, Len1),
    length(L2, Len2),
    MinLen is min(Len1, Len2),
    SwapCount is max(1, round(MinLen * Ratio)),
    numlist(1, MinLen, Indices),
    random_permutation(Indices, Shuffled),
    length(SwapIndices, SwapCount),
    append(SwapIndices, _, Shuffled),
    swap_at_indices(L1, L2, SwapIndices, NewL1, NewL2),
    save_lines_to_file(OutFile1, NewL1),
    save_lines_to_file(OutFile2, NewL2).

% ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
% フォールバック"無し"のシンプルな試行ループ
% ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー

% swap_until_valid とほぼ同じだが、
% 「試行回数が0になったら、フォールバックせず、失敗(fail)する」点が異なる。

swap_loop_simple(File1, File2, Ratio, OutFile1, OutFile2, MaxRetries) :-
    swap_loop_simple_internal(File1, File2, Ratio, OutFile1, OutFile2, MaxRetries).

% ベースケース (カウンタ 0): ★失敗(fail)して終了
swap_loop_simple_internal(_, _, _, _, _, 0) :-
    format('--> Simple loop failed. No valid solution found within retries.~n'),
    fail.

% 再帰ケース
swap_loop_simple_internal(File1, File2, Ratio, OutFile1, OutFile2, RetriesLeft) :-
    RetriesLeft > 0,
    swap_lines(File1, File2, Ratio, OutFile1, OutFile2),
    (   catch(check_constraints_from_file(OutFile1), _, fail),
        catch(check_constraints_from_file(OutFile2), _, fail)
    ->  ! % 成功
    ;   % 失敗したら再帰
        NextRetries is RetriesLeft - 1,
        swap_loop_simple_internal(File1, File2, Ratio, OutFile1, OutFile2, NextRetries)
    ).
% ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
% フォールバック述語 1 (mutation1)
% ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー

swap_and_check_loop_mutation1(File1, File2, Ratio, OutFile1, OutFile2, MaxRetries) :-
    MutationFile = '../static/iga/output/mutation_1.txt',
    
    atomic_concat(OutFile1, '_temp_mut_pair.txt', TempOutFileA),
    atomic_concat(OutFile2, '_temp_mut_pair.txt', TempOutFileB),

    format('--- Fallback Swap 1.1: Swapping ~w with ~w...~n', [File1, MutationFile]),
    
    % ★修正: 1つ目のswapを試行。失敗したら、この述語全体が fail する
    swap_loop_simple(File1, MutationFile, Ratio, OutFile1, TempOutFileA, MaxRetries),
    format('--- Fallback Swap 1.1 Success: Created ~w~n', [OutFile1]),
    (exists_file(TempOutFileA) -> delete_file(TempOutFileA) ; true),

    format('--- Fallback Swap 1.2: Swapping ~w with ~w...~n', [File2, MutationFile]),
    
    % ★修正: 2つ目のswapを試行。失敗したら、この述語全体が fail する
    swap_loop_simple(File2, MutationFile, Ratio, OutFile2, TempOutFileB, MaxRetries),
    format('--- Fallback Swap 1.2 Success: Created ~w~n', [OutFile2]),
    (exists_file(TempOutFileB) -> delete_file(TempOutFileB) ; true).

% ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
% フォールバック述語 2 (mutation2)
% ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー

swap_and_check_loop_mutation2(File1, File2, Ratio, OutFile1, OutFile2, MaxRetries) :-
    MutationFile = '../static/iga/output/mutation_2.txt',
    
    atomic_concat(OutFile1, '_temp_mut_pair.txt', TempOutFileA),
    atomic_concat(OutFile2, '_temp_mut_pair.txt', TempOutFileB),

    format('--- Fallback Swap 2.1: Swapping ~w with ~w...~n', [File1, MutationFile]),
    swap_loop_simple(File1, MutationFile, Ratio, OutFile1, TempOutFileA, MaxRetries),
    format('--- Fallback Swap 2.1 Success: Created ~w~n', [OutFile1]),
    (exists_file(TempOutFileA) -> delete_file(TempOutFileA) ; true),

    format('--- Fallback Swap 2.2: Swapping ~w with ~w...~n', [File2, MutationFile]),
    swap_loop_simple(File2, MutationFile, Ratio, OutFile2, TempOutFileB, MaxRetries),
    format('--- Fallback Swap 2.2 Success: Created ~w~n', [OutFile2]),
    (exists_file(TempOutFileB) -> delete_file(TempOutFileB) ; true).

% ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
% フォールバック最終手段 (ファイルコピー)
% ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー

copy_files_as_last_resort(File1, File2, OutFile1, OutFile2) :-
    format('--- CRITICAL FAILURE: Copying originals as last resort...~n'),
    
    % File1 を OutFile1 にコピー
    (   catch(read_lines_from_file(File1, Lines1), E1, (print_message(error, E1), fail)),
        catch(save_lines_to_file(OutFile1, Lines1), E2, (print_message(error, E2), fail))
    ->  format('--- Copied ~w to ~w~n', [File1, OutFile1])
    ;   format('--- ERROR: Failed to copy ~w to ~w~n', [File1, OutFile1])
    ),
    
    % File2 を OutFile2 にコピー
    (   catch(read_lines_from_file(File2, Lines2), E3, (print_message(error, E3), fail)),
        catch(save_lines_to_file(OutFile2, Lines2), E4, (print_message(error, E4), fail))
    ->  format('--- Copied ~w to ~w~n', [File2, OutFile2])
    ;   format('--- ERROR: Failed to copy ~w to ~w~n', [File2, OutFile2])
    ).