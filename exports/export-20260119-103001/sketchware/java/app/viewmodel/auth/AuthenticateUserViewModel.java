package app.viewmodel.auth;

import androidx.lifecycle.ViewModel;
import app.usecase.auth.AuthenticateUserUseCase;
import app.repository.RepositoryProvider;

public final class AuthenticateUserViewModel extends ViewModel {
    // BINDING READY
    // TODO: expose execute() via LiveData / StateFlow


    private final AuthenticateUserUseCase useCase;

    public AuthenticateUserViewModel() {
        this.useCase = new AuthenticateUserUseCase(
            RepositoryProvider.provide(
                AuthenticateUserUseCase.class
            )
        );
    
    public Object executeSafe(Object input) throws Exception {
        try {
            // DTO validation
            try {
                input.getClass().getMethod("validate").invoke(input);
            } catch (NoSuchMethodException ignore) {}
            return execute(input);
        } catch (IllegalArgumentException e) {
            throw e;
        }
    }

}

    public Object execute(Object input) throws Exception {
        return useCase.execute(input);
    }
}
