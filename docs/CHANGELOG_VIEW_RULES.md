## [Unreleased]

### Added
- VIEW 設計・運用ルールを正式化
- public スキーマを VIEW 専用とする方針を明文化

### Changed
- VIEW 作成時の必須手順を定義
  - 正本テーブル確認
  - 列の実在確認
  - 対象 VIEW のみ DROP
- 返品は出荷（shipping_detail）起点とする JOIN ルールを確定

### Fixed
- 仮定テーブル・仮定列による VIEW 作成を禁止
- VIEW の無差別 DROP を禁止
