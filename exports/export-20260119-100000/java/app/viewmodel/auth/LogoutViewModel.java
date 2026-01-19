package app.viewmodel.auth;

import androidx.lifecycle.ViewModel;
import app.usecase.auth.LogoutUseCase;
import app.repository.RepositoryProvider;

public final class LogoutViewModel extends ViewModel {
    // BINDING READY
    // TODO: expose execute() via LiveData / StateFlow


    private final LogoutUseCase useCase;

    public LogoutViewModel() {
        this.useCase = new LogoutUseCase(
            RepositoryProvider.provide(
                LogoutUseCase.class
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
