package app.viewmodel.auth;

import androidx.lifecycle.ViewModel;
import app.usecase.auth.LogoutUserUseCase;
import app.repository.RepositoryProvider;

public final class LogoutUserViewModel extends ViewModel {
    // BINDING READY
    // TODO: expose execute() via LiveData / StateFlow


    private final LogoutUserUseCase useCase;

    public LogoutUserViewModel() {
        this.useCase = new LogoutUserUseCase(
            RepositoryProvider.provide(
                LogoutUserUseCase.class
            )
        );
    }

    public Object execute(Object input) throws Exception {
        return useCase.execute(input);
    }
}
