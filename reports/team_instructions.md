# チーム別指示書（自動生成）


## Architect

- auth/AuthenticateUser: レイヤ構成・責務境界・RLS前提設計を確認
- auth/LogoutUser: レイヤ構成・責務境界・RLS前提設計を確認
- order/CreateOrder: レイヤ構成・責務境界・RLS前提設計を確認
- order/ConfirmOrder: レイヤ構成・責務境界・RLS前提設計を確認
- order/GetOrderList: レイヤ構成・責務境界・RLS前提設計を確認
- shipping/CreateShipping: レイヤ構成・責務境界・RLS前提設計を確認
- billing/CreateInvoice: レイヤ構成・責務境界・RLS前提設計を確認
- billing/GetInvoiceList: レイヤ構成・責務境界・RLS前提設計を確認

## Backend

- auth/AuthenticateUser: Repository / RPC / DTO 実装
- auth/LogoutUser: Repository / RPC / DTO 実装
- order/CreateOrder: Repository / RPC / DTO 実装
- order/ConfirmOrder: Repository / RPC / DTO 実装
- order/GetOrderList: Repository / RPC / DTO 実装
- shipping/CreateShipping: Repository / RPC / DTO 実装
- billing/CreateInvoice: Repository / RPC / DTO 実装
- billing/GetInvoiceList: Repository / RPC / DTO 実装

## Mobile

- auth/AuthenticateUser: ViewModel / UseCase 呼び出し
- auth/LogoutUser: ViewModel / UseCase 呼び出し
- order/CreateOrder: ViewModel / UseCase 呼び出し
- order/ConfirmOrder: ViewModel / UseCase 呼び出し
- order/GetOrderList: ViewModel / UseCase 呼び出し
- shipping/CreateShipping: ViewModel / UseCase 呼び出し
- billing/CreateInvoice: ViewModel / UseCase 呼び出し
- billing/GetInvoiceList: ViewModel / UseCase 呼び出し