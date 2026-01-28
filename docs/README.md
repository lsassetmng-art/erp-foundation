pm_loop：LLM 切替運用（確定）
目的
pm_loop は LLM 非依存で動作させる。
LLM は外部部品として 実行時に切替可能とする。
基本方針
pm_loop 本体は LLMを意識しない
LLM 切替は 環境変数のみ
フロー・ロジック・成果物は同一
使用する環境変数
コードをコピーする
Sh
PM_LOOP_LLM_CMD
pm_loop が LLM を呼び出す際に実行するコマンド
stdin → stdout で動作すること
LLM 切替コマンド
コードをコピーする
Sh
$HOME/pm_loop/bin/llm_switch.sh
対応モード
モード
内容
openai
OpenAI API を使用
ollama
ローカル LLM
none
LLM 無効（cat）
切替方法（重要）
必ず source 実行する
コードをコピーする
Sh
. "$HOME/pm_loop/bin/llm_switch.sh" openai
コードをコピーする
Sh
. "$HOME/pm_loop/bin/llm_switch.sh" ollama
コードをコピーする
Sh
. "$HOME/pm_loop/bin/llm_switch.sh" none
動作確認
コードをコピーする
Sh
echo "Yes" | $PM_LOOP_LLM_CMD
禁止事項
pm_loop 本体に LLM 分岐を入れる
YAML や設定ファイルで LLM を固定
llm_call.sh を直接書き換える
設計意図
LLM 障害・Quota 超過でも pm_loop は止めない
AI あり／なしで 同一フローを保証
将来の LLM 追加に影響を与えない
