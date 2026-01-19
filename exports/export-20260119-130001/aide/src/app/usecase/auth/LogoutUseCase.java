package app.usecase.auth;

/**
 * LogoutUseCase
 * Flow: 
 */
public final class LogoutUseCase {

    private final LogoutRepository repository;

    public LogoutUseCase(LogoutRepository repository) {
        this.repository = repository;
    }

    public LogoutResult execute(LogoutInput input) throws Exception {
        return repository.call(input);
    }
}
