package foundation.repository;

import org.json.JSONObject;
import app.usecase.auth.LogoutInput;
import app.usecase.auth.LogoutResult;
import app.usecase.auth.LogoutRepository;

public final class RpcLogoutRepository
        extends RpcRepository
        implements LogoutRepository {

    @Override
    public LogoutResult call(LogoutInput input) throws Exception {
        JSONObject res = callRpc("", input.toJson());
        return LogoutResult.fromJson(res);
    }
}
