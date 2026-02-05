package com.lsam.MoneySelfManager.activities.sales;

import android.os.Bundle;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

import com.lsam.MoneySelfManager.R;

import java.text.NumberFormat;
import java.util.Locale;

public final class SalesNetDetailActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_sales_net_detail);

        NumberFormat nf = NumberFormat.getNumberInstance(Locale.JAPAN);
        nf.setMaximumFractionDigits(2);

        String billingNo = getIntent().getStringExtra("billing_no");
        String billingDate = getIntent().getStringExtra("billing_date");
        long itemId = getIntent().getLongExtra("item_id", 0);

        double netAmount = getIntent().getDoubleExtra("net_amount", 0);
        double grossAmount = getIntent().getDoubleExtra("gross_amount", 0);
        double returnAmount = getIntent().getDoubleExtra("return_amount", 0);
        double unitPrice = getIntent().getDoubleExtra("unit_price", 0);
        double billedQty = getIntent().getDoubleExtra("billed_qty", 0);
        double returnedQty = getIntent().getDoubleExtra("returned_qty", 0);
        double netQty = getIntent().getDoubleExtra("net_qty", 0);

        ((TextView)findViewById(R.id.txtBilling)).setText((billingDate == null ? "" : billingDate) + "  " + (billingNo == null ? "" : billingNo));
        ((TextView)findViewById(R.id.txtItem)).setText("item=" + itemId);
        ((TextView)findViewById(R.id.txtQty)).setText("billed=" + nf.format(billedQty) + " returned=" + nf.format(returnedQty) + " net=" + nf.format(netQty));
        ((TextView)findViewById(R.id.txtMoney)).setText("gross=" + nf.format(grossAmount) + " return=" + nf.format(returnAmount) + " net=" + nf.format(netAmount));
        ((TextView)findViewById(R.id.txtUnit)).setText("unit_price=" + nf.format(unitPrice));
    }
}
