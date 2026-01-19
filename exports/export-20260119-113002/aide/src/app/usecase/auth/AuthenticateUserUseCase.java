package app.usecase.auth;

/**
 * AuthenticateUserUseCase
 * Flow: 
 */
public final class AuthenticateUserUseCase {

    private final AuthenticateUserRepository repository;

    public AuthenticateUserUseCase(AuthenticateUserRepository repository) {
        this.repository = repository;
    }

    public AuthenticateUserResult execute(AuthenticateUserInput input) throws Exception {
        return repository.call(input);
    }
}
