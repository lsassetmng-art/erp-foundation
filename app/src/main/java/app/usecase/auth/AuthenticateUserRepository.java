package app.usecase.auth;

public interface AuthenticateUserRepository {
    AuthenticateUserResult call(AuthenticateUserInput input) throws Exception;
}
