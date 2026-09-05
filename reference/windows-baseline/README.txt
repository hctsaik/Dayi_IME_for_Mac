大易兩碼・使用者設定說明
========================

一、部署方式
  將本資料夾內所有檔案複製到 Rime 使用者目錄後「重新部署」即可。
  使用者目錄路徑：%AppData%\Rime
  （可從 開始選單 → 小狼毫輸入法 → 用戶文件夾 開啟）

二、常用詞／常用字要生效（必做）
  • 常用詞：請在 user_setting 資料夾執行一次：
      python build_common_words_table.py
    預設會讀 luna_pinyin.practical.dict.yaml（每行一詞，詞庫大）；若無此檔則改讀 common_words.dict.yaml（詞\t權重）。
    會產生 common_words_import.dict.yaml（詞→碼），由 dayi2 的 import_tables 併入。
    複製到 Rime 時要一併複製 dayi2.dict.yaml 與 common_words_import.dict.yaml，重新部署後常見詞即生效。
    若想改回少數自訂詞，可暫時移走或改名 luna_pinyin.practical.dict.yaml，腳本會改用 common_words.dict.yaml。
  • 常用字：單字由 dayi2.dict.yaml 提供，已按字碼對照；順序可由 dayi2 碼表內
    的權重或使用習慣調整。

三、已套用的設定
  • 預設輸入法：大易兩碼（dayi2）為預設，由 default.custom.yaml 指定。
  • 常用詞：由 dayi2 import_tables 併入 common_words_import.dict.yaml（上方腳本產生）。
  • Tab：按 Tab 切換中/英，英文模式預設為小寫。
  • 單字不出詞：僅在輸入 2 碼以上時才用詞庫，打單字時只顯示單字候選。

四、編輯常用詞後
  若修改了 common_words.dict.yaml（詞+權重），請再執行一次
  build_common_words_table.py 重新產生 common_words_import.dict.yaml，
  再複製到 Rime 並重新部署。

五、常見詞沒出現時（排查）
  1) 確認 common_words_import.dict.yaml 已存在（執行 build_common_words_table.py）。
  2) 確認 dayi2.dict.yaml 與 common_words_import.dict.yaml 已複製到 %AppData%\Rime（可用 deploy_to_rime.ps1）。
  3) 重新部署後，檢查 %AppData%\Rime\build 是否出現 dayi2.table.bin（常見詞已併入此檔）。
  4) 查看日誌：%TEMP%\rime.weasel.* 或小狼毫「錯誤查看」。

六、備份與還原（換電腦或重裝後使用）
  • 備份：在 user_setting 資料夾執行 .\backup_rime_settings.ps1
    會將目前設定複製到專案下的 backup\rime_dayi2_日期時間 資料夾。
  • 還原：詳見 user_setting 內的 RESTORE.txt（備份時會一併複製過去）。
    簡述：把備份資料夾內容複製回 user_setting → 執行 build_common_words_table.py（若要常用詞）→ 執行 deploy_to_rime.ps1 → 小狼毫重新部署。
