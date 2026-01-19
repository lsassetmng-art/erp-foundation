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
    }

    public Object execute(Object input) throws Exception {
        return useCase.execute(input);
    }
}
