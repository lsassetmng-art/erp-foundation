# Architect Review

- auth/AuthenticateUser: レイヤ分離・RLS前提・依存方向OK
- auth/LogoutUser: レイヤ分離・RLS前提・依存方向OK
- order/CreateOrder: レイヤ分離・RLS前提・依存方向OK
- order/ConfirmOrder: レイヤ分離・RLS前提・依存方向OK
- order/GetOrderList: レイヤ分離・RLS前提・依存方向OK
- shipping/CreateShipping: レイヤ分離・RLS前提・依存方向OK
- billing/CreateInvoice: レイヤ分離・RLS前提・依存方向OK
- billing/GetInvoiceList: レイヤ分離・RLS前提・依存方向OK