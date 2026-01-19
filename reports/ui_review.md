# UI Review (Static)

- generated_at: 2026-01-19T11:30:01

## Summary
- Activity: app/src/main/java/app/activity/order/OrderActivity.java
- Activity: app/src/main/java/app/activity/order/CreateOrderActivity.java
- Activity: app/src/main/java/app/activity/order/ListOrdersActivity.java
- Activity: app/src/main/java/app/activity/order/ConfirmOrderActivity.java
- Activity: app/src/main/java/app/activity/order/GetOrderListActivity.java
- Activity: app/src/main/java/app/activity/auth/AuthenticateUserActivity.java
- Activity: app/src/main/java/app/activity/auth/LogoutActivity.java
- Activity: app/src/main/java/app/activity/auth/LogoutUserActivity.java
- Activity: app/src/main/java/app/activity/shipping/CreateShippingActivity.java
- Activity: app/src/main/java/app/activity/billing/CreateInvoiceActivity.java
- Activity: app/src/main/java/app/activity/billing/GetInvoiceListActivity.java
- Activity: app/src/main/java/app/activity/core/HomeActivity.java
- XML: app/src/main/res/layout/activity_order.xml
- XML: app/src/main/res/layout/activity_createorder.xml
- XML: app/src/main/res/layout/activity_listorders.xml
- XML: app/src/main/res/layout/activity_confirmorder.xml
- XML: app/src/main/res/layout/activity_getorderlist.xml
- XML: app/src/main/res/layout/activity_authenticateuser.xml
- XML: app/src/main/res/layout/activity_logout.xml
- XML: app/src/main/res/layout/activity_logoutuser.xml
- XML: app/src/main/res/layout/activity_createshipping.xml
- XML: app/src/main/res/layout/activity_createinvoice.xml
- XML: app/src/main/res/layout/activity_getinvoicelist.xml
- XML: app/src/main/res/layout/activity_host.xml
- XML: app/src/main/res/layout/activity_home.xml
- Compose: app/src/main/java/app/ui/compose/order/OrderScreen.kt
- Compose: app/src/main/java/app/ui/compose/order/CreateOrderScreen.kt
- Compose: app/src/main/java/app/ui/compose/order/ListOrdersScreen.kt
- Compose: app/src/main/java/app/ui/compose/order/ConfirmOrderScreen.kt
- Compose: app/src/main/java/app/ui/compose/order/GetOrderListScreen.kt
- Compose: app/src/main/java/app/ui/compose/auth/AuthenticateUserScreen.kt
- Compose: app/src/main/java/app/ui/compose/auth/LogoutScreen.kt
- Compose: app/src/main/java/app/ui/compose/auth/LogoutUserScreen.kt
- Compose: app/src/main/java/app/ui/compose/shipping/CreateShippingScreen.kt
- Compose: app/src/main/java/app/ui/compose/billing/CreateInvoiceScreen.kt
- Compose: app/src/main/java/app/ui/compose/billing/GetInvoiceListScreen.kt
- Compose: app/src/main/java/app/ui/compose/core/HomeScreen.kt

## Issues
- app/src/main/res/layout/activity_host.xml: TextView無し（最低表示要素不足の可能性）
## CRITICAL
- UI層に company_id が出現: app/src/main/java/app/viewmodel/order/OrderViewModel.java