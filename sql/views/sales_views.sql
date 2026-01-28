-- =========================================================
-- Sales Management : VIEW Definitions (OFFICIAL)
-- 正本 : 業務ステータス算出用 VIEW
-- 方針 :
--   ・status は保存しない
--   ・実績（出荷・返品・廃棄）を正本
--   ・damaged は保有・引当不可
-- =========================================================

BEGIN;

-- =========================================================
-- 1. 受注ステータス一覧
-- =========================================================
-- 想定テーブル:
--   order_header(order_id, order_no, company_id)
--   order_detail(order_id, qty)
--   shipping_detail(order_id, qty)
--   return_detail(order_id, qty)
-- =========================================================
CREATE OR REPLACE VIEW v_order_status_list AS
SELECT
  oh.order_id,
  oh.order_no,
  oh.company_id,

  COALESCE(SUM(od.qty), 0)        AS ordered_qty,
  COALESCE(SUM(sd.qty), 0)        AS shipped_qty,
  COALESCE(SUM(rd.qty), 0)        AS returned_qty,

  CASE
    WHEN COALESCE(SUM(sd.qty),0) = 0
      THEN 'NOT_SHIPPED'
    WHEN COALESCE(SUM(sd.qty),0) < COALESCE(SUM(od.qty),0)
      THEN 'PARTIALLY_SHIPPED'
    ELSE 'SHIPPED'
  END AS shipping_status

FROM order_header oh
LEFT JOIN order_detail   od ON od.order_id = oh.order_id
LEFT JOIN shipping_detail sd ON sd.order_id = oh.order_id
LEFT JOIN return_detail   rd ON rd.order_id = oh.order_id
GROUP BY oh.order_id, oh.order_no, oh.company_id;

-- =========================================================
-- 2. 未請求出荷一覧
-- =========================================================
-- 想定:
--   shipping_detail.invoiced = false
-- =========================================================
CREATE OR REPLACE VIEW v_uninvoiced_shipping AS
SELECT
  sd.shipping_id,
  sd.order_id,
  sd.company_id,
  sd.item_id,
  sd.qty,
  sd.shipping_date
FROM shipping_detail sd
WHERE sd.invoiced = false;

-- =========================================================
-- 3. 請求ステータス
-- =========================================================
-- 想定:
--   invoice_header.is_closed
--   invoice_detail.qty
-- =========================================================
CREATE OR REPLACE VIEW v_invoice_status AS
SELECT
  ih.invoice_id,
  ih.company_id,
  ih.customer_id,
  ih.is_closed,
  SUM(id.qty) AS invoice_qty
FROM invoice_header ih
LEFT JOIN invoice_detail id
  ON id.invoice_id = ih.invoice_id
GROUP BY ih.invoice_id, ih.company_id, ih.customer_id, ih.is_closed;

-- =========================================================
-- 4. 廃棄承認待ち一覧
-- =========================================================
-- 想定:
--   discard_request(status = 'pending')
-- =========================================================
CREATE OR REPLACE VIEW v_discard_pending AS
SELECT
  dr.request_id,
  dr.company_id,
  dr.warehouse_id,
  dr.item_id,
  dr.qty,
  dr.reason_code,
  dr.created_at
FROM discard_request dr
WHERE dr.status = 'pending';

-- =========================================================
-- 5. 在庫（保有数）
-- =========================================================
CREATE OR REPLACE VIEW v_stock_on_hand AS
SELECT
  s.company_id,
  s.warehouse_id,
  s.item_id,
  SUM(s.qty) AS on_hand_qty
FROM stock s
GROUP BY s.company_id, s.warehouse_id, s.item_id;

-- =========================================================
-- 6. 在庫（引当可能数）
-- =========================================================
-- damaged は引当不可
CREATE OR REPLACE VIEW v_stock_available AS
SELECT
  s.company_id,
  s.warehouse_id,
  s.item_id,
  SUM(
    CASE
      WHEN s.status = 'damaged' THEN 0
      ELSE s.qty
    END
  ) AS available_qty
FROM stock s
GROUP BY s.company_id, s.warehouse_id, s.item_id;

COMMIT;

-- =========================================================
-- END OF SALES VIEWS
-- =========================================================
