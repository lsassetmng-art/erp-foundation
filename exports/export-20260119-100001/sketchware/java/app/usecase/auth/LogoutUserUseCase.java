package app.usecase.auth;

/**
 * LogoutUserUseCase
 * Flow: 
 */
public final class LogoutUserUseCase {

    private final LogoutUserRepository repository;

    public LogoutUserUseCase(LogoutUserRepository repository) {
        this.repository = repository;
    }

    public LogoutUserResult execute(LogoutUserInput input) throws Exception {
        return repository.call(input);
    }
}
