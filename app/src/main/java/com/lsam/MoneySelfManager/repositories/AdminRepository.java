package com.lsam.MoneySelfManager.repositories;

import com.lsam.MoneySelfManager.network.SupabaseHttp;
import org.json.JSONObject;

public final class AdminRepository {

    public static String dashboard() throws Exception {
        return SupabaseHttp.get("/rest/v1/ops.v_dashboard_summary?select=*");
    }

    public static String approvals(String companyId) throws Exception {
        return SupabaseHttp.get("/rest/v1/workflow.approval_request?company_id=eq."+companyId+"&status=eq.pending&order=created_at.desc");
    }

    public static void approve(long id) throws Exception {
        JSONObject o = new JSONObject();
        o.put("p_id", id);
        SupabaseHttp.rpc("workflow.approve_request", o);
    }

    public static void reject(long id, String reason) throws Exception {
        JSONObject o = new JSONObject();
        o.put("p_id", id);
        o.put("p_reason", reason);
        SupabaseHttp.rpc("workflow.reject_request", o);
    }

    public static String alerts(String companyId) throws Exception {
        return SupabaseHttp.get("/rest/v1/ops.alert?company_id=eq."+companyId+"&order=created_at.desc");
    }

    public static String killStatus(String companyId) throws Exception {
        return SupabaseHttp.rpc("ops.get_kill_switch",
            new JSONObject().put("p_company_id", companyId));
    }

    public static void setKill(String companyId, boolean on, String reason) throws Exception {
        JSONObject o = new JSONObject();
        o.put("p_company_id", companyId);
        o.put("p_is_on", on);
        o.put("p_reason", reason);
        SupabaseHttp.rpc("ops.set_kill_switch", o);
    }
}
