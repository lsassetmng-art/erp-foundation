package app.viewmodel.order;

import androidx.lifecycle.ViewModel;
import app.usecase.order.ConfirmOrderUseCase;
import app.repository.RepositoryProvider;

public final class ConfirmOrderViewModel extends ViewModel {
    // BINDING READY
    // TODO: expose execute() via LiveData / StateFlow


    private final ConfirmOrderUseCase useCase;

    public ConfirmOrderViewModel() {
        this.useCase = new ConfirmOrderUseCase(
            RepositoryProvider.provide(
                ConfirmOrderUseCase.class
            )
        );
    }

    public Object execute(Object input) throws Exception {
        return useCase.execute(input);
    }
}
