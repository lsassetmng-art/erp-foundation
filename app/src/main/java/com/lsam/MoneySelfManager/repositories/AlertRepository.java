package com.lsam.MoneySelfManager.repositories;

import com.lsam.MoneySelfManager.network.SupabaseHttp;

public final class AlertRepository {
    public static String list(String companyId)throws Exception{
        return SupabaseHttp.get("/rest/v1/ops.alert?select=*&company_id=eq."+companyId+"&order=created_at.desc");
    }
}
