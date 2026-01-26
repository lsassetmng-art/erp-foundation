package com.lsam.MoneySelfManager.repositories;

import com.lsam.MoneySelfManager.network.SupabaseHttp;
import org.json.JSONObject;

public final class AdminOpsRepository {

    public static String dashboard() throws Exception {
        return SupabaseHttp.get("/rest/v1/ops.v_dashboard_summary?select=*");
    }

    public static String approvals(String companyId) throws Exception {
        return SupabaseHttp.get("/rest/v1/workflow.approval_request?select=*&company_id=eq."+companyId+"&status=eq.pending&order=created_at.desc");
    }

    public static void approve(long id, String by) throws Exception {
        JSONObject o = new JSONObject();
        o.put("p_id", id);
        o.put("p_decided_by", by);
        SupabaseHttp.rpc("workflow.approve_request", o);
    }

    public static void reject(long id, String by, String reason) throws Exception {
        JSONObject o = new JSONObject();
        o.put("p_id", id);
        o.put("p_decided_by", by);
        o.put("p_reason", reason);
        SupabaseHttp.rpc("workflow.reject_request", o);
    }

    public static String alerts(String companyId) throws Exception {
        return SupabaseHttp.get("/rest/v1/ops.alert?select=*&company_id=eq."+companyId+"&order=created_at.desc&limit=100");
    }

    public static String killSwitch(String companyId) throws Exception {
        JSONObject o = new JSONObject();
        o.put("p_company_id", companyId);
        return SupabaseHttp.rpc("ops.get_kill_switch", o);
    }

    public static void setKillSwitch(String companyId, boolean on, String reason) throws Exception {
        JSONObject o = new JSONObject();
        o.put("p_company_id", companyId);
        o.put("p_is_on", on);
        o.put("p_reason", reason);
        SupabaseHttp.rpc("ops.set_kill_switch", o);
    }
}
