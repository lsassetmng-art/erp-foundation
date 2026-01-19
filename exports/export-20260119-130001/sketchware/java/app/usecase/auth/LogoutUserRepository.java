package app.usecase.auth;

public interface LogoutUserRepository {
    LogoutUserResult call(LogoutUserInput input) throws Exception;
}
