package app.usecase.auth;

public interface LogoutRepository {
    LogoutResult call(LogoutInput input) throws Exception;
}
