package com.lsam.erp.approval;

import android.app.Activity;
import android.net.Uri;
import android.os.Bundle;
import android.widget.Toast;

public class ApprovalResultActivity extends Activity {
  @Override protected void onCreate(Bundle b){
    super.onCreate(b);
    Uri u = getIntent().getData();
    if(u!=null){
      String s=u.getQueryParameter("status");
      Toast.makeText(this,"Approval "+s,Toast.LENGTH_LONG).show();
    }
    finish();
  }
}
