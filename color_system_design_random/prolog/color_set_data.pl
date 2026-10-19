% 色セットの定義
color_set('Enjoyable', [orange, egg, turquoise, ivory, rose]).
color_set('Lighthearted', [sunset, ivory, lettuce, white, egg]).
color_set('Pretty', [flamingo, cherry, mobe, ivory, sulfur]).
color_set('Casual', [red, white, blue, egg, emerald]).
color_set('Rich', [brick, persimmon, coffee, olive, maroon]).
color_set('Graceful', [mauvepink, orchid, rosemist, cherryblossom,
lilac]). % 優雅な色
color_set('Plain', [olivegray, ivory, white, silvergray,
pearlgray]). % 無地色
color_set('Chic', [gray, silvergray, slateblue, moonstoneblue,
lightslategray]). % シックな色
color_set('Formal', [black, silvergray, midnightblue, pearlgray,
duskyviolet]). % フォーマル色
color_set('valentines_day', [magenta, pink, mobe, awafuji, lilac]). % valentines_day色
color_set('Christmas', [black, viridian, red, white, gray]). % Christmas色
color_set('New_year', [rouge, white, ivy, gold, nasukon]). % New_year色
color_set('Setsubun', [mist, orchid, kuwairo, orchidgray, tonokoiro]). % Setsubun色
color_set('test', [red, blue, pink, white, black]).

% ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
% TEL提案のテーマセット
% ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー

% ブルー・ライト
color_set('ブルー・ライト', [
    h_pale_gray_1,      % メインカラー #dbdcdb
    h_pale_blue_1,      % アソート #9dc3de
    white,              % アクセント1 #ffffff
    h_dark_dull_blue,   % アクセント2 #6e899e
    h_vivid_red         % アラート #e73118
]).

% ブルー・ダーク
color_set('ブルー・ダーク', [
    h_dark_gray,        % メインカラー #3e3939
    h_dark_dull_blue,   % アソート #6e899e
    h_pale_gray_2,      % アクセント1 #c7c9c9
    h_pale_blue_1,      % アクセント2 #9dc3de
    h_vivid_red         % アラート #e73118
]).

% グリーン・ダーク
color_set('グリーン・ダーク', [
    h_dark_gray,          % メインカラー #3e3939
    h_dark_dull_green,    % アソート #687159
    h_dull_pale_yellow,   % アクセント1 #e7e2b2
    h_dull_orange,        % アクセント2 #cb743b
    h_vivid_red           % アラート #e73118
]).

% ピンク・ダーク
color_set('ピンク・ダーク', [
    h_dark_gray,            % メインカラー #3e3939
    h_dark_grayish_purple,  % アソート #857079
    h_dull_pale_redpurple,  % アクセント1 #e1c1cf
    h_vivid_redpurple,      % アクセント2 #c55385
    h_vivid_red             % アラート #e73118
]).

% ピンク・ソフト
color_set('ピンク・ソフト', [
    h_pale_gray_3,      % メインカラー #efeeed
    h_pale_redpurple,   % アソート #edcbd8
    white,              % アクセント1 #ffffff
    h_vivid_bluegreen,  % アクセント2 #5fada9
    h_vivid_red         % アラート #e73118
]).

% ブルー・ソフト
color_set('ブルー・ソフト', [
    h_pale_blue_2,      % メインカラー #c1d6e9
    h_pale_green,       % アソート #d1deb2
    h_pale_pink,        % アクセント1 #f4dfe8
    white,              % アクセント2 #ffffff
    h_vivid_red         % アラート #e73118
]).

% パレット1
color_set('blue_light_2', [
    h_pale_blue_1,          % アソート1 #9dc3de (既存)
    white,                  % アソート2 #ffffff (既存)
    h_dark_dull_blue,       % アクセント1 #6e899e (既存)
    new_light_gray_2,       % アクセント2 #c9caca
    new_light_yellow_green  % アクセント3 #c1d69c
], [new_light_gray_1        % メイン #efefef
]).

% パレット1
color_set('blue_dark_2', [
    h_pale_blue_1,          % アソート1 #9dc3de (既存)
    white,                  % アソート2 #ffffff (既存)
    h_dark_dull_blue,       % アクセント1 #6e899e (既存)
    new_light_gray_2,       % アクセント2 #c9caca
    new_light_yellow_green  % アクセント3 #c1d69c
], [h_dark_gray             % メイン #3e3939 (既存)
]).

/*
% パレット2
color_set('TEL_Test', [
    h_dark_dull_blue,       % アソート1 #6e899e (既存)
    h_pale_gray_2,          % アソート2 #c7c9c9 (既存)
    h_pale_blue_1,          % アクセント1 #9dc3de (既存)
    new_dark_blue_gray,     % アクセント2 #61706f
    new_medium_gray         % アクセント3 #9fa0a0
], [h_dark_gray,            % メイン #3e3939 (既存)
    new_light_gray_1        % メイン #efefef
]).
*/

% TEL_Test ダーク
color_set('TEL_Test_dark', [
    h_dark_dull_blue,       % アソート1 #6e899e (既存)
    h_pale_gray_2,          % アソート2 #c7c9c9 (既存)
    h_pale_blue_1,          % アクセント1 #9dc3de (既存)
    new_dark_blue_gray,     % アクセント2 #61706f
    new_medium_gray         % アクセント3 #9fa0a0
], [h_dark_gray             % メイン #3e3939 (既存)
]).

% TEL_Test ライト
color_set('TEL_Test_light', [
    h_dark_dull_blue,       % アソート1 #6e899e (既存)
    h_pale_gray_2,          % アソート2 #c7c9c9 (既存)
    h_pale_blue_1,          % アクセント1 #9dc3de (既存)
    new_dark_blue_gray,     % アクセント2 #61706f
    new_medium_gray         % アクセント3 #9fa0a0
], [new_light_gray_1        % メイン #efefef
]).

% パレット3
color_set('pink_dark_2', [
    h_dark_grayish_purple,  % アソート1 #857079 (既存)
    new_dull_pale_redpurple,% アソート2 #ead4de
    h_vivid_redpurple,      % アクセント1 #c55385 (既存)
    new_light_redpurple,    % アクセント2 #e083a8
    new_pale_purple         % アクセント3 #baa6c6
], [h_dark_gray             % メイン #3e3939 (既存)
]).

% パレット3
color_set('pink_light_2', [
    h_dark_grayish_purple,  % アソート1 #857079 (既存)
    new_dull_pale_redpurple,% アソート2 #ead4de
    h_vivid_redpurple,      % アクセント1 #c55385 (既存)
    new_light_redpurple,    % アクセント2 #e083a8
    new_pale_purple         % アクセント3 #baa6c6
], [new_light_gray_1        % メイン #efefef
]).

% ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
% 11/21追加
% ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー

% ライトブルー背景明: [ボタン1, ボタン2, ボタン3, ボタン4, ボタン5], [ベース1, ベース2, ベース3]
color_set('ライトブルー背景明', [
    h_pale_blue_1, new_light_yellow_green, b_dull_dark_blue, b_light_aqua, white
], [
    b_light_dull_orange, b_light_dull_yellow, b_light_dull_aqua
]).

% ライトオレンジ背景明: [ボタン1, ボタン2, ボタン3, ボタン4, ボタン5], [ベース1, ベース2, ベース3]
color_set('ライトオレンジ背景明', [
    b_light_yellow, b_pale_yellow_green, white, b_pale_orange, b_bright_orange
], [
    b_light_dull_orange, b_light_dull_yellow, b_light_dull_aqua
]).

% ライトブルー背景中: [ボタン1, ボタン2, ボタン3, ボタン4, ボタン5], [ベース1, ベース2, ベース3]
color_set('ライトブルー背景中', [
    h_pale_blue_1, white, b_dull_dark_blue, b_light_aqua, new_light_yellow_green
], [
    b_grayish_orange, b_grayish_yellow, b_grayish_aqua
]).

% ライトオレンジ背景中: [ボタン1, ボタン2, ボタン3, ボタン4, ボタン5], [ベース1, ベース2, ベース3]
color_set('ライトオレンジ背景中', [
    b_light_yellow, b_pale_yellow_green, white, b_pale_orange, b_bright_orange
], [
    b_grayish_orange, b_grayish_yellow, b_grayish_aqua
]).

% ライトブルー背景暗: [ボタン1, ボタン2, ボタン3, ボタン4, ボタン5], [ベース1, ベース2, ベース3]
color_set('ライトブルー背景暗', [
    h_pale_blue_1, white, b_dull_dark_blue, b_light_aqua, new_light_yellow_green
], [
    b_dark_grayish_orange, b_dark_grayish_yellow, b_dark_grayish_aqua
]).

% ライトオレンジ背景暗: [ボタン1, ボタン2, ボタン3, ボタン4, ボタン5], [ベース1, ベース2, ベース3]
color_set('ライトオレンジ背景暗', [
    b_light_yellow, b_pale_yellow_green, white, b_pale_orange, b_bright_orange
], [
    b_dark_grayish_orange, b_dark_grayish_yellow, b_dark_grayish_aqua
]).

% test_01: [ボタン1, ボタン2, ボタン3, ボタン4, ボタン5], [ベース1, ベース2]
color_set('test_01', [
    t1_bright_purple, t1_gray_01, white, t1_light_aqua, t1_dark_gray
], [
    t1_deep_blue, t1_bright_yellow_green
]).

% test_02: [ボタン1, ボタン2, ボタン3, ボタン4, ボタン5], [ベース1, ベース2]
color_set('test_02', [
    t2_bright_orange, t2_medium_gray, white, t2_dark_gray, t2_bright_aqua
], [
    t2_light_gray, t2_dark_blue
]).

% test_03: [ボタン1, ボタン2, ボタン3, ボタン4, ボタン5], [ベース1, ベース2]
color_set('test_03', [
    t3_light_aqua, t3_gray_01, t3_light_gray, white, t3_dark_green
], [
    t3_medium_aqua, t2_dark_blue
]).

% オレンジ・ダーク: [ボタン1, ボタン2, ボタン3, ボタン4, ボタン5], [ベース]
color_set('オレンジ・ダーク', [
    b_light_yellow, new_light_yellow_green, b_bright_orange, b_pale_orange, ac3
], [
    base
]).
