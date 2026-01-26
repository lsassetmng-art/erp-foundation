package com.lsam.MoneySelfManager.repositories;

import com.lsam.MoneySelfManager.network.SupabaseHttp;
import org.json.JSONObject;

public final class ApprovalRepository {
    public static String listPending(String companyId) throws Exception {
        return SupabaseHttp.get("/rest/v1/workflow.approval_request?select=*&company_id=eq."+companyId+"&status=eq.pending&order=created_at.desc");
    }
    public static void approve(long id,String by) throws Exception{
        JSONObject o=new JSONObject();o.put("p_id",id);o.put("p_decided_by",by);
        SupabaseHttp.rpc("workflow.approve_request",o);
    }
    public static void reject(long id,String by,String reason) throws Exception{
        JSONObject o=new JSONObject();o.put("p_id",id);o.put("p_decided_by",by);o.put("p_reason",reason);
        SupabaseHttp.rpc("workflow.reject_request",o);
    }
}
