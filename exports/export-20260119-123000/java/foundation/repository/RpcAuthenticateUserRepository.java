package foundation.repository;

import org.json.JSONObject;
import app.usecase.auth.AuthenticateUserInput;
import app.usecase.auth.AuthenticateUserResult;
import app.usecase.auth.AuthenticateUserRepository;

public final class RpcAuthenticateUserRepository
        extends RpcRepository
        implements AuthenticateUserRepository {

    @Override
    public AuthenticateUserResult call(AuthenticateUserInput input) throws Exception {
        JSONObject res = callRpc("", input.toJson());
        return AuthenticateUserResult.fromJson(res);
    }
}
