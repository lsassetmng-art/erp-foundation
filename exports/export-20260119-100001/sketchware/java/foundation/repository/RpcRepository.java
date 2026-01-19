package foundation.repository;

import org.json.JSONObject;
import foundation.network.RpcClient;

/**
 * RpcRepository
 *
 * - 全 RpcXXXRepository の基底クラス
 * - company_id を扱わない（RLS前提）
 */
public abstract class RpcRepository {

    protected JSONObject callRpc(String action, JSONObject payload) throws Exception {
        return RpcClient.post(action, payload);
    }
}
