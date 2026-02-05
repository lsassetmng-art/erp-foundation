package com.lsam.MoneySelfManager.models;

public final class SalesNetRow {
    public String company_id;
    public long billing_id;
    public String billing_no;
    public String billing_date;
    public long item_id;

    public double billed_qty;
    public double returned_qty;
    public double net_qty;

    public double unit_price;
    public double gross_amount;
    public double return_amount;
    public double net_amount;
}
