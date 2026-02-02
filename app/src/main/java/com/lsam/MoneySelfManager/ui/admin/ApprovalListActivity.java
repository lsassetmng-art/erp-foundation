package com.lsam.MoneySelfManager.ui.admin;

import android.os.Bundle;
import android.app.AlertDialog;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import androidx.appcompat.app.AppCompatActivity;
import org.json.JSONArray;
import org.json.JSONObject;
import java.util.ArrayList;
import com.lsam.MoneySelfManager.R;
import com.lsam.MoneySelfManager.utils.AdminGuard;
import com.lsam.MoneySelfManager.repositories.ApprovalRepository;

public class ApprovalListActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle b) {
        super.onCreate(b);
        AdminGuard.ensureAdmin(this);
        setContentView(R.layout.activity_approval_list);

        ListView list = findViewById(R.id.listApproval);
        ArrayList<String> items = new ArrayList<>();
        ArrayAdapter<String> ad = new ArrayAdapter<>(this, android.R.layout.simple_list_item_1, items);
        list.setAdapter(ad);

        String companyId = getSharedPreferences("session", MODE_PRIVATE)
            .getString("company_id","");

        new Thread(() -> {
            try {
                JSONArray arr = new JSONArray(ApprovalRepository.listPending(companyId));
                items.clear();
                for (int i=0;i<arr.length();i++){
                    JSONObject o = arr.getJSONObject(i);
                    items.add(o.getLong("approval_request_id")+": "+o.optString("title"));
                }
                runOnUiThread(ad::notifyDataSetChanged);
            } catch(Exception e){
                items.clear(); items.add("ERR:"+e.getMessage());
                runOnUiThread(ad::notifyDataSetChanged);
            }
        }).start();

        list.setOnItemClickListener((p,v,pos,id)->{
            String txt = items.get(pos);
            long reqId = Long.parseLong(txt.split(":")[0]);

            new AlertDialog.Builder(this)
              .setTitle("承認操作")
              .setItems(new String[]{"Approve","Reject"}, (d,which)->{
                new Thread(() -> {
                    try{
                        if(which==0){
                            ApprovalRepository.approve(reqId,"admin");
                        }else{
                            ApprovalRepository.reject(reqId,"admin","manual reject");
                        }
                    }catch(Exception ignore){}
                }).start();
              }).show();
        });
    }
}
