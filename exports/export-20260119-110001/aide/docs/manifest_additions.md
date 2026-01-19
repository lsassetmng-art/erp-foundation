# AndroidManifest 追加（手動1回）

Home を起点にする場合、AndroidManifest.xml に以下を追加してください。

- HomeActivity を LAUNCHER にする
- 既存の LAUNCHER Activity がある場合は置き換え

例（概念）:
<activity android:name="app.activity.core.HomeActivity">
  <intent-filter>
    <action android:name="android.intent.action.MAIN"/>
    <category android:name="android.intent.category.LAUNCHER"/>
  </intent-filter>
</activity>
