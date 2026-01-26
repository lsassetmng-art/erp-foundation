package com.lsam.MoneySelfManager.repositories;

import com.lsam.MoneySelfManager.network.SupabaseHttp;
import org.json.JSONObject;

public final class KillSwitchRepository {
    public static String get(String companyId) throws Exception {
        JSONObject o=new JSONObject();o.put("p_company_id",companyId);
        return SupabaseHttp.rpc("ops.get_kill_switch",o);
    }
    public static void set(String companyId,boolean on,String reason) throws Exception{
        JSONObject o=new JSONObject();
        o.put("p_company_id",companyId);
        o.put("p_is_on",on);
        o.put("p_reason",reason);
        SupabaseHttp.rpc("ops.set_kill_switch",o);
    }
}
