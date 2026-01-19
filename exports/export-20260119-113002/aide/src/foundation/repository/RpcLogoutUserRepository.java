package foundation.repository;

import org.json.JSONObject;
import app.usecase.auth.LogoutUserInput;
import app.usecase.auth.LogoutUserResult;
import app.usecase.auth.LogoutUserRepository;

public final class RpcLogoutUserRepository
        extends RpcRepository
        implements LogoutUserRepository {

    @Override
    public LogoutUserResult call(LogoutUserInput input) throws Exception {
        JSONObject res = callRpc("", input.toJson());
        return LogoutUserResult.fromJson(res);
    }
}
